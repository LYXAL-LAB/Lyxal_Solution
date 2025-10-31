#!/usr/bin/env node

/**
 * Script de migration automatique des modules vers les configurations centralisées
 * Usage: node migrate-module.js <module-name> [type]
 * 
 * Exemples:
 *   node migrate-module.js lyxal-base node
 *   node migrate-module.js lyxalkitui react
 */

const fs = require('fs');
const path = require('path');

const REACT_MODULES = [
  'lyxal-master-console',
  'lyxalkitui', 
  'lyxal-investor'
];

const NODE_MODULES = [
  'lyxal-surreal',
  'lyxal-base',
  'lyxalauth',
  'lyxal-gdpr',
  'lyxal-config'
];

class ModuleMigrator {
  constructor(moduleName, moduleType) {
    this.moduleName = moduleName;
    this.moduleType = moduleType || this.detectModuleType(moduleName);
    this.modulePath = path.join(__dirname, '..', moduleName);
    
    console.log(`🔄 Migration du module: ${moduleName} (type: ${this.moduleType})`);
  }

  detectModuleType(moduleName) {
    if (REACT_MODULES.includes(moduleName)) return 'react';
    if (NODE_MODULES.includes(moduleName)) return 'node';
    
    // Détection automatique basée sur les fichiers
    const packageJsonPath = path.join(this.modulePath, 'package.json');
    if (fs.existsSync(packageJsonPath)) {
      const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, 'utf8'));
      if (packageJson.dependencies?.react) return 'react';
      if (packageJson.dependencies?.['surrealdb.js']) return 'node';
    }
    
    return 'node'; // Par défaut
  }

  migrate() {
    if (!fs.existsSync(this.modulePath)) {
      console.error(`❌ Module ${this.moduleName} non trouvé`);
      return false;
    }

    console.log('📦 Migration du package.json...');
    this.migratePackageJson();
    
    console.log('⚙️ Migration du tsconfig.json...');
    this.migrateTsConfig();
    
    console.log('🧪 Migration de jest.config.js...');
    this.migrateJestConfig();
    
    console.log('✅ Migration terminée !');
    return true;
  }

  migratePackageJson() {
    const packageJsonPath = path.join(this.modulePath, 'package.json');
    if (!fs.existsSync(packageJsonPath)) return;

    const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, 'utf8'));
    
    // Sauvegarder l'original
    fs.writeFileSync(
      packageJsonPath + '.backup',
      JSON.stringify(packageJson, null, 2)
    );

    // Supprimer les devDependencies communes
    const commonDevDeps = [
      '@types/node', '@types/react', '@types/react-dom', '@types/jest',
      '@typescript-eslint/eslint-plugin', '@typescript-eslint/parser',
      'eslint', 'jest', '@types/jest', 'typescript', 'ts-jest',
      '@testing-library/jest-dom', '@testing-library/react', 
      '@testing-library/user-event', 'babel-jest'
    ];

    if (packageJson.devDependencies) {
      commonDevDeps.forEach(dep => {
        delete packageJson.devDependencies[dep];
      });
      
      // Supprimer devDependencies si vide
      if (Object.keys(packageJson.devDependencies).length === 0) {
        delete packageJson.devDependencies;
      }
    }

    // Mettre à jour les scripts
    if (packageJson.scripts) {
      packageJson.scripts.test = 'jest --config ../.config/jest.config.base.js';
      packageJson.scripts['test:watch'] = 'jest --config ../.config/jest.config.base.js --watch';
      packageJson.scripts['test:coverage'] = 'jest --config ../.config/jest.config.base.js --coverage';
      packageJson.scripts.lint = 'eslint . --config ../.config/eslint.config.base.js';
      packageJson.scripts['lint:fix'] = 'eslint . --config ../.config/eslint.config.base.js --fix';
    }

    // Supprimer les dépendances communes qui sont maintenant dans le workspace
    if (packageJson.dependencies) {
      if (this.moduleType === 'react') {
        delete packageJson.dependencies.react;
        delete packageJson.dependencies['react-dom'];
      }
      delete packageJson.dependencies['surrealdb.js'];
    }

    fs.writeFileSync(packageJsonPath, JSON.stringify(packageJson, null, 2));
    console.log('  ✅ package.json migré');
  }

  migrateTsConfig() {
    const tsconfigPath = path.join(this.modulePath, 'tsconfig.json');
    if (!fs.existsSync(tsconfigPath)) return;

    const tsconfig = JSON.parse(fs.readFileSync(tsconfigPath, 'utf8'));
    
    // Sauvegarder l'original
    fs.writeFileSync(
      tsconfigPath + '.backup',
      JSON.stringify(tsconfig, null, 2)
    );

    // Nouvelle configuration simplifiée
    const newTsConfig = {
      extends: this.moduleType === 'react' 
        ? '../.config/tsconfig.react.json'
        : '../.config/tsconfig.node.json',
      compilerOptions: {
        composite: true
      },
      include: ['src/**/*']
    };

    // Conserver certaines options spécifiques
    if (tsconfig.compilerOptions?.baseUrl) {
      newTsConfig.compilerOptions.baseUrl = tsconfig.compilerOptions.baseUrl;
    }
    
    if (this.moduleType === 'node' && tsconfig.compilerOptions?.outDir) {
      newTsConfig.compilerOptions.outDir = tsconfig.compilerOptions.outDir;
      newTsConfig.compilerOptions.rootDir = tsconfig.compilerOptions.rootDir || './src';
    }

    fs.writeFileSync(tsconfigPath, JSON.stringify(newTsConfig, null, 2));
    console.log('  ✅ tsconfig.json migré');
  }

  migrateJestConfig() {
    const jestConfigPath = path.join(this.modulePath, 'jest.config.js');
    if (fs.existsSync(jestConfigPath)) {
      // Sauvegarder et supprimer (maintenant géré centralement)
      fs.renameSync(jestConfigPath, jestConfigPath + '.backup');
      console.log('  ✅ jest.config.js supprimé (utilise la config centralisée)');
    }
  }
}

// Point d'entrée
if (require.main === module) {
  const [,, moduleName, moduleType] = process.argv;
  
  if (!moduleName) {
    console.error('Usage: node migrate-module.js <module-name> [type]');
    console.error('Types disponibles: react, node');
    process.exit(1);
  }

  const migrator = new ModuleMigrator(moduleName, moduleType);
  const success = migrator.migrate();
  
  if (success) {
    console.log('🎉 Migration réussie !');
    console.log('📋 Prochaines étapes:');
    console.log('  1. Tester la compilation: npm run build');
    console.log('  2. Tester les tests: npm run test');
    console.log('  3. Supprimer les .backup si tout fonctionne');
  } else {
    process.exit(1);
  }
}

module.exports = ModuleMigrator; 