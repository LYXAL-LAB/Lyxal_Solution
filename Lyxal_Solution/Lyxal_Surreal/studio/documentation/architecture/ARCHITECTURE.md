# 🏗️ Architecture - Lyxal Studio

## Vue d'Ensemble

Lyxal Studio est conçu selon le principe **Database-Driven UI** : toute la structure de l'interface est stockée dans SurrealDB et rendue dynamiquement par React.

**95% Configuration / 5% Code**

---

## 🔄 Flux de Rendu Complet

```
┌──────────────────────────────────────────────────────────────┐
│ ÉTAPE 1 : CONNEXION UTILISATEUR                              │
│ (Lyxal Identity)                                             │
└────────────────────┬─────────────────────────────────────────┘
                     │
                     ↓ Authentification
┌──────────────────────────────────────────────────────────────┐
│ ÉTAPE 2 : CHARGEMENT CONFIGURATION                           │
│                                                               │
│  1. Récupérer tenant_id de l'utilisateur                     │
│  2. SELECT * FROM studio_config WHERE tenant_id = $tenant    │
│  3. Charger theme, logo, modules activés                     │
└────────────────────┬─────────────────────────────────────────┘
                     │
                     ↓ Config chargée
┌──────────────────────────────────────────────────────────────┐
│ ÉTAPE 3 : CONSTRUCTION DU MENU                               │
│                                                               │
│  1. SELECT * FROM studio_menu                                │
│     WHERE permissions CONTAINS $auth.role                    │
│     AND (modules = [] OR modules CONTAINSANY $active_modules)│
│  2. Construction hiérarchique (parent/child)                 │
│  3. Tri par order ASC                                        │
└────────────────────┬─────────────────────────────────────────┘
                     │
                     ↓ Menu construit
┌──────────────────────────────────────────────────────────────┐
│ ÉTAPE 4 : RENDU DE LA PAGE                                   │
│                                                               │
│  1. Router détecte l'URL (ex: /crm/dashboard)               │
│  2. SELECT * FROM studio_page WHERE url = '/crm/dashboard'   │
│  3. Charger les widgets de la page                           │
│  4. Pour chaque widget, exécuter sa query                    │
│  5. Rendu des composants React avec les données              │
└────────────────────┬─────────────────────────────────────────┘
                     │
                     ↓ Page rendue
┌──────────────────────────────────────────────────────────────┐
│ ÉTAPE 5 : INTERACTIONS UTILISATEUR                           │
│                                                               │
│  • Click sur menu → Chargement nouvelle page                 │
│  • Submit form → Validation + INSERT/UPDATE DB               │
│  • Filter table → UPDATE query + re-render                   │
│  • LIVE QUERY → Auto-update en temps réel                    │
└──────────────────────────────────────────────────────────────┘
```

---

## 🎨 Architecture en Couches

```
┌────────────────────────────────────────────────────────────┐
│                  COUCHE PRÉSENTATION                        │
│                     (React Components)                      │
├────────────────────────────────────────────────────────────┤
│  • StudioEngine (orchestrateur principal)                  │
│  • StudioMenu (navigation)                                 │
│  • StudioPage (conteneur de page)                          │
│  • StudioWidget (composants réutilisables)                 │
│  • StudioForm (formulaires dynamiques)                     │
│  • StudioTable (listes avec filtres/tri)                   │
└────────────────┬───────────────────────────────────────────┘
                 │
                 ↓ Props dynamiques depuis DB
┌────────────────────────────────────────────────────────────┐
│                COUCHE CONFIGURATION                         │
│                    (SurrealDB Tables)                       │
├────────────────────────────────────────────────────────────┤
│  • studio_config (config globale par tenant)               │
│  • studio_menu (structure navigation)                      │
│  • studio_page (définition pages)                          │
│  • studio_form (définition formulaires)                    │
│  • studio_table (définition listes)                        │
│  • studio_dashboard (définition dashboards)                │
│  • studio_widget (widgets réutilisables)                   │
│  • studio_theme (thèmes visuels)                           │
│  • studio_permission (contrôle d'accès)                    │
└────────────────┬───────────────────────────────────────────┘
                 │
                 ↓ Queries sur données métier
┌────────────────────────────────────────────────────────────┐
│                  COUCHE DONNÉES MÉTIER                      │
│                  (Business Tables)                          │
├────────────────────────────────────────────────────────────┤
│  • contact, company, deal (CRM)                            │
│  • invoice, quote (Sales)                                  │
│  • campaign (Marketing)                                    │
│  • project, task (Project Management)                      │
│  • ... toutes les tables business                          │
└────────────────────────────────────────────────────────────┘
```

