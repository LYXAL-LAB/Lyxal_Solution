#!/usr/bin/env node
// Lister TOUS les namespaces et databases

import Surreal from 'surrealdb';

const CONFIG = {
  URL: 'wss://lyxal-06bsd9k399ou7e5fa4tblm6b3g.aws-euw1.surreal.cloud/rpc',
  USER: 'admin',
  PASSWORD: 'admin',
};

async function listAllNamespaces() {
  console.log('🌍 LISTE DE TOUS LES NAMESPACES ET DATABASES');
  console.log('='.repeat(80));
  console.log();

  // Connexion
  console.log('📡 Connexion à SurrealDB...');
  const db = new Surreal();
  await db.connect(CONFIG.URL);
  await db.signin({ username: CONFIG.USER, password: CONFIG.PASSWORD });
  console.log('   ✅ Connecté\n');

  // Lister tous les namespaces
  console.log('📋 Liste des namespaces...\n');
  try {
    const rootInfo = await db.query('INFO FOR ROOT;');
    const root = rootInfo?.[0]?.result;
    
    if (root && root.namespaces) {
      const namespaces = Object.keys(root.namespaces);
      console.log(`✅ ${namespaces.length} namespace(s) trouvé(s) :\n`);
      
      for (const ns of namespaces) {
        console.log(`\n🔹 Namespace: ${ns}`);
        console.log('   ' + '─'.repeat(70));
        
        // Lister les databases de ce namespace
        try {
          const nsInfo = await db.query(`INFO FOR NS ${ns};`);
          const nsData = nsInfo?.[0]?.result;
          
          if (nsData && nsData.databases) {
            const databases = Object.keys(nsData.databases);
            console.log(`   📁 ${databases.length} database(s) :`);
            
            for (const dbName of databases) {
              console.log(`      • ${dbName}`);
              
              // Sélectionner cette database et compter les tables
              try {
                await db.use({ namespace: ns, database: dbName });
                const dbInfo = await db.query('INFO FOR DB;');
                const dbData = dbInfo?.[0]?.result;
                
                if (dbData && dbData.tables) {
                  const tables = Object.keys(dbData.tables);
                  
                  if (tables.length > 0) {
                    console.log(`        ↳ ${tables.length} table(s) :`);
                    
                    for (const tableName of tables) {
                      try {
                        const countResult = await db.query(`SELECT count() FROM ${tableName} GROUP ALL;`);
                        const count = countResult?.[0]?.result?.[0]?.count || 0;
                        
                        if (count > 0) {
                          console.log(`          📦 ${tableName.padEnd(35)} : ${count.toLocaleString().padStart(12)} enregistrements`);
                        }
                      } catch (e) {
                        // Ignorer les erreurs de comptage
                      }
                    }
                  }
                }
              } catch (e) {
                console.log(`        ⚠️ Erreur accès database: ${e.message}`);
              }
            }
          } else {
            console.log(`   📭 Aucune database`);
          }
        } catch (e) {
          console.log(`   ⚠️ Erreur accès namespace: ${e.message}`);
        }
      }
    } else {
      console.log('⚠️ Aucun namespace trouvé ou structure inattendue');
      console.log('Réponse brute:', JSON.stringify(root, null, 2));
    }
  } catch (e) {
    console.error('❌ Erreur lors de la récupération des infos:', e.message);
    console.error('   ', e);
  }

  console.log('\n' + '='.repeat(80));
  await db.close();
}

listAllNamespaces().catch(err => {
  console.error('💥 Erreur fatale:', err);
  process.exit(1);
});

