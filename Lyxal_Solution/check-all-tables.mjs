#!/usr/bin/env node
// Vérifier TOUTES les tables et leurs comptages

import Surreal from 'surrealdb';

const CONFIG = {
  URL: 'wss://lyxal-06bsd9k399ou7e5fa4tblm6b3g.aws-euw1.surreal.cloud/rpc',
  USER: 'admin',
  PASSWORD: 'admin',
  NS: 'Lyxal_Solution',
  DB: 'Labs',
};

async function checkAllTables() {
  console.log('📊 VÉRIFICATION DE TOUTES LES TABLES');
  console.log('='.repeat(80));
  console.log();

  // Connexion
  console.log('📡 Connexion à SurrealDB...');
  const db = new Surreal();
  await db.connect(CONFIG.URL);
  await db.signin({ username: CONFIG.USER, password: CONFIG.PASSWORD });
  await db.use({ namespace: CONFIG.NS, database: CONFIG.DB });
  console.log('   ✅ Connecté\n');

  // Lister toutes les tables
  console.log('📋 Liste des tables...\n');
  try {
    const infoResult = await db.query('INFO FOR DB;');
    const dbInfo = infoResult?.[0]?.result;
    
    if (dbInfo && dbInfo.tables) {
      console.log(`✅ ${Object.keys(dbInfo.tables).length} tables trouvées :\n`);
      
      // Compter les enregistrements de chaque table
      for (const tableName of Object.keys(dbInfo.tables)) {
        try {
          const countResult = await db.query(`SELECT count() FROM ${tableName} GROUP ALL;`);
          const count = countResult?.[0]?.result?.[0]?.count || 0;
          
          const emoji = count > 0 ? '📦' : '📭';
          console.log(`${emoji} ${tableName.padEnd(40)} : ${count.toLocaleString().padStart(12)} enregistrements`);
          
        } catch (e) {
          console.log(`⚠️ ${tableName.padEnd(40)} : erreur (${e.message})`);
        }
      }
    } else {
      console.log('⚠️ Aucune table trouvée ou structure inattendue');
      console.log('Réponse brute:', JSON.stringify(dbInfo, null, 2));
    }
  } catch (e) {
    console.error('❌ Erreur lors de la récupération des infos:', e.message);
  }

  console.log('\n' + '='.repeat(80));
  console.log(`📊 Namespace : ${CONFIG.NS}`);
  console.log(`📊 Database  : ${CONFIG.DB}`);
  console.log('='.repeat(80));

  await db.close();
}

checkAllTables().catch(err => {
  console.error('💥 Erreur fatale:', err);
  process.exit(1);
});

