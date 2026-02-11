#!/usr/bin/env node
// Simple build script that doesn't rely on npm scripts
const fs = require('fs');
const path = require('path');

function copyFile(src, dest) {
  const destDir = path.dirname(dest);
  if (!fs.existsSync(destDir)) {
    fs.mkdirSync(destDir, { recursive: true });
  }
  fs.copyFileSync(src, dest);
}

function copyDir(src, dest) {
  if (!fs.existsSync(dest)) {
    fs.mkdirSync(dest, { recursive: true });
  }

  const entries = fs.readdirSync(src, { withFileTypes: true });
  for (const entry of entries) {
    const srcPath = path.join(src, entry.name);
    const destPath = path.join(dest, entry.name);

    if (entry.isDirectory()) {
      copyDir(srcPath, destPath);
    } else {
      copyFile(srcPath, destPath);
    }
  }
}

console.log('🏗️ Building Lyxal UI Playground...');

// Create dist directory
if (!fs.existsSync('dist')) {
  fs.mkdirSync('dist');
  console.log('📁 Created dist directory');
}

// Copy index.html
copyFile('index.html', 'dist/index.html');
console.log('📄 Copied index.html');

// Copy src directory
copyDir('src', 'dist/src');
console.log('📂 Copied src directory');

console.log('✅ Build completed successfully!');
console.log('📦 Files ready in dist/ directory');
console.log('💡 Use: bun --hot dist/index.html to preview');
