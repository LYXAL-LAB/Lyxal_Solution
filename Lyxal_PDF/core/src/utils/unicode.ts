/*
 * Lyxal Optimized Unicode Utils
 * Uses TextEncoder/TextDecoder and Buffer where available.
 */

import { toHexString } from 'src/utils/strings';

declare const globalThis: any;

const hasTextEncoder = typeof TextEncoder !== 'undefined';
const hasTextDecoder = typeof TextDecoder !== 'undefined';
const hasBuffer = typeof Buffer !== 'undefined';

// --- Native / Optimized Implementations ---

export const utf8Encode = (input: string, byteOrderMark = true): Uint8Array => {
  if (hasTextEncoder) {
    const encoder = new TextEncoder(); // Always UTF-8
    const encoded = encoder.encode(input);
    if (!byteOrderMark) return encoded;
    
    // Add BOM (EF BB BF)
    const withBom = new Uint8Array(encoded.length + 3);
    withBom.set([0xef, 0xbb, 0xbf], 0);
    withBom.set(encoded, 3);
    return withBom;
  }
  // Fallback (rarely used in modern envs)
  return utf8EncodePure(input, byteOrderMark);
};

export const utf16Encode = (input: string, byteOrderMark = true): Uint16Array => {
  // Buffer optimization for Node/Bun
  if (hasBuffer) {
    // Node Buffer 'utf16le' gives Little Endian. PDF usually likes Big Endian for strings.
    // We get LE, then swap if needed.
    const buf = Buffer.from(input, 'utf16le');
    // Convert to Uint16Array
    const u16 = new Uint16Array(buf.buffer, buf.byteOffset, buf.length / 2);
    
    // Swap bytes to make it Big Endian (default for this function in original logic)
    // Actually, original implementation seems to produce Big Endian by default.
    // Let's stick to Big Endian.
    // Buffer.swap16() operates in-place.
    const swapped = Buffer.from(buf); // Copy to not mutate original if cached (safety)
    swapped.swap16(); 
    
    const res = new Uint16Array(swapped.buffer, swapped.byteOffset, swapped.length / 2);
    
    if (!byteOrderMark) return res;

    const withBom = new Uint16Array(res.length + 1);
    withBom[0] = 0xfeff; // BOM
    withBom.set(res, 1);
    return withBom;
  }

  return utf16EncodePure(input, byteOrderMark);
};

export const utf16Decode = (input: Uint8Array, byteOrderMark = true): string => {
    // If we have TextDecoder, we can use it for 'utf-16be' or 'utf-16le'
    if (hasTextDecoder) {
        // Detect BOM or assume BE
        let encoding = 'utf-16be';
        let offset = 0;
        
        if (byteOrderMark && input.length >= 2) {
            if (input[0] === 0xfe && input[1] === 0xff) {
                encoding = 'utf-16be';
                offset = 2;
            } else if (input[0] === 0xff && input[1] === 0xfe) {
                encoding = 'utf-16le';
                offset = 2;
            }
        }
        
        const decoder = new TextDecoder(encoding);
        // Slice to skip BOM if needed
        const data = offset > 0 ? input.subarray(offset) : input;
        return decoder.decode(data);
    }
    
    return utf16DecodePure(input, byteOrderMark);
}

// --- Pure JS Fallbacks (Legacy) ---

