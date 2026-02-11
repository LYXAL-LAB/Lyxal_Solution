# 📋 Processus standardisé de création de modules LyxalSuite

## 🎯 Objectif

Définir un **processus strict et uniforme** pour créer des modules dans l'écosystème LyxalSuite, assurant :
- **Cohérence** architecturale entre tous les modules
- **Intégration automatique** avec lyxal-surreal
- **Provisionnement automatique** des schémas de base de données
- **Maintenance simplifiée** et **évolutivité**
- **Facilitation pour l'agent IA** par des patterns standardisés

## 🏗️ Principe fondamental

**Chaque module est autonome** mais suit le **même template architectural** et s'intègre automatiquement avec **lyxal-surreal** comme orchestrateur central.

**Règle d'or :** Même si un SaaS n'utilise pas un module, **toutes les BDD sont créées** pour faciliter la maintenance et l'évolutivité.

**Architecture de déploiement universel :** 🔥
- **TOUS les modules** sont déployés automatiquement à chaque workspace
- **Auto-discovery** intelligent via `lyxal-*` et `module.config.json`
- **Scripts centralisés** dans lyxal-surreal pour déploiement/vérification
- **Aucune configuration manuelle** - détection automatique des nouveaux modules

## 📁 Structure standardisée de module

### **Template obligatoire**
```
lyxalsuite/
└── lyxal-{nom}/                     # Nom du module
    ├── package.json                 # Configuration NPM
    ├── README.md                    # Documentation module
    ├── jest.config.js              # Configuration tests
    ├── tsconfig.json               # Configuration TypeScript
    ├── .gitignore                  # Fichiers ignorés
    ├── module.config.json          # 🔥 CONFIGURATION MODULE (OBLIGATOIRE)
    │
    ├── model/                      # 📁 SCHÉMAS SURREALDB
    │   ├── {nom}_structure.surql   # Structure tables principales
    │   ├── {nom}_triggers.surql    # Triggers automatiques
    │   ├── {nom}_index.surql       # Index de performance
    │   ├── {nom}_relations.surql   # Relations entre tables (optionnel)
    │   ├── reference_{nom}_data.surql # Données de référence
    │   └── test_{nom}_flow.surql   # Tests de flux métier
    │
    ├── sdk/                        # 📁 CODE TYPESCRIPT
    │   ├── index.ts                # Point d'entrée principal
    │   ├── types/                  # Types et interfaces
    │   │   ├── types.ts            # Types métier
    │   │   └── api.ts              # Types API
    │   ├── services/               # Services métier
    │   │   ├── {nom}Service.ts     # Service principal
    │   │   └── {nom}Repository.ts  # Accès données (optionnel)
    │   ├── utils/                  # Utilitaires
    │   │   └── helpers.ts          # Fonctions utilitaires
    │   └── middleware/             # Middlewares spécifiques
    │       └── {nom}Middleware.ts  # Middleware module (optionnel)
    │
    ├── gateway/                    # 📁 API ET ROUTES
    │   ├── routes/                 # Routes API
    │   │   ├── {nom}Routes.ts      # Routes principales
    │   │   └── adminRoutes.ts      # Routes administration
    │   ├── controllers/            # Contrôleurs
    │   │   └── {nom}Controller.ts  # Contrôleur principal
    │   └── validators/             # Validation des données
    │       └── {nom}Validators.ts  # Schémas de validation
    │
    ├── tests/                      # 📁 TESTS
    │   ├── unit/                   # Tests unitaires
    │   ├── integration/            # Tests d'intégration
    │   └── fixtures/               # Données de test
    │
    └── docs/                       # 📁 DOCUMENTATION
        ├── api.md                  # Documentation API
        ├── architecture.md         # Architecture technique
        └── examples/               # Exemples d'usage
```

## 🔄 Processus de création étape par étape

### **Phase 1 : Préparation et design**

#### **Étape 1.1 : Analyse des besoins**
- [ ] Définir le **domaine métier** du module
- [ ] Identifier les **entités principales**
- [ ] Lister les **cas d'usage** essentiels
- [ ] Définir les **dépendances** avec autres modules

#### **Étape 1.2 : Design des données**
- [ ] Concevoir le **modèle de données** (ERD)
- [ ] Définir les **relations** entre entités
- [ ] Identifier les **contraintes** de validation
- [ ] Planifier les **index** de performance

#### **Étape 1.3 : Design des APIs**
- [ ] Définir les **endpoints** REST/GraphQL
- [ ] Spécifier les **schémas** de requête/réponse
- [ ] Planifier l'**authentification** et **autorisation**
- [ ] Documenter les **cas d'erreur**

