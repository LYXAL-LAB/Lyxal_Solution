#!/usr/bin/env node
// Suppression AGGRESSIVE avec toutes les méthodes possibles

import Surreal from 'surrealdb';
import readline from 'readline';

const CONFIG = {
  URL: 'wss://lyxal-06bsd9k399ou7e5fa4tblm6b3g.aws-euw1.surreal.cloud/rpc',
  USER: 'admin',
  PASSWORD: 'admin',
};

function ask(question) {
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
  });
  
  return new Promise(resolve => {
    rl.question(question, answer => {
      rl.close();
      resolve(answer.trim());
    });
  });
}

async function forceDeleteAll() {
  console.log('🔥 SUPPRESSION FORCÉE DE TOUS LES ENREGISTREMENTS');
  console.log('='.repeat(80));
  console.log();

  // Demander le namespace
  const ns = await ask('📝 Entrez le NAMESPACE (ex: Lyxal_Solution) : ');
  if (!ns) {
    console.log('❌ Namespace requis !');
    process.exit(1);
  }

  // Demander la database
  const dbName = await ask('📝 Entrez la DATABASE (ex: Labs) : ');
  if (!dbName) {
    console.log('❌ Database requise !');
    process.exit(1);
  }

  // Demander la table
  const tableName = await ask('📝 Entrez la TABLE (ex: business_company) : ');
  if (!tableName) {
    console.log('❌ Table requise !');
    process.exit(1);
  }

  console.log();
  console.log('📍 Cible :');
  console.log(`   Namespace : ${ns}`);
  console.log(`   Database  : ${dbName}`);
  console.log(`   Table     : ${tableName}`);
  console.log();

  // Confirmation
  const confirm = await ask('⚠️  ÊTES-VOUS SÛR ? Taper "OUI" pour confirmer : ');
  if (confirm.toUpperCase() !== 'OUI') {
    console.log('❌ Annulé');
    process.exit(0);
  }

  console.log();
  console.log('🚀 Début de la suppression...\n');

  // Connexion
  console.log('📡 Connexion à SurrealDB...');
  const db = new Surreal();
  await db.connect(CONFIG.URL);
  await db.signin({ username: CONFIG.USER, password: CONFIG.PASSWORD });
  await db.use({ namespace: ns, database: dbName });
  console.log('   ✅ Connecté\n');

  // Comptage avant
  console.log('📊 Comptage avant suppression...');
  try {
    const countResult = await db.query(`SELECT count() FROM ${tableName} GROUP ALL;`);
    const count = countResult?.[0]?.result?.[0]?.count || 0;
    console.log(`   📦 ${count.toLocaleString()} enregistrements trouvés\n`);
  } catch (e) {
    console.log(`   ⚠️ Impossible de compter: ${e.message}\n`);
  }

  // Méthode 1: DELETE simple
  console.log('🔧 Méthode 1: DELETE simple...');
  try {
    const startTime = Date.now();
    await db.query(`DELETE ${tableName};`);
    const elapsed = (Date.now() - startTime) / 1000;
    console.log(`   ✅ Réussi en ${elapsed.toFixed(1)}s\n`);
  } catch (e) {
    console.log(`   ❌ Échec: ${e.message}\n`);
    
    // Méthode 2: DELETE avec WHERE true
    console.log('🔧 Méthode 2: DELETE WHERE true...');
    try {
      await db.query(`DELETE ${tableName} WHERE true;`);
      console.log(`   ✅ Réussi\n`);
    } catch (e2) {
      console.log(`   ❌ Échec: ${e2.message}\n`);
      
      // Méthode 3: REMOVE TABLE puis DEFINE TABLE
      console.log('🔧 Méthode 3: REMOVE TABLE...');
      try {
        await db.query(`REMOVE TABLE ${tableName};`);
        console.log(`   ✅ Table supprimée`);
        console.log(`   ⚠️ N'oublie pas de recréer le schéma !\n`);
      } catch (e3) {
        console.log(`   ❌ Échec: ${e3.message}\n`);
        
        // Méthode 4: Suppression par batch
        console.log('🔧 Méthode 4: Suppression par batch de 10000...');
        try {
          let deleted = 0;
          let iteration = 0;
          const BATCH_SIZE = 10000;
          
          while (true) {
            iteration++;
            const result = await db.query(`DELETE ${tableName} LIMIT ${BATCH_SIZE};`);
            const batchDeleted = result?.[0]?.result?.length || 0;
            
            if (batchDeleted === 0) {
              break;
            }
            
            deleted += batchDeleted;
            console.log(`   🔄 Batch ${iteration}: ${deleted.toLocaleString()} supprimés...`);
            
            if (iteration > 1000) {
              console.log('   ⚠️ Trop d'itérations, arrêt');
              break;
            }
          }
          
          console.log(`   ✅ Total supprimé: ${deleted.toLocaleString()}\n`);
        } catch (e4) {
          console.log(`   ❌ Échec: ${e4.message}\n`);
        }
      }
    }
  }

  // Vérification finale
  console.log('📊 Vérification finale...');
  try {
    const countResult = await db.query(`SELECT count() FROM ${tableName} GROUP ALL;`);
    const count = countResult?.[0]?.result?.[0]?.count || 0;
    console.log(`   📦 ${count.toLocaleString()} enregistrements restants`);
    
    if (count === 0) {
      console.log('   ✅ TOUS LES ENREGISTREMENTS ONT ÉTÉ SUPPRIMÉS !');
    } else {
      console.log(`   ⚠️ Il reste encore ${count.toLocaleString()} enregistrements`);
    }
  } catch (e) {
    console.log('   ✅ Table vide ou supprimée');
  }

  await db.close();
  console.log('\n' + '='.repeat(80));
  console.log('✅ TERMINÉ');
  console.log('='.repeat(80));
}

forceDeleteAll().catch(err => {
  console.error('💥 Erreur fatale:', err);
  process.exit(1);
});

