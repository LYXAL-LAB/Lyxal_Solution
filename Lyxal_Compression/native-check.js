try {
  const zlib = require('node:zlib');
  console.log('Native zlib found!');
  const input = Buffer.from('Hello Native Compression');
  const compressed = zlib.deflateSync(input);
  console.log('Compression successful:', compressed.length > 0);
} catch (e) {
  console.log('Native zlib NOT found:', e.message);
}

