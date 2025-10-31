# Guide de Création de Modules LyxalSuite

## 🎯 Objectif

Ce guide vous accompagne étape par étape pour créer un nouveau module LyxalSuite en respectant l'architecture centralisée. **Suivez scrupuleusement ces étapes pour éviter les régressions architecturales.**

## 📋 Prérequis

- ✅ Avoir lu le **[ARCHITECTURE-REFACTORING-GUIDE.md](./ARCHITECTURE-REFACTORING-GUIDE.md)**
- ✅ Comprendre l'architecture centralisée de LyxalSuite
- ✅ Comprendre le rôle de **lyxal-surreal** comme backend unique
- ✅ Avoir accès au workspace `lyxalsuite/`

## 🗄️ **RÈGLE FONDAMENTALE : lyxal-surreal comme Backend Unique**

**🚨 CRITIQUE : Toute logique de base de données DOIT être centralisée dans `lyxal-surreal`**

### ✅ **Architecture Correcte**

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Votre Module  │───▶│   lyxal-surreal  │───▶│   SurrealDB     │
│                 │    │  (Backend Unique) │    │   (Database)    │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

**Votre module ne doit JAMAIS :**
- ❌ Importer directement `surrealdb` ou `surrealdb.js`
- ❌ Créer sa propre connexion SurrealDB
- ❌ Dupliquer des schémas `.surql` 
- ❌ Implémenter sa propre logique de cache
- ❌ Gérer ses propres namespaces/databases
- ❌ Créer ses propres middlewares SaaS/Workspace

**Votre module doit TOUJOURS :**
- ✅ Utiliser `SurrealClient` de `@lyxal/surreal`
- ✅ Définir ses schémas dans `lyxal-surreal/database/modules/`
- ✅ Utiliser les services centralisés (cache, monitoring, etc.)
- ✅ Respecter l'architecture bicéphale SaaS/Workspace

### 🏗️ **lyxal-surreal : Le Cœur de Données**

`lyxal-surreal` centralise TOUT ce qui concerne les données :

```
lyxal-surreal/
├── database/
│   ├── modules/
│   │   ├── base/              # Tables core
│   │   ├── crm/               # Schémas CRM
│   │   ├── marketing/         # Schémas Marketing
│   │   ├── VOTRE-MODULE/      # ✅ VOS schémas ici
│   │   └── ...
│   ├── monitoring_*.surql     # Monitoring système
│   └── deploy-central.js      # Déploiement unifié
├── model/
│   ├── surrealClient.ts       # Client unique (Singleton)
│   ├── cache.ts              # Cache centralisé
│   ├── performanceMonitor.ts  # Monitoring centralisé
│   └── middlewares.ts         # Middlewares SaaS/Workspace
└── index.ts                   # API publique
```

### 📊 **Exemples Concrets d'Intégration**

#### ❌ **MAUVAIS : Duplication dans le module**
```typescript
// ❌ NE JAMAIS FAIRE CELA dans votre module
import { Surreal } from 'surrealdb';

export class MonModuleService {
  private db = new Surreal(); // ❌ Connexion dupliquée
  
  async connect() {
    await this.db.connect('ws://localhost:8000'); // ❌ Configuration dupliquée
    await this.db.signin({ user: 'admin', pass: 'admin' }); // ❌ Auth dupliquée
  }
  
  async createRecord(data: any) {
    return await this.db.create('ma_table', data); // ❌ Logique dupliquée
  }
}
```

#### ✅ **CORRECT : Utilisation de lyxal-surreal**
```typescript
// ✅ CORRECT - Utilisation du backend centralisé
import { SurrealClient } from '@lyxal/surreal';

export class MonModuleService {
  private client: SurrealClient;
  
  constructor() {
    // ✅ Utilisation du client centralisé (Singleton)
    this.client = SurrealClient.getInstance();
  }
  
  async createRecord(saasId: string, workspaceId: string, data: any) {
    // ✅ Utilisation de l'architecture bicéphale
    await this.client.useWorkspace(saasId, workspaceId);
    
    // ✅ Utilisation du cache centralisé
    return await this.client.cachedQuery(
      'CREATE ma_table CONTENT $data',
      { data },
      `ma_table_${saasId}_${workspaceId}`,
      300 // TTL 5 minutes
    );
  }
  
  async getRecords(saasId: string, workspaceId: string) {
    await this.client.useWorkspace(saasId, workspaceId);
    
    // ✅ Utilisation des métriques centralisées
    const startTime = Date.now();
    const result = await this.client.query('SELECT * FROM ma_table');
    
    // ✅ Le monitoring est automatique via lyxal-surreal
    return result;
  }
}
```

