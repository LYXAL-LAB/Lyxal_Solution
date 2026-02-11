import fs from 'node:fs/promises';
import pako from '@lyxal-compression/compression';
import { basename, dirname, join } from 'node:path';

import { parseWin1252 } from './parseWin1252';
import { parseZapfDingbatsOrSymbol } from './parseZapfDingbatsOrSymbol';

const compressJson = (json: string) => {
  const jsonBytes = new Uint8Array(json.split('').map((c) => c.charCodeAt(0)));
  const deflated = pako.deflate(jsonBytes);
  return JSON.stringify(Buffer.from(deflated).toString('base64'));
};

const copyFileToSrc = async (src: string) => {
  const fileName = basename(src);
  // Reaching up from scripts/encodings/parse.ts -> scripts -> fonts -> src
  const currentDir = import.meta.dir;
  const rootDir = dirname(dirname(currentDir));
  const dest = join(rootDir, 'src', fileName);
  await fs.copyFile(src, dest);
};

const main = async () => {
  try {
    const currentDir = import.meta.dir;
    const rootDir = dirname(dirname(currentDir));
    const encodingMetricsDir = join(rootDir, 'encoding_metrics');

    const allEncodings: Record<string, any> = {};
    for (const fontName of ['symbol', 'zapfdingbats', 'win1252']) {
      const file = join(encodingMetricsDir, `${fontName}.txt`);
      console.log('Parsing:', file);
      const data = await fs.readFile(file, 'utf-8');

      const parser =
        fontName === 'win1252' ? parseWin1252 : parseZapfDingbatsOrSymbol;
      const jsonMetrics = parser(data);
      allEncodings[fontName] = jsonMetrics;

      const json = JSON.stringify(jsonMetrics);

      const jsonFile = join(encodingMetricsDir, `${fontName}-encoding.json`);
      await fs.writeFile(jsonFile, json);
    }

    const allJson = JSON.stringify(allEncodings);
    const allCompressedJson = compressJson(allJson);

    const allJsonFile = join(encodingMetricsDir, 'all-encodings.json');
    const allCompressedJsonFile = join(encodingMetricsDir, 'all-encodings.compressed.json');

    await fs.writeFile(allJsonFile, allJson);
    await fs.writeFile(allCompressedJsonFile, allCompressedJson);
    await copyFileToSrc(allCompressedJsonFile);
    console.log('✅ Encoding metrics generated successfully.');
  } catch (error) {
    console.error('❌ Error generating encoding metrics:', error);
    process.exit(1);
  }
};

main();
