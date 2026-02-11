import path from 'node:path';
import fs from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import { compileAll } from '@lyxal/logic-shared';
import type { OperatorMeta } from '@lyxal/logic-shared';
import { writeMetaFiles } from './fs/writeMetaFiles.js';

// 👉 Chaque plugin devra être importé ici pour compilation
import { dateInstancePlugin as dateInstanceUI } from '@lyxal/logic-ui';
import { arrayInstancePlugin as arrayInstanceUI } from '@lyxal/logic-ui';

import { dateInstancePlugin as dateInstanceBE } from '@lyxal/logic-backend';
import { arrayInstancePlugin as arrayInstanceBE } from '@lyxal/logic-backend';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// 📍 dossier de sortie
const OUTPUT_DIR = path.resolve(__dirname, '../../dist/meta');

async function ensureDir(dir: string) {
  try {
    await fs.mkdir(dir, { recursive: true });
  } catch {}
}

async function buildPlugin(plugin: any) {
  const { pluginId, version, operators } = plugin;

  const opsMeta: OperatorMeta[] = Object.values(operators).map((entry: any) => entry.meta);

  const { index, files } = compileAll(pluginId, version, opsMeta);

  const pluginDir = await writeMetaFiles({
    outputDir: OUTPUT_DIR,
    pluginId,
    index,
    files,
  });

  console.log(`✅ Plugin "${pluginId}" compilé via writeMetaFiles → ${pluginDir}`);

}

async function main() {
  console.log('🔧 Compilation des OperatorMeta...');

  await ensureDir(OUTPUT_DIR);

  // Ajoute chaque plugin ici
  await buildPlugin(dateInstanceUI);
  await buildPlugin(arrayInstanceUI);
  await buildPlugin(dateInstanceBE);
  await buildPlugin(arrayInstanceBE);

  console.log('✨ Compilation terminée.');
}

main().catch((err) => {
  console.error('❌ Erreur durant la compilation des OperatorMeta:', err);
  process.exit(1);
});
