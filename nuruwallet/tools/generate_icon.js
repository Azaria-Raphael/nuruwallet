#!/usr/bin/env node
// NuruWallet App Icon Generator — pure Node.js, no npm required
// Renders a teal "N" monogram with a 4-pointed star (Nuru = light in Swahili)
// then writes ic_launcher.png to every Android mipmap-* folder.

'use strict';

const fs   = require('fs');
const path = require('path');
const zlib = require('zlib');

// ─── Design constants ────────────────────────────────────────────────────────

const SIZE = 1024;      // source render size
const RADIUS = 220;     // rounded corner radius

// Colors [r, g, b]
const TEAL_BRIGHT = [20,  184, 166];  // #14B8A6
const TEAL_DARK   = [4,   50,  46];   // #04322E
const WHITE       = [255, 255, 255];

// ─── Math helpers ────────────────────────────────────────────────────────────

function lerp(a, b, t) { return a + (b - a) * Math.max(0, Math.min(1, t)); }
function lerpRGB(a, b, t) {
  return [lerp(a[0],b[0],t), lerp(a[1],b[1],t), lerp(a[2],b[2],t)];
}

// ─── Shape helpers ────────────────────────────────────────────────────────────

function inRoundedRect(x, y, rx, ry, rw, rh, r) {
  // SDF-based test
  const qx = Math.abs(x - rx - rw * 0.5) - rw * 0.5 + r;
  const qy = Math.abs(y - ry - rh * 0.5) - rh * 0.5 + r;
  const dist = Math.sqrt(Math.max(qx, 0) ** 2 + Math.max(qy, 0) ** 2)
             + Math.min(Math.max(qx, qy), 0)
             - r;
  return dist <= 0;
}

function inCircle(x, y, cx, cy, r) {
  return (x-cx)*(x-cx) + (y-cy)*(y-cy) <= r*r;
}

function inEllipse(x, y, cx, cy, rx, ry, angle) {
  const cos = Math.cos(angle), sin = Math.sin(angle);
  const dx = x - cx, dy = y - cy;
  const lx =  cos*dx + sin*dy;
  const ly = -sin*dx + cos*dy;
  return (lx/rx)*(lx/rx) + (ly/ry)*(ly/ry) <= 1;
}

// Diagonal strip of the N letter
// Goes from inner-top-right of left bar (340, 200) to inner-bottom-left of
// right bar (684, 820). Width 120 px measured perpendicular to the stroke.
const _DIAG_LEN = Math.sqrt(344*344 + 620*620); // ≈ 709
const _DIAG_PX  = 344 / _DIAG_LEN;              // unit along x
const _DIAG_PY  = 620 / _DIAG_LEN;              // unit along y
// Perpendicular unit vector (right-hand side of the direction)
const _PERP_PX  =  _DIAG_PY;   //  0.8742
const _PERP_PY  = -_DIAG_PX;   // -0.4851

function inNDiagonal(x, y) {
  const dx = x - 340, dy = y - 200;
  const along = dx * _DIAG_PX + dy * _DIAG_PY;
  if (along < 0 || along > _DIAG_LEN) return false;
  const perp  = dx * _PERP_PX + dy * _PERP_PY;
  return perp >= -60 && perp <= 60;   // ±60 → 120 px wide
}

// ─── Per-pixel renderer ───────────────────────────────────────────────────────

