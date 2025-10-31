# 🏗️ LyxalSuite - Référence Architecturale Principale

*Fiche de référence pour tous les modules LyxalSuite - Architecture bicéphale standardisée*

---

## 🎯 **Niveaux Architecturaux Standards**

### **INVESTOR_LEVEL** (Niveau 1 - Global)
- **Variable** : `INVESTOR_LEVEL`
- **Namespace** : `catalog`  
- **Database** : `main`, `monitoring`, `analytics`
- **Scope** : Vision globale de tous les SaaS de la plateforme
- **Personas** : Investisseurs, Platform Admins, CTO, C-Level

### **DEVELOPER_LEVEL** (Niveau 2 - SaaS)
- **Variable** : `DEVELOPER_LEVEL`
- **Namespace** : `{saas_id}` (ex: `acme-corp`)
- **Database** : `main`, `workspace_{id}`, `monitoring`
- **Scope** : Un SaaS spécifique et ses workspaces
- **Personas** : SaaS Owners, Developers, Business Users, End Users

---

## 🎨 **Use Cases par Niveau**

### **INVESTOR_LEVEL Use Cases**

#### **Monitoring & Analytics**
- `global_platform_health` - Santé globale de la plateforme
- `cross_saas_performance` - Performance comparative des SaaS
- `platform_resource_usage` - Utilisation des ressources globales
- `global_error_tracking` - Suivi des erreurs sur tous les SaaS

#### **Business Intelligence**
- `revenue_dashboard` - Dashboard revenue global
- `saas_growth_analytics` - Analytics de croissance par SaaS
- `platform_kpi_tracking` - KPI globaux de la plateforme
- `market_penetration_analysis` - Analyse de pénétration marché

#### **Administration**
- `saas_registry_management` - Gestion du registre des SaaS
- `global_user_analytics` - Analytics utilisateurs globaux
- `platform_security_overview` - Vue sécurité globale
- `compliance_reporting` - Rapports de conformité

#### **Strategic**
- `investment_roi_tracking` - Suivi ROI des investissements
- `market_opportunity_mapping` - Cartographie opportunités
- `competitive_analysis` - Analyse concurrentielle
- `scaling_recommendations` - Recommandations de scaling

### **DEVELOPER_LEVEL Use Cases**

#### **SaaS Management**
- `saas_configuration` - Configuration du SaaS
- `workspace_management` - Gestion des workspaces
- `saas_user_management` - Gestion utilisateurs SaaS
- `saas_permissions_control` - Contrôle des permissions

#### **Business Operations**
- `business_analytics` - Analytics business spécifiques
- `saas_performance_monitoring` - Monitoring performance SaaS
- `customer_journey_tracking` - Suivi parcours client
- `operational_reporting` - Rapports opérationnels

#### **Development**
- `module_installation` - Installation de modules
- `saas_customization` - Personnalisation SaaS
- `api_management` - Gestion des APIs
- `integration_management` - Gestion des intégrations

#### **Customer Experience**
- `customer_support_tools` - Outils support client
- `user_experience_analytics` - Analytics UX
- `feature_usage_tracking` - Suivi utilisation features
- `customer_satisfaction_monitoring` - Monitoring satisfaction

---

## 🛠️ **Patterns Techniques Standards**

### **Structure de Namespace**
```sql
-- INVESTOR_LEVEL
NAMESPACE catalog
    DATABASE main              -- Configuration globale
    DATABASE monitoring        -- Monitoring global
    DATABASE analytics         -- Analytics cross-SaaS
    DATABASE security          -- Sécurité globale

-- DEVELOPER_LEVEL  
NAMESPACE {saas_id}
    DATABASE main              -- Configuration SaaS
    DATABASE monitoring        -- Monitoring SaaS
    DATABASE workspace_{id}    -- Workspaces métier
```

### **Conventions de Nommage**
```typescript
// Constantes globales
export const ARCHITECTURE_LEVELS = {
  INVESTOR: 'investor_level',
  DEVELOPER: 'developer_level'
} as const;

// Namespaces
export const NAMESPACES = {
  CATALOG: 'catalog',
  SAAS: (saasId: string) => saasId.toLowerCase().replace(/[^a-z0-9]/g, '_')
} as const;

// Databases par niveau
export const DATABASES = {
  [ARCHITECTURE_LEVELS.INVESTOR]: {
    MAIN: 'main',
    MONITORING: 'monitoring', 
    ANALYTICS: 'analytics',
    SECURITY: 'security'
  },
  [ARCHITECTURE_LEVELS.DEVELOPER]: {
    MAIN: 'main',
    MONITORING: 'monitoring',
    WORKSPACE: (workspaceId: string) => `workspace_${workspaceId}`
  }
} as const;
```

### **Permissions Standards**
```sql
-- INVESTOR_LEVEL permissions
DEFINE TABLE global_metrics SCHEMAFULL
    PERMISSIONS
        FOR select WHERE $auth.level = 'platform_admin'
        FOR create, update WHERE $auth.level = 'system'
        FOR delete WHERE $auth.level = 'platform_admin';

-- DEVELOPER_LEVEL permissions  
DEFINE TABLE saas_metrics SCHEMAFULL
    PERMISSIONS
        FOR select WHERE $auth.ns = $this.namespace
        FOR create, update WHERE $auth.level CONTAINS 'saas_admin'
        FOR delete WHERE $auth.level CONTAINS 'saas_admin';
```

---

## 📋 **Templates par Module**

### **Template Monitoring Module**
```typescript
// Structure type pour module monitoring
interface MonitoringConfig {
  level: typeof ARCHITECTURE_LEVELS[keyof typeof ARCHITECTURE_LEVELS];
  namespace: string;
  useCases: string[];
  tables: {
    metrics: string;
    alerts: string;
    analytics: string;
  };
}

// Exemple configuration
const monitoringConfig: MonitoringConfig = {
  level: ARCHITECTURE_LEVELS.INVESTOR,
  namespace: NAMESPACES.CATALOG,
  useCases: [
    'global_platform_health',
    'cross_saas_performance',
    'platform_resource_usage'
  ],
  tables: {
    metrics: 'global_system_metrics',
    alerts: 'global_alerts',
    analytics: 'global_performance_analytics'
  }
};
```

### **Template Service Module**
```typescript
// Service base standardisé
abstract class LyxalBaseService {
  protected level: string;
  protected namespace: string;
  protected database: string;
  
  constructor(config: ServiceConfig) {
    this.level = config.level;
    this.namespace = config.namespace;
    this.database = config.database;
  }
  
  // Méthodes communes à tous les services
  abstract getMetrics(): Promise<any>;
  abstract getAnalytics(): Promise<any>;
  abstract performHealthCheck(): Promise<any>;
}
```

---

## 📚 **Références**

- [Overview Architecture](./overview.md)
- [Standards de Développement](./core/development-standards.md)
- [Backend Modulaire](./core/backend-modules.md)
- [Multi-Tenancy](./core/multi-tenancy.md)
- [DataTables Configurables](./concepts/datatables-configurables.md)
- [Déploiement SaaS](./deployment/saas-deployment.md)