### 🗄️ **Schémas de Base de Données : Centralisation Obligatoire**

#### 📁 **Où placer vos schémas**
```
lyxal-surreal/database/modules/VOTRE-MODULE/
├── votre-module_structure.surql    # Tables et types
├── votre-module_relations.surql    # Relations entre entités
├── votre-module_indexes.surql      # Index de performance
├── votre-module_triggers.surql     # Triggers et événements
└── votre-module_data.surql         # Données de référence
```

#### 📝 **Exemple de schéma centralisé**
```sql
-- lyxal-surreal/database/modules/inventory/inventory_structure.surql

-- ✅ CORRECT - Schéma centralisé dans lyxal-surreal
DEFINE TABLE inventory_items SCHEMAFULL;
DEFINE FIELD name ON inventory_items TYPE string ASSERT $value != NONE;
DEFINE FIELD quantity ON inventory_items TYPE int DEFAULT 0;
DEFINE FIELD saas_id ON inventory_items TYPE string ASSERT $value != NONE;
DEFINE FIELD workspace_id ON inventory_items TYPE string ASSERT $value != NONE;
DEFINE FIELD created_at ON inventory_items TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON inventory_items TYPE datetime DEFAULT time::now();

-- Index pour l'architecture bicéphale
DEFINE INDEX idx_inventory_saas_workspace ON inventory_items COLUMNS saas_id, workspace_id;
DEFINE INDEX idx_inventory_name ON inventory_items COLUMNS name;
```

#### 🚀 **Déploiement automatique**
```bash
# ✅ Vos schémas sont déployés automatiquement
cd lyxal-surreal
npm run deploy:module inventory

# ✅ Ou déploiement complet
npm run deploy:all
```

### 🔧 **Services Centralisés à Utiliser**

#### 1. **Cache Centralisé**
```typescript
// ✅ Utilisation du cache centralisé
import { SurrealClient, queryCache, metadataCache } from '@lyxal/surreal';

export class MonModuleService {
  async getCachedData(key: string) {
    return await queryCache.cached(`mon_module_${key}`, async () => {
      // Logique de récupération des données
      return await this.client.query('SELECT * FROM ma_table');
    }, 300); // TTL 5 minutes
  }
  
  async getMetadata(saasId: string) {
    return await metadataCache.cached(`metadata_${saasId}`, async () => {
      return await this.client.query('SELECT * FROM saas_config WHERE id = $saas', { saas: saasId });
    }, 600); // TTL 10 minutes
  }
}
```

#### 2. **Monitoring Centralisé**
```typescript
// ✅ Le monitoring est automatique via SurrealClient
import { SurrealClient, performanceMonitor } from '@lyxal/surreal';

export class MonModuleService {
  async operationComplexe() {
    // ✅ Le monitoring est automatique
    const result = await this.client.query('SELECT * FROM complex_table');
    
    // ✅ Métriques automatiquement collectées
    const metrics = performanceMonitor.getMetrics();
    console.log(`Temps de réponse moyen: ${metrics.avgResponseTime}ms`);
    
    return result;
  }
}
```

#### 3. **Architecture Bicéphale Automatique**
```typescript
// ✅ Architecture SaaS/Workspace intégrée
import { SurrealClient } from '@lyxal/surreal';

export class MonModuleService {
  async operationSaaS(saasId: string, data: any) {
    // ✅ Changement automatique de namespace
    await this.client.useSaaS(saasId);
    return await this.client.create('saas_config', data);
  }
  
  async operationWorkspace(saasId: string, workspaceId: string, data: any) {
    // ✅ Changement automatique de namespace + database
    await this.client.useWorkspace(saasId, workspaceId);
    return await this.client.create('workspace_data', data);
  }
}
```

