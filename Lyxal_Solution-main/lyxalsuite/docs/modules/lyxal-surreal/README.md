# 🌐 LyxalSurreal - Gateway SurrealDB Multi-tenant

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![SurrealDB](https://img.shields.io/badge/SurrealDB-Cloud-purple.svg)

**LyxalSurreal** est le module central de l'écosystème **LyxalSuite**, servant de **Gateway** et **orchestrateur** pour la gestion des données multi-tenant via SurrealDB Cloud.

## 🎯 Mission et objectifs

### **Mission principale**
Fournir une **interface unifiée** et **sécurisée** pour l'accès aux données dans une architecture SaaS multi-tenant, avec **provisionnement automatique** des modules métier.

### **Objectifs clés**
- ✅ **Isolation parfaite** des données par tenant et application
- ✅ **Provisionnement automatique** des schémas de base de données
- ✅ **Interface standardisée** pour tous les modules LyxalSuite
- ✅ **Gestion centralisée** des connexions et authentifications
- ✅ **Évolutivité** pour des milliers de tenants et applications
- ✅ **Maintenance simplifiée** avec des processus uniformes

## 🏗️ Architecture

### **Vue d'ensemble**
```
┌─────────────────────────────────────────────────────────┐
│                    LyxalSuite                          │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │
│  │ lyxal-gdpr  │ │ lyxalauth   │ │ lyxalkitui  │ ...  │
│  └─────────────┘ └─────────────┘ └─────────────┘      │
└─────────────────────┬───────────────────────────────────┘
                      │
              ┌───────▼──────────┐
              │   LyxalSurreal   │
              │    (Gateway)     │
              └───────┬──────────┘
                      │
              ┌───────▼──────────┐
              │  SurrealDB Cloud │
              └──────────────────┘
```

### **Structure hiérarchique des namespaces**
```
SurrealDB Instance
├── 📋 catalog                    (Métadonnées globales)
│   ├── tenant                    (Liste des clients)
│   ├── tenant_application        (Apps par client)
│   └── module                    (Catalogue des modules)
├── 🏢 tenant_clientA             (Données client A)
│   └── tenant_config             (Configuration client)
├── 📱 tenant_clientA_gdpr        (Module GDPR client A)
│   ├── gdpr_request             (Requêtes GDPR)
│   └── gdpr_response            (Réponses GDPR)
├── 🔐 tenant_clientA_auth        (Module Auth client A)
│   ├── user                     (Utilisateurs)
│   └── role                     (Rôles et permissions)
└── 🏢 tenant_clientB_*           (Autres clients...)
```

## 🚀 Fonctionnalités principales

### **1. Gestion des connexions**
- **Connexion SurrealDB Cloud** avec authentification sécurisée
- **Pool de connexions** optimisé pour les performances
- **Reconnexion automatique** en cas de déconnexion
- **Pattern Singleton** pour éviter les connexions multiples

### **2. Multi-tenancy**
- **Isolation complète** des données par namespace
- **Navigation transparente** entre les contextes tenant/application
- **Vérification d'existence** des namespaces avant utilisation
- **Gestion automatique** des contextes de requête

### **3. Provisionnement automatique**
- **Création automatique** des tenants et leurs namespaces
- **Déploiement des schémas** à partir des fichiers `.surql` des modules
- **Initialisation des tables** selon les définitions métier
- **Gestion des dépendances** entre modules

### **4. Sécurité et contrôle d'accès**
- **Middlewares Hono** pour validation tenant/application
- **Contrôle d'accès granulaire** par namespace
- **Audit trail** de toutes les opérations
- **Gestion d'erreurs centralisée** avec codes HTTP appropriés

### **5. Observabilité**
- **Logging structuré** avec niveaux configurables
- **Métriques de performance** des requêtes
- **Monitoring des connexions** et erreurs
- **Traces détaillées** pour le debugging

## 📦 Installation et configuration

### **Installation**
```bash
npm install @lyxal/lyxalsurreal
```

### **Configuration**
```typescript
import { SurrealClient } from '@lyxal/lyxalsurreal';

const config = {
  url: 'wss://your-instance.surrealdb.cloud/rpc',
  user: 'your-username',
  pass: 'your-password',
  namespace: 'catalog',
  database: 'main'
};

const client = SurrealClient.getInstance(config);
await client.initialize();
```

### **Variables d'environnement**
```env
SURREALDB_URL=wss://your-instance.surrealdb.cloud/rpc
SURREALDB_USER=your-username
SURREALDB_PASS=your-password
SURREALDB_NAMESPACE=catalog
SURREALDB_DATABASE=main
```

## 🎮 Utilisation

### **1. Gestion des tenants**
```typescript
// Créer un nouveau tenant
await client.createTenant('acme', 'ACME Corporation', 'acme.com');

// Basculer vers un tenant
await client.useTenant('acme');

// Vérifier l'existence d'un namespace
const exists = await client.namespaceExists('tenant_acme');
```

### **2. Gestion des applications**
```typescript
// Ajouter une application à un tenant
await client.addApplicationToTenant('acme', 'gdpr');

// Basculer vers une application spécifique
await client.useTenantApplication('acme', 'gdpr');

// Lister les applications d'un tenant
const apps = await client.getTenantApplications('acme');
```

### **3. Requêtes de données**
```typescript
// Exécuter des requêtes dans le contexte actuel
const result = await client.query('SELECT * FROM gdpr_request WHERE status = $status', {
  status: 'pending'
});

// Accès direct à l'instance SurrealDB
const db = client.getDB();
```

### **4. Middlewares Hono**
```typescript
import { tenantMiddleware } from '@lyxal/lyxalsurreal';

app.use('*', tenantMiddleware);

app.get('/api/data', async (c) => {
  const tenant = c.get('tenant');
  const surrealClient = c.get('surrealClient');
  
  // Le contexte est automatiquement configuré
  const data = await surrealClient.query('SELECT * FROM my_table');
  return c.json(data);
});
```

## 🔧 Architecture technique

### **Classes principales**

#### **SurrealClient** (Pattern Singleton)
- `getInstance(config)` - Obtenir l'instance unique
- `initialize()` - Initialiser la connexion
- `use(namespace, database)` - Changer de contexte
- `createTenant(name, displayName, domain)` - Créer un tenant
- `addApplicationToTenant(tenant, app)` - Provisionner une application
- `query(sql, vars)` - Exécuter du SurrealQL

#### **Middlewares Hono**
- `tenantMiddleware` - Validation et configuration du contexte tenant
- `autoProvisionTenantMiddleware` - Création automatique de tenant
- `autoProvisionAppMiddleware` - Provisionnement automatique d'application

#### **Gestion d'erreurs**
- Hiérarchie d'erreurs personnalisées (`SurrealError`, `TenantError`, etc.)
- Gestionnaire centralisé avec mapping HTTP
- Logging automatique des erreurs

### **Interfaces TypeScript**
```typescript
interface SurrealConfig {
  url: string;
  user: string;
  pass: string;
  namespace: string;
  database: string;
}

interface TenantApplication {
  application: string;
  version: string;
  status: string;
  settings?: Record<string, any>;
}
```

## 🔄 Cycle de vie d'un module

### **1. Enregistrement du module**
```typescript
// Le module est ajouté au registre avec ses schémas
const MODULE_REGISTRY = {
  'gdpr': {
    schemas: ['gdpr_structure.surql', 'gdpr_triggers.surql', 'gdpr_index.surql'],
    version: '1.0.0',
    dependencies: []
  }
};
```

### **2. Provisionnement automatique**
```typescript
// Lors de l'ajout à un tenant
await client.addApplicationToTenant('acme', 'gdpr');
// → Crée namespace tenant_acme_gdpr
// → Exécute tous les .surql du module
// → Met à jour le catalogue
```

### **3. Utilisation normale**
```typescript
// Le module utilise le client configuré
await client.useTenantApplication('acme', 'gdpr');
await client.query('SELECT * FROM gdpr_request');
```

## 📊 Monitoring et observabilité

### **Métriques disponibles**
- Temps de réponse des requêtes
- Nombre de connexions actives
- Erreurs par type et fréquence
- Utilisation des namespaces

### **Logs structurés**
```typescript
import { Logger } from '@lyxal/lyxalsurreal';

const logger = Logger.getInstance();
logger.info('Tenant created successfully', { tenant: 'acme' });
logger.error('Query failed', error);
```

## 🧪 Tests

### **Exécuter les tests**
```bash
npm test
```

### **Tests couverts**
- ✅ Connexion SurrealDB Cloud
- ✅ Gestion des namespaces
- ✅ Création et provisionnement de tenants
- ✅ Middlewares Hono
- ✅ Gestion d'erreurs
- ✅ Performance et stress tests

## 🗺️ Roadmap

### **Phase 1 - Stabilisation (Actuel)**
- [x] Architecture multi-tenant fonctionnelle
- [x] Provisionnement automatique
- [x] Tests complets
- [ ] Types TypeScript stricts
- [ ] Cache des métadonnées

### **Phase 2 - Optimisations**
- [ ] Pool de connexions avancé
- [ ] Requêtes batch optimisées
- [ ] Métriques de performance
- [ ] Monitoring avancé

### **Phase 3 - Évolutions**
- [ ] Support des migrations de schémas
- [ ] Backup/restore automatique
- [ ] Réplication multi-région
- [ ] Interface d'administration web

## 🤝 Contribution

### **Standards de développement**
- TypeScript strict
- Tests unitaires obligatoires
- Documentation complète
- Code review requis

### **Process de contribution**
1. Fork du repository
2. Branche feature
3. Tests et documentation
4. Pull request avec review

## 📄 Licence

MIT License - voir [LICENSE](LICENSE) pour les détails.

## 🔗 Liens utiles

- [SurrealDB Documentation](https://surrealdb.com/docs)
- [Hono Framework](https://hono.dev/)
- [LyxalSuite Documentation](../docs/)

---

**LyxalSurreal** - Le cœur de votre architecture SaaS multi-tenant 🚀 