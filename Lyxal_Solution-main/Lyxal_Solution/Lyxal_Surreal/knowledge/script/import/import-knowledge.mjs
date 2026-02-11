// Importeur spécifique pour le module knowledge uniquement
// Utilise la lib 'surrealdb' (RPC WebSocket), sans modifier les fichiers importés
// Importe uniquement les fichiers database/ et analyzer/ pour le moment

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
  ROOT: path.resolve(__dirname, '../../'), // Pointe vers knowledge/
};

const CONFIG = {
  url: process.env.SURREALDB_URL || DEFAULTS.URL,
  user: process.env.SURREALDB_USER || DEFAULTS.USER,
  pass: process.env.SURREALDB_PASS || DEFAULTS.PASS,
  ns: process.env.SURREALDB_NS || DEFAULTS.NS,
  db: process.env.SURREALDB_DB || DEFAULTS.DB,
  root: process.env.ROOT_KNOWLEDGE_DIR || DEFAULTS.ROOT,
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

    // Structure du module knowledge:
    // - analyzer/ (analyseurs pour recherche full-text: knowledge_keywords_analyzer)
    // - database/ (tables knowledge: domain, topic, content, category, etc.)
    // - function/ (fonctions API pour requêtes optimisées IA)

    const databaseDir = path.join(CONFIG.root, 'database');
    const analyzerDir = path.join(CONFIG.root, 'analyzer');
    const functionDir = path.join(CONFIG.root, 'function');

    // Ordre d'import pour respecter les dépendances:
    // 1. analyzer/ (analyseurs doivent être créés en premier pour les index FULLTEXT)
    // 2. database/ dans l'ordre des dépendances:
    //    - knowledge_domain (niveau 1, aucune dépendance knowledge)
    //    - knowledge_category (niveau 1, aucune dépendance knowledge)
    //    - knowledge_content_type (niveau 1, aucune dépendance knowledge)
    //    - knowledge_keyword (niveau 1, aucune dépendance knowledge - nouveau)
    //    - knowledge_sub_category (dépend de knowledge_category)
    //    - knowledge_topic (dépend de knowledge_domain, knowledge_category, knowledge_sub_category)
    //    - knowledge_content (dépend de knowledge_topic, knowledge_content_type)
    //    - knowledge_domain_keyword (dépend de knowledge_domain, knowledge_keyword, knowledge_keywords_analyzer)
    //    - knowledge_topic_keyword (dépend de knowledge_topic, knowledge_keyword, knowledge_keywords_analyzer)
    //    - knowledge_dataset_export (dépend de knowledge_domain)
    // 3. function/ (fonctions API pour requêtes optimisées IA - dépendent de toutes les tables)

    const analyzerFiles = [];
    try {
      analyzerFiles.push(...(await listSurqlFiles(analyzerDir)));
    } catch (e) {
      console.warn('Dossier analyzer/ introuvable:', e?.message || e);
    }

    const databaseFiles = [];
    try {
      const allFiles = await listSurqlFiles(databaseDir);
      // Ordonner les fichiers pour respecter les dépendances
      const orderedFiles = [];
      
      // Niveau 1 : Tables sans dépendances knowledge
      const level1Patterns = [
        'knowledge_domain.surql',
        'knowledge_category.surql',
        'knowledge_content_type.surql',
        'knowledge_keyword.surql', // Nouveau
      ];
      
      // Niveau 2 : Tables dépendant du niveau 1
      const level2Patterns = [
        'knowledge_sub_category.surql', // dépend de knowledge_category
      ];
      
      // Niveau 3 : Tables dépendant du niveau 2 ou niveau 1
      const level3Patterns = [
        'knowledge_topic.surql', // dépend de knowledge_domain, knowledge_category, knowledge_sub_category
        'knowledge_dataset_export.surql', // dépend de knowledge_domain
      ];
      
      // Niveau 4 : Tables dépendant du niveau 3
      const level4Patterns = [
        'knowledge_content.surql', // dépend de knowledge_topic, knowledge_content_type
      ];
      
      // Niveau 5 : Tables dépendant du niveau 4
      const level5Patterns = [
        'knowledge_feedback.surql', // dépend de knowledge_content
        'knowledge_gap.surql', // dépend de knowledge_domain, knowledge_topic, knowledge_content
        'knowledge_content_proposal.surql', // dépend de knowledge_gap, knowledge_topic, knowledge_content_type
      ];
      
      // Niveau 6 : Relations dépendant des tables précédentes
      const level6Patterns = [
        'knowledge_content_relation.surql', // dépend de knowledge_content
        'knowledge_domain_keyword.surql', // dépend de knowledge_domain, knowledge_keywords_analyzer
        'knowledge_topic_keyword.surql', // dépend de knowledge_topic, knowledge_keywords_analyzer
      ];
      
      // Fonction pour trouver les fichiers par pattern
      const findFiles = (patterns) => {
        return patterns
          .map(pattern => allFiles.find(f => f.endsWith(pattern)))
          .filter(Boolean);
      };
      
      orderedFiles.push(...findFiles(level1Patterns));
      orderedFiles.push(...findFiles(level2Patterns));
      orderedFiles.push(...findFiles(level3Patterns));
      orderedFiles.push(...findFiles(level4Patterns));
      orderedFiles.push(...findFiles(level5Patterns));
      orderedFiles.push(...findFiles(level6Patterns));
      
      // Ajouter les fichiers non catégorisés à la fin
      const orderedPaths = new Set(orderedFiles.map(f => path.normalize(f)));
      const remainingFiles = allFiles.filter(f => !orderedPaths.has(path.normalize(f)));
      orderedFiles.push(...remainingFiles);
      
      databaseFiles.push(...orderedFiles);
    } catch (e) {
      console.warn('Dossier database/ introuvable:', e?.message || e);
    }

    const functionFiles = [];
    try {
      functionFiles.push(...(await listSurqlFiles(functionDir)));
    } catch (e) {
      console.warn('Dossier function/ introuvable:', e?.message || e);
    }

    // Assemblage des fichiers dans l'ordre d'import
    const files = [
      ...analyzerFiles,
      ...databaseFiles,
      ...functionFiles, // Fonctions après toutes les tables
    ];

    console.log('Fichiers à importer:', files.length);
    if (files.length === 0) {
      console.warn('Aucun fichier .surql trouvé dans le module knowledge');
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
      const knowledgeTables = tables.filter(t => 
        t.startsWith('knowledge_')
      );
      console.log(`📊 Tables knowledge détectées: ${knowledgeTables.length}`);
      if (knowledgeTables.length > 0 && knowledgeTables.length <= 20) {
        console.log('   Tables:', knowledgeTables.join(', '));
      } else if (knowledgeTables.length > 20) {
        console.log('   Tables (premiers):', knowledgeTables.slice(0, 20).join(', '), '...');
      }

      // Vérification des analyseurs
      const infoNs = await db.query('INFO FOR NS;');
      const analyzers = Object.keys(infoNs?.[0]?.result?.analyzers || {});
      const knowledgeAnalyzers = analyzers.filter(a => 
        a.startsWith('knowledge_')
      );
      console.log(`🔍 Analyseurs knowledge détectés: ${knowledgeAnalyzers.length}`);
      if (knowledgeAnalyzers.length > 0) {
        console.log('   Analyseurs:', knowledgeAnalyzers.join(', '));
      }

      // Vérification des fonctions
      const functions = Object.keys(infoNs?.[0]?.result?.functions || {});
      const knowledgeFunctions = functions.filter(f => 
        f.startsWith('fn::knowledge_')
      );
      console.log(`⚙️  Fonctions knowledge détectées: ${knowledgeFunctions.length}`);
      if (knowledgeFunctions.length > 0) {
        console.log('   Fonctions:', knowledgeFunctions.join(', '));
      }
    } catch (e) {
      console.warn('⚠️  Impossible d\'obtenir INFO FOR DB/NS:', e?.message || e);
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

