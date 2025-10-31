# 🎨 Architecture UI LyxalSuite - Document de Référence

*Architecture d'interface utilisateur hiérarchique pour LyxalSuite - Guide d'implémentation étape par étape*

---

## 🎯 **Vue d'Ensemble de l'Architecture**

### **Philosophie d'Architecture : Hybride Intelligente**
Cette architecture combine la **réutilisation maximale de code** avec la **spécialisation par niveau** pour créer une expérience utilisateur cohérente tout en respectant les besoins spécifiques de chaque niveau hiérarchique.

### **Principe Directeur**
- **Niveau 0** : Console dédiée (contrôle plateforme unique)
- **Niveaux 1-3** : Framework unifié avec use cases (interface 3-en-1)
- **Niveaux 4-5** : Templates industrie déployés (SaaS spécialisés)

---

## 🏗️ **Architecture Technique Détaillée**

### **1. Niveau 0 : LYXAL Master Console**

```typescript
interface Level0Architecture {
  module: "lyxal-master-console",
  purpose: "platform_control_and_monitoring",
  deployment: "internal_lyxal_infrastructure",
  domain: "console.lyxal.com",
  access: "lyxal_administrators_only"
}
```

**Structure du Module :**
```
lyxalsuite/lyxal-master-console/
├── package.json                     # Configuration module
├── vite.config.ts                   # Configuration build
├── src/
│   ├── main.tsx                     # Point d'entrée
│   ├── App.tsx                      # Application principale
│   ├── pages/
│   │   ├── PlatformOverview.tsx     # Vue d'ensemble plateforme
│   │   ├── InvestorManagement.tsx   # Gestion des investors
│   │   ├── RevenueAnalytics.tsx     # Analytics revenus globaux
│   │   ├── SystemControl.tsx        # Contrôle système
│   │   ├── MaintenanceManager.tsx   # Gestion maintenance
│   │   └── SecurityMonitoring.tsx   # Monitoring sécurité
│   ├── components/
│   │   ├── MasterDashboard.tsx      # Dashboard principal
│   │   ├── InvestorTable.tsx        # Table gestion investors
│   │   ├── GlobalMetrics.tsx        # Métriques globales
│   │   └── SystemStatus.tsx         # Statut système
│   ├── services/
│   │   ├── PlatformAPI.ts           # API contrôle plateforme
│   │   ├── InvestorService.ts       # Service gestion investors
│   │   └── MonitoringService.ts     # Service monitoring global
│   └── types/
│       ├── Platform.ts              # Types plateforme
│       └── Investor.ts              # Types investor
└── module.config.json               # Configuration spécifique niveau 0
```

**Fonctionnalités Clés :**
- **Monitoring global** : Vue d'ensemble de tous les niveaux
- **Gestion investors** : Création, suspension, analytics
- **Contrôle système** : Maintenance, déploiements, sécurité
- **Analytics revenus** : Revenus globaux, commissions, prédictions
- **Support escalation** : Gestion tickets critiques

### **2. Niveaux 1-3 : LyxalKitUI Unifié**

```typescript
interface Levels1to3Architecture {
  framework: "lyxalkitui",
  approach: "single_app_multi_usecase",
  routing: "intelligent_level_usecase_detection",
  deployment: "domain_specific_configuration"
}
```

