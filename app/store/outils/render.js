// Rend les pages HTML en PNG : image de présentation 1024x500, captures 1290x2796.
const { chromium } = require('playwright');
const path = require('path');
(async () => {
  const dir = process.argv[2], out = process.argv[3];
  const b = await chromium.launch();
  for (const p of [1, 2, 3]) {
    let pg = await b.newPage({ viewport: { width: 1024, height: 500 }, deviceScaleFactor: 1 });
    await pg.goto('file://' + path.join(dir, `p${p}-feature.html`)); await pg.waitForTimeout(300);
    await pg.screenshot({ path: path.join(out, `p${p}-feature-1024x500.png`) }); await pg.close();
    for (let i = 1; i <= 4; i++) {
      pg = await b.newPage({ viewport: { width: 430, height: 932 }, deviceScaleFactor: 3 });
      await pg.goto('file://' + path.join(dir, `p${p}-s${i}.html`)); await pg.waitForTimeout(300);
      await pg.screenshot({ path: path.join(out, `p${p}-capture${i}-1290x2796.png`) }); await pg.close();
    }
  }
  await b.close();
})();