### 🚨 **Anti-Patterns à Éviter Absolument**

#### ❌ **Duplication de Configuration**
```typescript
// ❌ NE JAMAIS FAIRE
const config = {
  url: 'ws://localhost:8000',
  user: 'admin',
  pass: 'admin'
}; // Configuration dupliquée !
```

#### ❌ **Schémas Dispersés**
```
mon-module/
├── database/           # ❌ Schémas isolés
│   └── schema.surql    # ❌ Duplication
└── src/
```

#### ❌ **Cache Personnel**
```typescript
// ❌ NE JAMAIS FAIRE
class MonCache {
  private cache = new Map(); // ❌ Cache dupliqué
}
```

#### ❌ **Middlewares Personnels**
```typescript
// ❌ NE JAMAIS FAIRE
function monSaaSMiddleware() {
  // ❌ Logique SaaS dupliquée
}
```

### ✅ **Pattern d'Intégration Recommandé**

```typescript
// ✅ Template parfait pour votre service
import { SurrealClient } from '@lyxal/surreal';

export class VotreModuleService {
  private client: SurrealClient;
  
  constructor() {
    this.client = SurrealClient.getInstance();
  }
  
  // ✅ Méthodes SaaS (niveau tenant)
  async createSaaSResource(saasId: string, data: any) {
    await this.client.useSaaS(saasId);
    return await this.client.create('votre_table_saas', {
      ...data,
      saas_id: saasId,
      created_at: new Date().toISOString()
    });
  }
  
  // ✅ Méthodes Workspace (niveau application)
  async createWorkspaceResource(saasId: string, workspaceId: string, data: any) {
    await this.client.useWorkspace(saasId, workspaceId);
    return await this.client.cachedQuery(
      'CREATE votre_table_workspace CONTENT $data',
      { 
        data: {
          ...data,
          saas_id: saasId,
          workspace_id: workspaceId,
          created_at: new Date().toISOString()
        }
      },
      `votre_table_${saasId}_${workspaceId}`,
      300 // Cache 5 minutes
    );
  }
  
  // ✅ Méthodes avec gestion d'erreurs centralisée
  async getResources(saasId: string, workspaceId: string) {
    try {
      await this.client.useWorkspace(saasId, workspaceId);
      
      return await this.client.cachedQuery(
        `SELECT * FROM votre_table_workspace 
         WHERE saas_id = $saas AND workspace_id = $workspace 
         ORDER BY created_at DESC`,
        { saas: saasId, workspace: workspaceId },
        `resources_${saasId}_${workspaceId}`,
        600 // Cache 10 minutes
      );
    } catch (error) {
      // ✅ Gestion d'erreurs centralisée via lyxal-surreal
      throw error; // Les erreurs sont automatiquement typées et loggées
    }
  }
}
```

## 🚀 Étapes de Création

### 1. Planification du Module

#### Questions à se poser :
- **Quel est le rôle** de ce module ?
- **Type de module** : Node.js, React, ou hybride ?
- **Dépendances spécifiques** nécessaires ?
- **Intégration SurrealDB** requise ?

#### Nommage :
- **Format obligatoire** : `lyxal-nom-du-module`
- **Exemples valides** : `lyxal-inventory`, `lyxal-reporting`, `lyxal-analytics`

### 1.5 🎯 **Règles d'Imports - ARCHITECTURE WORKSPACE**

**🚨 IMPORTANT : Bonnes pratiques d'imports dans le workspace**

#### ✅ **À FAIRE - Imports Propres**

**1. Utiliser des alias TypeScript (PAS de chemins relatifs)**
```typescript
// ✅ CORRECT - Alias configurés
import { SurrealClient } from '@lyxal/surreal';
import { AuthService } from '@lyxal/auth';
import { TestHelpers } from '@lyxal/test';

// ❌ INCORRECT - Chemins relatifs
import { SurrealClient } from '../lyxal-surreal/src/index';
import { AuthService } from '../../lyxalauth/src/services';
```

**2. Imports directs entre modules du workspace**
```typescript
// ✅ CORRECT - Import direct (même workspace)
import { UserService } from '@lyxal/base';
import { GDPRService } from '@lyxal/gdpr';

// ❌ INCORRECT - Import npm (réservé aux packages externes)
// Ces modules sont dans le même workspace !
```

