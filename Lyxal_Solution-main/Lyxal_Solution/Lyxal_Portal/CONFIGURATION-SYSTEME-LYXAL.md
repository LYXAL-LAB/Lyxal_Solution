# 🏗️ Configuration Système LYXAL - Architecture API Backend

## 📋 Vue d'Ensemble

**Contexte :** Développement direct en mode production avec API backend pour le niveau LYXAL uniquement.

**Approche :** Pas de mauvaises surprises au déploiement - tout testé en conditions réelles dès le début.

**Module :** `lyxal-master-console` (Niveau 0 - Contrôle plateforme)  
**Scope :** Variables système LYXAL uniquement  
**Mode :** Production dès le développement  
**Backend :** API endpoints pour configuration

---

## 🎯 Variables Système Niveau LYXAL

### Interface TypeScript

```typescript
interface LyxalSystemConfig {
  // === IDENTITÉ PLATEFORME ===
  platformName: string;           // "LYXAL Master Platform"
  platformId: string;             // "lyxal-master-001"
  environment: string;            // "production" | "staging"
  
  // === INFRASTRUCTURE TECHNIQUE ===
  surrealDbUrl: string;           // "wss://lyxal-master.surrealdb.cloud/rpc"
  surrealNamespace: string;       // "lyxal_master"
  surrealDatabase: string;        // "platform_control"
  
  // === AUTHENTIFICATION MAÎTRE ===
  logtoMasterEndpoint: string;    // "https://lyxal-master.logto.cloud"
  logtoAdminAppId: string;        // "lyxal-admin-console"
  
  // === LIMITES PLATEFORME ===
  maxInvestors: number;           // 100
  maxTotalTenants: number;        // 10000
  maxConcurrentUsers: number;     // 50000
  
  // === MONITORING GLOBAL ===
  sentryDsn: string;
  logLevel: string;               // "info" | "debug" | "error"
}
```

---

## 🔧 Architecture API Backend

### Endpoints API

```typescript
// === LECTURE CONFIGURATION ===
GET  /api/system/config                    // Configuration complète
GET  /api/system/config/infrastructure     // Config technique uniquement
GET  /api/system/config/limits             // Limites plateforme
GET  /api/system/config/:key               // Variable spécifique

// === MODIFICATION CONFIGURATION ===
PUT  /api/system/config/:key               // Mise à jour variable
POST /api/system/config/bulk               // Mise à jour multiple
POST /api/system/config/validate           // Validation avant sauvegarde

// === ADMINISTRATION ===
GET  /api/system/config/history            // Historique des changements
POST /api/system/config/rollback/:version  // Rollback vers version
GET  /api/system/config/schema             // Schéma de validation
```

### Exemple d'Utilisation

```typescript
// Lecture de configuration
const config = await fetch('/api/system/config').then(r => r.json());

// Mise à jour d'une variable
const updateSurrealConfig = async () => {
  const response = await fetch('/api/system/config/infrastructure.surrealDbUrl', {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      value: 'wss://nouvelle-instance.surrealdb.cloud/rpc',
      reason: 'Migration vers nouvelle infrastructure'
    })
  });
  
  if (response.ok) {
    // Validation automatique, test de connexion, sauvegarde avec historique
    // Notification temps réel, reconnexion automatique
  }
};
```

---

## 🗄️ Stockage SurrealDB

### Schéma de Base de Données

