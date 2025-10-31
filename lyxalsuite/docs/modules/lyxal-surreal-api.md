# 📚 LyxalSurreal - Référence API Bicéphale

*Documentation complète pour l'architecture bicéphale SaaS/Workspace*

## 🎯 Vue d'ensemble

LyxalSurreal est le client de base de données **bicéphale** pour l'écosystème LyxalSuite. Il fournit une interface TypeScript pour SurrealDB avec architecture **SaaS/Workspace**, cache intelligent, monitoring intégré et gestion automatique des namespaces.

## 🚀 Installation et Configuration

### Installation

```bash
npm install @lyxalsuite/lyxal-surreal
```

### Configuration de Base

```typescript
import { SurrealClient } from '@lyxalsuite/lyxal-surreal';
import type { SurrealConfig } from '@lyxalsuite/lyxal-surreal';

const config: SurrealConfig = {
  url: 'wss://your-surrealdb-instance.com/rpc',
  user: 'admin',
  pass: 'password',
  namespace: 'catalog',  // Namespace de démarrage
  database: 'main'       // Database de démarrage
};

const client = SurrealClient.getInstance(config);
await client.initialize();
```

## 🏗️ Architecture Bicéphale SaaS/Workspace

### Structure Bicéphale

```
🌐 CATALOGUE GLOBAL (namespace: catalog)
└── 📊 main (Database)
    ├── saas_registry            # Inventaire instances SaaS
    └── modules_global           # Modules disponibles

🏢 INSTANCE SAAS (namespace: acme-corp)
├── 📊 main (Database instance SaaS)
│   ├── saas_settings           # Configuration SaaS
│   ├── workspaces_registry     # Workspaces de l'instance
│   └── modules_catalog         # Modules disponibles
├── 🗂️ production (Database workspace)
│   ├── workspace_config        # Configuration workspace
│   ├── workspace_modules       # Modules installés
│   └── customers, deals...     # Tables métier
└── 🗂️ staging (Database workspace)
    └── tables de test...
```

### Création d'une Instance SaaS

```typescript
import type { SaaSRecord } from '@lyxalsuite/lyxal-surreal';

// Configuration SaaS
const saasConfig: Partial<SaaSRecord> = {
  displayName: 'ACME Corporation',
  domain: 'acme.com',
  plan: 'enterprise',
  limits: {
    maxWorkspaces: 50,
    maxUsers: 1000,
    maxStorage: 1000000
  }
};

// Créer l'instance SaaS
await client.createSaaS('acme-corp', saasConfig);

// L'instance SaaS crée automatiquement :
// - Namespace: acme-corp
// - Database: main
// - Tables: saas_settings, workspaces_registry, modules_catalog
```

## 📋 API Référence

### 🔧 Méthodes de Base

#### `getInstance(config: SurrealConfig): SurrealClient`
Obtient l'instance unique du client (Pattern Singleton)

```typescript
const client = SurrealClient.getInstance(config);
```

#### `initialize(): Promise<void>`
Initialise la connexion à SurrealDB

```typescript
await client.initialize();
```

#### `close(): Promise<void>`
Ferme proprement la connexion

```typescript
await client.close();
```

#### `use(namespace: string, database: string): Promise<void>`
Change le contexte de namespace/database

```typescript
await client.use('acme-corp', 'production');
```

### 🏢 Gestion des Instances SaaS

#### `createSaaS(name: string, config: Partial<SaaSRecord>): Promise<void>`
Crée une nouvelle instance SaaS avec sa structure complète

```typescript
await client.createSaaS('acme-corp', {
  displayName: 'ACME Corporation',
  plan: 'pro',
  limits: { maxWorkspaces: 10, maxUsers: 100, maxStorage: 50000 }
});
```

**Validation :**
- `name` doit respecter le format : `/^[a-zA-Z0-9_-]+$/`
- Crée automatiquement les tables de configuration SaaS

#### `useSaaS(saasId: string): Promise<void>`
Navigue vers une instance SaaS

```typescript
await client.useSaaS('acme-corp');
// Positionne le client sur namespace: acme-corp, database: main
```

#### `saasExists(name: string): Promise<boolean>`
Vérifie l'existence d'une instance SaaS avec cache TTL

```typescript
const exists = await client.saasExists('acme-corp');
// Utilise le cache pendant 5 minutes
```

### 🗂️ Gestion des Workspaces

#### `createWorkspace(saasId: string, workspaceId: string, modules?: string[]): Promise<void>`
Crée un workspace dans une instance SaaS