**Structure Étendue LyxalKitUI :**
```
lyxalsuite/lyxalkitui/
├── src/
│   ├── pages/
│   │   ├── universal/                    # Composants universels
│   │   │   ├── UniversalDashboard.tsx    # Dashboard adaptatif
│   │   │   ├── UniversalRouter.tsx       # Routing intelligent
│   │   │   ├── ClientPortal.tsx          # Portail client universel
│   │   │   ├── CommercialSite.tsx        # Site commercial générique
│   │   │   └── InternalInterface.tsx     # Interface interne adaptative
│   │   ├── level-specific/               # Spécificités par niveau
│   │   │   ├── investor/
│   │   │   │   ├── InvestorDashboard.tsx
│   │   │   │   ├── BusinessManagement.tsx
│   │   │   │   └── InvestorAnalytics.tsx
│   │   │   ├── business/
│   │   │   │   ├── BusinessDashboard.tsx
│   │   │   │   ├── DeveloperManagement.tsx
│   │   │   │   └── BusinessAnalytics.tsx
│   │   │   └── developer/
│   │   │       ├── DeveloperDashboard.tsx
│   │   │       ├── ContractorManagement.tsx
│   │   │       └── TemplateManager.tsx
│   │   └── monitoring/
│   │       └── surreal/                  # Réutilise monitoring existant
│   ├── components/
│   │   ├── shared/                       # Composants partagés
│   │   │   ├── HierarchicalNav.tsx       # Navigation hiérarchique
│   │   │   ├── LevelBadge.tsx            # Badge niveau utilisateur
│   │   │   ├── UniversalHeader.tsx       # Header adaptatif
│   │   │   └── PermissionGate.tsx        # Contrôle permissions
│   │   ├── forms/
│   │   │   ├── CreateBusinessForm.tsx
│   │   │   ├── CreateDeveloperForm.tsx
│   │   │   └── CreateContractorForm.tsx
│   │   └── widgets/
│   │       ├── RevenueWidget.tsx
│   │       ├── PerformanceWidget.tsx
│   │       └── HierarchyWidget.tsx
│   ├── hooks/
│   │   ├── useLevelContext.tsx           # Context niveau/usecase
│   │   ├── useHierarchyPermissions.tsx   # Permissions hiérarchiques
│   │   ├── useDomainConfig.tsx           # Configuration domaine
│   │   └── useUniversalRouting.tsx       # Routing universel
│   ├── services/
│   │   ├── HierarchyService.ts           # Service hiérarchie
│   │   ├── PermissionService.ts          # Service permissions
│   │   └── ConfigurationService.ts       # Service configuration
│   └── utils/
│       ├── levelDetection.ts             # Détection niveau
│       ├── domainAnalysis.ts             # Analyse domaine
│       └── routingLogic.ts               # Logique routing
```

**Interface 3-en-1 Implementation :**
```typescript
interface TripleInterface {
  internal: {
    route: "admin.{domain}",
    purpose: "gestion_interne_niveau",
    users: ["admin", "manager", "employee"],
    features: ["dashboard", "management", "analytics", "settings"]
  },
  client: {
    route: "portal.{domain}", 
    purpose: "interface_niveau_inferieur",
    users: ["client_admin", "client_user"],
    features: ["client_dashboard", "service_management", "billing"]
  },
  commercial: {
    route: "{domain}",
    purpose: "site_promotionnel_vente", 
    users: ["public", "prospects"],
    features: ["landing_page", "pricing", "signup", "demos"]
  }
}
```

### **3. Niveaux 4-5 : Templates Industrie**

```typescript
interface Levels4to5Architecture {
  approach: "industry_template_instances",
  deployment: "contractor_specific_domains",
  customization: "template_based_configuration"
}
```

**Structure Templates :**
```
lyxalsuite/lyxalkitui/templates/
├── restaurant/
│   ├── RestaurantApp.tsx            # App restaurant complète
│   ├── pages/
│   │   ├── Dashboard.tsx            # Dashboard restaurant
│   │   ├── MenuManager.tsx          # Gestion menu
│   │   ├── Reservations.tsx         # Système réservations
│   │   ├── Orders.tsx               # Gestion commandes
│   │   └── Customers.tsx            # Gestion clients
│   ├── components/
│   │   ├── MenuCard.tsx             # Carte menu
│   │   ├── BookingWidget.tsx        # Widget réservation
│   │   └── OrderTracker.tsx         # Suivi commandes
│   ├── config.json                  # Configuration industrie
│   └── branding.config.ts           # Configuration branding
├── ecommerce/
│   ├── EcommerceApp.tsx
│   ├── pages/
│   │   ├── ProductCatalog.tsx
│   │   ├── OrderManagement.tsx
│   │   ├── Inventory.tsx
│   │   └── CustomerService.tsx
│   └── config.json
├── legal/
│   ├── LegalApp.tsx
│   ├── pages/
│   │   ├── CaseManagement.tsx
│   │   ├── DocumentManager.tsx
│   │   ├── ClientPortal.tsx
│   │   └── Billing.tsx
│   └── config.json
└── shared/
    ├── ContractorBase.tsx           # Base commune contractors
    ├── CustomerInterface.tsx        # Interface clients finaux
    └── BaseComponents/              # Composants base templates
```

