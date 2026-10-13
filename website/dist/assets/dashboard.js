const byId = (id) => document.getElementById(id);
const number = (value) => Number.isFinite(Number(value)) ? Number(value) : null;
let latestData = null;
let loading = false;

function text(id, value) { byId(id).textContent = value; }
function element(tag, className, content) {
  const node = document.createElement(tag);
  if (className) node.className = className;
  if (content !== undefined) node.textContent = content;
  return node;
}

function renderList(container, items, build, emptyText) {
  container.replaceChildren();
  if (!Array.isArray(items) || items.length === 0) {
    container.append(element('div', 'empty-card', emptyText));
    return;
  }
  for (const item of items) container.append(build(item));
}

function renderFreshness(data) {
  const collected = new Date(data.collected_at);
  const ageSeconds = (Date.now() - collected.getTime()) / 1000;
  const fresh = Number.isFinite(ageSeconds) && ageSeconds >= -120 && ageSeconds <= 60;
  const pill = byId('freshness');
  pill.className = `state-pill ${fresh ? 'state-fresh' : 'state-stale'}`;
  pill.textContent = fresh ? 'Serveur connecté' : 'Relevé ancien';
  text('collected-at', Number.isNaN(collected.getTime()) ? 'Date inconnue' : `Dernier relevé : ${new Intl.DateTimeFormat('fr-FR', {dateStyle:'medium',timeStyle:'medium'}).format(collected)}`);
  const hostState = byId('host-state');
  if (hostState) {
    hostState.className = `vm-state ${fresh ? 'vm-on' : 'vm-off'}`;
    hostState.textContent = fresh ? 'Connecté' : 'À vérifier';
  }
}

function render(data) {
  renderFreshness(data);

  const vms = Array.isArray(data.vms) ? data.vms : [];
  const steps = Array.isArray(data.project?.steps) ? data.project.steps : [];
  const tests = data.project?.tests || {};
  text('vm-running', data.collection?.hyperv === 'ok' ? String(vms.filter(vm => vm.state === 'Running').length) : '—');
  text('vm-total', data.collection?.hyperv === 'ok' ? `Sur ${vms.length} VM suivies` : 'Lecture Hyper-V indisponible');
  text('host-memory', number(data.host?.memory_available_gb)?.toFixed(1) ?? '—');
  text('steps-done', String(steps.filter(step => step.status === 'Validée').length));
  text('steps-total', `Sur ${steps.length} étapes`);
  text('tests-done', String(number(tests.passed) ?? 0));
  text('tests-total', `Sur ${number(tests.total) ?? 15} tests T01–T15`);
  const notice = byId('notice');
  notice.hidden = data.collection?.hyperv === 'ok';
  if (!notice.hidden) notice.textContent = 'Le relevé du projet a été reçu, mais la lecture Hyper-V n’est pas autorisée pour le compte qui exécute le collecteur. Les états des VM et des commutateurs sont indisponibles.';

  const servers = [
    { name: 'Hôte Hyper-V', role: 'Serveur physique du laboratoire', vm: null },
    { name: 'CC-PFS01', role: 'Pare-feu et routage pfSense', vm: 'CC-PFS01' },
    { name: 'CC-DC01', role: 'Active Directory, DNS et fichiers', vm: 'CC-DC01' },
  ];
  renderList(byId('server-list'), servers, server => {
    const vm = vms.find(item => item.name === server.vm);
    const state = server.vm === null ? 'Connecté' : data.collection?.hyperv !== 'ok' ? 'Indisponible' : vm ? vm.state === 'Running' ? 'En cours' : vm.state === 'Off' ? 'Arrêté' : vm.state : 'Non créé';
    const card = element('article', 'server-card');
    const head = element('div', 'vm-head');
    const badge = element('span', `vm-state ${state === 'Connecté' || state === 'En cours' ? 'vm-on' : 'vm-off'}`, state);
    if (server.vm === null) badge.id = 'host-state';
    head.append(element('strong', '', server.name), badge);
    card.append(head, element('p', '', server.role));
    if (vm) card.append(element('small', '', `${number(vm.memory_mb) ?? 0} Mio affectés · ${number(vm.checkpoints) ?? 0} point(s) de contrôle`));
    return card;
  }, 'Aucun serveur disponible.');
  renderFreshness(data);

  renderList(byId('vm-list'), vms, vm => {
    const card = element('article', 'vm-card');
    const head = element('div', 'vm-head');
    head.append(element('strong', '', vm.name), element('span', `vm-state ${vm.state === 'Running' ? 'vm-on' : 'vm-off'}`, vm.state === 'Running' ? 'En cours' : vm.state === 'Off' ? 'Arrêtée' : vm.state));
    card.append(head, element('p', '', `${number(vm.memory_mb) ?? 0} Mio affectés · ${number(vm.checkpoints) ?? 0} point(s) de contrôle`));
    return card;
  }, 'Aucun relevé des VM disponible.');
  renderList(byId('switch-list'), data.switches, sw => {
    const card = element('div', 'switch-card');
    card.append(element('strong', '', sw.name), element('span', '', sw.type));
    return card;
  }, 'Aucun relevé des commutateurs disponible.');
  const list = byId('step-list'); list.replaceChildren();
  if (!steps.length) list.append(element('li', 'empty-card', 'Aucun relevé d’avancement disponible.'));
  for (const step of steps) {
    const row = element('li', 'progress-item');
    row.append(element('span', 'progress-number', String(step.number).padStart(2, '0')), element('strong', '', step.title), element('span', `progress-status ${step.status === 'Validée' ? 'progress-done' : ''}`, step.status));
    list.append(row);
  }
}

async function refresh() {
  if (loading) return;
  loading = true;
  byId('refresh').disabled = true;
  try {
    const response = await fetch('/api/status', { cache: 'no-store' });
    if (response.status === 204) return;
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    const data = await response.json();
    if (data.collected_at !== latestData?.collected_at) render(data);
    latestData = data;
    renderFreshness(data);
  } catch {
    const notice = byId('notice'); notice.hidden = false;
    notice.textContent = 'Le relevé n’a pas pu être chargé. Réessayez plus tard.';
  } finally { byId('refresh').disabled = false; loading = false; }
}

byId('refresh').addEventListener('click', refresh);
refresh();
setInterval(() => {
  if (latestData) renderFreshness(latestData);
  if (!document.hidden) refresh();
}, 5000);
document.addEventListener('visibilitychange', () => { if (!document.hidden) refresh(); });