```typescript
await client.createWorkspace('acme-corp', 'production', ['crm', 'gdpr', 'auth']);
```

**Comportement :**
- Crée une database : `production` dans le namespace `acme-corp`
- Enregistre le workspace dans `workspaces_registry`
- Installe les modules spécifiés

#### `useWorkspace(saasId: string, workspaceId: string): Promise<void>`
Navigue vers un workspace spécifique

```typescript
await client.useWorkspace('acme-corp', 'production');
// Positionne le client sur namespace: acme-corp, database: production
```

#### `workspaceExists(saasId: string, workspaceId: string): Promise<boolean>`
Vérifie l'existence d'un workspace

```typescript
const exists = await client.workspaceExists('acme-corp', 'production');
```

### 📦 Gestion des Modules

#### `installModuleInWorkspace(saasId: string, workspaceId: string, moduleName: string): Promise<void>`
Installe un module dans un workspace

```typescript
await client.installModuleInWorkspace('acme-corp', 'production', 'analytics');
```

**Comportement :**
- Vérifie que le module existe dans `modules_catalog`
- Crée les tables nécessaires dans le workspace
- Enregistre l'installation dans `workspace_modules`

#### `getWorkspaceModules(saasId: string, workspaceId: string): Promise<WorkspaceModule[]>`
Récupère tous les modules installés dans un workspace

```typescript
const modules = await client.getWorkspaceModules('acme-corp', 'production');
// Retourne: [{ moduleName: 'crm', version: '2.0.0', status: 'active' }]
```

### 🗄️ Opérations de Base de Données

#### `query(sql: string, vars?: Record<string, any>): Promise<any[]>`
Exécute une requête SurrealQL avec monitoring

```typescript
const result = await client.query('SELECT * FROM customers WHERE status = $status', {
  status: 'active'
});
```

**Fonctionnalités :**
- Monitoring automatique des performances
- Détection des requêtes lentes (>1000ms)
- Logging des erreurs avec contexte SaaS/Workspace

#### `cachedQuery(sql: string, vars?: Record<string, any>, cacheKey?: string): Promise<any[]>`
Exécute une requête avec cache intelligent

```typescript
const result = await client.cachedQuery(
  'SELECT * FROM products WHERE category = $category',
  { category: 'electronics' },
  'products_electronics'
);
```

### 📊 Monitoring et Performance

#### `getPerformanceMetrics(): PerformanceMetrics`
Récupère les métriques de performance complètes

```typescript
const metrics = client.getPerformanceMetrics();

// Structure des métriques bicéphales :
interface PerformanceMetrics {
  cache: {
    metadata: CacheMetrics;
    query: CacheMetrics;
  };
  monitoring: MonitoringMetrics;
}

interface CacheMetrics {
  totalHits: number;
  totalMisses: number;
  hitRatio: number;
  totalEntries: number;
  avgResponseTime: number;
}

interface MonitoringMetrics {
  totalQueries: number;
  successfulQueries: number;
  failedQueries: number;
  avgResponseTime: number;
  slowQueries: QueryMetrics[];
}
```

#### `generatePerformanceReport(): string`
Génère un rapport de performance formaté

```typescript
const report = client.generatePerformanceReport();
console.log(report);

// Exemple de sortie :
// ╔══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗
// ║                                          RAPPORT DE PERFORMANCE LYXALSURREAL                                                ║
// ╠══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╣
// ║ 🧠 Cache métadonnées   │ Taux de hit: 85.2% │ Entrées: 150 │ Temps moyen: 12ms                                            ║
// ║ 🚀 Cache requêtes      │ Taux de hit: 72.8% │ Entrées: 89  │ Temps moyen: 45ms                                            ║
// ╚══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝
```

#### `invalidateCache(pattern?: string): number`
Invalide le cache (complètement ou par pattern)

```typescript
// Invalider tout le cache
const cleared = client.invalidateCache();

// Invalider par pattern
const cleared = client.invalidateCache('products.*');
```

#### `getCurrentNamespace(): string | null`
Récupère le namespace actuel

```typescript
const namespace = client.getCurrentNamespace();
// Retourne: 'acme-corp' ou null
```

#### `getCurrentDatabase(): string | null`
Récupère la database actuelle

```typescript
const database = client.getCurrentDatabase();
// Retourne: 'production' ou null
```

## 🎛️ Middlewares Bicéphales

### `saasMiddleware`
Middleware pour validation et navigation SaaS

