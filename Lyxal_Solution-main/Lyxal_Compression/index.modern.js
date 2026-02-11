// Lyxal Optimized Compression Entry Point
'use strict';

const pako = require('./lib/index.js'); // Original Pako implementation
let nativeZlib = null;

try {
  // Try to load native node:zlib
  nativeZlib = require('node:zlib');
} catch (e) {
  // Fallback to pako if not available (e.g. browser without polyfill)
}

// --- Deflate Wrapper ---
function deflate(input, options) {
  if (nativeZlib) { 
    try {
      // Native zlib options mapping could be added here if needed
      // For now, basic deflateSync works for standard PDF use cases
      return nativeZlib.deflateSync(input, options);
    } catch (e) {
      // Fallback on error or incompatible options
    }
  }
  return pako.deflate(input, options);
}

// --- Inflate Wrapper ---
function inflate(input, options) {
  if (nativeZlib) {
    try {
      return nativeZlib.inflateSync(input, options);
    } catch (e) {
      // Fallback on error
    }
  }
  return pako.inflate(input, options);
}

// Export hybrid API
module.exports = {
  ...pako,
  deflate,
  inflate,
};
