# Architecture des Namespaces SurrealDB

## Structure bicéphale

### Namespaces (Instances SaaS)
- `catalog` : Registre global des instances SaaS
- `<saas-id>` : Instance SaaS spécifique

### Databases (Workspaces)
- `main` : Configuration SaaS
- `workspace_<workspace-id>` : Workspace métier

## Conventions de nommage

### Namespaces
- Nom de l'instance SaaS en minuscules
- Tirets pour séparer les mots
- Exemple : `acme-corp`, `netflix`

### Databases
- `main` pour la configuration SaaS
- `workspace_` préfixe pour les workspaces
- Exemple : `workspace_production`, `workspace_staging`

## Gestion des permissions

Chaque namespace est isolé avec ses propres utilisateurs et permissions.

## Vue d'ensemble

LyxalSurreal utilise une architecture hiérarchique de namespaces pour organiser les données multi-tenant :

```
Root (SurrealDB Instance)
├── system (namespace système)
│   └── system (database)
├── catalog (namespace catalogue)
│   └── main (database)
│       ├── tenant (table des tenants)
│       ├── tenant_application (table des applications par tenant)
│       └── module (table des modules disponibles)
└── tenant_{name} (namespace par tenant)
    └── main (database)
        └── tenant_config (configuration du tenant)
```

## Namespaces Système

### `system`
- **Usage** : Administration et gestion des namespaces
- **Database** : `system`
- **Permissions** : Admin uniquement

### `catalog`
- **Usage** : Catalogue global des tenants et applications
- **Database** : `main`
- **Tables principales** :
  - `tenant` : Liste des tenants
  - `tenant_application` : Applications par tenant
  - `module` : Modules disponibles

## Namespaces Tenant

### `tenant_{name}`
- **Usage** : Données spécifiques au tenant
- **Database** : `main`
- **Isolation** : Complète entre tenants

### `tenant_{name}_{app}`
- **Usage** : Données spécifiques à une application dans un tenant
- **Database** : `main`
- **Isolation** : Par application et par tenant

## Avantages

1. **Isolation complète** : Chaque tenant a ses propres namespaces
2. **Sécurité** : Impossible d'accéder aux données d'un autre tenant
3. **Scalabilité** : Ajout facile de nouveaux tenants
4. **Maintenance** : Gestion centralisée via le catalogue
5. **Flexibilité** : Chaque tenant peut avoir des applications différentes

## Exemples d'utilisation

```typescript
// Accéder au catalogue
await client.useCatalog();

// Accéder à un tenant spécifique
await client.useTenant('acme_corp');

// Accéder à une application dans un tenant
await client.useTenantApplication('acme_corp', 'crm');
``` 