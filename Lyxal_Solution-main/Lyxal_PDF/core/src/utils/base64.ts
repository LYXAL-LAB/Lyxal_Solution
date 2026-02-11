/*
 * Lyxal Optimized Base64
 * Uses native Buffer (Node/Bun) or atob/btoa (Browser) when available.
 * Fallbacks to pure JS implementation.
 */

declare const globalThis: any;

const hasBuffer = typeof Buffer !== 'undefined';
const hasAtob = typeof atob !== 'undefined' && typeof btoa !== 'undefined';

// --- Pure JS Implementation (Fallback) ---
const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
const lookup = new Uint8Array(256);
for (let i = 0; i < chars.length; i++) lookup[chars.charCodeAt(i)] = i;

const encodeToBase64Pure = (bytes: Uint8Array): string => {
  let base64 = '';
  const len = bytes.length;
  for (let i = 0; i < len; i += 3) {
    base64 += chars[bytes[i] >> 2];
    base64 += chars[((bytes[i] & 3) << 4) | (bytes[i + 1] >> 4)];
    base64 += chars[((bytes[i + 1] & 15) << 2) | (bytes[i + 2] >> 6)];
    base64 += chars[bytes[i + 2] & 63];
  }
  if (len % 3 === 2) base64 = base64.substring(0, base64.length - 1) + '=';
  else if (len % 3 === 1) base64 = base64.substring(0, base64.length - 2) + '==';
  return base64;
};

const decodeFromBase64Pure = (base64: string): Uint8Array => {
  let bufferLength = base64.length * 0.75;
  const len = base64.length;
  let i;
  let p = 0;
  let encoded1, encoded2, encoded3, encoded4;

  if (base64[base64.length - 1] === '=') {
    bufferLength--;
    if (base64[base64.length - 2] === '=') bufferLength--;
  }

  const bytes = new Uint8Array(bufferLength);

  for (i = 0; i < len; i += 4) {
    encoded1 = lookup[base64.charCodeAt(i)];
    encoded2 = lookup[base64.charCodeAt(i + 1)];
    encoded3 = lookup[base64.charCodeAt(i + 2)];
    encoded4 = lookup[base64.charCodeAt(i + 3)];

    bytes[p++] = (encoded1 << 2) | (encoded2 >> 4);
    bytes[p++] = ((encoded2 & 15) << 4) | (encoded3 >> 2);
    bytes[p++] = ((encoded3 & 3) << 6) | (encoded4 & 63);
  }
  return bytes;
};

// --- Native Implementations ---

export const encodeToBase64 = (bytes: Uint8Array): string => {
  if (hasBuffer) {
    return Buffer.from(bytes).toString('base64');
  }
  if (hasAtob) {
    // Binary string strategy for browser
    // Note: large arrays might stack overflow with spread, so we iterate
    // or use a Chunk strategy if needed. For now simple iteration.
    let binary = '';
    const len = bytes.byteLength;
    for (let i = 0; i < len; i++) {
        binary += String.fromCharCode(bytes[i]);
    }
    return btoa(binary);
  }
  return encodeToBase64Pure(bytes);
};

export const decodeFromBase64 = (base64: string): Uint8Array => {
  if (hasBuffer) {
    return new Uint8Array(Buffer.from(base64, 'base64'));
  }
  if (hasAtob) {
    const binaryString = atob(base64);
    const len = binaryString.length;
    const bytes = new Uint8Array(len);
    for (let i = 0; i < len; i++) {
        bytes[i] = binaryString.charCodeAt(i);
    }
    return bytes;
  }
  return decodeFromBase64Pure(base64);
};

const DATA_URI_PREFIX_REGEX = /^(data)?:?([\w\/\+]+)?;?(charset=[\w-]+|base64)?.*,/i;

export const decodeFromBase64DataUri = (dataUri: string): Uint8Array => {
  const trimmedUri = dataUri.trim();
  const prefix = trimmedUri.substring(0, 100);
  const res = prefix.match(DATA_URI_PREFIX_REGEX);

  if (!res) return decodeFromBase64(trimmedUri);

  const [fullMatch] = res;
  const data = trimmedUri.substring(fullMatch.length);
  return decodeFromBase64(data);
};
