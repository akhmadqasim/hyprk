// usage: node bshot.js OUT.png [W H] -> screenshots the broadway page at :8085 after the app has drawn
// needs playwright-core (NODE_PATH or PLAYWRIGHT_CORE) and its chromium (~/.cache/ms-playwright)
const { chromium } = require(process.env.PLAYWRIGHT_CORE || '/mnt/code/kasir/node_modules/.bun/playwright-core@1.65.0/node_modules/playwright-core');
(async () => {
  const [out, w, h] = [process.argv[2], +process.argv[3] || 1280, +process.argv[4] || 860];
  const b = await chromium.launch({ args: ['--no-sandbox'] });
  const p = await b.newPage({ viewport: { width: w, height: h } });
  await p.goto('http://127.0.0.1:' + (process.env.BWPORT || 8085) + '/');
  await p.waitForTimeout(+process.env.SETTLE || 4000);
  await p.screenshot({ path: out });
  await b.close();
})();