const utf8EncodePure = (input: string, byteOrderMark = true): Uint8Array => {
  const encoded = [];
  if (byteOrderMark) encoded.push(0xef, 0xbb, 0xbf);

  for (let idx = 0, len = input.length; idx < len; ) {
    const codePoint = input.codePointAt(idx)!;
    if (codePoint < 0x80) {
      encoded.push(codePoint & 0x7f);
      idx += 1;
    } else if (codePoint < 0x0800) {
      encoded.push(((codePoint >> 6) & 0x1f) | 0xc0, (codePoint & 0x3f) | 0x80);
      idx += 1;
    } else if (codePoint < 0x010000) {
      encoded.push(((codePoint >> 12) & 0x0f) | 0xe0, ((codePoint >> 6) & 0x3f) | 0x80, (codePoint & 0x3f) | 0x80);
      idx += 1;
    } else {
      encoded.push(
        ((codePoint >> 18) & 0x07) | 0xf0,
        ((codePoint >> 12) & 0x3f) | 0x80,
        ((codePoint >> 6) & 0x3f) | 0x80,
        ((codePoint >> 0) & 0x3f) | 0x80
      );
      idx += 2;
    }
  }
  return new Uint8Array(encoded);
};

// Exports for helpers needed elsewhere
// From Unicode 3.0 spec, section 3.7:
export const highSurrogate = (codePoint: number) => Math.floor((codePoint - 0x10000) / 0x400) + 0xd800;
export const lowSurrogate = (codePoint: number) => ((codePoint - 0x10000) % 0x400) + 0xdc00;

const utf16EncodePure = (input: string, byteOrderMark = true): Uint16Array => {
  const encoded = [];
  if (byteOrderMark) encoded.push(0xfeff);

  for (let idx = 0, len = input.length; idx < len; ) {
    const codePoint = input.codePointAt(idx)!;
    if (codePoint < 0x010000) {
      encoded.push(codePoint);
      idx += 1;
    } else {
      encoded.push(highSurrogate(codePoint), lowSurrogate(codePoint));
      idx += 2;
    }
  }
  return new Uint16Array(encoded);
};

// ... Helpers for Decode ...
const REPLACEMENT = 0xfffd; // ''
enum ByteOrder { BigEndian = 'BigEndian', LittleEndian = 'LittleEndian' }

const readBOM = (bytes: Uint8Array): ByteOrder => 
    (bytes[0] === 0xfe && bytes[1] === 0xff) ? ByteOrder.BigEndian :
    (bytes[0] === 0xff && bytes[1] === 0xfe) ? ByteOrder.LittleEndian : ByteOrder.BigEndian;

const decodeValues = (first: number, second: number, byteOrder: ByteOrder) => 
    byteOrder === ByteOrder.LittleEndian ? (second << 8) | first : (first << 8) | second;

const isHighSurrogate = (cp: number) => cp >= 0xd800 && cp <= 0xdbff;
const isLowSurrogate = (cp: number) => cp >= 0xdc00 && cp <= 0xdfff;

const utf16DecodePure = (input: Uint8Array, byteOrderMark = true): string => {
  if (input.length <= 1) return String.fromCodePoint(REPLACEMENT);
  const byteOrder = byteOrderMark ? readBOM(input) : ByteOrder.BigEndian;
  let idx = byteOrderMark ? 2 : 0;
  const codePoints: number[] = [];

  while (input.length - idx >= 2) {
    const first = decodeValues(input[idx++], input[idx++], byteOrder);
    if (isHighSurrogate(first)) {
        if (input.length - idx < 2) { codePoints.push(REPLACEMENT); }
        else {
            const second = decodeValues(input[idx++], input[idx++], byteOrder);
            if (isLowSurrogate(second)) codePoints.push(first, second);
            else codePoints.push(REPLACEMENT);
        }
    } else if (isLowSurrogate(first)) {
        idx += 2; codePoints.push(REPLACEMENT);
    } else {
        codePoints.push(first);
    }
  }
  if (idx < input.length) codePoints.push(REPLACEMENT);
  return String.fromCodePoint(...codePoints);
};

export const isWithinBMP = (codePoint: number) => codePoint >= 0 && codePoint <= 0xffff;
export const hasSurrogates = (codePoint: number) => codePoint >= 0x010000 && codePoint <= 0x10ffff;
export const hasUtf16BOM = (bytes: Uint8Array) => (bytes[0] === 0xfe && bytes[1] === 0xff) || (bytes[0] === 0xff && bytes[1] === 0xfe);
