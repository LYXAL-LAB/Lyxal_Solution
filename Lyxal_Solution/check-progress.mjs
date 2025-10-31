#!/usr/bin/env node
// Vérifier la progression de l'import SIRENE

import fs from 'node:fs';
import Surreal from 'surrealdb';

const CONFIG = {
  URL: 'wss://lyxal-06bsd9k399ou7e5fa4tblm6b3g.aws-euw1.surreal.cloud/rpc',
  USER: 'admin',
  PASSWORD: 'admin',
  NS: 'Lyxal_Solution',
  DB: 'Labs',
  TABLE: 'business_company',
  TOTAL_EXPECTED: 28760238,
};

async function checkProgress() {
  console.log('📊 PROGRESSION DE L\'IMPORT SIRENE');
  console.log('='.repeat(80));
  console.log();

  // Lire le checkpoint
  let checkpoint = null;
  if (fs.existsSync('import_checkpoint.json')) {
    try {
      const data = fs.readFileSync('import_checkpoint.json', 'utf-8');
      checkpoint = JSON.parse(data);
      
      console.log('📄 Checkpoint :');
      console.log(`   Lignes traitées : ${checkpoint.last_processed.toLocaleString()}`);
      console.log(`   Importées       : ${checkpoint.total_imported.toLocaleString()}`);
      console.log(`   Erreurs         : ${checkpoint.errors.toLocaleString()}`);
      console.log(`   Dernière MAJ    : ${new Date(checkpoint.timestamp).toLocaleString('fr-FR')}`);
      
      const progress = (checkpoint.last_processed / CONFIG.TOTAL_EXPECTED * 100).toFixed(2);
      console.log(`   Progression     : ${progress}%`);
      console.log();
    } catch (e) {
      console.log('⚠️ Checkpoint illisible\n');
    }
  } else {
    console.log('📄 Pas de checkpoint (import pas encore démarré ou terminé)\n');
  }

  // Compter dans la database
  console.log('📦 Vérification SurrealDB...');
  try {
    const db = new Surreal();
    await db.connect(CONFIG.URL);
    await db.signin({ username: CONFIG.USER, password: CONFIG.PASSWORD });
    await db.use({ namespace: CONFIG.NS, database: CONFIG.DB });
    
    const countResult = await db.query(`SELECT count() FROM ${CONFIG.TABLE} GROUP ALL;`);
    const count = countResult?.[0]?.result?.[0]?.count || 0;
    
    console.log(`   Enregistrements en base : ${count.toLocaleString()}`);
    
    const dbProgress = (count / CONFIG.TOTAL_EXPECTED * 100).toFixed(2);
    console.log(`   Progression DB          : ${dbProgress}%`);
    
    await db.close();
  } catch (e) {
    console.log(`   ⚠️ Erreur connexion: ${e.message}`);
  }

  console.log();
  console.log('='.repeat(80));
  console.log(`🎯 Objectif total : ${CONFIG.TOTAL_EXPECTED.toLocaleString()} entreprises`);
  console.log('='.repeat(80));
}

checkProgress().catch(err => {
  console.error('💥 Erreur:', err);
  process.exit(1);
});

