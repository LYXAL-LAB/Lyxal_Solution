import pako from './lib/index.js';

export const deflate = pako.deflate;
export const inflate = pako.inflate;
export const deflateRaw = pako.deflateRaw;
export const gzip = pako.gzip;
export const ungzip = pako.ungzip;

export default pako;