```sql
-- Table configuration système LYXAL
DEFINE TABLE lyxal_system_config SCHEMAFULL;
DEFINE FIELD namespace ON lyxal_system_config TYPE string;
DEFINE FIELD key ON lyxal_system_config TYPE string;
DEFINE FIELD value ON lyxal_system_config TYPE string | number | bool | object;
DEFINE FIELD type ON lyxal_system_config TYPE string;
DEFINE FIELD description ON lyxal_system_config TYPE string;
DEFINE FIELD editable ON lyxal_system_config TYPE bool DEFAULT true;
DEFINE FIELD created_at ON lyxal_system_config TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON lyxal_system_config TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_by ON lyxal_system_config TYPE string;

-- Index pour performance
DEFINE INDEX config_lookup ON lyxal_system_config COLUMNS namespace, key;
DEFINE INDEX editable_config ON lyxal_system_config COLUMNS editable;

-- Table historique
DEFINE TABLE lyxal_config_history SCHEMAFULL;
DEFINE FIELD config_id ON lyxal_config_history TYPE record(lyxal_system_config);
DEFINE FIELD old_value ON lyxal_config_history TYPE string | number | bool | object;
DEFINE FIELD new_value ON lyxal_config_history TYPE string | number | bool | object;
DEFINE FIELD changed_at ON lyxal_config_history TYPE datetime DEFAULT time::now();
DEFINE FIELD changed_by ON lyxal_config_history TYPE string;
DEFINE FIELD reason ON lyxal_config_history TYPE string;
```

### Données Initiales

```sql
-- Configuration initiale LYXAL
INSERT INTO lyxal_system_config [
  {
    namespace: "identity",
    key: "platformName",
    value: "LYXAL Master Platform",
    type: "string",
    description: "Nom de la plateforme LYXAL",
    editable: true
  },
  {
    namespace: "identity",
    key: "platformId",
    value: "lyxal-master-001",
    type: "string",
    description: "Identifiant unique de la plateforme",
    editable: false
  },
  {
    namespace: "infrastructure",
    key: "surrealDbUrl",
    value: "wss://lyxal-master.surrealdb.cloud/rpc",
    type: "url",
    description: "URL de connexion SurrealDB maître",
    editable: true
  },
  {
    namespace: "limits",
    key: "maxInvestors",
    value: 100,
    type: "number",
    description: "Nombre maximum d'investors",
    editable: true
  }
];
```

---

## 🔄 Flux de Configuration

### Architecture Complète

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Interface     │───▶│   API Backend    │───▶│   SurrealDB     │
│   Admin LYXAL   │    │   /api/config    │    │   Config Table  │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                               │
                               ▼
                       ┌──────────────────┐
                       │   Frontend App   │
                       │   (Consomme)     │
                       └──────────────────┘
```

### Scénario : Changement d'Instance SurrealDB

**Étapes :**

1. **Admin se connecte** à l'interface d'administration LYXAL
2. **Navigue** vers Configuration → Infrastructure → Base de Données
3. **Modifie** l'URL SurrealDB : `wss://nouvelle-instance.surrealdb.cloud/rpc`
4. **Valide** et sauvegarde avec raison du changement
5. **L'API** teste la connexion à la nouvelle instance
6. **Sauvegarde** en base avec historique complet
7. **Notification** temps réel aux composants frontend
8. **Reconnexion** automatique et transparente

**Résultat :** ✅ **Changement immédiat, testé, tracé et appliqué sans interruption**

---

## 🎛️ Interface d'Administration

### Intégration dans le Header

```typescript
// Ajout dans systemMenuItems du Header.tsx
{
  id: 'menu-system-configuration',
  label: 'Configuration Système',
  ariaLabel: 'Accéder à la configuration système LYXAL',
  onClick: () => navigate('/admin/system-config'),
  className: 'btn btn-sm btn-ghost justify-start !px-3 !mx-1 text-xs sm:text-sm'
}
```

### Structure de la Page d'Administration

```tsx
function SystemConfigPage() {
  return (
    <div className="container mx-auto p-6">
      <div className="flex items-center justify-between mb-6">
        <h1 className="text-2xl font-bold text-base-content">Configuration Système LYXAL</h1>
        <div className="badge badge-primary">Niveau 0 - Plateforme</div>
      </div>
      
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Identité Plateforme */}
        <ConfigSection 
          title="Identité Plateforme" 
          namespace="identity"
          icon="🏢"
          description="Informations de base de la plateforme LYXAL"
        />
        
        {/* Infrastructure Technique */}
        <ConfigSection 
          title="Infrastructure" 
          namespace="infrastructure"
          icon="🔧"
          description="Configuration technique (SurrealDB, Logto, etc.)"
        />
        
        {/* Limites Plateforme */}
        <ConfigSection 
          title="Limites & Quotas" 
          namespace="limits"
          icon="📊"
          description="Quotas et contraintes de la plateforme"
        />
        
        {/* Monitoring */}
        <ConfigSection 
          title="Monitoring" 
          namespace="monitoring"
          icon="📈"
          description="Configuration du monitoring global"
        />
      </div>
      
      {/* Historique des Changements */}
      <div className="mt-8">
        <ConfigHistory />
      </div>
    </div>
  );
}
```

