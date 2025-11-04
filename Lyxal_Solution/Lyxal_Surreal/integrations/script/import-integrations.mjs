// Importeur de fichiers .surql pour le module INTEGRATIONS uniquement
// Utilise la lib 'surrealdb' (RPC WebSocket)
// Ordre: database -> reference (schemas puis seeds)

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
  ROOT: path.resolve(__dirname, '..'), // Parent de 'script' = 'integrations'
};

const CONFIG = {
  url: process.env.SURREALDB_URL || DEFAULTS.URL,
  user: process.env.SURREALDB_USER || DEFAULTS.USER,
  pass: process.env.SURREALDB_PASS || DEFAULTS.PASS,
  ns: process.env.SURREALDB_NS || DEFAULTS.NS,
  db: process.env.SURREALDB_DB || DEFAULTS.DB,
  root: process.env.ROOT_INTEGRATIONS_DIR || DEFAULTS.ROOT,
};

// Fichiers à exclure (exemples, tests, documentation)
const EXCLUDE_FILES = new Set([
  'example_queries.surql',
  'integration_schema.surql', // Schéma global (documentation)
]);

// Patterns de fichiers à exclure (seeds batch peuvent être énormes)
const EXCLUDE_PATTERNS = [
  /test/i,           // Fichiers de test
  /example/i,        // Fichiers d'exemple
  /_LIST\.md$/,      // Fichiers de liste
  /README\.md$/,     // Documentation
  /INDEX\.md$/,      // Index
  /ANALYSE/i,        // Analyses
  /REFACTORING/i,    // Documentation de refactoring
  /RECAP/i,          // Récapitulatifs
  /COMPARAISON/i,    // Comparaisons
  /EXPLICATION/i,    // Explications
  /EXEMPLES/i,       // Exemples
  /LIMITATIONS/i,    // Documentation limitations
];

async function listSurqlFiles(dir, excludeSeeds = false) {
  const out = [];
  async function walk(current) {
    try {
      const entries = await fs.readdir(current, { withFileTypes: true });
      for (const e of entries) {
        const p = path.join(current, e.name);
        
        if (e.isDirectory()) {
          await walk(p);
        } else if (e.isFile() && e.name.endsWith('.surql')) {
          // Vérifier exclusions
          if (EXCLUDE_FILES.has(e.name)) continue;
          
          // Vérifier patterns d'exclusion
          let shouldExclude = false;
          for (const pattern of EXCLUDE_PATTERNS) {
            if (pattern.test(p)) {
              shouldExclude = true;
              break;
            }
          }
          if (shouldExclude) continue;
          
          // Exclure les seeds si demandé
          if (excludeSeeds && p.includes('_seeds.surql')) continue;
          
          out.push(p);
        }
      }
    } catch (e) {
      // Dossier inexistant ou inaccessible
    }
  }
  await walk(dir);
  return out.sort((a, b) => a.localeCompare(b));
}

