// ============================================================================
// Script d'Export JSONL - Module Knowledge
// ============================================================================
// Convertit les données exportées par fn::knowledge_export_domain_for_training()
// en fichier JSONL pour entraînement IA
// ============================================================================

import Surreal from 'surrealdb';
import fs from 'node:fs/promises';
import path from 'node:path';
import crypto from 'node:crypto';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const DEFAULTS = {
  URL: 'wss://lyxal-06bsd9k399ou7e5fa4tblm6b3g.aws-euw1.surreal.cloud/rpc',
  USER: 'admin',
  PASS: 'admin',
  NS: 'Lyxal_Solution',
  DB: 'Developpement',
  OUTPUT_DIR: path.resolve(__dirname, '../../../exports'),
};

const CONFIG = {
  url: process.env.SURREALDB_URL || DEFAULTS.URL,
  user: process.env.SURREALDB_USER || DEFAULTS.USER,
  pass: process.env.SURREALDB_PASS || DEFAULTS.PASS,
  ns: process.env.SURREALDB_NS || DEFAULTS.NS,
  db: process.env.SURREALDB_DB || DEFAULTS.DB,
  outputDir: process.env.EXPORT_OUTPUT_DIR || DEFAULTS.OUTPUT_DIR,
};

// Arguments de ligne de commande
const args = process.argv.slice(2);
const domainCode = args[0] || process.env.EXPORT_DOMAIN_CODE;
const minQualityScore = parseFloat(args[1]) || parseFloat(process.env.EXPORT_MIN_QUALITY) || 0.7;
const datasetVersion = args[2] || process.env.EXPORT_VERSION;
const includeOnlyMarked = args[3] === 'true' || process.env.EXPORT_ONLY_MARKED === 'true';
const updateExportRecord = args[4] !== 'false' && process.env.EXPORT_UPDATE_RECORD !== 'false';