function renderPixel(px, py) {

  // 1. Clip to rounded background
  if (!inRoundedRect(px, py, 0, 0, SIZE, SIZE, RADIUS)) {
    return [0, 0, 0, 0]; // fully transparent outside
  }

  // 2. Radial gradient background (bright centre, dark corners)
  const gdist = Math.sqrt((px-370)*(px-370) + (py-310)*(py-310));
  const gt    = Math.min(1, gdist / 860);
  let [r, g, b] = lerpRGB(TEAL_BRIGHT, TEAL_DARK, gt * gt);

  // alpha-blend helper (modifies r,g,b in scope)
  function blendWhite(alpha) {
    r = lerp(r, 255, alpha);
    g = lerp(g, 255, alpha);
    b = lerp(b, 255, alpha);
  }

  // 3. Inner highlight circle (top-left glow, adds depth)
  const hlDist = Math.sqrt((px-160)*(px-160) + (py-160)*(py-160));
  blendWhite(Math.max(0, 1 - hlDist / 480) * 0.10);

  // ── Letter N ─────────────────────────────────────────────────────────────
  // Left  vertical bar: x 220-340, y 200-820 (120 px wide, 620 px tall)
  // Right vertical bar: x 684-804, y 200-820
  // Diagonal:           from (340,200) to (684,820), 120 px perpendicular width

  if (px >= 220 && px <= 340 && py >= 200 && py <= 820) blendWhite(1.0);
  if (px >= 684 && px <= 804 && py >= 200 && py <= 820) blendWhite(1.0);
  if (inNDiagonal(px, py)) blendWhite(1.0);

  // ── Sparkle star: "Nuru" means Light in Swahili ───────────────────────────
  const SX = 820, SY = 155;

  // Soft glow halo behind the star
  const sDist = Math.sqrt((px-SX)*(px-SX) + (py-SY)*(py-SY));
  if (sDist < 130) blendWhite(Math.max(0, 1 - sDist/130) * 0.20);

  // Four-armed star: vertical + horizontal + two diagonal ellipses
  if ( inEllipse(px, py, SX, SY,  18, 80, 0)               // vertical
    || inEllipse(px, py, SX, SY,  80, 18, 0)               // horizontal
    || inEllipse(px, py, SX, SY,  13, 56, Math.PI / 4)     // 45°
    || inEllipse(px, py, SX, SY,  13, 56, -Math.PI / 4)    // -45°
    || inCircle(px, py, SX, SY, 24)                        // bright centre
  ) {
    blendWhite(0.96);
  }

  // Small decorative dots (light scatter effect)
  if (inCircle(px, py, 162, 845, 11)) blendWhite(0.32);
  if (inCircle(px, py, 880, 790,  8)) blendWhite(0.24);
  if (inCircle(px, py, 855, 430,  5)) blendWhite(0.18);

  return [Math.round(r), Math.round(g), Math.round(b), 255];
}

// ─── Render full source image ─────────────────────────────────────────────────

function renderFull() {
  process.stdout.write('Rendering 1024 × 1024 ...');
  const pixels = new Uint8Array(SIZE * SIZE * 4);
  for (let y = 0; y < SIZE; y++) {
    for (let x = 0; x < SIZE; x++) {
      const [r2, g2, b2, a] = renderPixel(x, y);
      const i = (y * SIZE + x) * 4;
      pixels[i] = r2; pixels[i+1] = g2; pixels[i+2] = b2; pixels[i+3] = a;
    }
  }
  console.log(' done.');
  return pixels;
}

// ─── Box-filter downscale ─────────────────────────────────────────────────────

function downscale(src, srcSize, dstSize) {
  const scale = srcSize / dstSize;
  const dst = new Uint8Array(dstSize * dstSize * 4);
  for (let dy = 0; dy < dstSize; dy++) {
    for (let dx = 0; dx < dstSize; dx++) {
      const sx0 = Math.floor(dx * scale);
      const sx1 = Math.min(srcSize, Math.ceil((dx + 1) * scale));
      const sy0 = Math.floor(dy * scale);
      const sy1 = Math.min(srcSize, Math.ceil((dy + 1) * scale));
      let R = 0, G = 0, B = 0, A = 0, n = 0;
      for (let sy = sy0; sy < sy1; sy++) {
        for (let sx = sx0; sx < sx1; sx++) {
          const si = (sy * srcSize + sx) * 4;
          R += src[si]; G += src[si+1]; B += src[si+2]; A += src[si+3]; n++;
        }
      }
      const di = (dy * dstSize + dx) * 4;
      dst[di]=R/n|0; dst[di+1]=G/n|0; dst[di+2]=B/n|0; dst[di+3]=A/n|0;
    }
  }
  return dst;
}