```typescript
import { saasMiddleware } from '@lyxalsuite/lyxal-surreal';
import { Hono } from 'hono';

const app = new Hono();
app.use('/api/saas/*', saasMiddleware);

app.get('/api/saas/info', async (c) => {
  const saas = c.get('saas');           // SaaSRecord
  const client = c.get('surrealClient'); // SurrealClient
  
  return c.json({ saas: saas.name });
});
```

**Headers requis :**
- `X-SaaS-ID` : Identifiant de l'instance SaaS

### `workspaceMiddleware`
Middleware pour validation et navigation Workspace

```typescript
import { workspaceMiddleware } from '@lyxalsuite/lyxal-surreal';

app.use('/api/workspace/*', saasMiddleware, workspaceMiddleware);

app.get('/api/workspace/data', async (c) => {
  const saas = c.get('saas');           // SaaSRecord
  const workspace = c.get('workspace'); // WorkspaceRecord
  const client = c.get('surrealClient'); // SurrealClient
  
  // Le client est automatiquement positionné sur le workspace
  const data = await client.query('SELECT * FROM customers');
  
  return c.json({ data: data[0] || [] });
});
```

**Headers requis :**
- `X-SaaS-ID` : Identifiant de l'instance SaaS
- `X-Workspace-ID` : Identifiant du workspace

### `autoProvisionSaaSMiddleware`
Middleware pour création automatique d'instances SaaS

```typescript
import { autoProvisionSaaSMiddleware } from '@lyxalsuite/lyxal-surreal';

app.use('/api/auto-saas/*', autoProvisionSaaSMiddleware);

app.post('/api/auto-saas/init', async (c) => {
  const saas = c.get('saas');
  const isNewlyCreated = c.get('saasCreated'); // boolean
  
  return c.json({
    message: isNewlyCreated ? 'Instance SaaS créée' : 'Instance SaaS existante',
    saas
  });
});
```

**Headers pour auto-création :**
- `X-SaaS-ID` : Identifiant de l'instance SaaS
- `X-SaaS-DisplayName` : Nom d'affichage (optionnel)
- `X-SaaS-Domain` : Domaine (optionnel)
- `X-SaaS-Plan` : Plan (starter|pro|enterprise, optionnel)

### `autoProvisionWorkspaceMiddleware`
Middleware pour création automatique de workspaces

```typescript
import { autoProvisionWorkspaceMiddleware } from '@lyxalsuite/lyxal-surreal';

app.use('/api/auto-workspace/*', autoProvisionWorkspaceMiddleware);

app.post('/api/auto-workspace/setup', async (c) => {
  const workspace = c.get('workspace');
  const isNewlyCreated = c.get('workspaceCreated'); // boolean
  
  return c.json({
    message: isNewlyCreated ? 'Workspace créé' : 'Workspace existant',
    workspace
  });
});
```

**Headers pour auto-création :**
- `X-SaaS-ID` : Identifiant de l'instance SaaS
- `X-Workspace-ID` : Identifiant du workspace
- `X-Workspace-Modules` : Liste des modules (séparés par virgule, optionnel)

## 🎯 Types TypeScript

### `SaaSRecord`
```typescript
interface SaaSRecord {
  id: string;
  name: string;
  displayName: string;
  domain: string;
  plan: 'starter' | 'pro' | 'enterprise';
  status: 'active' | 'inactive' | 'suspended';
  limits: {
    maxWorkspaces: number;
    maxUsers: number;
    maxStorage: number;
  };
  settings: Record<string, any>;
  createdAt: Date;
}
```

### `WorkspaceRecord`
```typescript
interface WorkspaceRecord {
  id: string;
  saasId: string;
  name: string;
  displayName: string;
  status: 'active' | 'inactive' | 'archived';
  modules: string[];
  users: string[];
  settings: Record<string, any>;
  createdAt: Date;
  lastAccessedAt: Date;
}
```

### `WorkspaceModule`
```typescript
interface WorkspaceModule {
  id?: string;
  workspaceId: string;
  moduleName: string;
  version: string;
  status: 'active' | 'inactive' | 'updating';
  configuration: Record<string, any>;
  installedAt: Date;
  lastUpdatedAt: Date;
}
```

## ❌ Gestion d'Erreurs

### Erreurs SaaS
```typescript
import { SaaSError, SaaSNotFoundError, SaaSInactiveError } from '@lyxalsuite/lyxal-surreal';

try {
  await client.useSaaS('nonexistent');
} catch (error) {
  if (error instanceof SaaSNotFoundError) {
    console.log('Instance SaaS non trouvée');
  }
}
```

