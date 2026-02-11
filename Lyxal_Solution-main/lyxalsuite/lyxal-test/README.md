# LyxalSuite Test Module

## 🎯 Vue d'Ensemble

Le module `@lyxalsuite/lyxal-test` centralise tous les utilitaires de test, mocks et fixtures pour LyxalSuite. Il suit la philosophie d'architecture centralisée en évitant la duplication des outils de test à travers les modules.

## 📋 Fonctionnalités

### ✅ **Utilitaires de Test Centralisés**
- Helpers pour tests asynchrones
- Génération d'IDs de test uniques
- Gestion d'environnements de test isolés
- Nettoyage automatique des données temporelles

### ✅ **Mocks Partagés**
- Mock SurrealDB complet avec API compatible
- Mocks d'authentification
- Mocks d'API REST

### ✅ **Fixtures de Données**
- Utilisateurs de test prédéfinis
- Données d'entreprises de test
- Configurations SurrealDB de test

### ✅ **Scripts de Test Globaux**
- Exécution de tous les tests
- Rapports de couverture centralisés
- Setup/teardown de base de données de test

## 🚀 Installation et Usage

### Installation
```bash
# Le module est automatiquement installé avec le workspace
cd lyxalsuite
npm install
```

### Usage de Base
```typescript
import { 
  createTestUser, 
  MockSurrealDB, 
  generateTestId,
  createTestEnvironment 
} from '@lyxalsuite/lyxal-test';

// Créer un utilisateur de test
const testUser = createTestUser({ role: 'admin' });

// Utiliser le mock SurrealDB
const mockDB = new MockSurrealDB();
await mockDB.connect();
await mockDB.create('users', testUser);

// Créer un environnement de test isolé
const testEnv = createTestEnvironment('user-service');
testEnv.addCleanup(() => mockDB.clearAll());
```

## 📁 Structure du Module

```
lyxal-test/
├── src/
│   ├── fixtures/              ← Données de test partagées
│   │   ├── users.fixture.ts   ← Utilisateurs de test
│   │   ├── companies.fixture.ts
│   │   └── surrealdb.fixture.ts
│   ├── mocks/                 ← Mocks partagés
│   │   ├── surrealdb.mock.ts  ← Mock SurrealDB complet
│   │   ├── auth.mock.ts
│   │   └── api.mock.ts
│   ├── helpers/               ← Utilitaires de test
│   │   ├── test-utils.ts      ← Utilitaires généraux
│   │   ├── db-helpers.ts
│   │   └── assertion-helpers.ts
│   ├── setup/                 ← Configuration globale
│   │   ├── jest-setup.ts
│   │   └── test-environment.ts
│   └── index.ts               ← Exports centralisés
├── templates/                 ← Templates de tests
├── scripts/                   ← Scripts de test globaux
└── package.json
```

## 🔧 API Principale

### Test Utilities
```typescript
// Génération d'IDs uniques
const id = generateTestId('user'); // 'user_1234567890_abc123'

// Délais pour tests asynchrones
await delay(1000);

// Nettoyage des timestamps pour comparaisons
const cleanData = cleanTimestamps(responseData);

// Environnement de test isolé
const env = createTestEnvironment('integration-test');
env.addCleanup(() => cleanup());
await env.teardown();
```

### Mock SurrealDB
```typescript
const mockDB = new MockSurrealDB();

// API compatible avec SurrealDB
await mockDB.connect();
const user = await mockDB.create('users', { name: 'Test' });
const users = await mockDB.select('users');
await mockDB.update(user.id, { name: 'Updated' });
await mockDB.delete(user.id);

// Utilitaires de test
mockDB.clearTable('users');
mockDB.clearAll();
const data = mockDB.getTableData('users');
```

### Fixtures
```typescript
// Utilisateurs prédéfinis
import { TEST_USERS, getTestUserByRole } from '@lyxalsuite/lyxal-test';

const adminUser = getTestUserByRole('admin');

// Création dynamique
const customUser = createTestUser({ 
  role: 'admin', 
  email: 'custom@test.com' 
});

// Création en masse
const users = createMultipleTestUsers(5, { role: 'user' });
```

## 📊 Scripts Disponibles

```bash
# Tests du module
npm run test

# Tests de tous les modules
npm run test:all

# Couverture de code
npm run test:coverage

# Setup base de données de test
npm run db:test:setup

# Nettoyage base de données de test
npm run db:test:teardown
```

## 🎯 Avantages de la Centralisation

### ✅ **Cohérence**
- Standards de test uniformes
- Mocks réutilisables
- Fixtures partagées

### ✅ **Maintenance**
- Un seul endroit pour les utilitaires
- Mise à jour centralisée
- Configuration unifiée

### ✅ **Performance**
- Évite la duplication de code
- Setup optimisé
- Ressources partagées

### ✅ **DX (Developer Experience)**
- API unifiée
- Documentation centralisée
- Templates prêts à l'emploi

## 🚨 Règles d'Usage

### ❌ **À Éviter**
- Dupliquer les utilitaires dans d'autres modules
- Créer des mocks spécifiques sans vérifier s'ils existent ici
- Ignorer les fixtures existantes

### ✅ **Bonnes Pratiques**
- Utiliser les fixtures existantes quand possible
- Contribuer aux utilitaires communs
- Suivre les patterns établis
- Nettoyer les données de test après usage

## 🔄 Contribution

Pour ajouter de nouveaux utilitaires :

1. **Vérifier** si l'utilitaire existe déjà
2. **Ajouter** dans le bon dossier (helpers/mocks/fixtures)
3. **Exporter** dans l'index approprié
4. **Documenter** l'usage
5. **Tester** l'utilitaire

## 📚 Ressources

- [ARCHITECTURE-REFACTORING-GUIDE.md](../lyxal-docs/ARCHITECTURE-REFACTORING-GUIDE.md) - Règles architecturales
- [MODULE-CREATION-GUIDE.md](../lyxal-docs/MODULE-CREATION-GUIDE.md) - Guide de création de modules

---

**Version :** 1.0.0  
**Statut :** Actif et maintenu  
**Responsable :** Équipe Architecture LyxalSuite