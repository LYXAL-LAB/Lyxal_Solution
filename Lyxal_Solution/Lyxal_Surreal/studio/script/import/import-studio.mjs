// Importeur spécifique pour le module studio uniquement
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
  DB: 'Developpement',
  ROOT: path.resolve(__dirname, '../../../studio'),
};

const CONFIG = {
  url: process.env.SURREALDB_URL || DEFAULTS.URL,
  user: process.env.SURREALDB_USER || DEFAULTS.USER,
  pass: process.env.SURREALDB_PASS || DEFAULTS.PASS,
  ns: process.env.SURREALDB_NS || DEFAULTS.NS,
  db: process.env.SURREALDB_DB || DEFAULTS.DB,
  root: process.env.ROOT_STUDIO_DIR || DEFAULTS.ROOT,
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

    // Structure du module studio:
    // - database/icon/ (tables icon)
    // - database/theme/ (tables theme)
    // - database/studio/ (tables studio: component, page, template, etc.)
    // - reference/icon/ (seeds icon)
    // - reference/studio/ (seeds studio)

    const databaseIconDir = path.join(CONFIG.root, 'database', 'icon');
    const databaseThemeDir = path.join(CONFIG.root, 'database', 'theme');
    const databaseStudioDir = path.join(CONFIG.root, 'database', 'studio');
    const referenceIconDir = path.join(CONFIG.root, 'reference', 'icon');
    const referenceStudioDir = path.join(CONFIG.root, 'reference', 'studio');

    // Ordre d'import pour respecter les dépendances:
    // 1. database/icon (dépendances minimales)
    // 2. database/theme (peut dépendre de icon)
    // 3. database/studio (dépend de icon et theme)
    // 4. reference/icon (données de référence pour icon)
    // 5. reference/studio (données de référence pour studio)

    const databaseIconFiles = [];
    try {
      databaseIconFiles.push(...(await listSurqlFiles(databaseIconDir)));
    } catch (e) {
      console.warn('Dossier database/icon introuvable:', e?.message || e);
    }

    const databaseThemeFiles = [];
    try {
      databaseThemeFiles.push(...(await listSurqlFiles(databaseThemeDir)));
    } catch (e) {
      console.warn('Dossier database/theme introuvable:', e?.message || e);
    }

    const databaseStudioFiles = [];
    try {
      databaseStudioFiles.push(...(await listSurqlFiles(databaseStudioDir)));
    } catch (e) {
      console.warn('Dossier database/studio introuvable:', e?.message || e);
    }

    const referenceIconFiles = [];
    try {
      referenceIconFiles.push(...(await listSurqlFiles(referenceIconDir)));
    } catch (e) {
      console.warn('Dossier reference/icon introuvable:', e?.message || e);
    }

    const referenceStudioFiles = [];
    try {
      referenceStudioFiles.push(...(await listSurqlFiles(referenceStudioDir)));
    } catch (e) {
      console.warn('Dossier reference/studio introuvable:', e?.message || e);
    }

    // Assemblage des fichiers dans l'ordre d'import
    const files = [
      ...databaseIconFiles,
      ...databaseThemeFiles,
      ...databaseStudioFiles,
      ...referenceIconFiles,
      ...referenceStudioFiles,
    ];

    console.log('Fichiers à importer:', files.length);
    if (files.length === 0) {
      console.warn('Aucun fichier .surql trouvé dans le module studio');
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
      const studioTables = tables.filter(t => 
        t.startsWith('studio_') || 
        t.startsWith('icon_') || 
        t.startsWith('theme_') ||
        t.startsWith('css_framework')
      );
      console.log(`📊 Tables studio détectées: ${studioTables.length}`);
      if (studioTables.length > 0 && studioTables.length <= 20) {
        console.log('   Tables:', studioTables.join(', '));
      } else if (studioTables.length > 20) {
        console.log('   Tables (premiers):', studioTables.slice(0, 20).join(', '), '...');
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

