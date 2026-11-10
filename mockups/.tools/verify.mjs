// Drives the gallery in a real (headless) Chromium over CDP, spins every card
// once and reports which ones did not produce a winner, plus any page errors.
// Uses Node's built-in fetch and WebSocket, so no npm packages are needed.
import { spawn } from 'node:child_process';
import { mkdirSync } from 'node:fs';
import { setTimeout as sleep } from 'node:timers/promises';

const ROOT = new URL('..', import.meta.url).pathname; // mockups/
const URL_ = 'file://' + ROOT + 'roulette-gallery.html';
const PROFILE = ROOT + '.tools/profile';
const SHOT = ROOT + '.shots/gallery-final.png';
const PORT = 9333;

mkdirSync(PROFILE, { recursive: true });

const chrome = spawn('/usr/bin/chromium', [
  '--headless=new', '--no-sandbox', '--disable-gpu', '--hide-scrollbars',
  '--remote-debugging-port=' + PORT,
  '--user-data-dir=' + PROFILE,
  '--window-size=1500,2600',
  'about:blank',
], { stdio: 'ignore' });

let ws;
try {
  // wait for the debugging endpoint
  let version;
  for (let i = 0; i < 60; i++) {
    try {
      version = await (await fetch(`http://127.0.0.1:${PORT}/json/version`)).json();
      break;
    } catch {
      await sleep(250);
    }
  }
  if (!version) throw new Error('chromium debugging endpoint never came up');

  const target = await (await fetch(
    `http://127.0.0.1:${PORT}/json/new?about:blank`, { method: 'PUT' },
  )).json();

  ws = new WebSocket(target.webSocketDebuggerUrl);
  await new Promise((res, rej) => {
    ws.addEventListener('open', res, { once: true });
    ws.addEventListener('error', rej, { once: true });
  });

  let nextId = 0;
  const pending = new Map();
  const errors = [];
  ws.addEventListener('message', (ev) => {
    const msg = JSON.parse(ev.data);
    if (msg.id && pending.has(msg.id)) {
      pending.get(msg.id)(msg);
      pending.delete(msg.id);
    }
    if (msg.method === 'Runtime.exceptionThrown') {
      errors.push(msg.params.exceptionDetails.text + ': ' +
        (msg.params.exceptionDetails.exception?.description || ''));
    }
    if (msg.method === 'Runtime.consoleAPICalled' && msg.params.type === 'error') {
      errors.push(msg.params.args.map((a) => a.value ?? a.description).join(' '));
    }
  });
  const send = (method, params = {}) => new Promise((res) => {
    const id = ++nextId;
    pending.set(id, res);
    ws.send(JSON.stringify({ id, method, params }));
  });
  const evaluate = async (expression) => {
    const r = await send('Runtime.evaluate', { expression, returnByValue: true, awaitPromise: true });
    return r.result?.result?.value;
  };

  await send('Runtime.enable');
  await send('Page.enable');
  await send('Page.navigate', { url: URL_ });
  await sleep(1200);

  const cards = await evaluate("document.querySelectorAll('.card').length");
  console.log('cards rendered:', cards);

  await evaluate("document.getElementById('spin-all').click()");

  const started = Date.now();
  let results = [];
  while (Date.now() - started < 40000) {
    results = JSON.parse(await evaluate(
      "JSON.stringify([...document.querySelectorAll('.result')].map(e => e.textContent.trim()))",
    ));
    if (results.length === 20 && results.every((t) => t.includes('Winner'))) break;
    await sleep(400);
  }

  const winners = results.filter((t) => t.includes('Winner')).length;
  console.log('finished spins:', winners + '/20 in ' + ((Date.now() - started) / 1000).toFixed(1) + 's');
  const stuck = results.map((t, i) => ({ i: i + 1, t })).filter((x) => !x.t.includes('Winner'));
  if (stuck.length) console.log('not finished:', JSON.stringify(stuck));

  await send('Emulation.setDeviceMetricsOverride', {
    width: 1500, height: 2600, deviceScaleFactor: 1, mobile: false,
  });
  await sleep(300);
  const shot = await send('Page.captureScreenshot', { format: 'png' });
  const { writeFileSync } = await import('node:fs');
  writeFileSync(SHOT, Buffer.from(shot.result.data, 'base64'));
  console.log('screenshot:', SHOT);
  console.log('page errors:', errors.length ? errors.slice(0, 5) : 'none');
} finally {
  try { ws?.close(); } catch {}
  chrome.kill('SIGTERM');
}
