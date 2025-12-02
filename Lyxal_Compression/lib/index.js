'use strict';

const Deflate = require('./deflate.js');
const Inflate = require('./inflate.js');
const constants = require('./zlib/constants.js');

module.exports = {
  Deflate: Deflate.Deflate,
  deflate: Deflate.deflate,
  deflateRaw: Deflate.deflateRaw,
  gzip: Deflate.gzip,
  Inflate: Inflate.Inflate,
  inflate: Inflate.inflate,
  inflateRaw: Inflate.inflateRaw,
  ungzip: Inflate.ungzip,
  constants: constants
};