### Composants de Configuration

```tsx
interface ConfigSectionProps {
  title: string;
  namespace: string;
  icon: string;
  description: string;
}

function ConfigSection({ title, namespace, icon, description }: ConfigSectionProps) {
  const { config, loading, updateConfig } = useSystemConfig(namespace);
  
  return (
    <div className="card bg-base-100 shadow-lg border border-base-300">
      <div className="card-body">
        <div className="flex items-center gap-3 mb-4">
          <span className="text-2xl">{icon}</span>
          <div>
            <h2 className="card-title text-lg">{title}</h2>
            <p className="text-sm text-base-content/70">{description}</p>
          </div>
        </div>
        
        {loading ? (
          <div className="flex justify-center py-8">
            <span className="loading loading-spinner loading-md"></span>
          </div>
        ) : (
          <div className="space-y-4">
            {Object.entries(config).map(([key, item]) => (
              <ConfigField
                key={key}
                item={item}
                onUpdate={(value) => updateConfig(namespace, key, value)}
              />
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
```

---

## 🚀 Service de Configuration

### Hook React Principal

```typescript
export function useSystemConfig(namespace?: string) {
  const [config, setConfig] = useState<SystemConfig | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  const loadConfig = useCallback(async () => {
    try {
      setLoading(true);
      const url = namespace 
        ? `/api/system/config/${namespace}` 
        : '/api/system/config';
      
      const response = await fetch(url);
      if (!response.ok) throw new Error('Erreur de chargement');
      
      const data = await response.json();
      setConfig(data);
      setError(null);
    } catch (err) {
      setError(err as Error);
    } finally {
      setLoading(false);
    }
  }, [namespace]);

  const updateConfig = useCallback(async (
    ns: string, 
    key: string, 
    value: any,
    reason?: string
  ) => {
    try {
      const response = await fetch(`/api/system/config/${ns}.${key}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ value, reason })
      });
      
      if (!response.ok) throw new Error('Erreur de mise à jour');
      
      // Recharger la configuration
      await loadConfig();
      
      // Notification de succès
      toast.success('Configuration mise à jour avec succès');
    } catch (err) {
      toast.error('Erreur lors de la mise à jour');
      throw err;
    }
  }, [loadConfig]);

  useEffect(() => {
    loadConfig();
  }, [loadConfig]);

  return {
    config,
    loading,
    error,
    updateConfig,
    refreshConfig: loadConfig
  };
}
```

### Service Backend (Express/Hono)

```typescript
// Service de configuration système
export class LyxalSystemConfigService {
  private db: Surreal;
  private cache: Map<string, any> = new Map();

  async getConfig(namespace?: string, key?: string) {
    const cacheKey = `${namespace || 'all'}.${key || 'all'}`;
    
    if (this.cache.has(cacheKey)) {
      return this.cache.get(cacheKey);
    }

    let query = 'SELECT * FROM lyxal_system_config';
    const params: any = {};

    if (namespace) {
      query += ' WHERE namespace = $namespace';
      params.namespace = namespace;
      
      if (key) {
        query += ' AND key = $key';
        params.key = key;
      }
    }

    const result = await this.db.query(query, params);
    const config = this.formatConfig(result);
    
    // Cache pendant 5 minutes
    this.cache.set(cacheKey, config);
    setTimeout(() => this.cache.delete(cacheKey), 5 * 60 * 1000);
    
    return config;
  }

