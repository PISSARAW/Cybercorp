import assert from 'node:assert/strict';
import worker from '../dist/server/index.js';

let stored = null;
const env = {
  CYBERCORP_COLLECTOR_KEY: 'test-key',
  BUCKET: {
    async get() { return stored && { body: JSON.stringify(stored) }; },
    async put(_key, value) { stored = JSON.parse(value); },
  },
};
const base = 'https://cybercorp.example.test';
const request = (path, options) => new Request(base + path, options);

assert.equal((await worker.fetch(request('/'), env)).status, 200);
assert.equal((await worker.fetch(request('/equipe'), env)).status, 200);
assert.equal((await worker.fetch(request('/tableau-de-bord'), env)).status, 200);
assert.equal((await worker.fetch(request('/api/status'), env)).status, 204);
const sample = {
  schema: 1,
  collected_at: new Date().toISOString(),
  collection: { hyperv: 'ok' },
  host: { memory_available_gb: 2.5 },
  vms: [{ name: 'CC-DC01', state: 'Running', memory_mb: 4096, checkpoints: 1 }],
  switches: [{ name: 'CC-LAN', type: 'Private' }],
  project: { steps: [{ number: 1, title: 'Inventaire', status: 'Validée' }], tests: { total: 15, passed: 0 } },
};
const post = (body, key = 'test-key') => request('/api/telemetry', {
  method: 'POST',
  headers: { 'content-type': 'application/json', 'x-cybercorp-collector-key': key },
  body: JSON.stringify(body),
});
assert.equal((await worker.fetch(post(sample, 'wrong'), env)).status, 401);
assert.equal((await worker.fetch(post({ ...sample, vms: [{ ...sample.vms[0], name: 'PERSONAL-VM' }] }), env)).status, 400);
assert.equal((await worker.fetch(post(sample), env)).status, 200);
assert.equal((await (await worker.fetch(request('/api/status'), env)).json()).vms[0].name, 'CC-DC01');
console.log('Worker CyberCorp : routes, authentification, validation et lecture OK.');
