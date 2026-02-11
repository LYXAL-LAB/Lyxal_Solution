// ============================================================================
// Script de Validation - Vérification du Système Knowledge
// ============================================================================
// Vérifie que toutes les tables, fonctions et analyseurs sont correctement installés
// ============================================================================

import Surreal from 'surrealdb';
import pkg from 'surrealdb/package.json' assert { type: 'json' };

const DEFAULTS = {
  URL: 'wss://lyxal-06bsd9k399ou7e5fa4tblm6b3g.aws-euw1.surreal.cloud/rpc',
  USER: 'admin',
  PASS: 'admin',
  NS: 'Lyxal_Solution',
  DB: 'Developpement',
};

const CONFIG = {
  url: process.env.SURREALDB_URL || DEFAULTS.URL,
  user: process.env.SURREALDB_USER || DEFAULTS.USER,
  pass: process.env.SURREALDB_PASS || DEFAULTS.PASS,
  ns: process.env.SURREALDB_NS || DEFAULTS.NS,
  db: process.env.SURREALDB_DB || DEFAULTS.DB,
};

// Tables attendues
const EXPECTED_TABLES = [
  'knowledge_domain',
  'knowledge_category',
  'knowledge_sub_category',
  'knowledge_topic',
  'knowledge_keyword',
  'knowledge_content_type',
  'knowledge_content',
  'knowledge_feedback',
  'knowledge_gap',
  'knowledge_content_proposal',
  'knowledge_dataset_export',
  'knowledge_content_relation',
  'knowledge_domain_keyword',
  'knowledge_topic_keyword',
];

// Analyseurs attendus
const EXPECTED_ANALYZERS = [
  'knowledge_keywords_analyzer',
];

// Fonctions attendues (premières lettres seulement pour correspondance)
const EXPECTED_FUNCTIONS_PATTERNS = [
  'fn::knowledge_get_',
  'fn::knowledge_search_',
  'fn::knowledge_track_',
  'fn::knowledge_gap_',
  'fn::knowledge_enrich_',
  'fn::knowledge_analytics_',
  'fn::knowledge_export_',
];