**3. Configuration des alias dans tsconfig.json**
```json
{
  "extends": "../.config/tsconfig.node.json",
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@lyxal/surreal": ["../lyxal-surreal/src"],
      "@lyxal/auth": ["../lyxalauth/src"],
      "@lyxal/base": ["../lyxal-base/src"],
      "@lyxal/test": ["../lyxal-test/src"],
      "@lyxal/ui": ["../lyxalkitui/src"],
      "@lyxal/gdpr": ["../lyxal-gdpr/src"],
      "@/*": ["./src/*"]
    }
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
```

#### ❌ **À ÉVITER - Anti-patterns**

```typescript
// ❌ Chemins relatifs longs et fragiles
import { something } from '../../../other-module/src/services';

// ❌ Imports npm pour modules du workspace
import { UserService } from '@lyxalsuite/lyxal-base'; // C'est dans le workspace !

// ❌ Mélange d'alias et chemins relatifs
import { SurrealClient } from '@lyxal/surreal';
import { AuthService } from '../lyxalauth/src'; // Incohérent !
```

#### 🎯 **Mapping des Alias Standards**

| Module | Alias | Import |
|--------|--------|---------|
| `lyxal-surreal` | `@lyxal/surreal` | `import { SurrealClient } from '@lyxal/surreal'` |
| `lyxalauth` | `@lyxal/auth` | `import { AuthService } from '@lyxal/auth'` |
| `lyxal-base` | `@lyxal/base` | `import { BaseService } from '@lyxal/base'` |
| `lyxalkitui` | `@lyxal/ui` | `import { Button } from '@lyxal/ui'` |
| `lyxal-test` | `@lyxal/test` | `import { createTestEnv } from '@lyxal/test'` |
| `lyxal-gdpr` | `@lyxal/gdpr` | `import { GDPRService } from '@lyxal/gdpr'` |
| **Votre module** | `@lyxal/nouveau-module` | `import { Service } from '@lyxal/nouveau-module'` |

### 2. Création de la Structure

#### 2.1 Créer le Dossier
```bash
cd lyxalsuite
mkdir lyxal-nouveau-module
cd lyxal-nouveau-module
```

#### 2.2 Structure de Base
```
lyxal-nouveau-module/
├── src/
│   ├── index.ts          ← Point d'entrée principal
│   ├── types/            ← Types TypeScript
│   ├── services/         ← Services métier
│   └── utils/            ← Utilitaires
├── package.json          ← Configuration minimale
├── tsconfig.json         ← Configuration minimale
└── README.md             ← Documentation du module

⚠️  PAS de dossier __tests__/ - Tests centralisés dans lyxal-test/
```

### 3. Fichiers de Configuration

#### 3.1 Package.json Minimal
```json
{
  "name": "@lyxalsuite/lyxal-nouveau-module",
  "version": "1.0.0",
  "description": "Description claire du module",
  "type": "module",
  "main": "dist/index.js",
  "types": "dist/index.d.ts",
  "scripts": {
    "build": "tsc",
    "dev": "tsc --watch",
    "clean": "rimraf dist"
  },
  "keywords": [
    "lyxalsuite",
    "module-specifique"
  ],
  "author": "LyxalSuite",
  "license": "MIT",
  "dependencies": {
    // SEULEMENT les dépendances spécifiques au module
    // Exemple : "@lyxalsuite/lyxal-surreal": "^1.0.0"
  }
}
```

#### 3.2 TSConfig.json Minimal

**Pour un module Node.js :**
```json
{
  "extends": "../.config/tsconfig.node.json",
  "compilerOptions": {
    "outDir": "./dist",
    "rootDir": "./src",
    "baseUrl": ".",
    "paths": {
      "@lyxal/surreal": ["../lyxal-surreal/src"],
      "@lyxal/auth": ["../lyxalauth/src"],
      "@lyxal/base": ["../lyxal-base/src"],
      "@lyxal/test": ["../lyxal-test/src"],
      "@lyxal/ui": ["../lyxalkitui/src"],
      "@lyxal/gdpr": ["../lyxal-gdpr/src"],
      "@/*": ["./src/*"]
    }
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
```