---

## 🔄 **Routing et Configuration Intelligente**

### **Domain-Based Routing Logic**
```typescript
interface RoutingStrategy {
  domain_detection: {
    pattern: "console.lyxal.com",
    target: "lyxal_master_console",
    level: "LEVEL_0",
    usecase: "platform_control"
  },
  subdomain_routing: {
    "admin.{domain}": {
      target: "lyxalkitui",
      usecase: "internal",
      level: "detected_from_domain_config"
    },
    "portal.{domain}": {
      target: "lyxalkitui", 
      usecase: "client",
      level: "detected_from_domain_config"
    },
    "{domain}": {
      target: "lyxalkitui_or_template",
      usecase: "commercial_or_saas",
      level: "detected_from_domain_config"
    }
  }
}
```

### **Configuration par Domaine**
```typescript
interface DomainConfiguration {
  "investor-corp.com": {
    level: "INVESTOR",
    owner_id: "investor_123",
    branding: {
      logo: "https://cdn.investor-corp.com/logo.png",
      colors: { primary: "#1a365d", secondary: "#2d3748" },
      name: "Investor Corp Solutions"
    },
    modules: ["business_management", "analytics", "billing"],
    permissions: ["create_business", "manage_hierarchy"]
  },
  "business-france.com": {
    level: "BUSINESS",
    owner_id: "business_456", 
    parent_id: "investor_123",
    branding: {
      logo: "https://cdn.business-france.com/logo.png",
      colors: { primary: "#2b6cb0", secondary: "#3182ce" },
      name: "Business France"
    },
    modules: ["developer_management", "local_analytics"],
    permissions: ["create_developer", "manage_contractors"]
  }
}
```

---

## 🛠️ **Services et APIs**

### **Services Hiérarchiques**
```typescript
interface HierarchicalServices {
  LevelDetectionService: {
    detectFromDomain: "(domain: string) => Level",
    detectFromAuth: "(token: JWT) => Level", 
    detectFromContext: "(context: AppContext) => Level"
  },
  PermissionService: {
    checkHierarchicalPermission: "(user: User, action: Action, target: Target) => boolean",
    getInheritedPermissions: "(level: Level, parentId: string) => Permission[]",
    validateLevelAccess: "(user: User, targetLevel: Level) => boolean"
  },
  ConfigurationService: {
    getDomainConfig: "(domain: string) => DomainConfig",
    getBrandingConfig: "(ownerId: string) => BrandingConfig",
    getModuleConfig: "(level: Level, ownerId: string) => ModuleConfig"
  },
  RoutingService: {
    resolveRoute: "(domain: string, path: string) => RouteResolution",
    getUseCaseFromRoute: "(domain: string, subdomain: string) => UseCase",
    buildHierarchicalNavigation: "(userLevel: Level, permissions: Permission[]) => Navigation"
  }
}
```

### **APIs par Niveau**
```typescript
interface LevelAPIs {
  Level0_APIs: {
    "/api/platform/investors": "CRUD investors",
    "/api/platform/analytics": "Analytics globales", 
    "/api/platform/system": "Contrôle système",
    "/api/platform/maintenance": "Gestion maintenance"
  },
  Level1to3_APIs: {
    "/api/hierarchy/create": "Création niveau inférieur",
    "/api/hierarchy/manage": "Gestion hiérarchie",
    "/api/hierarchy/analytics": "Analytics niveau",
    "/api/hierarchy/billing": "Facturation"
  },
  Level4to5_APIs: {
    "/api/saas/operations": "Opérations SaaS",
    "/api/saas/customers": "Gestion clients finaux",
    "/api/saas/data": "Données métier"
  }
}
```

---

## 🔐 **Authentication et Permissions**

### **Stratégie d'Authentification**
```typescript
interface AuthStrategy {
  level_0: {
    method: "dedicated_admin_auth",
    provider: "internal_lyxal_auth",
    mfa: "required",
    session: "24h_max"
  },
  levels_1to3: {
    method: "logto_hierarchical_sso",
    provider: "logto_multi_tenant",
    cascade: "level_based_permissions",
    session: "configurable_per_level"
  },
  levels_4to5: {
    method: "contractor_specific_auth",
    provider: "logto_app_specific",
    isolation: "strict_tenant_isolation",
    session: "standard_web_session"
  }
}
```

