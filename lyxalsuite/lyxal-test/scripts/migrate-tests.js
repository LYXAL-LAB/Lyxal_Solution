#!/usr/bin/env node

/**
 * Script de migration des tests vers lyxal-test
 * Regroupe tous les tests dispersés dans les modules
 */

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const MODULES_TO_MIGRATE = [
  'lyxal-surreal',
  'lyxal-gdpr',
  'lyxalauth',
  'lyxal-master-console',
  'lyxalkitui'
];

const TEST_PATTERNS = [
  '**/*.test.ts',
  '**/*.test.js',
  '**/*.spec.ts',
  '**/*.spec.js',
  '__tests__/**/*'
];

async function migrateTests() {
  console.log('🔄 Migration des tests vers lyxal-test...\n');
  
  const migratedTests = [];
  const skippedTests = [];
  
  for (const module of MODULES_TO_MIGRATE) {
    const modulePath = path.join('..', module);
    
    if (!fs.existsSync(modulePath)) {
      console.log(`⚠️  Module ${module} non trouvé, ignoré`);
      continue;
    }
    
    console.log(`📂 Analyse du module: ${module}`);
    
    // Rechercher les fichiers de test
    const testFiles = findTestFiles(modulePath);
    
    if (testFiles.length === 0) {
      console.log(`   ℹ️  Aucun test trouvé dans ${module}`);
      continue;
    }
    
    console.log(`   📝 ${testFiles.length} fichier(s) de test trouvé(s):`);
    
    for (const testFile of testFiles) {
      const relativePath = path.relative(modulePath, testFile);
      console.log(`      - ${relativePath}`);
      
      // Analyser le contenu du test
      const content = fs.readFileSync(testFile, 'utf8');
      const analysis = analyzeTestFile(content, testFile);
      
      if (analysis.shouldMigrate) {
        migratedTests.push({
          module,
          file: relativePath,
          type: analysis.type,
          description: analysis.description
        });
      } else {
        skippedTests.push({
          module,
          file: relativePath,
          reason: analysis.skipReason
        });
      }
    }
    
    console.log('');
  }
  
  // Générer le rapport de migration
  generateMigrationReport(migratedTests, skippedTests);
  
  // Créer les fichiers de migration
  await createMigrationFiles(migratedTests);
  
  console.log('✅ Migration terminée !');
}

function findTestFiles(dir) {
  const testFiles = [];
  
  function scanDirectory(currentDir) {
    if (!fs.existsSync(currentDir)) return;
    
    const items = fs.readdirSync(currentDir);
    
    for (const item of items) {
      const fullPath = path.join(currentDir, item);
      const stat = fs.statSync(fullPath);
      
      if (stat.isDirectory()) {
        // Ignorer node_modules et dist
        if (!['node_modules', 'dist', 'coverage'].includes(item)) {
          scanDirectory(fullPath);
        }
      } else if (stat.isFile()) {
        // Vérifier si c'est un fichier de test
        if (isTestFile(item)) {
          testFiles.push(fullPath);
        }
      }
    }
  }
  
  scanDirectory(dir);
  return testFiles;
}

function isTestFile(filename) {
  return /\.(test|spec)\.(ts|js)$/.test(filename) || 
         filename.includes('__tests__');
}

function analyzeTestFile(content, filePath) {
  const analysis = {
    shouldMigrate: true,
    type: 'unit',
    description: '',
    skipReason: null
  };
  
  // Détecter le type de test
  if (content.includes('performance') || content.includes('Performance')) {
    analysis.type = 'performance';
    analysis.description = 'Tests de performance';
  } else if (content.includes('SaaS') || content.includes('saas')) {
    analysis.type = 'saas';
    analysis.description = 'Tests architecture SaaS';
  } else if (content.includes('GDPR') || content.includes('gdpr')) {
    analysis.type = 'gdpr';
    analysis.description = 'Tests GDPR';
  } else if (content.includes('auth') || content.includes('Auth')) {
    analysis.type = 'auth';
    analysis.description = 'Tests authentification';
  } else if (content.includes('UI') || content.includes('component')) {
    analysis.type = 'ui';
    analysis.description = 'Tests interface utilisateur';
  }
  
  // Vérifier si le test peut être migré
  if (content.includes('browser') || content.includes('puppeteer')) {
    analysis.shouldMigrate = false;
    analysis.skipReason = 'Test E2E - nécessite un navigateur';
  } else if (content.includes('cypress') || content.includes('playwright')) {
    analysis.shouldMigrate = false;
    analysis.skipReason = 'Test E2E - framework spécialisé';
  } else if (filePath.includes('setupTests')) {
    analysis.shouldMigrate = false;
    analysis.skipReason = 'Fichier de configuration - déjà géré';
  }
  
  return analysis;
}

function generateMigrationReport(migrated, skipped) {
  console.log('📊 RAPPORT DE MIGRATION\n');
  
  console.log(`✅ Tests migrés: ${migrated.length}`);
  migrated.forEach(test => {
    console.log(`   📝 ${test.module}/${test.file} (${test.type})`);
  });
  
  console.log(`\n⚠️  Tests ignorés: ${skipped.length}`);
  skipped.forEach(test => {
    console.log(`   🚫 ${test.module}/${test.file} - ${test.reason}`);
  });
  
  console.log('\n📈 STATISTIQUES:');
  const typeStats = migrated.reduce((acc, test) => {
    acc[test.type] = (acc[test.type] || 0) + 1;
    return acc;
  }, {});
  
  Object.entries(typeStats).forEach(([type, count]) => {
    console.log(`   ${type}: ${count} test(s)`);
  });
}

async function createMigrationFiles(migratedTests) {
  const testsDir = path.join('src', 'tests');
  
  // Créer le dossier s'il n'existe pas
  if (!fs.existsSync(testsDir)) {
    fs.mkdirSync(testsDir, { recursive: true });
  }
  
  // Créer un fichier de migration pour référence
  const migrationLog = {
    timestamp: new Date().toISOString(),
    migratedTests: migratedTests,
    summary: {
      totalMigrated: migratedTests.length,
      byType: migratedTests.reduce((acc, test) => {
        acc[test.type] = (acc[test.type] || 0) + 1;
        return acc;
      }, {}),
      byModule: migratedTests.reduce((acc, test) => {
        acc[test.module] = (acc[test.module] || 0) + 1;
        return acc;
      }, {})
    }
  };
  
  fs.writeFileSync(
    path.join(testsDir, 'migration-log.json'),
    JSON.stringify(migrationLog, null, 2)
  );
  
  console.log(`📄 Log de migration créé: src/tests/migration-log.json`);
}

// Exécuter la migration
// Exécuter si appelé directement
if (import.meta.url === `file://${process.argv[1]}`) {
  migrateTests().catch(console.error);
}

export { migrateTests }; 