**Pour un module React :**
```json
{
  "extends": "../.config/tsconfig.react.json",
  "compilerOptions": {
    "outDir": "./dist",
    "rootDir": "./src",
    "baseUrl": ".",
    "paths": {
      "@lyxal/surreal": ["../lyxal-surreal/src"],
      "@lyxal/auth": ["../lyxalauth/src"],
      "@lyxal/base": ["../lyxal-base/src"],
      "@lyxal/test": ["../lyxal-test/src"],
      "@lyxal/ui": ["../lyxalkitui/src"],
      "@lyxal/gdpr": ["../lyxal-gdpr/src"],
      "@/*": ["./src/*"]
    }
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
```

⚠️ **IMPORTANT :** Les alias permettent d'éviter les chemins relatifs fragiles comme `../../../autre-module`

### 4. Code de Base

#### 4.1 src/index.ts
```typescript
/**
 * Module Lyxal Nouveau Module
 * Description: Fonctionnalité principale du module
 */

export * from './types';
export * from './services';
export * from './utils';

// Point d'entrée principal
export const MODULE_NAME = '@lyxalsuite/lyxal-nouveau-module';
export const MODULE_VERSION = '1.0.0';
```

#### 4.2 src/types/index.ts
```typescript
/**
 * Types TypeScript pour le module
 */

export interface ModuleConfig {
  // Configuration du module
}

export interface ModuleResponse {
  // Réponses du module
}
```

#### 4.3 ⚠️ Tests - ARCHITECTURE CENTRALISÉE

**🚨 IMPORTANT : Ne PAS créer de dossier `__tests__/` dans le module !**

**Tous les tests sont centralisés dans `lyxal-test/`**

Pour ajouter des tests pour votre module :

1. **Éditer** `lyxal-test/src/tests/[category].test.ts` (ex: `auth.test.ts`, `ui.test.tsx`)
2. **Ou créer** un nouveau fichier de test si nécessaire

```typescript
// Dans lyxal-test/src/tests/nouveau-module.test.ts
// ✅ CORRECT - Utilisation d'alias pour les tests
import { createTestEnvironment, generateTestId } from '@lyxal/test';
import { MODULE_NAME, MODULE_VERSION } from '@lyxal/nouveau-module';

describe('🆕 Nouveau Module - LyxalSuite', () => {
  let testEnv: ReturnType<typeof createTestEnvironment>;

  beforeAll(() => {
    testEnv = createTestEnvironment('nouveau-module-tests');
  });

  afterAll(async () => {
    await testEnv.teardown();
  });

  test('should export module name and version', () => {
    expect(MODULE_NAME).toBe('@lyxalsuite/lyxal-nouveau-module');
    expect(MODULE_VERSION).toBe('1.0.0');
    
    console.log(`✅ Module validé: ${MODULE_NAME} v${MODULE_VERSION}`);
  });

  test('should integrate with test environment', () => {
    const testId = generateTestId('module');
    expect(testId).toContain('module_');
    expect(testEnv.testId).toBeDefined();
    
    console.log(`🧪 Test environment: ${testEnv.testId}`);
  });
});
```

### 5. Intégration au Workspace

#### 5.1 Ajouter au Workspace Principal
Éditer `lyxalsuite/package.json` :
```json
{
  "workspaces": [
    "lyxal-*",
    "lyxal-nouveau-module"  // Ajouter cette ligne
  ]
}
```

#### 5.2 Installation des Dépendances
```bash
cd lyxalsuite
npm install
```

### 6. Intégration SurrealDB (Si Nécessaire)

#### 6.1 Schémas de Base de Données
Créer : `lyxal-surreal/database/modules/nouveau-module/`
```sql
-- nouveau_module_schema.surql
DEFINE TABLE nouveau_module SCHEMAFULL;
DEFINE FIELD name ON nouveau_module TYPE string;
DEFINE FIELD created_at ON nouveau_module TYPE datetime DEFAULT time::now();
```

