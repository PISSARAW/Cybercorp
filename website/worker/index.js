const noStore = { 'cache-control': 'private, no-store', 'content-type': 'application/json; charset=utf-8' };
const allowedVmNames = new Set(['CC-PFS01', 'CC-DC01', 'CC-W11-01', 'CC-KALI01', 'PFSENSE01', 'DC01', 'CLIENT01']);
const allowedSwitchNames = new Set(['CC-LAN', 'CC-AUDIT', 'CC-WAN-MAINT', 'LAB-AD']);
const allowedStates = new Set(['Running', 'Off', 'Saved', 'Paused', 'Starting', 'Stopping', 'Saving', 'Pausing', 'Resuming', 'Critical', 'Other']);
const allowedStepStates = new Set(['Validée', 'En cours', 'À faire', 'Bloquée']);

function safeEqual(a, b) {
  if (typeof a !== 'string' || typeof b !== 'string' || a.length !== b.length) return false;
  let diff = 0;
  for (let i = 0; i < a.length; i++) diff |= a.charCodeAt(i) ^ b.charCodeAt(i);
  return diff === 0;
}

function boundedNumber(value, min, max) {
  return typeof value === 'number' && Number.isFinite(value) && value >= min && value <= max ? value : null;
}

function normalize(body) {
  if (!body || body.schema !== 1) throw new Error('schema');
  const timestamp = Date.parse(body.collected_at);
  if (!Number.isFinite(timestamp) || timestamp > Date.now() + 300000 || timestamp < Date.now() - 2592000000) throw new Error('date');
  const hyperv = body.collection?.hyperv;
  if (!['ok', 'access_denied', 'error'].includes(hyperv)) throw new Error('hyperv');
  const vms = Array.isArray(body.vms) ? body.vms : [];
  const switches = Array.isArray(body.switches) ? body.switches : [];
  const steps = Array.isArray(body.project?.steps) ? body.project.steps : [];
  if (vms.length > 7 || switches.length > 4 || steps.length > 10) throw new Error('count');
  const cleanVms = vms.map(vm => {
    if (!allowedVmNames.has(vm.name) || !allowedStates.has(vm.state)) throw new Error('vm');
    const memory = boundedNumber(vm.memory_mb, 0, 65536);
    const checkpoints = boundedNumber(vm.checkpoints, 0, 100);
    if (memory === null || checkpoints === null) throw new Error('vm-number');
    return { name: vm.name, state: vm.state, memory_mb: memory, checkpoints };
  });
  const cleanSwitches = switches.map(sw => {
    if (!allowedSwitchNames.has(sw.name) || !['Private', 'Internal', 'External'].includes(sw.type)) throw new Error('switch');
    return { name: sw.name, type: sw.type };
  });
  const cleanSteps = steps.map(step => {
    if (!Number.isInteger(step.number) || step.number < 1 || step.number > 10 || typeof step.title !== 'string' || step.title.length > 100 || !allowedStepStates.has(step.status)) throw new Error('step');
    return { number: step.number, title: step.title, status: step.status };
  });
  const memoryAvailable = boundedNumber(body.host?.memory_available_gb, 0, 1024);
  const total = boundedNumber(body.project?.tests?.total, 0, 15);
  const passed = boundedNumber(body.project?.tests?.passed, 0, 15);
  if (memoryAvailable === null || total === null || passed === null || passed > total) throw new Error('metrics');
  if (hyperv !== 'ok' && (cleanVms.length || cleanSwitches.length)) throw new Error('unavailable');
  return { schema: 1, collected_at: new Date(timestamp).toISOString(), collection: { hyperv }, host: { memory_available_gb: memoryAvailable }, vms: cleanVms, switches: cleanSwitches, project: { steps: cleanSteps, tests: { total, passed } } };
}

function staticResponse(pathname) {
  const route = pathname === '/' ? '/index.html' : pathname === '/equipe' ? '/equipe.html' : pathname === '/tableau-de-bord' ? '/tableau-de-bord.html' : pathname;
  const asset = ASSETS[route];
  if (!asset) return new Response('Page introuvable', { status: 404 });
  const type = route.endsWith('.css') ? 'text/css' : route.endsWith('.js') ? 'text/javascript' : route.endsWith('.svg') ? 'image/svg+xml' : 'text/html';
  return new Response(asset, { headers: { 'content-type': `${type}; charset=utf-8`, 'x-content-type-options': 'nosniff', 'cache-control': 'private, max-age=60' } });
}

export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    if (url.pathname === '/api/status' && request.method === 'GET') {
      const object = await env.BUCKET.get('latest-status.json');
      return object ? new Response(object.body, { headers: noStore }) : new Response(null, { status: 204, headers: { 'cache-control': 'private, no-store' } });
    }
    if (url.pathname === '/api/telemetry' && request.method === 'POST') {
      if (!env.CYBERCORP_COLLECTOR_KEY || !safeEqual(request.headers.get('x-cybercorp-collector-key'), env.CYBERCORP_COLLECTOR_KEY)) return new Response('Non autorisé', { status: 401 });
      const origin = request.headers.get('origin');
      if (origin && origin !== url.origin) return new Response('Origine refusée', { status: 403 });
      if (!(request.headers.get('content-type') || '').startsWith('application/json')) return new Response('JSON requis', { status: 415 });
      const raw = await request.text();
      if (raw.length > 16384) return new Response('Relevé trop volumineux', { status: 413 });
      try {
        const snapshot = normalize(JSON.parse(raw));
        await env.BUCKET.put('latest-status.json', JSON.stringify(snapshot), { httpMetadata: { contentType: 'application/json' } });
        return new Response(JSON.stringify({ accepted: true, collected_at: snapshot.collected_at }), { headers: noStore });
      } catch {
        return new Response('Relevé invalide', { status: 400 });
      }
    }
    if (request.method !== 'GET' && request.method !== 'HEAD') return new Response('Méthode refusée', { status: 405 });
    return staticResponse(url.pathname);
  },
};