### **Phase 2 : Initialisation du module**

#### **Étape 2.1 : Création de la structure**
```bash
# Créer le répertoire module
mkdir lyxalsuite/lyxal-{nom}
cd lyxalsuite/lyxal-{nom}

# Initialiser NPM
npm init -y

# Créer l'arborescence
mkdir -p model sdk/{types,services,utils,middleware} gateway/{routes,controllers,validators} tests/{unit,integration,fixtures} docs/examples
```

#### **Étape 2.2 : Configuration de base**
- [ ] **package.json** avec dépendances standards
- [ ] **tsconfig.json** avec configuration TypeScript stricte
- [ ] **jest.config.js** pour les tests
- [ ] **.gitignore** adapté
- [ ] **README.md** avec template standard
- [ ] **module.config.json** (OBLIGATOIRE) - Configuration pour auto-discovery

#### **Étape 2.3 : Intégration lyxal-surreal**
```typescript
// sdk/services/{nom}Service.ts
import { SurrealClient } from '@lyxal/lyxal-surreal';

export class {Nom}Service extends SurrealClient {
  constructor() {
    super();
  }
  
  // Méthodes métier spécifiques
}
```

### **Phase 3 : Développement des schémas**

#### **Étape 3.1 : Structure principale**
```sql
-- model/{nom}_structure.surql
-- Tables principales du module
DEFINE TABLE {nom}_entity SCHEMAFUL;
DEFINE FIELD name ON {nom}_entity TYPE string;
DEFINE FIELD status ON {nom}_entity TYPE string DEFAULT 'active';
DEFINE FIELD createdAt ON {nom}_entity TYPE datetime DEFAULT time::now();
-- ... autres champs
```

#### **Étape 3.2 : Triggers et automatisations**
```sql
-- model/{nom}_triggers.surql
-- Triggers pour validation et automatisations
DEFINE EVENT {nom}_validation ON TABLE {nom}_entity WHEN $event = "CREATE" THEN {
  -- Logique de validation
};
```

#### **Étape 3.3 : Index et performances**
```sql
-- model/{nom}_index.surql
-- Index pour optimiser les requêtes
DEFINE INDEX idx_{nom}_status ON {nom}_entity COLUMNS status;
DEFINE INDEX idx_{nom}_created ON {nom}_entity COLUMNS createdAt;
```

#### **Étape 3.4 : Données de référence**
```sql
-- model/reference_{nom}_data.surql
-- Données de base nécessaires au fonctionnement
CREATE {nom}_config SET name = 'default', settings = {};
```

#### **Étape 3.5 : Tests de flux**
```sql
-- model/test_{nom}_flow.surql
-- Scénarios de test complets
CREATE {nom}_entity:test1 SET name = 'Test Entity', status = 'active';
SELECT * FROM {nom}_entity WHERE name = 'Test Entity';
```

### **Phase 4 : Configuration pour auto-discovery**

#### **Étape 4.1 : Création du module.config.json**
```json
{
  "name": "{nom}",
  "version": "1.0.0",
  "description": "Module {description}",
  "schemas": [
    "{nom}_structure.surql",
    "{nom}_triggers.surql",
    "{nom}_index.surql",
    "reference_{nom}_data.surql"
  ],
  "dependencies": [],
  "testSchemas": [
    "test_{nom}_flow.surql"
  ],
  "verification": {
    "requiredTables": ["{nom}_entity"],
    "requiredData": ["{nom}_config"],
    "testQueries": [
      "SELECT COUNT() FROM {nom}_entity"
    ]
  }
}
```

#### **Étape 4.2 : Auto-discovery par lyxal-surreal**
⚠️ **IMPORTANT** : Plus besoin de registre manuel ! Le système détecte automatiquement :
- Modules avec préfixe `lyxal-*`
- Présence obligatoire de `module.config.json`
- Dossier `model/` avec fichiers `.surql`

#### **Étape 4.2 : Tests d'intégration**
```typescript
// tests/integration/{nom}Integration.test.ts
describe('{Nom} Module Integration', () => {
  test('Should provision automatically', async () => {
    await client.addApplicationToTenant('test-tenant', '{nom}');
    const apps = await client.getTenantApplications('test-tenant');
    expect(apps.find(app => app.application === '{nom}')).toBeDefined();
  });
});
```

### **Phase 5 : Développement de la logique métier**