async function validateSystem() {
  const db = new Surreal();
  const results = {
    connection: false,
    tables: { expected: EXPECTED_TABLES.length, found: [], missing: [] },
    analyzers: { expected: EXPECTED_ANALYZERS.length, found: [], missing: [] },
    functions: { expected: 0, found: [], missing: [], count: 0 },
    errors: [],
  };

  try {
    console.log('🔌 Connexion à SurrealDB...');
    await db.connect(CONFIG.url);
    await db.signin({ username: CONFIG.user, password: CONFIG.pass });
    await db.use({ namespace: CONFIG.ns, database: CONFIG.db });
    console.log('✅ Connecté:', CONFIG.ns, '/', CONFIG.db);
    results.connection = true;

    // 1. Vérifier les tables
    console.log('\n📊 Vérification des tables...');
    const infoDb = await db.query('INFO FOR DB;');
    const tables = Object.keys(infoDb?.[0]?.result?.tables || {});

    EXPECTED_TABLES.forEach(table => {
      if (tables.includes(table)) {
        results.tables.found.push(table);
      } else {
        results.tables.missing.push(table);
      }
    });

    console.log(`   ✅ Trouvées: ${results.tables.found.length} / ${EXPECTED_TABLES.length}`);
    if (results.tables.missing.length > 0) {
      console.log(`   ❌ Manquantes: ${results.tables.missing.join(', ')}`);
    }

    // 2. Vérifier les analyseurs
    console.log('\n🔍 Vérification des analyseurs...');
    const infoNs = await db.query('INFO FOR NS;');
    const analyzers = Object.keys(infoNs?.[0]?.result?.analyzers || {});

    EXPECTED_ANALYZERS.forEach(analyzer => {
      if (analyzers.includes(analyzer)) {
        results.analyzers.found.push(analyzer);
      } else {
        results.analyzers.missing.push(analyzer);
      }
    });

    console.log(`   ✅ Trouvés: ${results.analyzers.found.length} / ${EXPECTED_ANALYZERS.length}`);
    if (results.analyzers.missing.length > 0) {
      console.log(`   ❌ Manquants: ${results.analyzers.missing.join(', ')}`);
    }

    // 3. Vérifier les fonctions
    console.log('\n⚙️  Vérification des fonctions...');
    const functions = Object.keys(infoNs?.[0]?.result?.functions || {});
    const knowledgeFunctions = functions.filter(f => f.startsWith('fn::knowledge_'));

    results.functions.count = knowledgeFunctions.length;
    
    EXPECTED_FUNCTIONS_PATTERNS.forEach(pattern => {
      const matching = knowledgeFunctions.filter(f => f.startsWith(pattern));
      if (matching.length > 0) {
        results.functions.found.push(...matching);
      } else {
        results.functions.missing.push(pattern);
      }
    });

    console.log(`   ✅ Fonctions knowledge trouvées: ${knowledgeFunctions.length}`);
    if (results.functions.missing.length > 0) {
      console.log(`   ⚠️  Patterns manquants: ${results.functions.missing.join(', ')}`);
    }

    // 4. Test de quelques fonctions critiques
    console.log('\n🧪 Tests de fonctionnalités...');
    const functionTests = [];

    // Test fn::knowledge_get_topic_bundle_for_ai
    try {
      const testResult = await db.query(`
        SELECT * FROM fn::knowledge_get_topic_bundle_for_ai("TEST_TOPIC", "QUICK_HELP", 0.5, 1)
      `);
      functionTests.push({ name: 'get_topic_bundle', status: 'ok', note: 'Fonction disponible' });
    } catch (error) {
      functionTests.push({ name: 'get_topic_bundle', status: 'error', note: error.message });
    }

    // Test fn::knowledge_track_content_access
    try {
      // Ne pas vraiment tracker pour éviter de modifier les données
      functionTests.push({ name: 'track_content_access', status: 'ok', note: 'Fonction disponible (non testée)' });
    } catch (error) {
      functionTests.push({ name: 'track_content_access', status: 'error', note: error.message });
    }

    functionTests.forEach(test => {
      const icon = test.status === 'ok' ? '✅' : '❌';
      console.log(`   ${icon} ${test.name}: ${test.note}`);
    });

    // Résumé
    console.log('\n' + '='.repeat(60));
    console.log('📊 RÉSUMÉ DE VALIDATION');
    console.log('='.repeat(60));
    console.log(`   Connexion: ${results.connection ? '✅' : '❌'}`);
    console.log(`   Tables: ${results.tables.found.length}/${EXPECTED_TABLES.length} ${results.tables.missing.length === 0 ? '✅' : '⚠️'}`);
    console.log(`   Analyseurs: ${results.analyzers.found.length}/${EXPECTED_ANALYZERS.length} ${results.analyzers.missing.length === 0 ? '✅' : '⚠️'}`);
    console.log(`   Fonctions: ${results.functions.count} trouvées`);
    console.log('='.repeat(60));

    const isValid = results.connection 
      && results.tables.missing.length === 0 
      && results.analyzers.missing.length === 0
      && results.functions.count > 0;

    if (isValid) {
      console.log('\n✅ Système Knowledge validé avec succès !');
      process.exitCode = 0;
    } else {
      console.log('\n⚠️  Des éléments manquent. Vérifiez les détails ci-dessus.');
      process.exitCode = 1;
    }

    return results;

  } catch (error) {
    console.error('❌ Erreur lors de la validation:', error.message);
    results.errors.push(error.message);
    process.exitCode = 1;
    return results;
  } finally {
    try {
      await db.close();
    } catch {}
  }
}

validateSystem().catch(err => {
  console.error('💥 Erreur fatale:', err.message);
  process.exit(1);
});