---

## 🧩 Composants Principaux

### 1. StudioEngine

**Rôle** : Orchestrateur principal qui charge la configuration et initialise l'application.

```typescript
<StudioEngine 
  tenant="lyxal"
  user={currentUser}
  onConfigLoad={(config) => console.log('Config loaded', config)}
>
  {/* Application complète */}
</StudioEngine>
```

**Responsabilités** :
- Charger `studio_config` pour le tenant
- Initialiser le thème
- Configurer les routes dynamiques
- Gérer les permissions globales

### 2. StudioMenu

**Rôle** : Construire et afficher la navigation dynamique.

```typescript
<StudioMenu 
  tenant="lyxal"
  role={user.role}
  activeModules={user.enabled_modules}
  onMenuClick={(item) => navigate(item.url)}
/>
```

**Responsabilités** :
- Récupérer les menus autorisés
- Construire l'arborescence hiérarchique
- Gérer les menus actifs/inactifs
- Afficher les icônes et labels ML

### 3. StudioPage

**Rôle** : Rendre une page complète à partir de sa définition DB.

```typescript
<StudioPage 
  pageCode="crm_dashboard"
  tenant="lyxal"
  onLoad={(page) => console.log('Page loaded', page)}
/>
```

**Responsabilités** :
- Charger la définition de la page
- Instancier les widgets
- Exécuter les queries des widgets
- Gérer le layout (grid, flex, etc.)

### 4. StudioForm

**Rôle** : Générer et gérer un formulaire dynamique.

```typescript
<StudioForm 
  formCode="contact_create"
  onSubmit={(data) => console.log('Form submitted', data)}
  onValidationError={(errors) => console.log('Errors', errors)}
/>
```

**Responsabilités** :
- Charger la définition du formulaire
- Générer les champs dynamiquement
- Valider les données (client-side)
- Soumettre à SurrealDB (INSERT/UPDATE)

### 5. StudioTable

**Rôle** : Afficher une liste de données avec filtres et tri.

```typescript
<StudioTable 
  tableCode="contact_list"
  onRowClick={(row) => navigate(`/crm/contact/${row.id}`)}
  onFilterChange={(filters) => console.log('Filters', filters)}
/>
```

**Responsabilités** :
- Charger la définition de la table
- Exécuter la query avec filtres/tri
- Afficher les colonnes configurées
- Gérer la pagination

### 6. StudioWidget

**Rôle** : Composant réutilisable (stat card, chart, etc.).

```typescript
<StudioWidget 
  widgetCode="contacts_count"
  refreshInterval={60000}  // 1 minute
/>
```

**Responsabilités** :
- Charger la définition du widget
- Exécuter la query associée
- Rendu selon le type (stat, chart, list, etc.)
- Auto-refresh si configuré

---

## 🔐 Système de Permissions

### Architecture des Permissions

```
┌────────────────────────────────────────────┐
│          Utilisateur (Identity)             │
│  • role: "admin" | "user" | "guest"        │
│  • tenant_id: "lyxal" | "batipro"          │
│  • enabled_modules: ["crm", "sales"]       │
└────────────────┬───────────────────────────┘
                 │
                 ↓ Vérification permissions
┌────────────────────────────────────────────┐
│      studio_permission (Règles)             │
│  • resource_type: "menu" | "page" | "form" │
│  • resource_id: record<studio_*>           │
│  • required_roles: ["admin"]               │
│  • required_modules: ["crm"]               │
└────────────────┬───────────────────────────┘
                 │
                 ↓ Appliquées dynamiquement
┌────────────────────────────────────────────┐
│         Composants Studio                   │
│  • StudioMenu filtre les menus             │
│  • StudioPage vérifie l'accès              │
│  • StudioForm désactive certains champs    │
└────────────────────────────────────────────┘
```

### Exemple de Vérification

```typescript
// Fonction de vérification permissions
const checkPermission = async (resource, user) => {
  const permissions = await db.query(`
    SELECT * FROM studio_permission
    WHERE resource_id = ${resource.id}
    AND (
      required_roles CONTAINS '${user.role}'
      OR required_roles = []
    )
    AND (
      required_modules CONTAINSANY ${user.enabled_modules}
      OR required_modules = []
    )
  `);
  
  return permissions.length > 0;
};
```

---

## 🔄 Réactivité avec LIVE QUERY

### Architecture Temps Réel

