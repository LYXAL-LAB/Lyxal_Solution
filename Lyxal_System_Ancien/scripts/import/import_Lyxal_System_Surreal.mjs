// Importeur spécifique pour le module Lyxal_System uniquement
// Utilise la lib 'surrealdb' (RPC WebSocket), sans modifier les fichiers importés

import Surreal from 'surrealdb';
import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const DEFAULTS = {
  URL: 'wss://lyxal-06bsd9k399ou7e5fa4tblm6b3g.aws-euw1.surreal.cloud/rpc',
  USER: 'admin',
  PASS: 'admin',
  NS: 'Lyxal_Solution',
  DB: 'Labs',
  ROOT: path.resolve(__dirname, '../..'),
};

const CONFIG = {
  url: process.env.SURREALDB_URL || DEFAULTS.URL,
  user: process.env.SURREALDB_USER || DEFAULTS.USER,
  pass: process.env.SURREALDB_PASS || DEFAULTS.PASS,
  ns: process.env.SURREALDB_NS || DEFAULTS.NS,
  db: process.env.SURREALDB_DB || DEFAULTS.DB,
  root: process.env.ROOT_LYXAL_SYSTEM_DIR || DEFAULTS.ROOT,
};

const EXCLUDE_FILES = new Set([]);

async function listSurqlFiles(dir) {
  const out = [];
  async function walk(current) {
    const entries = await fs.readdir(current, { withFileTypes: true });
    for (const e of entries) {
      const p = path.join(current, e.name);
      if (e.isDirectory()) {
        await walk(p);
      } else if (e.isFile() && e.name.endsWith('.surql') && !EXCLUDE_FILES.has(e.name)) {
        out.push(p);
      }
    }
  }
  await walk(dir);
  return out.sort((a, b) => a.localeCompare(b));
}

async function main() {
  const db = new Surreal();
  try {
    console.log('Connexion à', CONFIG.url);
    await db.connect(CONFIG.url);
    await db.signin({ username: CONFIG.user, password: CONFIG.pass });

    // Utilisation du namespace et database configurés
    await db.use({ namespace: CONFIG.ns, database: CONFIG.db });
    console.log('Namespace:', CONFIG.ns, '| Database:', CONFIG.db);

    // Structure du module Lyxal_System:
    // - database/ (tables: error_code, error_severity, log, log_archive, system_configuration, time_unit)
    // - resource/ (fonctions: error_code, error_severity, log, time_unit)
    // - events/ (events: error_code, error_severity, time_unit)
    // - reference/ (seeds: error, log, time_unit)

    const databaseDir = path.join(CONFIG.root, 'database');
    const resourceDir = path.join(CONFIG.root, 'resource');
    const eventsDir = path.join(CONFIG.root, 'events');
    const referenceDir = path.join(CONFIG.root, 'reference');

    // Ordre d'import pour respecter les dépendances:
    // 1. database/ (tables d'abord - dépendances minimales)
    // 2. resource/ (fonctions ensuite - dépendent des tables)
    // 3. events/ (events ensuite - dépendent des tables)
    // 4. reference/ (seeds en dernier - dépendent des fonctions et tables)

    const databaseFiles = [];
    try {
      databaseFiles.push(...(await listSurqlFiles(databaseDir)));
    } catch (e) {
      console.warn('Dossier database/ introuvable:', e?.message || e);
    }

    const resourceFiles = [];
    try {
      resourceFiles.push(...(await listSurqlFiles(resourceDir)));
    } catch (e) {
      console.warn('Dossier resource/ introuvable:', e?.message || e);
    }

    const eventsFiles = [];
    try {
      eventsFiles.push(...(await listSurqlFiles(eventsDir)));
    } catch (e) {
      console.warn('Dossier events/ introuvable:', e?.message || e);
    }

    const referenceFiles = [];
    try {
      referenceFiles.push(...(await listSurqlFiles(referenceDir)));
    } catch (e) {
      console.warn('Dossier reference/ introuvable:', e?.message || e);
    }

    // Assemblage des fichiers dans l'ordre d'import
    const files = [
      ...databaseFiles,
      ...resourceFiles,
      ...eventsFiles,
      ...referenceFiles,
    ];

    console.log('Fichiers à importer:', files.length);
    if (files.length === 0) {
      console.warn('Aucun fichier .surql trouvé dans le module Lyxal_System');
      return;
    }

    const failures = [];
    let successCount = 0;

    for (const file of files) {
      try {
        const sql = await fs.readFile(file, 'utf8');
        const relativePath = path.relative(CONFIG.root, file);
        console.log(`[${successCount + failures.length + 1}/${files.length}] Importing: ${relativePath}`);
        await db.query(sql);
        successCount += 1;
      } catch (e) {
        const relativePath = path.relative(CONFIG.root, file);
        console.error(`❌ Erreur fichier: ${relativePath}`);
        console.error('  ->', e?.message || e);
        failures.push({ file: relativePath, error: e?.message || String(e) });
        // continuer malgré l'erreur
      }
    }

    console.log(`\n✅ Import terminé. Succès: ${successCount} / ${files.length}, ❌ Echecs: ${failures.length}`);

    // Vérification des tables créées
    try {
      const infoDb = await db.query('INFO FOR DB;');
      const tables = Object.keys(infoDb?.[0]?.result?.tables || {});
      const systemTables = tables.filter(t => 
        t === 'error_code' ||
        t === 'error_severity' ||
        t === 'log' ||
        t === 'log_archive' ||
        t === 'system_configuration' ||
        t === 'time_unit'
      );
      console.log(`📊 Tables Lyxal_System détectées: ${systemTables.length}`);
      if (systemTables.length > 0 && systemTables.length <= 20) {
        console.log('   Tables:', systemTables.join(', '));
      } else if (systemTables.length > 20) {
        console.log('   Tables (premiers):', systemTables.slice(0, 20).join(', '), '...');
      }
    } catch (e) {
      console.warn('⚠️  Impossible d\'obtenir INFO FOR DB:', e?.message || e);
    }

    if (failures.length > 0) {
      console.log('\n❌ Fichiers en échec:');
      for (const f of failures) {
        console.log(`   - ${f.file}`);
        console.log(`     ${f.error}`);
      }
    }
  } catch (err) {
    console.error('❌ Erreur import:', err?.message || err);
    process.exitCode = 1;
  } finally {
    try { 
      await db.close(); 
    } catch {}
  }
}

main();