async function generateJSONL(domainCode, minQualityScore, datasetVersion, includeOnlyMarked) {
  const db = new Surreal();
  
  try {
    console.log('🔌 Connexion à SurrealDB...');
    await db.connect(CONFIG.url);
    await db.signin({ username: CONFIG.user, password: CONFIG.pass });
    await db.use({ namespace: CONFIG.ns, database: CONFIG.db });
    console.log('✅ Connecté:', CONFIG.ns, '/', CONFIG.db);

    if (!domainCode) {
      throw new Error('Code domaine requis. Usage: node export-dataset-to-jsonl.mjs <domain_code> [min_quality] [version] [include_only_marked]');
    }

    console.log('\n📊 Paramètres d\'export:');
    console.log(`   Domaine: ${domainCode}`);
    console.log(`   Qualité minimum: ${minQualityScore}`);
    console.log(`   Version: ${datasetVersion || 'auto'}`);
    console.log(`   Uniquement marqués: ${includeOnlyMarked}`);

    // 1. Créer l'enregistrement d'export si version fournie et updateExportRecord = true
    let exportRecordId = null;
    if (datasetVersion && updateExportRecord) {
      console.log('\n📝 Création de l\'enregistrement d\'export...');
      const createResult = await db.query(`
        SELECT * FROM fn::knowledge_export_create_dataset(
          "${domainCode}",
          ${minQualityScore},
          "manual",
          "export_script",
          "Export manuel via script",
          false
        )
      `);
      
      if (createResult[0]?.result?.[0]?.success) {
        exportRecordId = createResult[0].result[0].export_record.id;
        console.log('✅ Enregistrement créé:', exportRecordId);
      } else {
        console.warn('⚠️  Impossible de créer l\'enregistrement d\'export:', createResult[0]?.result?.[0]?.error);
      }
    }

    // 2. Exporter les données
    console.log('\n📦 Export des données...');
    const exportQuery = `
      SELECT * FROM fn::knowledge_export_domain_for_training(
        "${domainCode}",
        ${minQualityScore},
        ${datasetVersion ? `"${datasetVersion}"` : 'NONE'},
        ${includeOnlyMarked}
      )
    `;
    
    const exportResult = await db.query(exportQuery);
    const exportData = exportResult[0]?.result?.[0];

    if (!exportData || !exportData.success) {
      throw new Error(`Erreur lors de l'export: ${exportData?.error || 'Inconnu'}`);
    }

    const { stats, data } = exportData;

    console.log('✅ Données exportées:');
    console.log(`   Items trouvés: ${stats.total_contents_found}`);
    console.log(`   Items exportés: ${stats.total_items_exported}`);
    console.log(`   Qualité moyenne: ${stats.avg_quality_score?.toFixed(3) || 'N/A'}`);
    console.log(`   Poids moyen: ${stats.avg_training_weight?.toFixed(3) || 'N/A'}`);

    if (!data || data.length === 0) {
      console.warn('⚠️  Aucune donnée à exporter');
      return null;
    }

    // 3. Convertir en JSONL
    console.log('\n📄 Conversion en JSONL...');
    const jsonlLines = data.map(item => JSON.stringify(item, null, 0));
    const jsonlContent = jsonlLines.join('\n');

    // 4. Créer le répertoire de sortie si nécessaire
    await fs.mkdir(CONFIG.outputDir, { recursive: true });

    // 5. Générer le nom de fichier
    const version = stats.dataset_version || datasetVersion || `v${Date.now()}`;
    const timestamp = new Date().toISOString().replace(/[:.]/g, '-').split('T')[0];
    const filename = `dataset_${domainCode}_${version}_${timestamp}.jsonl`;
    const filepath = path.join(CONFIG.outputDir, filename);

    // 6. Écrire le fichier
    await fs.writeFile(filepath, jsonlContent, 'utf8');
    const fileSize = (await fs.stat(filepath)).size;
    
    console.log('✅ Fichier créé:', filepath);
    console.log(`   Taille: ${(fileSize / 1024).toFixed(2)} KB`);

    // 7. Calculer le hash SHA-256
    const hash = crypto.createHash('sha256').update(jsonlContent, 'utf8').digest('hex');
    console.log(`   Hash SHA-256: ${hash.substring(0, 16)}...`);

    // 8. Mettre à jour l'enregistrement d'export si créé
    if (exportRecordId && updateExportRecord) {
      console.log('\n📝 Mise à jour de l\'enregistrement d\'export...');
      await db.query(`
        UPDATE ${exportRecordId} SET
          provenance.file_path = "${filepath}",
          provenance.file_size_bytes = ${fileSize},
          provenance.file_hash_sha256 = "${hash}",
          export.total_items_exported = ${stats.total_items_exported},
          export.avg_quality_score = ${stats.avg_quality_score || 0},
          export.avg_training_weight = ${stats.avg_training_weight || 0},
          metadata.updated_at = time::now()
      `);
      console.log('✅ Enregistrement mis à jour');
    }

    // 9. Résumé
    console.log('\n' + '='.repeat(60));
    console.log('✅ EXPORT TERMINÉ');
    console.log('='.repeat(60));
    console.log(`   Fichier: ${filename}`);
    console.log(`   Emplacement: ${filepath}`);
    console.log(`   Taille: ${(fileSize / 1024).toFixed(2)} KB`);
    console.log(`   Items: ${stats.total_items_exported}`);
    console.log(`   Hash: ${hash}`);
    console.log('='.repeat(60));

    return {
      filepath,
      filename,
      fileSize,
      hash,
      stats,
      exportRecordId,
    };

  } catch (error) {
    console.error('❌ Erreur:', error.message);
    console.error(error.stack);
    process.exitCode = 1;
    throw error;
  } finally {
    try {
      await db.close();
    } catch {}
  }
}

// Exécution
const result = await generateJSONL(
  domainCode,
  minQualityScore,
  datasetVersion,
  includeOnlyMarked
).catch(err => {
  console.error('💥 Échec de l\'export:', err.message);
  process.exit(1);
});

if (result) {
  console.log('\n🎯 Export réussi !');
}

