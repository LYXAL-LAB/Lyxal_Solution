import fs from 'node:fs/promises';
import pako from '@lyxal-compression/compression';
import { basename, dirname, join } from 'node:path';

import { ICharMetrics, parseCharMetricsSection } from './parseCharacterMetrics';
import { IFontMetrics, parseFontMetricsSection } from './parseFontMetrics';
import { IKernPair, parseKernPairsSection } from './parseKernPairs';

interface IMetrics extends IFontMetrics {
  CharMetrics: ICharMetrics[];
  KernPairs: IKernPair[];
}

export { IMetrics };

export const parseFontMetrics = (data: string): IMetrics => ({
  ...parseFontMetricsSection(data),
  CharMetrics: parseCharMetricsSection(data),
  KernPairs: parseKernPairsSection(data),
});

// Bun native directory (replaces __dirname)
const currentDir = import.meta.dir;
const rootDir = dirname(dirname(currentDir));

const getAfmFilePaths = async () => {
  const fontMetricsDir = join(rootDir, 'font_metrics');
  const files = await fs.readdir(fontMetricsDir);
  const afmFiles = files.filter((name) => name.endsWith('.afm'));
  return afmFiles.map((name) => join(fontMetricsDir, name));
};

const compressJson = (json: string) => {
  const jsonBytes = new Uint8Array(json.split('').map((c) => c.charCodeAt(0)));
  const deflated = pako.deflate(jsonBytes);
  // Native Base64 encoding using Buffer
  return JSON.stringify(Buffer.from(deflated).toString('base64'));
};

const copyFileToSrc = async (src: string) => {
  const fileName = basename(src);
  const dest = join(rootDir, 'src', fileName);
  await fs.copyFile(src, dest);
};

const main = async () => {
  try {
    const afmFiles = await getAfmFilePaths();

    for (const afmFile of afmFiles) {
      console.log('Parsing:', afmFile);
      const data = await fs.readFile(afmFile, 'utf-8');

      const metrics = parseFontMetrics(data);
      const jsonMetrics = JSON.stringify(metrics);

      const jsonFile = afmFile.replace('.afm', '.json');
      const compressedJsonFile = afmFile.replace('.afm', '.compressed.json');

      await fs.writeFile(jsonFile, jsonMetrics);
      await fs.writeFile(compressedJsonFile, compressJson(jsonMetrics));
      await copyFileToSrc(compressedJsonFile);
    }
    console.log('✅ Font metrics generated successfully.');
  } catch (error) {
    console.error('❌ Error generating font metrics:', error);
    process.exit(1);
  }
};

main();
