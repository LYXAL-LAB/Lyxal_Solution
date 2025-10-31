#!/usr/bin/env node
// Import SIRENE → SurrealDB (28+ millions d'entreprises)
// Utilise surrealdb.js (même lib que import-surql.mjs qui fonctionne)

import Surreal from 'surrealdb';
import fs from 'node:fs';
import { createReadStream } from 'node:fs';
import { createInterface } from 'node:readline';
import { mkdir, writeFile, readFile } from 'node:fs/promises';
import path from 'node:path';

// ============================================================
// CONFIG
// ============================================================

const CONFIG = {
  SIRENE_FILE: 'C:\\Users\\Admin\\Desktop\\Lyxal_Solution\\Lyxal_Solution\\dataset\\StockUniteLegale_utf8.jsonl',
  SURREALDB_URL: 'wss://lyxal-06bsd9k399ou7e5fa4tblm6b3g.aws-euw1.surreal.cloud/rpc',
  SURREALDB_USER: 'admin',
  SURREALDB_PASSWORD: 'admin',
  SURREALDB_NS: 'Lyxal_Solution',
  SURREALDB_DB: 'Labs',
  TABLE_NAME: 'business_company',
  BATCH_SIZE: 1000,  // Batch important pour réduire les transactions et éviter "No space left"
  CHECKPOINT_EVERY: 10000,
  CHECKPOINT_FILE: 'import_checkpoint.json',
  ERROR_LOG_FILE: 'erreurs_import.log',
  TOTAL_ESTIMATED: 28760238,
  RESET_CHECKPOINT: false,
};

// Remapping codes non-officiels
const WORKFORCE_REMAP = {
  '32': '31', // Non-officiel → 500 à 999
  '53': '52', // Non-officiel → 2000 à 4999
};

// ============================================================
// CHECKPOINTS
// ============================================================

async function loadCheckpoint() {
  try {
    if (fs.existsSync(CONFIG.CHECKPOINT_FILE)) {
      const data = await readFile(CONFIG.CHECKPOINT_FILE, 'utf-8');
      return JSON.parse(data);
    }
  } catch (e) {
    console.warn('⚠️ Checkpoint illisible, reprise à 0');
  }
  return { last_processed: 0, total_imported: 0, errors: 0 };
}

async function saveCheckpoint(checkpoint) {
  await writeFile(CONFIG.CHECKPOINT_FILE, JSON.stringify(checkpoint, null, 2));
}

// ============================================================
// LOG ERREURS
// ============================================================

async function logError(lineNumber, rawLine, error) {
  const errorLine = `[${new Date().toISOString()}] Ligne ${lineNumber}: ${error}\n${rawLine}\n${'='.repeat(80)}\n`;
  await fs.promises.appendFile(CONFIG.ERROR_LOG_FILE, errorLine, 'utf-8');
}

// ============================================================
// UTILS
// ============================================================

function safeId(val) {
  if (!val) return null;
  return String(val).trim().toLowerCase().replace(/[^a-z0-9_]+/g, '_');
}

function toSurrealDate(value) {
  if (!value) return null;
  const val = String(value).trim();
  if (val === '0000-00-00' || val === '9999-12-31') return null;
  try {
    const dt = new Date(val);
    if (isNaN(dt.getTime())) return null;
    return dt.toISOString();
  } catch {
    return null;
  }
}

function cleanNullValues(obj) {
  if (!obj || typeof obj !== 'object') return obj;
  
  if (Array.isArray(obj)) {
    return obj.filter(v => v !== null && v !== undefined).map(cleanNullValues);
  }
  
  const result = {};
  for (const [key, value] of Object.entries(obj)) {
    if (value !== null && value !== undefined) {
      result[key] = typeof value === 'object' ? cleanNullValues(value) : value;
    }
  }
  return result;
}

// ============================================================
// CONVERSION SIRENE → COMPANY
// ============================================================