#### 6.2 Utilisation du Client SurrealDB
```typescript
// ✅ CORRECT - Utilisation d'alias
import { SurrealClient } from '@lyxal/surreal';

export class NouveauModuleService {
  private db: SurrealClient;

  constructor() {
    this.db = new SurrealClient();
  }

  async createRecord(data: any) {
    return await this.db.create('nouveau_module', data);
  }
}
```

### 7. Tests et Validation

#### 7.1 Ajouter les Tests (Module lyxal-test)
```bash
cd lyxalsuite/lyxal-test

# Créer les tests pour votre module
# Option 1: Ajouter à un fichier existant
code src/tests/[category].test.ts

# Option 2: Créer un nouveau fichier de test
code src/tests/nouveau-module.test.ts
```

#### 7.2 Exécuter les Tests
```bash
# Tous les tests
npm test

# Tests spécifiques
npm test -- --testNamePattern="Nouveau Module"

# Tests en mode watch
npm run test:watch
```

#### 7.3 Build du Module
```bash
cd lyxalsuite
npm run build:lyxal-nouveau-module
```

#### 7.4 Vérifications Finales
```bash
# Vérifier qu'aucun package-lock.json n'a été créé
find lyxal-nouveau-module -name "package-lock.json"

# Vérifier qu'aucun node_modules n'a été créé
find lyxal-nouveau-module -name "node_modules"

# Vérifier qu'aucun dossier __tests__ n'a été créé
find lyxal-nouveau-module -name "__tests__"
```

## ✅ Checklist de Validation

Avant de considérer le module comme terminé :

- [ ] **Structure** : Dossier créé avec la bonne structure (SANS __tests__)
- [ ] **Package.json** : Minimal et conforme (SANS scripts test)
- [ ] **TSConfig** : Étend les configurations centralisées
- [ ] **Workspace** : Ajouté au workspace principal
- [ ] **Tests** : Ajoutés dans lyxal-test/src/tests/ (PAS dans le module)
- [ ] **Build** : Compilation réussie
- [ ] **Pas de redondances** : Aucun package-lock.json, node_modules, ou __tests__ local
- [ ] **Documentation** : README.md du module créé
- [ ] **SurrealDB** : Schémas centralisés si nécessaire
- [ ] **Tests fonctionnels** : Tests exécutés avec succès depuis lyxal-test

## 🚨 Erreurs Communes à Éviter

1. **❌ Créer un dossier `__tests__/`** dans le module (tests centralisés dans lyxal-test)
2. **❌ Créer un package-lock.json** dans le module
3. **❌ Dupliquer les devDependencies** du workspace
4. **❌ Installer npm install** dans le module directement
5. **❌ Créer un tsconfig.json complet** au lieu d'étendre
6. **❌ Oublier d'ajouter** au workspace principal
7. **❌ Ajouter des scripts test** dans le package.json du module
8. **❌ Utiliser des chemins relatifs** au lieu d'alias (`../../../module` → `@lyxal/module`)
9. **❌ Importer via npm** des modules du même workspace (`@lyxalsuite/module` → `@lyxal/module`)
10. **❌ Mélanger alias et chemins relatifs** dans le même fichier

## 🧪 Architecture des Tests - Points Clés

### ✅ À FAIRE :
- Ajouter les tests dans `lyxal-test/src/tests/`
- Utiliser les helpers centralisés (`@lyxal-test/helpers`)
- Utiliser les fixtures centralisées (`@lyxal-test/fixtures`)
- Utiliser les mocks centralisés (`@lyxal-test/mocks`)
- Suivre le pattern de nommage : `describe('🆕 Nom Module - LyxalSuite')`

### ❌ À ÉVITER :
- Créer des dossiers `__tests__/` dans les modules
- Dupliquer les configurations Jest
- Installer Jest ou des outils de test dans les modules
- Créer des mocks ou fixtures spécifiques au module

### 📁 Où Ajouter Vos Tests :

| Type de Module | Fichier de Test | Exemple |
|----------------|-----------------|---------|
| **Authentification** | `auth.test.ts` | Tests de login, JWT, etc. |
| **Interface UI** | `ui.test.tsx` | Tests React, composants |
| **Base de données** | `surreal-advanced.test.ts` | Tests SurrealDB |
| **Performance** | `performance.test.ts` | Tests de charge |
| **GDPR** | `gdpr.test.ts` | Tests conformité |
| **SaaS** | `saas.test.ts` | Tests architecture |
| **Nouveau domaine** | `nouveau-domaine.test.ts` | Nouveau fichier |