```
┌────────────────────────────────────────────┐
│      Admin modifie la config               │
│  UPDATE studio_config:lyxal SET            │
│    primary_color = "#FF0000"               │
└────────────────┬───────────────────────────┘
                 │
                 ↓ Event dans SurrealDB
┌────────────────────────────────────────────┐
│      LIVE QUERY détecte le changement      │
│  LIVE SELECT * FROM studio_config          │
│  WHERE tenant_id = 'lyxal'                 │
└────────────────┬───────────────────────────┘
                 │
                 ↓ Notification WebSocket
┌────────────────────────────────────────────┐
│   Frontend React reçoit la notification    │
│  • State mis à jour automatiquement        │
│  • Re-render des composants concernés      │
│  • Thème appliqué instantanément           │
└────────────────────────────────────────────┘
```

### Implémentation

```typescript
// Hook React pour LIVE QUERY
const useStudioConfig = (tenant) => {
  const [config, setConfig] = useState(null);

  useEffect(() => {
    // Query initiale
    db.query(`SELECT * FROM studio_config WHERE tenant_id = '${tenant}'`)
      .then(setConfig);

    // LIVE QUERY pour réactivité
    const liveQuery = db.live(
      `SELECT * FROM studio_config WHERE tenant_id = '${tenant}'`,
      (update) => {
        if (update.action === 'UPDATE') {
          setConfig(update.result);
        }
      }
    );

    return () => liveQuery.kill();
  }, [tenant]);

  return config;
};
```

---

## 📊 Performance & Optimisation

### 1. Caching Intelligent

```typescript
// Cache des configs par tenant
const configCache = new Map();

const getConfig = async (tenant) => {
  if (configCache.has(tenant)) {
    return configCache.get(tenant);
  }
  
  const config = await db.query(`SELECT * FROM studio_config WHERE tenant_id = '${tenant}'`);
  configCache.set(tenant, config);
  
  return config;
};
```

### 2. Lazy Loading des Pages

```typescript
// Charger les pages à la demande
const StudioPage = ({ pageCode }) => {
  const [page, setPage] = useState(null);
  
  useEffect(() => {
    // Chargement uniquement quand nécessaire
    db.query(`SELECT * FROM studio_page WHERE code = '${pageCode}'`)
      .then(setPage);
  }, [pageCode]);
  
  if (!page) return <Skeleton />;
  return <PageRenderer page={page} />;
};
```

### 3. Préchargement des Menus

```typescript
// Précharger le menu au démarrage
const App = () => {
  useEffect(() => {
    // Préchargement du menu (critique)
    db.query(`SELECT * FROM studio_menu WHERE active = true`)
      .then(cacheMenu);
  }, []);
};
```

### 4. Pagination et Virtualisation

```typescript
// Pour les grandes listes
<StudioTable 
  tableCode="all_contacts"
  pageSize={50}
  virtualScroll={true}  // Virtual scrolling pour > 1000 rows
/>
```

---

## 🎯 Patterns de Développement

### Pattern 1 : Configuration First

```
1. Définir la structure dans SurrealDB
2. Tester avec des seeds
3. Adapter le frontend si besoin
4. Déployer la config (pas le code)
```

### Pattern 2 : Progressive Enhancement

```
Version 1 : Config simple (logo, couleurs)
Version 2 : Menus dynamiques
Version 3 : Pages configurables
Version 4 : Formulaires complets
```

### Pattern 3 : Fallback Gracieux

```typescript
// Si la config n'existe pas, fallback sur défaut
const config = await getConfig(tenant) || defaultConfig;
```

### Pattern 4 : Validation Côté DB

```surql
-- Validation dans la table
DEFINE FIELD primary_color ON studio_config
  TYPE string
  ASSERT string::starts_with($value, '#') AND string::len($value) = 7;
```

---

## 🔗 Intégrations Externes

### Intégration avec Lyxal Identity

```typescript
// Récupérer le tenant de l'utilisateur authentifié
const { user } = useAuth();
const config = useStudioConfig(user.tenant_id);
```

### Intégration avec Lyxal Mail

```surql
-- Formulaire de création de campagne email
CREATE studio_form:campaign_create SET
  table = "email_campaign",  -- Table Lyxal Mail
  fields = [
    { name: "subject", type: "text", required: true },
    { name: "template", type: "relation", relation_table: "email_template" }
  ];
```

### Intégration avec Modules Business

```surql
-- Dashboard CRM utilisant les données business
CREATE studio_dashboard:crm SET
  widgets = [
    {
      type: "stat",
      query: "SELECT count() FROM contact WHERE status = 'active'"
    }
  ];
```

---

## 🎨 Architecture Multi-Tenant

