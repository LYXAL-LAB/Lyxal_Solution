#!/usr/bin/env node
// SUPPRESSION IMMÉDIATE de business_company

import Surreal from 'surrealdb';

const CONFIG = {
  URL: 'wss://lyxal-06bsd9k399ou7e5fa4tblm6b3g.aws-euw1.surreal.cloud/rpc',
  USER: 'admin',
  PASSWORD: 'admin',
  NS: 'Lyxal_Solution',
  DB: 'Labs',
  TABLE: 'business_company',
};

async function deleteNow() {
  console.log('🔥 SUPPRESSION EN COURS...\n');

  const db = new Surreal();
  await db.connect(CONFIG.URL);
  await db.signin({ username: CONFIG.USER, password: CONFIG.PASSWORD });
  await db.use({ namespace: CONFIG.NS, database: CONFIG.DB });
  console.log('✅ Connecté\n');

  // Comptage avant
  try {
    const countResult = await db.query(`SELECT count() FROM ${CONFIG.TABLE} GROUP ALL;`);
    const count = countResult?.[0]?.result?.[0]?.count || 0;
    console.log(`📦 Avant: ${count.toLocaleString()} enregistrements\n`);
  } catch (e) {
    console.log(`⚠️ Comptage impossible: ${e.message}\n`);
  }

  // SUPPRESSION
  console.log('🗑️  DELETE en cours...');
  const startTime = Date.now();
  
  try {
    await db.query(`DELETE ${CONFIG.TABLE};`);
    const elapsed = (Date.now() - startTime) / 1000;
    console.log(`✅ Supprimé en ${elapsed.toFixed(1)}s\n`);
  } catch (e) {
    console.log(`❌ Erreur: ${e.message}\n`);
    
    // Essayer REMOVE TABLE
    console.log('🔧 Essai avec REMOVE TABLE...');
    try {
      await db.query(`REMOVE TABLE ${CONFIG.TABLE};`);
      console.log('✅ Table supprimée avec REMOVE TABLE\n');
    } catch (e2) {
      console.log(`❌ Échec: ${e2.message}\n`);
    }
  }

  // Vérification
  try {
    const countResult = await db.query(`SELECT count() FROM ${CONFIG.TABLE} GROUP ALL;`);
    const count = countResult?.[0]?.result?.[0]?.count || 0;
    console.log(`📦 Après: ${count.toLocaleString()} enregistrements\n`);
    
    if (count === 0) {
      console.log('✅ TOUT EST SUPPRIMÉ !');
    } else {
      console.log(`⚠️ Il reste ${count.toLocaleString()} enregistrements`);
    }
  } catch (e) {
    console.log('✅ Table vide ou inexistante');
  }

  await db.close();
}

deleteNow().catch(err => {
  console.error('💥 Erreur:', err);
  process.exit(1);
});