#### **Étape 5.1 : Types TypeScript**
```typescript
// sdk/types/types.ts
export interface {Nom}Entity {
  id?: string;
  name: string;
  status: 'active' | 'inactive';
  createdAt?: Date;
  updatedAt?: Date;
}

export interface {Nom}CreateRequest {
  name: string;
  // ... autres champs
}
```

#### **Étape 5.2 : Service principal**
```typescript
// sdk/services/{nom}Service.ts
export class {Nom}Service extends SurrealClient {
  async create{Nom}(data: {Nom}CreateRequest): Promise<{Nom}Entity> {
    return this.query('CREATE {nom}_entity CONTENT $data', { data });
  }
  
  async get{Nom}ById(id: string): Promise<{Nom}Entity | null> {
    const result = await this.query('SELECT * FROM $id', { id });
    return result[0]?.[0] || null;
  }
  
  async list{Nom}s(): Promise<{Nom}Entity[]> {
    const result = await this.query('SELECT * FROM {nom}_entity WHERE status = "active"');
    return result[0] || [];
  }
}
```

#### **Étape 5.3 : Contrôleurs API**
```typescript
// gateway/controllers/{nom}Controller.ts
export class {Nom}Controller {
  private service = new {Nom}Service();
  
  async create{Nom}(c: Context) {
    const data = await c.req.json();
    const result = await this.service.create{Nom}(data);
    return c.json(result, 201);
  }
  
  async get{Nom}(c: Context) {
    const id = c.req.param('id');
    const result = await this.service.get{Nom}ById(id);
    return result ? c.json(result) : c.json({ error: 'Not found' }, 404);
  }
}
```

### **Phase 6 : APIs et routes**

#### **Étape 6.1 : Définition des routes**
```typescript
// gateway/routes/{nom}Routes.ts
import { Hono } from 'hono';
import { tenantMiddleware } from '@lyxalsuite/lyxal-surreal';
import { {Nom}Controller } from '../controllers/{nom}Controller';

const app = new Hono();
const controller = new {Nom}Controller();

// Middleware tenant obligatoire
app.use('*', tenantMiddleware);

// Routes CRUD
app.post('/{nom}s', controller.create{Nom}.bind(controller));
app.get('/{nom}s/:id', controller.get{Nom}.bind(controller));
app.get('/{nom}s', controller.list{Nom}s.bind(controller));

export default app;
```

#### **Étape 6.2 : Validation des données**
```typescript
// gateway/validators/{nom}Validators.ts
import { z } from 'zod';

export const create{Nom}Schema = z.object({
  name: z.string().min(1).max(100),
  // ... autres validations
});

export const update{Nom}Schema = create{Nom}Schema.partial();
```

### **Phase 7 : Tests et documentation**

#### **Étape 7.1 : Tests unitaires**
```typescript
// tests/unit/{nom}Service.test.ts
describe('{Nom}Service', () => {
  let service: {Nom}Service;
  
  beforeEach(() => {
    service = new {Nom}Service();
  });
  
  test('Should create {nom} entity', async () => {
    const data = { name: 'Test {Nom}' };
    const result = await service.create{Nom}(data);
    expect(result.name).toBe('Test {Nom}');
  });
});
```

#### **Étape 7.2 : Tests d'intégration**
```typescript
// tests/integration/{nom}Api.test.ts
describe('{Nom} API', () => {
  test('POST /{nom}s should create entity', async () => {
    const response = await app.request('/{nom}s', {
      method: 'POST',
      headers: { 'X-Tenant-ID': 'test-tenant' },
      body: JSON.stringify({ name: 'Test Entity' })
    });
    expect(response.status).toBe(201);
  });
});
```

#### **Étape 7.3 : Documentation**
```markdown
<!-- docs/api.md -->
# {Nom} Module API

## Endpoints

### POST /{nom}s
Créer une nouvelle entité {nom}.

#### Request
```json
{
  "name": "string"
}
```

#### Response 201
```json
{
  "id": "string",
  "name": "string",
  "status": "active",
  "createdAt": "datetime"
}
```
```

### **Phase 8 : Finalisation et validation**

#### **Étape 8.1 : Validation complète**
- [ ] Tous les tests passent (npm test)
- [ ] Schémas SurrealDB valides
- [ ] Types TypeScript stricts
- [ ] Documentation complète
- [ ] Exemples fonctionnels

#### **Étape 8.2 : Test de provisionnement**
```typescript
// Tester le provisionnement automatique
await client.addApplicationToTenant('test-tenant', '{nom}');
// Vérifier que toutes les tables sont créées
// Vérifier que les données de référence sont présentes
```