// ─── Pure-JS PNG encoder ──────────────────────────────────────────────────────

const CRC_TABLE = (() => {
  const t = new Uint32Array(256);
  for (let n = 0; n < 256; n++) {
    let c = n;
    for (let k = 0; k < 8; k++) c = (c & 1) ? 0xEDB88320 ^ (c >>> 1) : c >>> 1;
    t[n] = c;
  }
  return t;
})();

function crc32(buf) {
  let c = 0xFFFFFFFF;
  for (let i = 0; i < buf.length; i++) c = CRC_TABLE[(c ^ buf[i]) & 0xFF] ^ (c >>> 8);
  return (c ^ 0xFFFFFFFF) >>> 0;
}

function chunk(type, data) {
  const len = Buffer.alloc(4); len.writeUInt32BE(data.length, 0);
  const t   = Buffer.from(type, 'ascii');
  const crc = Buffer.alloc(4);
  crc.writeUInt32BE(crc32(Buffer.concat([t, data])), 0);
  return Buffer.concat([len, t, data, crc]);
}

function encodePNG(pixels, w, h) {
  // Build unfiltered raw data: filter-byte (0) + row pixels
  const rowStride = 1 + w * 4;
  const raw = Buffer.alloc(h * rowStride);
  for (let y = 0; y < h; y++) {
    raw[y * rowStride] = 0; // None filter
    for (let x = 0; x < w; x++) {
      const si = (y * w + x) * 4;
      const di = y * rowStride + 1 + x * 4;
      raw[di]=pixels[si]; raw[di+1]=pixels[si+1]; raw[di+2]=pixels[si+2]; raw[di+3]=pixels[si+3];
    }
  }

  const compressed = zlib.deflateSync(raw, { level: 6 });

  const ihdr = Buffer.alloc(13);
  ihdr.writeUInt32BE(w, 0); ihdr.writeUInt32BE(h, 4);
  ihdr[8]=8; ihdr[9]=6; // 8-bit RGBA

  return Buffer.concat([
    Buffer.from([137,80,78,71,13,10,26,10]), // PNG signature
    chunk('IHDR', ihdr),
    chunk('IDAT', compressed),
    chunk('IEND', Buffer.alloc(0)),
  ]);
}

// ─── Main ────────────────────────────────────────────────────────────────────

const ROOT = path.resolve(__dirname, '..');

const ANDROID = [
  { dir: 'mipmap-mdpi',    size: 48  },
  { dir: 'mipmap-hdpi',    size: 72  },
  { dir: 'mipmap-xhdpi',   size: 96  },
  { dir: 'mipmap-xxhdpi',  size: 144 },
  { dir: 'mipmap-xxxhdpi', size: 192 },
];

const full = renderFull();

// Save the 1024×1024 source asset
const assetDir = path.join(ROOT, 'assets', 'icon');
if (!fs.existsSync(assetDir)) fs.mkdirSync(assetDir, { recursive: true });
fs.writeFileSync(path.join(assetDir, 'app_icon.png'), encodePNG(full, SIZE, SIZE));
console.log('Saved  assets/icon/app_icon.png  (1024 × 1024 — source)');

// Write each Android mipmap size
for (const { dir, size } of ANDROID) {
  const px  = size === SIZE ? full : downscale(full, SIZE, size);
  const out = path.join(ROOT, 'android', 'app', 'src', 'main', 'res', dir, 'ic_launcher.png');
  fs.writeFileSync(out, encodePNG(px, size, size));
  console.log(`Saved  android/.../res/${dir}/ic_launcher.png  (${size} × ${size})`);
}

console.log('\nAll icons generated successfully.');
