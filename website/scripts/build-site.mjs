import { readFileSync, writeFileSync, mkdirSync } from 'node:fs';
import { join } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = fileURLToPath(new URL('../', import.meta.url));
const content = join(root, 'dist');
const assets = Object.fromEntries([
  'index.html', 'equipe.html', 'tableau-de-bord.html',
  'assets/style.css', 'assets/dashboard.js', 'assets/logo-mark.svg', 'assets/logo-lockup.svg',
].map(path => [`/${path}`, readFileSync(join(content, path), 'utf8')]));
const worker = readFileSync(join(root, 'worker/index.js'), 'utf8');
mkdirSync(join(content, 'server'), { recursive: true });
mkdirSync(join(content, '.openai'), { recursive: true });
writeFileSync(join(content, 'server/index.js'), `const ASSETS = ${JSON.stringify(assets)};\n${worker}`);
writeFileSync(join(content, '.openai/hosting.json'), readFileSync(join(root, '.openai/hosting.json')));
console.log('Worker CyberCorp généré : 7 ressources, API de relevé en lecture seule côté visiteur.');