#### **Étape 8.3 : Release**
- [ ] Version dans package.json
- [ ] Tags Git
- [ ] Publication NPM (si applicable)
- [ ] Mise à jour documentation globale

### **Phase 9 : Déploiement universel et validation** 🔥

#### **Étape 9.1 : Test d'auto-discovery**
```bash
# Depuis lyxal-surreal, tester la détection automatique
cd ../lyxal-surreal
npm run workspace:deploy -- --dry-run

# Vérifier que le nouveau module est détecté
# Vérifier la configuration module.config.json
```

#### **Étape 9.2 : Déploiement complet**
```bash
# Déployer TOUS les modules (architecture universelle)
npm run workspace:deploy

# Vérifier l'intégrité de tous les modules
npm run workspace:verify

# Tester le nouveau module spécifiquement
npm run workspace:verify -- --module {nom}
```

#### **Étape 9.3 : Validation en environnement**
- [ ] Module détecté automatiquement par auto-discovery
- [ ] Schémas déployés sans erreur
- [ ] Données de référence présentes
- [ ] Tests de vérification passent
- [ ] Aucune régression sur autres modules

#### **Étape 9.4 : Documentation des scripts workspace**
Le module sera automatiquement intégré aux scripts universels :
- `npm run workspace:deploy` : Déploie TOUS les modules
- `npm run workspace:verify` : Vérifie TOUS les modules  
- `npm run workspace:reset` : Réinitialise TOUS les modules

## 🎯 Checklist de validation finale

### **Structure et fichiers**
- [ ] Structure de dossiers conforme au template
- [ ] Tous les fichiers obligatoires présents
- [ ] **module.config.json** correctement configuré
- [ ] Configuration TypeScript stricte
- [ ] Tests configurés et fonctionnels

### **Auto-discovery et déploiement universel** 🔥
- [ ] **module.config.json** présent et valide
- [ ] Module détecté par auto-discovery `lyxal-*`
- [ ] Schémas listés correctement dans la configuration
- [ ] Tests de vérification définis
- [ ] Déploiement réussi avec `npm run workspace:deploy`
- [ ] Vérification réussie avec `npm run workspace:verify`

### **Intégration lyxal-surreal**
- [ ] ~~Module enregistré dans MODULE_REGISTRY~~ (obsolète)
- [ ] Schémas .surql syntaxiquement corrects
- [ ] Provisionnement automatique fonctionnel
- [ ] Service étend SurrealClient correctement
- [ ] **Auto-discovery fonctionnel**

### **Qualité du code**
- [ ] Types TypeScript stricts (pas de 'any')
- [ ] Gestion d'erreurs appropriée
- [ ] Logging avec niveaux appropriés
- [ ] Validation des inputs

### **APIs et interfaces**
- [ ] Middlewares tenant appliqués
- [ ] Endpoints RESTful cohérents
- [ ] Validation des données d'entrée
- [ ] Codes de réponse HTTP appropriés

### **Tests et documentation**
- [ ] Couverture de tests > 80%
- [ ] Tests unitaires et d'intégration
- [ ] Documentation API complète
- [ ] Exemples d'usage fonctionnels

### **Performance et sécurité**
- [ ] Index de base de données appropriés
- [ ] Requêtes optimisées
- [ ] Validation des permissions
- [ ] Audit trail des opérations critiques

## 🤖 Facilitation pour l'agent IA

### **Patterns standardisés**
L'agent IA peut facilement :
- **Générer un nouveau module** en suivant le template exact
- **Analyser la structure** grâce aux conventions strictes
- **Créer des tests** basés sur les patterns existants
- **Générer la documentation** avec les templates standardisés

### **Métadonnées pour l'IA**
```typescript
// sdk/metadata.ts - Fichier obligatoire pour l'IA
export const MODULE_METADATA = {
  name: '{nom}',
  version: '1.0.0',
  description: 'Module description',
  entities: ['{nom}_entity'],
  endpoints: ['POST /{nom}s', 'GET /{nom}s/:id'],
  dependencies: [],
  aiGenerated: true, // Marquer si généré par IA
  lastUpdated: new Date().toISOString()
};
```

## 🚀 Évolution et maintenance

### **Versioning des modules**
- **Semantic versioning** obligatoire
- **Migration scripts** pour les changements de schéma
- **Backward compatibility** assurée

### **Monitoring et observabilité**
- **Métriques automatiques** via lyxalsurreal
- **Logs structurés** pour chaque module
- **Health checks** standardisés

---

**Ce processus garantit la cohérence, la maintenabilité et l'évolutivité de l'écosystème LyxalSuite** 🎯 