async function main() {
  const db = new Surreal();
  
  console.log('═══════════════════════════════════════════════════════════════');
  console.log('  IMPORT MODULE INTEGRATIONS - Lyxal Solution');
  console.log('═══════════════════════════════════════════════════════════════\n');
  
  try {
    // ========================================================================
    // 1. CONNEXION
    // ========================================================================
    console.log('🔌 Connexion à SurrealDB...');
    console.log(`   URL: ${CONFIG.url}`);
    await db.connect(CONFIG.url);
    await db.signin({ username: CONFIG.user, password: CONFIG.pass });
    console.log('   ✅ Connecté\n');
    
    // ========================================================================
    // 2. SÉLECTION NAMESPACE + DATABASE
    // ========================================================================
    console.log('📦 Configuration:');
    console.log(`   Namespace: ${CONFIG.ns}`);
    console.log(`   Database:  ${CONFIG.db}`);
    
    await db.use({ namespace: CONFIG.ns, database: CONFIG.db });
    console.log('   ✅ Namespace et Database sélectionnés\n');
    
    // ========================================================================
    // 3. VÉRIFICATION ÉTAT ACTUEL
    // ========================================================================
    console.log('📊 État actuel de la base:');
    try {
      const infoDb = await db.query('INFO FOR DB;');
      const tables = Object.keys(infoDb?.[0]?.result?.tables || {});
      const integrationTables = tables.filter(t => 
        t.includes('provider') || 
        t.includes('service') || 
        t.includes('resource') || 
        t.includes('tool') || 
        t.includes('parameter') ||
        t.includes('credential') ||
        t.includes('error_mapping') ||
        t.includes('response_mapping') ||
        t.includes('webhook_config') ||
        t.includes('i18n_key')
      );
      console.log(`   Tables totales: ${tables.length}`);
      console.log(`   Tables integrations existantes: ${integrationTables.length}`);
      if (integrationTables.length > 0) {
        console.log(`   → ${integrationTables.slice(0, 5).join(', ')}${integrationTables.length > 5 ? '...' : ''}`);
      }
    } catch (e) {
      console.warn('   ⚠️  Impossible d\'obtenir INFO FOR DB:', e?.message || e);
    }
    console.log();
    
    // ========================================================================
    // 4. COLLECTE DES FICHIERS À IMPORTER
    // ========================================================================
    console.log('📁 Collecte des fichiers .surql...');
    
    const integrationsRoot = CONFIG.root;
    const databaseDir = path.join(integrationsRoot, 'database');
    const referenceDir = path.join(integrationsRoot, 'reference');
    
    console.log(`   Racine: ${integrationsRoot}`);
    
    // Ordre d'import: database (schemas) puis reference (seeds)
    const databaseSubOrder = [
      'credentials',      // auth_type, credential_type, etc.
      'provider',         // providers
      'service',          // services
      'resource',         // resources
      'tool',             // tools
      'parameter',        // parameters
      'error_mapping',    // error mappings
      'response_mapping', // response mappings (si schéma créé)
      'webhook_config',   // webhook config (si schéma créé)
    ];
    
    const databaseFiles = [];
    for (const sub of databaseSubOrder) {
      const subdir = path.join(databaseDir, sub);
      try {
        const files = await listSurqlFiles(subdir);
        if (files.length > 0) {
          console.log(`   ✓ ${sub}: ${files.length} fichier(s)`);
        }
        databaseFiles.push(...files);
      } catch (e) {
        // Sous-dossier absent: ignorer
      }
    }
    
    // Ask user if they want to import seeds (can be very large)
    const importSeeds = process.env.IMPORT_SEEDS === 'true' || process.argv.includes('--seeds');
    
    let referenceFiles = [];
    if (importSeeds) {
      console.log('\n   📦 Import des SEEDS activé (peut être long)...');
      
      // Ordre des seeds
      const referenceSubOrder = [
        'credentials',
        'Provider',         // Note: majuscule dans le nom du dossier
        'service',
        'resource',
        'tool',
        'parameter',
        'error_mapping',
        'response_mapping',
        'webhook_config',
      ];
      
      for (const sub of referenceSubOrder) {
        const subdir = path.join(referenceDir, sub);
        try {
          const files = await listSurqlFiles(subdir, false); // Inclure les seeds
          // Filtrer pour ne garder que les fichiers _seeds.surql et _i18n*.surql
          const seedFiles = files.filter(f => 
            f.includes('_seeds.surql') || 
            f.includes('_i18n_keys.surql') || 
            f.includes('_i18n_translations.surql')
          );
          if (seedFiles.length > 0) {
            console.log(`   ✓ ${sub}: ${seedFiles.length} fichier(s) de seeds`);
          }
          referenceFiles.push(...seedFiles);
        } catch (e) {
          // Sous-dossier absent: ignorer
        }
      }
    } else {
      console.log('\n   ⏭️  Import des SEEDS désactivé (schemas uniquement)');
      console.log('      Pour importer les seeds: IMPORT_SEEDS=true ou --seeds');
    }
    
    // Fichiers à la racine de integrations (le cas échéant)
    try {
      const rootEntries = await fs.readdir(integrationsRoot, { withFileTypes: true });
      const rootFiles = rootEntries
        .filter(e => e.isFile() && e.name.endsWith('.surql'))
        .filter(e => !EXCLUDE_FILES.has(e.name))
        .map(e => path.join(integrationsRoot, e.name))
        .sort((a, b) => a.localeCompare(b));
      
      if (rootFiles.length > 0) {
        console.log(`   ✓ Racine: ${rootFiles.length} fichier(s)`);
        // Ajouter les fonctions (fn_execute_tool.surql, etc.) au début
        databaseFiles.unshift(...rootFiles);
      }
    } catch (e) {
      // Pas de fichiers racine: ignorer
    }
    
    const allFiles = [...databaseFiles, ...referenceFiles];
    
    console.log(`\n   📊 Total: ${allFiles.length} fichier(s) à importer`);
    console.log(`      - Schemas: ${databaseFiles.length}`);
    console.log(`      - Seeds:   ${referenceFiles.length}\n`);
    
    if (allFiles.length === 0) {
      console.log('   ⚠️  Aucun fichier à importer. Vérifiez le chemin.');
      return;
    }
    
    // ========================================================================
    // 5. IMPORT DES FICHIERS
    // ========================================================================
    console.log('═══════════════════════════════════════════════════════════════');
    console.log('  IMPORT EN COURS...');
    console.log('═══════════════════════════════════════════════════════════════\n');
    
    const failures = [];
    let successCount = 0;
    let currentFile = 1;
    
    for (const file of allFiles) {
      try {
        const sql = await fs.readFile(file, 'utf8');
        const fileName = path.basename(file);
        const fileDir = path.basename(path.dirname(file));
        
        // Afficher progression
        const progress = `[${currentFile}/${allFiles.length}]`;
        console.log(`${progress} 📄 ${fileDir}/${fileName}`);
        
        // Import
        const startTime = Date.now();
        await db.query(sql);
        const duration = Date.now() - startTime;
        
        console.log(`         ✅ OK (${duration}ms)\n`);
        successCount += 1;
      } catch (e) {
        console.error(`         ❌ ERREUR: ${e?.message || e}\n`);
        failures.push({ 
          file: path.relative(integrationsRoot, file), 
          error: e?.message || String(e) 
        });
        // Continuer malgré l'erreur
      }
      currentFile++;
    }
    
    // ========================================================================
    // 6. RAPPORT FINAL
    // ========================================================================
    console.log('═══════════════════════════════════════════════════════════════');
    console.log('  RAPPORT FINAL');
    console.log('═══════════════════════════════════════════════════════════════\n');
    
    console.log(`✅ Succès:  ${successCount} / ${allFiles.length}`);
    console.log(`❌ Échecs:  ${failures.length} / ${allFiles.length}`);
    
    if (successCount > 0) {
      const successRate = ((successCount / allFiles.length) * 100).toFixed(1);
      console.log(`📊 Taux de réussite: ${successRate}%`);
    }
    
    // Vérifier les tables créées
    console.log('\n📊 État final de la base:');
    try {
      const infoDb = await db.query('INFO FOR DB;');
      const tables = Object.keys(infoDb?.[0]?.result?.tables || {});
      const integrationTables = tables.filter(t => 
        t.includes('provider') || 
        t.includes('service') || 
        t.includes('resource') || 
        t.includes('tool') || 
        t.includes('parameter') ||
        t.includes('credential') ||
        t.includes('error_mapping') ||
        t.includes('response_mapping') ||
        t.includes('webhook_config') ||
        t.includes('i18n_key')
      );
      
      console.log(`   Tables totales: ${tables.length}`);
      console.log(`   Tables integrations: ${integrationTables.length}`);
      
      if (integrationTables.length > 0) {
        console.log('\n   Tables integrations créées:');
        for (const table of integrationTables.sort()) {
          // Compter les enregistrements
          try {
            const countResult = await db.query(`SELECT count() FROM ${table} GROUP ALL;`);
            const count = countResult?.[0]?.result?.[0]?.count || 0;
            console.log(`   - ${table.padEnd(30)} : ${count.toLocaleString()} record(s)`);
          } catch (e) {
            console.log(`   - ${table.padEnd(30)} : ? record(s)`);
          }
        }
      }
    } catch (e) {
      console.warn('   ⚠️  Impossible d\'obtenir INFO FOR DB:', e?.message || e);
    }
    
    // Liste des échecs
    if (failures.length > 0) {
      console.log('\n═══════════════════════════════════════════════════════════════');
      console.log('  FICHIERS EN ÉCHEC');
      console.log('═══════════════════════════════════════════════════════════════\n');
      for (const f of failures) {
        console.log(`❌ ${f.file}`);
        console.log(`   → ${f.error}\n`);
      }
    }
    
    console.log('\n═══════════════════════════════════════════════════════════════');
    console.log('  IMPORT TERMINÉ');
    console.log('═══════════════════════════════════════════════════════════════\n');
    
    // Code de sortie
    if (failures.length > 0) {
      console.log('⚠️  Certains fichiers ont échoué. Vérifiez les erreurs ci-dessus.\n');
      process.exitCode = 1;
    } else {
      console.log('✅ Tous les fichiers ont été importés avec succès!\n');
    }
    
  } catch (err) {
    console.error('\n❌ ERREUR FATALE:', err?.message || err);
    console.error(err?.stack || '');
    process.exitCode = 1;
  } finally {
    try { 
      await db.close(); 
      console.log('🔌 Connexion fermée.\n');
    } catch {}
  }
}

main();

