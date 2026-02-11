// ============================================================================
// Script de Maintenance - Nettoyage des Exports Anciens
// ============================================================================
// Nettoie les exports de datasets anciens selon des critères configurables
// ============================================================================

import Surreal from 'surrealdb';

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

// Arguments: [days_old] [dry_run]
const args = process.argv.slice(2);
const daysOld = parseInt(args[0]) || parseInt(process.env.CLEANUP_DAYS_OLD) || 90;
const dryRun = args[1] === 'true' || process.env.CLEANUP_DRY_RUN === 'true';

async function cleanupOldExports(daysOld, dryRun) {
  const db = new Surreal();
  
  try {
    console.log('🔌 Connexion à SurrealDB...');
    await db.connect(CONFIG.url);
    await db.signin({ username: CONFIG.user, password: CONFIG.pass });
    await db.use({ namespace: CONFIG.ns, database: CONFIG.db });

    console.log(`\n🧹 Nettoyage des exports anciens (${daysOld} jours)`);
    console.log(`   Mode: ${dryRun ? 'DRY RUN (simulation)' : 'RÉEL'}`);

    // Récupérer les exports à nettoyer
    const query = `
      SELECT id, identity.name, identity.version, metadata.created_at, metadata.is_active, provenance.file_path
      FROM knowledge_dataset_export
      WHERE metadata.created_at < time::now() - duration::days(${daysOld})
        AND metadata.is_active = true
      ORDER BY metadata.created_at ASC
    `;

    const result = await db.query(query);
    const oldExports = result[0]?.result || [];

    console.log(`\n📊 Exports trouvés à nettoyer: ${oldExports.length}`);

    if (oldExports.length === 0) {
      console.log('✅ Aucun export à nettoyer');
      return { cleaned: 0, errors: [] };
    }

    // Afficher la liste
    console.log('\n📋 Exports à nettoyer:');
    oldExports.forEach((exp, idx) => {
      const age = Math.floor((Date.now() - new Date(exp.metadata.created_at).getTime()) / (1000 * 60 * 60 * 24));
      console.log(`   ${idx + 1}. ${exp.identity.name} (v${exp.identity.version}) - ${age} jours - ${exp.provenance.file_path || 'N/A'}`);
    });

    if (dryRun) {
      console.log('\n✅ Mode DRY RUN - Aucune modification effectuée');
      return { cleaned: oldExports.length, dryRun: true, errors: [] };
    }

    // Marquer comme inactif et définir expiration
    console.log('\n🗑️  Marquage des exports comme inactifs...');
    const errors = [];
    let cleanedCount = 0;

    for (const exp of oldExports) {
      try {
        await db.query(`
          UPDATE ${exp.id} SET
            metadata.is_active = false,
            metadata.expires_at = time::now() + duration::days(30)
        `);
        cleanedCount++;
        console.log(`   ✅ ${exp.identity.name}`);
      } catch (error) {
        errors.push({ export: exp.identity.name, error: error.message });
        console.error(`   ❌ ${exp.identity.name}: ${error.message}`);
      }
    }

    console.log('\n✅ Nettoyage terminé:');
    console.log(`   Exports nettoyés: ${cleanedCount} / ${oldExports.length}`);
    if (errors.length > 0) {
      console.log(`   Erreurs: ${errors.length}`);
    }

    return { cleaned: cleanedCount, errors, dryRun: false };

  } catch (error) {
    console.error('❌ Erreur:', error.message);
    throw error;
  } finally {
    try {
      await db.close();
    } catch {}
  }
}

// Nettoyage des fichiers expirés (optionnel, nécessite accès fichiers)
async function cleanupExpiredFiles(dryRun) {
  // Cette fonction nécessiterait un accès au système de fichiers
  // et pourrait être implémentée séparément si nécessaire
  console.log('\n📝 Note: Nettoyage des fichiers physiques non implémenté ici');
  console.log('   Les fichiers JSONL doivent être nettoyés manuellement ou via un gestionnaire de fichiers');
}

async function main() {
  try {
    const result = await cleanupOldExports(daysOld, dryRun);
    
    console.log('\n' + '='.repeat(60));
    console.log('📊 RÉSUMÉ DU NETTOYAGE');
    console.log('='.repeat(60));
    console.log(`   Exports nettoyés: ${result.cleaned}`);
    console.log(`   Mode: ${result.dryRun ? 'DRY RUN' : 'RÉEL'}`);
    if (result.errors?.length > 0) {
      console.log(`   Erreurs: ${result.errors.length}`);
    }
    console.log('='.repeat(60));

    // Code de sortie approprié
    process.exitCode = result.errors?.length > 0 ? 1 : 0;

  } catch (error) {
    console.error('💥 Erreur fatale:', error.message);
    process.exit(1);
  }
}

main();