function convertSireneToCompany(data) {
  const siren = String(data.siren || '').padStart(9, '0');
  const nic = data.nicSiegeUniteLegale ? String(data.nicSiegeUniteLegale).padStart(5, '0') : null;
  const siret = siren && nic ? `${siren}${nic}` : null;

  // IDs normalisés
  const activityCode = safeId(data.activitePrincipaleUniteLegale);
  const nomenclature = safeId(data.nomenclatureActivitePrincipaleUniteLegale);
  const legalForm = safeId(data.categorieJuridiqueUniteLegale);
  const adminStatus = safeId(data.etatAdministratifUniteLegale);
  const category = safeId(data.categorieEntreprise);
  let workforceRange = safeId(data.trancheEffectifsUniteLegale);
  const gender = safeId(data.sexeUniteLegale);

  // Remapping workforce
  if (workforceRange && WORKFORCE_REMAP[workforceRange]) {
    workforceRange = WORKFORCE_REMAP[workforceRange];
  }

  // Construction de l'objet (tous les champs SIRENE)
  const company = {
    identifiers: {
      siren,
      nic_siege: nic,
      siret_siege: siret,
    },
    names: {
      official: data.denominationUniteLegale || null,
      usual_1: data.denominationUsuelle1UniteLegale || null,
      usual_2: data.denominationUsuelle2UniteLegale || null,
      usual_3: data.denominationUsuelle3UniteLegale || null,
      sigle: data.sigleUniteLegale || null,
    },
    individual: {
      last_name: data.nomUniteLegale || null,
      usage_name: data.nomUsageUniteLegale || null,
      first_name_1: data.prenom1UniteLegale || null,
      first_name_2: data.prenom2UniteLegale || null,
      first_name_3: data.prenom3UniteLegale || null,
      first_name_4: data.prenom4UniteLegale || null,
      usual_first_name: data.prenomUsuelUniteLegale || null,
      pseudonym: data.pseudonymeUniteLegale || null,
      gender: gender ? `business_gender:gender_${gender}` : null,
    },
    activity: {
      code: activityCode && nomenclature ? `business_activity_code:${nomenclature}_${activityCode}` : null,
      nomenclature: nomenclature ? `business_nomenclature_type:${nomenclature}` : null,
    },
    legal: {
      form: legalForm ? `business_legal_form:cj_${legalForm}` : null,
      administrative_status: adminStatus ? `business_administrative_status:status_${adminStatus}` : null,
      creation_date: toSurrealDate(data.dateCreationUniteLegale),
    },
    classification: {
      category: category ? `business_company_category:cat_${category}` : null,
      category_year: data.anneeCategorieEntreprise || null,
    },
    workforce: {
      range: workforceRange ? `business_workforce_range:wr_${workforceRange}` : null,
      year: data.anneeEffectifsUniteLegale || null,
    },
    social_economy: {
      is_ess: data.economieSocialeSolidaireUniteLegale === 'O',
      association_id: data.identifiantAssociationUniteLegale || null,
    },
    diffusion: {
      status: data.statutDiffusionUniteLegale || 'O',
      is_purged: data.unitePurgeeUniteLegale === 'true' || data.unitePurgeeUniteLegale === true,
    },
    metadata: {
      period_start_date: toSurrealDate(data.dateDebut),
      import_date: new Date().toISOString(),
    },
  };

  // Ne PAS supprimer les objets structurels vides (requis par le schéma)
  // Supprimer seulement les valeurs null à l'intérieur
  for (const key in company) {
    if (company[key] && typeof company[key] === 'object') {
      company[key] = cleanNullValues(company[key]);
    }
  }
  return company;
}

// ============================================================
// CRÉATION REQUÊTE SURREALQL
// ============================================================

function buildCreateQuery(siren, company) {
  // Convertir l'objet en SurrealQL natif (record IDs sans guillemets)
  const surql = buildSurQLObject(company, 1);
  return `CREATE ${CONFIG.TABLE_NAME}:s${siren} CONTENT ${surql};`;
}

function buildSurQLObject(obj, indent = 0) {
  if (obj === null || obj === undefined) return 'NONE';
  
  const ind = '  '.repeat(indent);
  const ind2 = '  '.repeat(indent + 1);
  
  if (Array.isArray(obj)) {
    if (obj.length === 0) return '[]';
    const items = obj.map(v => buildSurQLObject(v, indent + 1)).join(', ');
    return `[${items}]`;
  }
  
  if (obj instanceof Date || (typeof obj === 'string' && /^\d{4}-\d{2}-\d{2}T/.test(obj))) {
    return `d"${typeof obj === 'string' ? obj : obj.toISOString()}"`;
  }
  
  if (typeof obj === 'string') {
    // Record ID (commence par business_)
    if (obj.startsWith('business_')) {
      return obj;
    }
    // String normale
    return `"${obj.replace(/\\/g, '\\\\').replace(/"/g, '\\"')}"`;
  }
  
  if (typeof obj === 'number') return String(obj);
  if (typeof obj === 'boolean') return obj ? 'true' : 'false';
  
  if (typeof obj === 'object') {
    const entries = Object.entries(obj);
    if (entries.length === 0) return '{}';
    
    const fields = entries.map(([key, value]) => {
      return `${ind2}${key}: ${buildSurQLObject(value, indent + 1)}`;
    }).join(',\n');
    
    return `{\n${fields}\n${ind}}`;
  }
  
  return 'NONE';
}

// ============================================================
// IMPORT PRINCIPAL
// ============================================================