  async updateConfig(namespace: string, key: string, value: any, updatedBy: string, reason?: string) {
    // 1. Validation
    await this.validateConfig(namespace, key, value);
    
    // 2. Récupération de l'ancienne valeur
    const oldConfig = await this.getConfig(namespace, key);
    
    // 3. Mise à jour
    await this.db.query(`
      UPDATE lyxal_system_config 
      SET value = $value, updated_at = time::now(), updated_by = $updatedBy
      WHERE namespace = $namespace AND key = $key
    `, { value, updatedBy, namespace, key });
    
    // 4. Historique
    await this.db.query(`
      INSERT INTO lyxal_config_history {
        config_id: (SELECT id FROM lyxal_system_config WHERE namespace = $namespace AND key = $key),
        old_value: $oldValue,
        new_value: $value,
        changed_by: $updatedBy,
        reason: $reason
      }
    `, { namespace, key, oldValue: oldConfig?.value, value, updatedBy, reason });
    
    // 5. Invalidation du cache
    this.invalidateCache(namespace);
    
    // 6. Notification temps réel (WebSocket)
    this.notifyConfigChange(namespace, key, value);
  }

  private async validateConfig(namespace: string, key: string, value: any) {
    // Validation spécifique selon le type de configuration
    if (namespace === 'infrastructure' && key === 'surrealDbUrl') {
      if (!value.startsWith('ws://') && !value.startsWith('wss://')) {
        throw new Error('URL SurrealDB invalide');
      }
      
      // Test de connexion
      await this.testSurrealConnection(value);
    }
    
    if (namespace === 'limits' && typeof value !== 'number') {
      throw new Error('Les limites doivent être des nombres');
    }
  }
}
```

---

## 🎯 Avantages de cette Architecture

### ✅ Sécurité Production
- Configuration protégée dès le développement
- Authentification et autorisation sur les endpoints
- Validation stricte des valeurs
- Historique complet des changements

### ✅ Tests Réels
- Aucune différence entre développement et production
- Test de connexion automatique lors des changements
- Validation en temps réel
- Rollback immédiat en cas de problème

### ✅ Traçabilité Complète
- Historique de tous les changements avec raison
- Qui a changé quoi et quand
- Possibilité de rollback vers n'importe quelle version
- Audit trail pour compliance

### ✅ Performance
- Cache intelligent avec TTL
- Invalidation ciblée par namespace
- Requêtes optimisées avec index
- Notification temps réel via WebSocket

### ✅ Scope Maîtrisé
- Focus uniquement sur le niveau LYXAL
- Variables critiques identifiées
- Interface d'administration dédiée
- Évolutivité contrôlée

---

## 🔄 Flux de Développement

### Phase 1 : Fondations
1. **Créer le schéma SurrealDB** avec les tables de configuration
2. **Implémenter les endpoints API** de base (GET/PUT)
3. **Créer le hook React** `useSystemConfig`
4. **Tester** avec quelques variables critiques

### Phase 2 : Interface Admin
1. **Créer la page de configuration** dans le menu système
2. **Implémenter les composants** `ConfigSection` et `ConfigField`
3. **Ajouter la validation** en temps réel
4. **Tester** l'édition et la sauvegarde

### Phase 3 : Fonctionnalités Avancées
1. **Ajouter l'historique** des changements
2. **Implémenter le rollback** vers versions précédentes
3. **Ajouter les notifications** WebSocket temps réel
4. **Optimiser** les performances avec cache

### Phase 4 : Production
1. **Tests de charge** sur l'API
2. **Validation** de tous les scénarios de changement
3. **Documentation** utilisateur
4. **Déploiement** en production

---

## 📋 Variables Système Prioritaires

### À Implémenter en Premier

```typescript
// Variables critiques niveau LYXAL
const priorityConfig = {
  // Infrastructure de base
  'infrastructure.surrealDbUrl': 'wss://lyxal-master.surrealdb.cloud/rpc',
  'infrastructure.surrealNamespace': 'lyxal_master',
  'infrastructure.surrealDatabase': 'platform_control',
  
  // Identité plateforme
  'identity.platformName': 'LYXAL Master Platform',
  'identity.platformId': 'lyxal-master-001',
  'identity.environment': 'production',
  
  // Limites critiques
  'limits.maxInvestors': 100,
  'limits.maxConcurrentUsers': 50000
};
```

Cette architecture permet un développement en mode production dès le début, avec une gestion complète et sécurisée des variables système LYXAL. 🚀 