```
┌──────────────────────────────────────────────────┐
│           SurrealDB Cloud (Single Instance)       │
├──────────────────────────────────────────────────┤
│                                                   │
│  studio_config:lyxal                              │
│    ├─ app_name: "Lyxal Suite"                     │
│    ├─ primary_color: "#3B82F6"                    │
│    └─ enabled_modules: [all]                      │
│                                                   │
│  studio_config:batipro                            │
│    ├─ app_name: "BatiPro"                         │
│    ├─ primary_color: "#FF6B35"                    │
│    └─ enabled_modules: ["crm", "project"]         │
│                                                   │
│  studio_config:comptapro                          │
│    ├─ app_name: "ComptaPro"                       │
│    ├─ primary_color: "#10B981"                    │
│    └─ enabled_modules: ["treasury", "invoicing"]  │
│                                                   │
└──────────────────────────────────────────────────┘
         ↓                ↓                ↓
┌────────────┐  ┌────────────┐  ┌────────────┐
│ app.lyxal  │  │app.batipro │  │comptapro   │
│   .com     │  │   .com     │  │  .com      │
└────────────┘  └────────────┘  └────────────┘
```

**Isolation garantie** par le `tenant_id` dans toutes les queries ! 🔒

---

---

## 📱 Architecture Multi-Plateforme (Web + Mobile)

### Vue d'Ensemble

```
┌────────────────────────────────────────────────────────────┐
│              SURREALDB CLOUD (Source Unique)               │
│  • studio_config (partagé web + mobile)                    │
│  • studio_menu (partagé)                                   │
│  • studio_page (partagé)                                   │
│  • studio_form (partagé)                                   │
│  • studio_widget (partagé)                                 │
└────────────────────┬───────────────────────────────────────┘
                     │ WebSocket Sécurisé (WSS)
         ┌───────────┴───────────┐
         ↓                       ↓
┌──────────────────────┐  ┌──────────────────────┐
│   WEB (React)        │  │ MOBILE (React Native)│
│  • DaisyUI           │  │ • React Navigation   │
│  • Tailwind CSS      │  │ • RN Paper/NativeBase│
│  • Lucide Icons      │  │ • Vector Icons       │
│  • React Router      │  │ • Drawer + Tabs      │
└──────────────────────┘  └──────────────────────┘
```

### Flux de Rendu Mobile

```
┌──────────────────────────────────────────────────────────────┐
│ ÉTAPE 1 : CONNEXION UTILISATEUR (Lyxal Identity)             │
└────────────────────┬─────────────────────────────────────────┘
                     ↓
┌──────────────────────────────────────────────────────────────┐
│ ÉTAPE 2 : CHARGEMENT CONFIGURATION                           │
│  1. Récupérer tenant_id                                      │
│  2. SELECT * FROM studio_config WHERE tenant_id = $tenant    │
│  3. Charger mobile_theme, logo, modules                      │
└────────────────────┬─────────────────────────────────────────┘
                     ↓
┌──────────────────────────────────────────────────────────────┐
│ ÉTAPE 3 : CONSTRUCTION NAVIGATION (Drawer/Tabs)              │
│  1. SELECT * FROM studio_menu WHERE ...                      │
│  2. Créer navigation structure                               │
│  3. Appliquer icônes et labels ML                            │
└────────────────────┬─────────────────────────────────────────┘
                     ↓
┌──────────────────────────────────────────────────────────────┐
│ ÉTAPE 4 : RENDU DES SCREENS                                  │
│  1. Navigator détecte la navigation                          │
│  2. SELECT * FROM studio_page WHERE code = ...               │
│  3. Charger widgets et exécuter queries                      │
│  4. Rendu composants natifs avec données                     │
└──────────────────────────────────────────────────────────────┘
```

### Composants React Native

#### StudioEngine.native.tsx

```typescript
import React, { useEffect, useState } from 'react';
import { View, StyleSheet } from 'react-native';
import { NavigationContainer } from '@react-navigation/native';
import { createDrawerNavigator } from '@react-navigation/drawer';
import { db } from '@/lib/surrealdb';

const Drawer = createDrawerNavigator();

export const StudioEngine = ({ tenant }) => {
  const [config, setConfig] = useState(null);
  const { user } = useAuth();

  useEffect(() => {
    const loadConfig = async () => {
      const result = await db.query(`
        SELECT fn::studio_get_config('${tenant}')
      `);
      
      if (result?.[0]?.config) {
        setConfig(result[0].config);
      }
    };

    loadConfig();
  }, [tenant]);

  if (!config) return <LoadingScreen />;

  return (
    <NavigationContainer>
      <Drawer.Navigator
        screenOptions={{
          drawerStyle: {
            backgroundColor: config.mobile_theme?.background,
          },
          headerStyle: {
            backgroundColor: config.mobile_theme?.primary,
          },
        }}
      >
        <StudioMenuNavigator 
          config={config} 
          role={user.role} 
          modules={config.enabled_modules} 
        />
      </Drawer.Navigator>
    </NavigationContainer>
  );
};
```