### Erreurs Workspace
```typescript
import { WorkspaceError, WorkspaceNotFoundError } from '@lyxalsuite/lyxal-surreal';

try {
  await client.useWorkspace('acme-corp', 'nonexistent');
} catch (error) {
  if (error instanceof WorkspaceNotFoundError) {
    console.log('Workspace non trouvé');
  }
}
```

### Erreurs Modules
```typescript
import { WorkspaceModuleError, WorkspaceModuleNotFoundError } from '@lyxalsuite/lyxal-surreal';

try {
  await client.installModuleInWorkspace('acme-corp', 'prod', 'nonexistent');
} catch (error) {
  if (error instanceof WorkspaceModuleNotFoundError) {
    console.log('Module non trouvé dans le catalogue');
  }
}
```

## 📝 Exemples Pratiques

### Création complète SaaS + Workspace + Modules

```typescript
import { SurrealClient } from '@lyxalsuite/lyxal-surreal';

async function setupCompleteSaaS() {
  const client = SurrealClient.getInstance({
    url: 'wss://your-instance.surrealdb.cloud/rpc',
    user: 'admin',
    pass: 'password',
    namespace: 'catalog',
    database: 'main'
  });

  await client.initialize();

  // 1. Créer l'instance SaaS
  await client.createSaaS('acme-corp', {
    displayName: 'ACME Corporation',
    domain: 'acme.com',
    plan: 'enterprise',
    limits: {
      maxWorkspaces: 50,
      maxUsers: 1000,
      maxStorage: 1000000
    }
  });

  // 2. Créer des workspaces
  await client.createWorkspace('acme-corp', 'production', ['crm', 'gdpr', 'auth']);
  await client.createWorkspace('acme-corp', 'staging', ['crm']);
  await client.createWorkspace('acme-corp', 'development', ['crm']);

  // 3. Naviguer et travailler
  await client.useWorkspace('acme-corp', 'production');
  
  // 4. Créer des données
  const customers = await client.query(`
    CREATE customers SET
      name = 'John Doe',
      email = 'john@acme.com',
      status = 'active',
      createdAt = time::now()
  `);

  console.log('✅ Instance SaaS complète créée avec succès');
}
```

### API REST complète avec middlewares

```typescript
import { Hono } from 'hono';
import { serve } from '@hono/node-server';
import { 
  SurrealClient,
  saasMiddleware,
  workspaceMiddleware,
  autoProvisionSaaSMiddleware
} from '@lyxalsuite/lyxal-surreal';

const app = new Hono();

// Administration
app.post('/admin/saas', autoProvisionSaaSMiddleware, async (c) => {
  const saas = c.get('saas');
  const isNew = c.get('saasCreated');
  
  return c.json({
    success: true,
    message: isNew ? 'Instance SaaS créée' : 'Instance SaaS existante',
    saas
  });
});

// API métier bicéphale
app.use('/api/*', saasMiddleware, workspaceMiddleware);

app.get('/api/customers', async (c) => {
  const client = c.get('surrealClient');
  const customers = await client.query('SELECT * FROM customers');
  
  return c.json({ customers: customers[0] || [] });
});

app.post('/api/customers', async (c) => {
  const data = await c.req.json();
  const client = c.get('surrealClient');
  
  const result = await client.query('CREATE customers CONTENT $data', { data });
  
  return c.json({ customer: result[0]?.[0] }, 201);
});

serve({ fetch: app.fetch, port: 3000 });
```

### Utilisation avec curl

```bash
# Créer une instance SaaS
curl -X POST \
  -H "X-SaaS-ID: acme-corp" \
  -H "X-SaaS-DisplayName: ACME Corporation" \
  -H "X-SaaS-Plan: enterprise" \
  http://localhost:3000/admin/saas

# Lister les customers
curl -H "X-SaaS-ID: acme-corp" \
     -H "X-Workspace-ID: production" \
     http://localhost:3000/api/customers

# Créer un customer
curl -X POST \
  -H "X-SaaS-ID: acme-corp" \
  -H "X-Workspace-ID: production" \
  -H "Content-Type: application/json" \
  -d '{"name": "Jane Smith", "email": "jane@acme.com"}' \
  http://localhost:3000/api/customers
```

---

**📚 LyxalSurreal API Référence v2.0 - Architecture Bicéphale**  
*Documentation complète pour l'écosystème SaaS/Workspace* 🚀