async function importCompanies() {
  console.log('='.repeat(100));
  console.log('IMPORT SIRENE → SurrealDB (JavaScript)');
  console.log('='.repeat(100));
  console.log();

  // Checkpoint
  let checkpoint = await loadCheckpoint();
  if (CONFIG.RESET_CHECKPOINT) {
    checkpoint = { last_processed: 0, total_imported: 0, errors: 0 };
    await saveCheckpoint(checkpoint);
    console.log('♻️ Checkpoint réinitialisé\n');
  }

  const startLine = checkpoint.last_processed;
  let totalImported = checkpoint.total_imported;
  let totalErrors = checkpoint.errors;

  // Connexion SurrealDB
  console.log('📡 Connexion à SurrealDB...');
  const db = new Surreal();
  await db.connect(CONFIG.SURREALDB_URL);
  await db.signin({ username: CONFIG.SURREALDB_USER, password: CONFIG.SURREALDB_PASSWORD });
  await db.use({ namespace: CONFIG.SURREALDB_NS, database: CONFIG.SURREALDB_DB });
  console.log('   ✅ Connecté\n');

  // Test d'écriture
  console.log('🧪 Test d\'écriture...');
  try {
    const testRes = await db.query('CREATE import_probe CONTENT { ok: true, at: time::now() };');
    console.log('   ✅ Test réussi\n');
  } catch (e) {
    console.error('   ❌ Test échoué:', e.message);
    process.exit(1);
  }

  // Traitement du fichier
  const startTime = Date.now();
  let currentLine = 0;
  let batch = [];

  const fileStream = createReadStream(CONFIG.SIRENE_FILE, { encoding: 'utf-8' });
  const rl = createInterface({ input: fileStream, crlfDelay: Infinity });

  console.log(`🚀 Début de l'import (reprise ligne ${startLine.toLocaleString()})\n`);

  for await (const rawLine of rl) {
    currentLine++;
    
    // Skip déjà traité
    if (currentLine <= startLine) continue;

    try {
      const data = JSON.parse(rawLine);
      const company = convertSireneToCompany(data);
      
      if (!company || !company.identifiers?.siren) {
        totalErrors++;
        await logError(currentLine, rawLine, 'SIREN invalide ou manquant');
        continue;
      }

      const siren = company.identifiers.siren;
      const query = buildCreateQuery(siren, company);
      batch.push(query);

      // Exécution par batch
      if (batch.length >= CONFIG.BATCH_SIZE) {
        try {
          const batchQuery = batch.join('\n');
          await db.query(batchQuery);
          totalImported += batch.length;
          batch = [];
        } catch (e) {
          console.error(`\n❌ Erreur batch (ligne ${currentLine.toLocaleString()}):`, e.message);
          console.log('🔎 Décomposition du batch...');
          
          // Réessayer ligne par ligne
          for (const query of batch) {
            try {
              await db.query(query);
              totalImported++;
            } catch (e2) {
              totalErrors++;
              await logError(currentLine, rawLine, e2.message);
            }
          }
          batch = [];
        }
      }

      // Affichage progression
      if (currentLine % 1000 === 0) {
        const elapsed = (Date.now() - startTime) / 1000;
        const rate = (currentLine - startLine) / elapsed;
        const etaH = ((CONFIG.TOTAL_ESTIMATED - currentLine) / rate / 3600) || 0;
        
        console.log(
          `📊 ${currentLine.toLocaleString().padStart(10)} lignes | ` +
          `✅ ${totalImported.toLocaleString().padStart(10)} importées | ` +
          `❌ ${totalErrors.toLocaleString().padStart(8)} erreurs | ` +
          `⚡ ${Math.round(rate).toLocaleString().padStart(6)}/s | ` +
          `⏳ ETA: ${etaH.toFixed(1)}h`
        );
      }

      // Checkpoint
      if (currentLine % CONFIG.CHECKPOINT_EVERY === 0) {
        await saveCheckpoint({
          last_processed: currentLine,
          total_imported: totalImported,
          errors: totalErrors,
          timestamp: new Date().toISOString(),
        });
        console.log(`   💾 Checkpoint @ ${currentLine.toLocaleString()}`);
      }

    } catch (e) {
      totalErrors++;
      await logError(currentLine, rawLine, e.message);
    }
  }

  // Dernier batch
  if (batch.length > 0) {
    try {
      await db.query(batch.join('\n'));
      totalImported += batch.length;
    } catch (e) {
      console.error(`\n❌ Erreur dernier batch:`, e.message);
      for (const query of batch) {
        try {
          await db.query(query);
          totalImported++;
        } catch (e2) {
          totalErrors++;
        }
      }
    }
  }

  // Checkpoint final
  await saveCheckpoint({
    last_processed: currentLine,
    total_imported: totalImported,
    errors: totalErrors,
    timestamp: new Date().toISOString(),
  });

  // Rapport final
  const totalElapsed = (Date.now() - startTime) / 1000;
  console.log('\n' + '='.repeat(100));
  console.log('✅ IMPORT TERMINÉ');
  console.log('='.repeat(100));
  console.log(`📊 Lignes traitées       : ${currentLine.toLocaleString()}`);
  console.log(`✅ Entreprises importées : ${totalImported.toLocaleString()}`);
  console.log(`❌ Erreurs               : ${totalErrors.toLocaleString()}`);
  console.log(`⏱️  Temps écoulé          : ${(totalElapsed / 3600).toFixed(2)} heures`);
  console.log(`⚡ Vitesse moyenne       : ${Math.round((currentLine - startLine) / totalElapsed).toLocaleString()} enr/s`);
  console.log('='.repeat(100));

  await db.close();
}

// ============================================================
// MAIN
// ============================================================

importCompanies().catch(err => {
  console.error('💥 Erreur fatale:', err);
  process.exit(1);
});