### Avantages Architecture Multi-Plateforme

| Aspect | Bénéfice |
|--------|----------|
| **Configuration** | 1 config DB → Web + Mobile |
| **Menus** | Identiques, adapté au UI natif |
| **Pages** | Même structure, rendu natif |
| **Thèmes** | Synchronisés en temps réel |
| **Maintenance** | Division par 2 du travail |
| **Données** | Partagées via SurrealDB Cloud |

---

## 🎨 Architecture DaisyUI + Lyxal Studio

### Intégration avec Thèmes Dynamiques

```
┌──────────────────────────────────────────────┐
│         SURREALDB (Configuration)             │
│  • studio_config.web_theme = "corporate"     │
│  • studio_config.daisy_custom = {...}        │
└────────────────┬─────────────────────────────┘
                 │
                 ↓ Chargement config
┌──────────────────────────────────────────────┐
│      REACT FRONTEND (StudioEngine)            │
│  • Lecture config.web_theme                  │
│  • Application <div data-theme={...}>        │
│  • Ou Custom CSS Variables                   │
└────────────────┬─────────────────────────────┘
                 │
                 ↓ Rendu instantané
┌──────────────────────────────────────────────┐
│       UI avec DaisyUI Components              │
│  • btn btn-primary                           │
│  • card bg-base-100                          │
│  • menu bg-base-200                          │
│  • Tous stylés par le thème DB !             │
└──────────────────────────────────────────────┘
```

### Application Thème DaisyUI

```typescript
// Hook pour appliquer thème DaisyUI depuis DB
const applyDaisyTheme = (config: StudioConfig) => {
  const root = document.documentElement;
  
  if (config.web_theme) {
    // Thème prédéfini DaisyUI
    root.setAttribute('data-theme', config.web_theme);
  } else if (config.daisy_custom) {
    // Thème personnalisé
    Object.entries(config.daisy_custom).forEach(([key, value]) => {
      root.style.setProperty(`--${key}`, value);
    });
  }
};

// Dans StudioEngine
useEffect(() => {
  if (config?.web_theme || config?.daisy_custom) {
    applyDaisyTheme(config);
  }
}, [config]);
```

### Composants Studio avec DaisyUI

```tsx
// StudioWidget avec DaisyUI
const StatWidget = ({ widget, data }) => {
  return (
    <div className="card bg-base-100 shadow-xl">
      <div className="card-body">
        <h2 className="card-title">{widget.title.fr}</h2>
        <div className="stats shadow">
          <div className="stat">
            <div className="stat-value text-primary">
              {data?.count || 0}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

// StudioMenu avec DaisyUI
const StudioMenu = ({ menu }) => {
  return (
    <ul className="menu bg-base-200 w-56 rounded-box">
      {menu.map(item => (
        <li key={item.code}>
          <a className={item.active ? 'active' : ''}>
            <Icon name={item.icon} />
            {item.label.fr}
          </a>
        </li>
      ))}
    </ul>
  );
};
```

### Thèmes DaisyUI Disponibles

**Thèmes prédéfinis** (33 disponibles) :
- `light` (clair par défaut)
- `dark` (sombre par défaut)
- `cupcake`, `bumblebee`, `emerald`, `corporate`, `synthwave`, `retro`, `cyberpunk`, `valentine`, `halloween`, `garden`, `forest`, `aqua`, `lofi`, `pastel`, `fantasy`, `wireframe`, `black`, `luxury`, `dracula`, `cmyk`, `autumn`, `business`, `acid`, `lemonade`, `night`, `coffee`, `winter`

**Ou personnalisé** :
```surql
daisy_custom = {
  "primary": "#FF6B35",
  "secondary": "#004E89",
  "accent": "#FFC857",
  "neutral": "#1F2937",
  "base-100": "#FFFFFF"
}
```

---

## 🚀 Prochaines Étapes

1. **[DATABASE.md](./DATABASE.md)** → Voir schémas avec champs mobile/web
2. **[FUNCTIONS.md](./FUNCTIONS.md)** → Code de toutes les fonctions
3. **[GUIDE.md](./GUIDE.md)** → Guide d'utilisation pratique
4. **[INTEGRATION.md](./INTEGRATION.md)** → Intégration React + React Native
5. **[MOBILE.md](./MOBILE.md)** → Guide complet React Native
6. **[DAISYUI.md](./DAISYUI.md)** → Guide complet DaisyUI


