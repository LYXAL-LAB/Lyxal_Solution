#!/usr/bin/env node
// Suppression de TOUS les enregistrements business_company

import Surreal from 'surrealdb';

const CONFIG = {
  URL: 'wss://lyxal-06bsd9k399ou7e5fa4tblm6b3g.aws-euw1.surreal.cloud/rpc',
  USER: 'admin',
  PASSWORD: 'admin',
  NS: 'Lyxal_Solution',
  DB: 'Labs',
};

async function deleteAllCompanies() {
  console.log('🗑️  SUPPRESSION DE TOUS LES ENREGISTREMENTS business_company');
  console.log('='.repeat(80));
  console.log();

  // Connexion
  console.log('📡 Connexion à SurrealDB...');
  const db = new Surreal();
  await db.connect(CONFIG.URL);
  await db.signin({ username: CONFIG.USER, password: CONFIG.PASSWORD });
  await db.use({ namespace: CONFIG.NS, database: CONFIG.DB });
  console.log('   ✅ Connecté\n');

  // Compter les enregistrements avant
  console.log('📊 Comptage des enregistrements...');
  try {
    const countResult = await db.query('SELECT count() FROM business_company GROUP ALL;');
    const count = countResult?.[0]?.result?.[0]?.count || 0;
    console.log(`   📦 Enregistrements trouvés : ${count.toLocaleString()}\n`);
    
    if (count === 0) {
      console.log('✅ La table est déjà vide !\n');
      await db.close();
      return;
    }
  } catch (e) {
    console.log(`   ⚠️ Impossible de compter (peut-être vide) : ${e.message}\n`);
  }

  // Suppression
  console.log('🔥 Suppression en cours...');
  console.log('   (Cela peut prendre quelques minutes pour 1.3M+ enregistrements)');
  console.log();

  const startTime = Date.now();
  
  try {
    // DELETE supprime tous les enregistrements
    const result = await db.query('DELETE business_company;');
    
    const elapsed = (Date.now() - startTime) / 1000;
    console.log(`\n✅ SUPPRESSION TERMINÉE en ${elapsed.toFixed(1)}s`);
    console.log('='.repeat(80));
  } catch (e) {
    console.error('❌ Erreur lors de la suppression:', e.message);
    console.log('\n🔧 Tentative alternative : REMOVE TABLE...');
    
    try {
      await db.query('REMOVE TABLE business_company;');
      console.log('✅ Table supprimée avec REMOVE TABLE');
      console.log('⚠️ N\'oublie pas de recréer la table avec le schéma !');
    } catch (e2) {
      console.error('❌ Échec également avec REMOVE TABLE:', e2.message);
    }
  }

  // Vérification
  console.log('\n📊 Vérification...');
  try {
    const countResult = await db.query('SELECT count() FROM business_company GROUP ALL;');
    const count = countResult?.[0]?.result?.[0]?.count || 0;
    console.log(`   📦 Enregistrements restants : ${count.toLocaleString()}`);
    
    if (count === 0) {
      console.log('   ✅ Tous les enregistrements ont été supprimés !');
    } else {
      console.log(`   ⚠️ Il reste encore ${count.toLocaleString()} enregistrements`);
    }
  } catch (e) {
    console.log('   ✅ Table vide ou supprimée');
  }

  await db.close();
  console.log('\n='.repeat(80));
}

deleteAllCompanies().catch(err => {
  console.error('💥 Erreur fatale:', err);
  process.exit(1);
});