### 🛠️ Utilitaires de Test Centralisés

#### Helpers Disponibles
```typescript
// ✅ CORRECT - Alias pour les helpers de test
import { 
  createTestEnvironment,    // Environnement de test isolé
  generateTestId,           // IDs uniques pour les tests
  delay,                    // Attente asynchrone
  expectAsyncError,         // Test d'erreurs async
  cleanTimestamps          // Nettoyage des timestamps
} from '@lyxal/test';

// Exemple d'utilisation
const testEnv = createTestEnvironment('mon-module');
const uniqueId = generateTestId('user');
await delay(100);
await expectAsyncError(() => functionThatThrows(), 'Expected error');
```

#### Fixtures Disponibles
```typescript
// ✅ CORRECT - Alias pour les fixtures
import { 
  TEST_USERS,              // Utilisateurs de test prédéfinis
  createTestUser,          // Créer un utilisateur de test
  getTestUserByRole       // Récupérer par rôle
} from '@lyxal/test';

// Exemple d'utilisation
const admin = getTestUserByRole('admin');
const newUser = createTestUser('user');
console.log(TEST_USERS.length); // Tous les utilisateurs de test
```

#### Mocks Disponibles
```typescript
// ✅ CORRECT - Alias pour les mocks
import { mockSurrealDB } from '@lyxal/test';

// Exemple d'utilisation
const db = mockSurrealDB();
await db.connect();
const result = await db.create('users', { name: 'Test User' });
await db.close();
```

#### Pattern de Test Recommandé
```typescript
// Dans lyxal-test/src/tests/mon-module.test.ts
// ✅ CORRECT - Tous les imports via alias
import { createTestEnvironment, generateTestId } from '@lyxal/test';
import { createTestUser } from '@lyxal/test';
import { mockSurrealDB } from '@lyxal/test';

describe('🆕 Mon Module - LyxalSuite', () => {
  let testEnv: ReturnType<typeof createTestEnvironment>;
  let db: ReturnType<typeof mockSurrealDB>;

  beforeAll(async () => {
    testEnv = createTestEnvironment('mon-module-tests');
    db = mockSurrealDB();
    await db.connect();
  });

  afterAll(async () => {
    await db.close();
    await testEnv.teardown();
  });

  test('should work with test utilities', () => {
    const user = createTestUser('admin');
    const id = generateTestId('test');
    
    expect(user.role).toBe('admin');
    expect(id).toContain('test_');
    expect(testEnv.testId).toBeDefined();
    
    console.log(`✅ Test réussi: ${testEnv.testId}`);
  });
});
```

## 📖 Ressources

- [ARCHITECTURE-REFACTORING-GUIDE.md](./ARCHITECTURE-REFACTORING-GUIDE.md) - Règles architecturales
- [README.md](./README.md) - Vue d'ensemble de la documentation
- `lyxal-surreal/README.md` - Guide du client SurrealDB
- `lyxal-test/README.md` - Guide des tests centralisés
- `lyxal-test/TESTS-MIGRATION.md` - Migration des tests existants

## 🔄 Migration depuis l'Ancienne Architecture

Si vous avez des modules existants avec des dossiers `__tests__/` :

1. **Analyser les tests existants** :
   ```bash
   cd lyxalsuite/lyxal-test
   npm run test:migrate -- --analyze ../mon-ancien-module
   ```

2. **Migrer automatiquement** :
   ```bash
   npm run test:migrate -- --migrate ../mon-ancien-module
   ```

3. **Nettoyer l'ancien module** :
   ```bash
   rm -rf ../mon-ancien-module/__tests__
   rm -rf ../mon-ancien-module/jest.config.js
   # Retirer les scripts test du package.json
   ```

4. **Vérifier la migration** :
   ```bash
   npm test -- --testNamePattern="Mon Ancien Module"
   ```

---

**Dernière mise à jour :** Décembre 2024  
**Version :** 2.0 - Architecture Centralisée des Tests  
**Statut :** Guide Actif 