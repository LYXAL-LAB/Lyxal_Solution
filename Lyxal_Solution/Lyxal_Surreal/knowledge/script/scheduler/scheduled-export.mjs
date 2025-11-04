// ============================================================================
// Script de Scheduler - Exports Automatiques
// ============================================================================
// Script pour planifier des exports automatiques de datasets d'entraînement
// Usage: Exécuter via cron, scheduler système, ou Azure Functions/AWS Lambda
// ============================================================================

import Surreal from 'surrealdb';
import { exec } from 'child_process';
import { promisify } from 'util';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const execAsync = promisify(exec);

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

// Configuration des exports (peut être dans unfichier JSON ou DB)
const SCHEDULED_EXPORTS = [
  {
    domain_code: 'SURREAL_DB',
    min_quality_score: 0.7,
    export_type: 'scheduled',
    created_by: 'automation_system',
    description: 'Export hebdomadaire automatique',
    schedule: 'weekly', // weekly, daily, monthly
  },
  // Ajouter d'autres exports ici
];

async function executeScheduledExport(config) {
  const db = new Surreal();
  
  try {
    console.log(`\n🚀 Export planifié: ${config.domain_code} (${config.schedule})`);
    await db.connect(CONFIG.url);
    await db.signin({ username: CONFIG.user, password: CONFIG.pass });
    await db.use({ namespace: CONFIG.ns, database: CONFIG.db });

    // Créer l'export avec versioning automatique
    console.log('📝 Création de l\'enregistrement d\'export...');
    const createResult = await db.query(`
      SELECT * FROM fn::knowledge_export_create_dataset(
        "${config.domain_code}",
        ${config.min_quality_score},
        "${config.export_type}",
        "${config.created_by}",
        "${config.description}",
        true
      )
    `);

    const exportData = createResult[0]?.result?.[0];

    if (!exportData || !exportData.success) {
      throw new Error(`Échec création export: ${exportData?.error || 'Inconnu'}`);
    }

    console.log('✅ Export créé:', exportData.version, '-', exportData.dataset_name);

    // Générer le fichier JSONL via le script d'export
    console.log('📄 Génération du fichier JSONL...');
    const exportScriptPath = path.resolve(__dirname, '../export/export-dataset-to-jsonl.mjs');
    
    const envVars = {
      SURREALDB_URL: CONFIG.url,
      SURREALDB_USER: CONFIG.user,
      SURREALDB_PASS: CONFIG.pass,
      SURREALDB_NS: CONFIG.ns,
      SURREALDB_DB: CONFIG.db,
      EXPORT_DOMAIN_CODE: config.domain_code,
      EXPORT_MIN_QUALITY: config.min_quality_score.toString(),
      EXPORT_VERSION: exportData.version,
      EXPORT_ONLY_MARKED: 'false',
      EXPORT_UPDATE_RECORD: 'true',
    };

    const command = `node "${exportScriptPath}" "${config.domain_code}" ${config.min_quality_score} "${exportData.version}" false true`;
    
    try {
      const { stdout, stderr } = await execAsync(command, {
        env: { ...process.env, ...envVars },
        cwd: path.dirname(exportScriptPath),
      });
      
      if (stdout) console.log(stdout);
      if (stderr) console.warn(stderr);

      console.log('✅ Export terminé avec succès');
      return { success: true, exportData };

    } catch (execError) {
      console.error('❌ Erreur lors de la génération du fichier:', execError.message);
      // Ne pas faire échouer tout le processus si le fichier ne peut pas être généré
      return { success: false, error: execError.message, exportData };
    }

  } catch (error) {
    console.error(`❌ Erreur export ${config.domain_code}:`, error.message);
    return { success: false, error: error.message };
  } finally {
    try {
      await db.close();
    } catch {}
  }
}

async function main() {
  console.log('⏰ Scheduler d\'exports automatiques');
  console.log('='.repeat(60));
  console.log(`   Exports configurés: ${SCHEDULED_EXPORTS.length}`);
  console.log(`   Environnement: ${CONFIG.ns} / ${CONFIG.db}`);
  console.log('='.repeat(60));

  const results = [];
  
  for (const config of SCHEDULED_EXPORTS) {
    const result = await executeScheduledExport(config);
    results.push({ config, result });
  }

  // Résumé
  console.log('\n' + '='.repeat(60));
  console.log('📊 RÉSUMÉ DES EXPORTS');
  console.log('='.repeat(60));
  
  const successCount = results.filter(r => r.result.success).length;
  const failCount = results.length - successCount;

  console.log(`   ✅ Succès: ${successCount}`);
  console.log(`   ❌ Échecs: ${failCount}`);

  results.forEach(({ config, result }) => {
    const status = result.success ? '✅' : '❌';
    console.log(`   ${status} ${config.domain_code}: ${result.success ? 'OK' : result.error}`);
  });

  console.log('='.repeat(60));

  // Code de sortie approprié
  process.exitCode = failCount > 0 ? 1 : 0;
}

// Exécution
main().catch(err => {
  console.error('💥 Erreur fatale:', err.message);
  process.exit(1);
});

