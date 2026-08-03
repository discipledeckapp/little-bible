// Rasterises the app-icon vector sources to the PNGs that flutter_launcher_icons
// consumes. The SVGs in assets/brand/ are the canonical artwork — these PNGs are
// build output and should never be hand-edited.
//
//   node tool/render_icons.mjs
//   dart run flutter_launcher_icons
//
// sharp is resolved from the web app's node_modules at the repo root (the Flutter
// project has no package.json of its own).

import { createRequire } from 'node:module';
import { fileURLToPath } from 'node:url';
import path from 'node:path';
import fs from 'node:fs';

const here = path.dirname(fileURLToPath(import.meta.url));
const brand = path.join(here, '..', 'assets', 'brand');
const require = createRequire(path.join(here, '..', '..', 'package.json'));

let sharp;
try {
  sharp = require('sharp');
} catch {
  console.error(
    'sharp not found. Run `npm install` at the repo root (../), which is where\n' +
    'the web app keeps its node_modules.',
  );
  process.exit(1);
}

const jobs = [
  // Full-bleed store/launcher icon. Opaque: iOS rejects alpha in app icons.
  {
    src: 'lumi-app-icon.svg',
    out: 'app_icon.png',
    flatten: '#7C2D12',
  },
  // Android adaptive foreground. Transparent; artwork sits inside the safe zone.
  {
    src: 'lumi-adaptive-foreground.svg',
    out: 'app_icon_foreground.png',
    flatten: null,
  },
];

for (const job of jobs) {
  // density 384 ≈ 4× the 96dpi default, so the 1024px raster is supersampled
  // from the vector rather than upscaled.
  let pipeline = sharp(fs.readFileSync(path.join(brand, job.src)), { density: 384 })
    .resize(1024, 1024);
  if (job.flatten) pipeline = pipeline.flatten({ background: job.flatten });

  await pipeline.png().toFile(path.join(brand, job.out));

  const meta = await sharp(path.join(brand, job.out)).metadata();
  console.log(`${job.out.padEnd(24)} ${meta.width}x${meta.height}  alpha=${meta.hasAlpha}`);
}