### **Matrice de Permissions**
```typescript
interface PermissionMatrix {
  LEVEL_0_LYXAL: {
    can_see: "everything",
    can_create: ["investors"],
    can_manage: ["platform", "investors", "system"], 
    can_access: ["all_levels", "all_data"]
  },
  LEVEL_1_INVESTOR: {
    can_see: ["own_hierarchy", "direct_business", "cascade_all"],
    can_create: ["business"],
    can_manage: ["own_business", "hierarchy_analytics"],
    can_access: ["business_interfaces", "analytics"]
  },
  LEVEL_2_BUSINESS: {
    can_see: ["own_developers", "own_contractors"],
    can_create: ["developers"],
    can_manage: ["own_developers", "branch_analytics"],
    can_access: ["developer_interfaces"]
  },
  LEVEL_3_DEVELOPER: {
    can_see: ["own_contractors"],
    can_create: ["contractors"],
    can_manage: ["own_contractors", "templates"],
    can_access: ["contractor_interfaces"]
  },
  LEVEL_4_CONTRACTOR: {
    can_see: ["own_data", "own_customers"],
    can_create: ["end_users"],
    can_manage: ["own_saas", "customers"],
    can_access: ["saas_interface"]
  }
}
```

---

## 📱 **Responsive Design et UX**

### **Design System Unifié**
```typescript
interface DesignSystem {
  base_framework: {
    ui: "KitUI + DaisyUI + TailwindCSS",
    consistency: "shared_component_library",
    theming: "level_specific_branding"
  },
  responsive_strategy: {
    mobile_first: "progressive_enhancement",
    breakpoints: "tailwind_standard_breakpoints",
    navigation: "adaptive_mobile_navigation"
  },
  accessibility: {
    standards: "WCAG_2.1_AA_compliance",
    testing: "automated_accessibility_testing",
    support: "screen_reader_keyboard_navigation"
  }
}
```

### **Composants Réutilisables**
```typescript
interface SharedComponents {
  navigation: [
    "HierarchicalNav", "LevelBreadcrumb", "QuickActions"
  ],
  data_display: [
    "UniversalTable", "MetricsCard", "AnalyticsChart" 
  ],
  forms: [
    "HierarchicalForm", "LevelSpecificForm", "ValidationWrapper"
  ],
  feedback: [
    "NotificationSystem", "LoadingStates", "ErrorBoundaries"
  ]
}
```

---

## 🚀 **Plan d'Implémentation Étape par Étape**

### **Phase 1 : Fondations (Semaines 1-2)**

#### **Semaine 1 : Niveau 0 LYXAL Master Console**
- [ ] Créer module `lyxal-master-console`
- [ ] Implémenter dashboard niveau 0 LYXAL
- [ ] Développer services hiérarchiques base
- [ ] Configuration SurrealDB niveau 0

#### **Semaine 2 : Bases LyxalKitUI**
- [ ] Étendre `lyxalkitui` avec routing intelligent
- [ ] Créer composants universels partagés
- [ ] Implémenter système permissions hiérarchiques

---

## 📋 **Checklist de Démarrage - Niveau 0**

### **Prérequis Techniques**
- [ ] SurrealDB configuré avec namespace `lyxal_master`
- [ ] Logto configuré pour authentification admin
- [ ] Environnement de développement prêt

### **Étapes d'Implémentation Niveau 0**
1. [ ] Créer structure module `lyxal-master-console`
2. [ ] Configurer package.json et vite.config.ts
3. [ ] Implémenter App.tsx principal
4. [ ] Créer PlatformOverview.tsx (dashboard principal)
5. [ ] Développer InvestorManagement.tsx
6. [ ] Intégrer services SurrealDB
7. [ ] Tests et validation

---

## 🎯 **Objectif Immédiat**

**Commencer par le Niveau 0 LYXAL Master Console** pour établir les fondations de contrôle de la plateforme avant de progresser vers les autres niveaux.

---

*Document de référence - Version 1.0*  
*Statut : Prêt pour Phase 1 - Niveau 0* 