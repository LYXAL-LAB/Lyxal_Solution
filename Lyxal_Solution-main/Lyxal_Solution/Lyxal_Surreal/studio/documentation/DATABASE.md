# 📊 Database Schema - Lyxal Studio

Ce document décrit toutes les tables et leurs schémas complets pour Lyxal Studio.

---

## 📋 Vue d'Ensemble des Tables

| Table | Rôle | Relations |
|-------|------|-----------|
| `studio_config` | Configuration globale par tenant | → `studio_theme` |
| **`studio_component`** | **Composants UI DB-driven** | → `studio_component` (auto) |
| `studio_menu` | Structure de navigation | → `studio_menu` (parent) |
| `studio_page` | Définition des pages | → `studio_widget[]`, `studio_component[]` |
| `studio_form` | Définition des formulaires | → `studio_field[]` |
| `studio_table` | Définition des listes | → `studio_column[]` |
| `studio_dashboard` | Définition des dashboards | → `studio_widget[]` |
| `studio_widget` | Widgets réutilisables | → `studio_page`, `studio_dashboard` |
| `studio_theme` | Thèmes visuels | → `studio_config` |
| `studio_permission` | Permissions granulaires | → `studio_*` |

---

## 1️⃣ studio_config

**Rôle** : Configuration globale de l'application par tenant (White-Label).

```surql
-- Définition de la table
DEFINE TABLE studio_config SCHEMAFULL
  COMMENT 'Configuration globale par tenant';

-- Champs
DEFINE FIELD tenant_id ON studio_config
  TYPE string
  ASSERT $value != NONE
  COMMENT 'Identifiant unique du tenant';

DEFINE FIELD app_name ON studio_config
  TYPE object
  COMMENT 'Nom de l'application (multilingue)';

DEFINE FIELD logo ON studio_config
  TYPE string
  COMMENT 'URL du logo';

DEFINE FIELD favicon ON studio_config
  TYPE option<string>
  COMMENT 'URL du favicon';

DEFINE FIELD primary_color ON studio_config
  TYPE string
  ASSERT string::starts_with($value, '#') AND string::len($value) = 7
  COMMENT 'Couleur primaire (hex)';

DEFINE FIELD secondary_color ON studio_config
  TYPE string
  ASSERT string::starts_with($value, '#') AND string::len($value) = 7
  COMMENT 'Couleur secondaire (hex)';

DEFINE FIELD accent_color ON studio_config
  TYPE option<string>
  COMMENT 'Couleur d\'accentuation (hex)';

DEFINE FIELD theme ON studio_config
  TYPE record<studio_theme>
  COMMENT 'Thème visuel appliqué';

DEFINE FIELD web_theme ON studio_config
  TYPE option<string>
  COMMENT 'Thème DaisyUI pour Web (light, dark, corporate, etc.)';

DEFINE FIELD daisy_custom ON studio_config
  TYPE option<object>
  COMMENT 'Thème DaisyUI personnalisé (CSS variables)';

DEFINE FIELD mobile_theme ON studio_config
  TYPE option<object>
  COMMENT 'Thème pour React Native (colors object)';

DEFINE FIELD language_default ON studio_config
  TYPE string
  DEFAULT 'fr'
  ASSERT $value IN ['fr', 'en', 'es', 'de', 'it']
  COMMENT 'Langue par défaut';

DEFINE FIELD enabled_modules ON studio_config
  TYPE array<string>
  DEFAULT []
  COMMENT 'Modules activés pour ce tenant';

DEFINE FIELD custom_css ON studio_config
  TYPE option<string>
  COMMENT 'CSS personnalisé (optionnel)';

DEFINE FIELD custom_domain ON studio_config
  TYPE option<string>
  COMMENT 'Domaine personnalisé (ex: app.batipro.com)';

DEFINE FIELD active ON studio_config
  TYPE bool
  DEFAULT true
  COMMENT 'Tenant actif ou désactivé';

DEFINE FIELD metadata ON studio_config
  TYPE object
  COMMENT 'Métadonnées de traçabilité';

DEFINE FIELD metadata.created_at ON studio_config
  TYPE datetime
  DEFAULT time::now()
  READONLY
  COMMENT 'Date de création';

DEFINE FIELD metadata.updated_at ON studio_config
  TYPE datetime
  DEFAULT time::now()
  COMMENT 'Dernière mise à jour';

-- Index
DEFINE INDEX tenant_id_unique ON studio_config FIELDS tenant_id UNIQUE;
DEFINE INDEX active_idx ON studio_config FIELDS active;
```

### Exemple de Seed

```surql
-- Configuration Lyxal par défaut (Web + Mobile)
CREATE studio_config:lyxal SET
  tenant_id = "lyxal",
  app_name = {
    fr: "Lyxal Suite",
    en: "Lyxal Suite"
  },
  logo = "https://cdn.lyxal.com/logo.svg",
  favicon = "https://cdn.lyxal.com/favicon.ico",
  primary_color = "#3B82F6",
  secondary_color = "#10B981",
  accent_color = "#F59E0B",
  theme = studio_theme:lyxal_default,
  
  -- Thème Web (DaisyUI)
  web_theme = "corporate",  -- Thème DaisyUI prédéfini
  
  -- Thème Mobile (React Native)
  mobile_theme = {
    primary: "#3B82F6",
    secondary: "#10B981",
    accent: "#F59E0B",
    background: "#FFFFFF",
    surface: "#F9FAFB",
    text: "#1F2937",
    error: "#EF4444",
    success: "#10B981"
  },
  
  language_default = "fr",
  enabled_modules = ["crm", "sales", "marketing", "treasury", "project"],
  active = true,
  metadata = {
    created_at: time::now(),
    updated_at: time::now()
  };

-- Configuration BatiPro (White-Label avec thème personnalisé)
CREATE studio_config:batipro SET
  tenant_id = "batipro",
  app_name = {
    fr: "BatiPro",
    en: "BatiPro"
  },
  logo = "https://cdn.batipro.com/logo.svg",
  primary_color = "#FF6B35",
  secondary_color = "#004E89",
  theme = studio_theme:batipro_custom,
  
  -- Thème Web personnalisé (DaisyUI custom)
  daisy_custom = {
    "primary": "#FF6B35",
    "secondary": "#004E89",
    "accent": "#FFC857",
    "neutral": "#1F2937",
    "base-100": "#FFFFFF",
    "base-200": "#F9FAFB",
    "base-300": "#E5E7EB",
    "info": "#3ABFF8",
    "success": "#36D399",
    "warning": "#FBBD23",
    "error": "#F87272"
  },
  
  -- Thème Mobile (React Native)
  mobile_theme = {
    primary: "#FF6B35",
    secondary: "#004E89",
    accent: "#FFC857",
    background: "#FFFFFF",
    surface: "#F9FAFB",
    text: "#1F2937",
    error: "#F87272",
    success: "#36D399"
  },
  
  language_default = "fr",
  enabled_modules = ["crm", "project"],
  custom_domain = "app.batipro.com",
  active = true,
  metadata = {
    created_at: time::now(),
    updated_at: time::now()
  };
```

---

## 1.5️⃣ studio_component

**Rôle** : Composants UI réutilisables définis en base de données (système DB-driven).

**Cette table est le cœur du système Lyxal Studio Runtime** - elle définit tous les composants UI comme des structures JSON stockées en base.

```surql
-- Définition de la table
DEFINE TABLE IF NOT EXISTS studio_component TYPE NORMAL SCHEMAFULL
COMMENT 'Composants UI réutilisables définis en base de données pour le système Lyxal Studio';

-- ============================================================================
-- BLOC IDENTITY : Identification unique du composant
-- ============================================================================

DEFINE FIELD IF NOT EXISTS identity ON TABLE studio_component
  TYPE object
  COMMENT 'Bloc identité : identification unique du composant';

  DEFINE FIELD IF NOT EXISTS identity.value ON TABLE studio_component
    TYPE string
    ASSERT $value != NONE AND $value != "" AND string::len($value) > 0
    COMMENT 'Valeur technique : button, card, input, table, contact_list';

  DEFINE FIELD IF NOT EXISTS identity.slug ON TABLE studio_component
    TYPE string
    ASSERT $value != NONE AND $value != "" AND string::len($value) > 0 AND string::matches($value, '^[a-z0-9-]+$')
    COMMENT 'Slug URL-friendly : button, card, input, table, contact-list';

  DEFINE FIELD IF NOT EXISTS identity.code ON TABLE studio_component
    TYPE string
    ASSERT $value != NONE AND $value != "" AND string::len($value) > 0
    COMMENT 'Code unique du composant (snake_case) : button, contact_list';

-- ============================================================================
-- BLOC PRESENTATION : Affichage dans l'interface
-- ============================================================================

DEFINE FIELD IF NOT EXISTS presentation ON TABLE studio_component
  TYPE object
  COMMENT 'Bloc présentation : affichage dans l\'interface';

  DEFINE FIELD IF NOT EXISTS presentation.name_i18n ON TABLE studio_component
    TYPE option<record<i18n_key>>
    REFERENCE ON DELETE REJECT
    COMMENT 'Nom du composant (i18n)';

  DEFINE FIELD IF NOT EXISTS presentation.description_i18n ON TABLE studio_component
    TYPE option<record<i18n_key>>
    REFERENCE ON DELETE REJECT
    COMMENT 'Description du composant (i18n)';

  DEFINE FIELD IF NOT EXISTS presentation.preview_url ON TABLE studio_component
    TYPE option<record<url>>
    REFERENCE ON DELETE REJECT
    COMMENT 'URL de prévisualisation du composant (screenshot, SVG)';

  DEFINE FIELD IF NOT EXISTS presentation.keywords ON TABLE studio_component
    TYPE option<array<string>>
    DEFAULT []
    COMMENT 'Mots-clés pour recherche : ["button", "action", "form", "ui"]';

-- ============================================================================
-- BLOC STRUCTURE : Structure JSON du composant
-- ============================================================================

DEFINE FIELD IF NOT EXISTS structure ON TABLE studio_component
  TYPE object
  COMMENT 'Bloc structure : structure JSON complète du composant (100% DB-driven)';

  DEFINE FIELD IF NOT EXISTS structure.type ON TABLE studio_component
    TYPE string
    ASSERT $value != NONE AND $value != "" AND string::len($value) > 0
    COMMENT 'Type de l\'élément racine : "button", "div", "input", "component" (pour composants imbriqués)';

  DEFINE FIELD IF NOT EXISTS structure.props ON TABLE studio_component
    FLEXIBLE
    TYPE option<object>
    COMMENT 'Props de l\'élément (camelCase) : {className: [...], onClick: {...}, disabled: "{{props.disabled}}"}';

  DEFINE FIELD IF NOT EXISTS structure.children ON TABLE studio_component
    FLEXIBLE
    TYPE option<array<object>>
    DEFAULT []
    COMMENT 'Children récursifs : [{type: "text", content: "{{props.label}}"}]';

  DEFINE FIELD IF NOT EXISTS structure.variants ON TABLE studio_component
    FLEXIBLE
    TYPE option<object>
    COMMENT 'Variants conditionnels : {primary: {css_classes: [...]}, secondary: {...}}';

-- ============================================================================
-- BLOC CONFIG : Configuration du composant
-- ============================================================================

DEFINE FIELD IF NOT EXISTS config ON TABLE studio_component
  TYPE object
  COMMENT 'Bloc configuration : paramètres du composant';

  DEFINE FIELD IF NOT EXISTS config.category ON TABLE studio_component
    TYPE string
    ASSERT $value INSIDE ['atom', 'molecule', 'organism', 'template', 'page']
    DEFAULT 'molecule'
    COMMENT 'Catégorie Atomic Design : atom (button, input), molecule (card), organism (table), template, page';

  DEFINE FIELD IF NOT EXISTS config.version ON TABLE studio_component
    TYPE string
    DEFAULT '1.0.0'
    COMMENT 'Version du composant : 1.0.0, 2.1.3, etc.';

  DEFINE FIELD IF NOT EXISTS config.props_schema ON TABLE studio_component
    FLEXIBLE
    TYPE array
    DEFAULT []
    COMMENT 'Schéma de validation des props : [{name: "label", type: "string", required: true}]';

  DEFINE FIELD IF NOT EXISTS config.supports_slots ON TABLE studio_component
    TYPE bool
    DEFAULT false
    COMMENT 'Supporte les slots (children nommés) ? : header, footer, default';

  DEFINE FIELD IF NOT EXISTS config.slots ON TABLE studio_component
    TYPE option<array<string>>
    DEFAULT []
    COMMENT 'Liste des slots supportés : ["header", "footer", "actions"]';

  DEFINE FIELD IF NOT EXISTS config.icon ON TABLE studio_component
    TYPE option<record<icon>>
    REFERENCE ON DELETE REJECT
    COMMENT 'Icône représentative du composant';

-- ============================================================================
-- BLOC CONTEXT : Contexte d'utilisation du composant
-- ============================================================================

DEFINE FIELD IF NOT EXISTS context ON TABLE studio_component
  TYPE object
  COMMENT 'Bloc contexte : où et comment le composant est utilisé';

  DEFINE FIELD IF NOT EXISTS context.usage_hints ON TABLE studio_component
    TYPE option<array<string>>
    DEFAULT []
    COMMENT 'Indications d\'usage : ["form", "dashboard", "list", "detail"]';

  DEFINE FIELD IF NOT EXISTS context.semantic_meaning ON TABLE studio_component
    TYPE option<string>
    COMMENT 'Signification sémantique : "Bouton d\'action principale", "Carte d\'affichage de données"';

  DEFINE FIELD IF NOT EXISTS context.dependencies ON TABLE studio_component
    TYPE option<array<record<studio_component>>>
    REFERENCE ON DELETE REJECT
    COMMENT 'Composants requis par ce composant (imbriqués)';

-- ============================================================================
-- BLOC STATUS : État du composant
-- ============================================================================

DEFINE FIELD IF NOT EXISTS status ON TABLE studio_component
  TYPE object
  COMMENT 'Bloc statut : état général du composant';

  DEFINE FIELD IF NOT EXISTS status.is_active ON TABLE studio_component
    TYPE bool
    DEFAULT true
    COMMENT 'Composant actif (disponible pour utilisation) ?';

  DEFINE FIELD IF NOT EXISTS status.is_system_component ON TABLE studio_component
    TYPE bool
    DEFAULT false
    COMMENT 'Composant système (fourni par défaut) ou custom (créé par utilisateur) ?';

  DEFINE FIELD IF NOT EXISTS status.is_deprecated ON TABLE studio_component
    TYPE bool
    DEFAULT false
    COMMENT 'Composant déprécié (ne plus utiliser) ?';

  DEFINE FIELD IF NOT EXISTS status.deprecation_reason ON TABLE studio_component
    TYPE option<string>
    COMMENT 'Raison de la dépréciation si is_deprecated = true';

  DEFINE FIELD IF NOT EXISTS status.source ON TABLE studio_component
    TYPE string
    ASSERT $value INSIDE ['system', 'user_created', 'import', 'marketplace', 'custom']
    DEFAULT 'system'
    COMMENT 'Source du composant';

-- ============================================================================
-- BLOC METADATA : Métadonnées système
-- ============================================================================

DEFINE FIELD IF NOT EXISTS metadata ON TABLE studio_component
  TYPE object
  COMMENT 'Bloc métadonnées : informations système';

  DEFINE FIELD IF NOT EXISTS metadata.notes ON TABLE studio_component
    TYPE option<string>
    COMMENT 'Notes internes libres';

  DEFINE FIELD IF NOT EXISTS metadata.tags ON TABLE studio_component
    TYPE option<array<record<tag>>>
    REFERENCE ON DELETE REJECT
    COMMENT 'Tags pour classification : ["ui", "form", "data-display"]';

  DEFINE FIELD IF NOT EXISTS metadata.author_user_id ON TABLE studio_component
    TYPE option<record<identity>>
    REFERENCE ON DELETE REJECT
    COMMENT 'Utilisateur créateur du composant (si custom)';

  DEFINE FIELD IF NOT EXISTS metadata.usage_count ON TABLE studio_component
    TYPE int
    DEFAULT 0
    COMMENT 'Nombre d\'utilisations du composant (analytics)';

  DEFINE FIELD IF NOT EXISTS metadata.last_used_at ON TABLE studio_component
    TYPE option<datetime>
    COMMENT 'Date de dernière utilisation';

-- ============================================================================
-- TIMESTAMPS & ETAG
-- ============================================================================

DEFINE FIELD IF NOT EXISTS timestamp ON TABLE studio_component
  TYPE object
  COMMENT 'Dates de création et modification';

  DEFINE FIELD IF NOT EXISTS timestamp.created_at ON TABLE studio_component
    TYPE datetime
    READONLY
    DEFAULT time::now()
    COMMENT 'Date de création (readonly)';

  DEFINE FIELD IF NOT EXISTS timestamp.updated_at ON TABLE studio_component
    TYPE datetime
    READONLY
    DEFAULT ALWAYS time::now()
    COMMENT 'Date de dernière modification (readonly)';

DEFINE FIELD IF NOT EXISTS etag ON TABLE studio_component
  TYPE uuid
  READONLY
  DEFAULT ALWAYS rand::uuid::v7()
  COMMENT 'ETag pour optimistic locking (readonly)';

-- ============================================================================
-- INDEX
-- ============================================================================

DEFINE INDEX IF NOT EXISTS idx_studio_component_code ON studio_component
  FIELDS identity.code UNIQUE
  COMMENT 'Index unique sur le code';

DEFINE INDEX IF NOT EXISTS idx_studio_component_slug ON studio_component
  FIELDS identity.slug UNIQUE
  COMMENT 'Index unique sur le slug';

DEFINE INDEX IF NOT EXISTS idx_studio_component_value ON studio_component
  FIELDS identity.value UNIQUE
  COMMENT 'Index unique sur la valeur';

DEFINE INDEX IF NOT EXISTS idx_studio_component_category ON studio_component
  FIELDS config.category
  COMMENT 'Index sur la catégorie (atom, molecule, organism)';

DEFINE INDEX IF NOT EXISTS idx_studio_component_active ON studio_component
  FIELDS status.is_active
  COMMENT 'Index sur les composants actifs';

DEFINE INDEX IF NOT EXISTS idx_studio_component_system ON studio_component
  FIELDS status.is_system_component
  COMMENT 'Index sur les composants système';

DEFINE INDEX IF NOT EXISTS idx_studio_component_deprecated ON studio_component
  FIELDS status.is_deprecated
  COMMENT 'Index sur les composants dépréciés';
```

### Vue d'Ensemble des 8 Blocs

| Bloc | Rôle | Contenu Principal |
|------|------|-------------------|
| `identity` | Identification unique | `code`, `slug`, `value` |
| `presentation` | Interface utilisateur | `name_i18n`, `description_i18n`, `keywords` |
| `structure` | Définition technique | `type`, `props`, `children`, `variants` |
| `config` | Configuration | `category`, `version`, `props_schema`, `slots` |
| `context` | Utilisation | `usage_hints`, `dependencies`, `semantic_meaning` |
| `status` | État | `is_active`, `is_system_component`, `source` |
| `metadata` | Analytics | `tags`, `usage_count`, `author_user_id` |
| `timestamp` | Historique | `created_at`, `updated_at`, `etag` |

### Exemple Complet : Composant Button

```surql
CREATE studio_component:button SET
  -- Bloc identité
  identity = {
    code = "button",
    value = "button",
    slug = "button"
  },

  -- Bloc présentation
  presentation = {
    name_i18n = i18n_key:studio_component_button_name,
    description_i18n = i18n_key:studio_component_button_description,
    keywords = ["button", "action", "form", "ui"]
  },

  -- Bloc structure (cœur du composant)
  structure = {
    type = "button",
    props = {
      className = ["btn", "btn-base", "{{props.variant}}"],
      onClick = {
        type = "action",
        action = "state_update",
        target = "button_clicked"
      },
      disabled = "{{props.disabled}}"
    },
    children = [
      {
        type = "text",
        content = "{{props.label}}"
      }
    ],
    variants = {
      primary = {
        css_classes = ["bg-blue-500", "text-white", "hover:bg-blue-600"]
      },
      secondary = {
        css_classes = ["bg-gray-500", "text-white", "hover:bg-gray-600"]
      }
    }
  },

  -- Bloc configuration
  config = {
    category = "atom",
    version = "1.0.0",
    props_schema = [
      {
        name = "label",
        type = "string",
        required = true,
        description = "Texte du bouton"
      },
      {
        name = "variant",
        type = "string",
        default = "primary",
        options = ["primary", "secondary", "danger", "ghost"]
      },
      {
        name = "disabled",
        type = "boolean",
        default = false
      }
    ]
  },

  -- Bloc contexte
  context = {
    usage_hints = ["form", "dashboard", "modal"],
    semantic_meaning = "Bouton d'action générique",
    dependencies = []
  },

  -- Bloc statut
  status = {
    is_active = true,
    is_system_component = true,
    is_deprecated = false,
    source = "system"
  },

  -- Bloc métadonnées
  metadata = {
    notes = "Composant bouton de base",
    tags = ["ui", "form", "action"],
    usage_count = 0
  };
```

### Utilisation dans le Code TypeScript

```typescript
// Charger le composant depuis DB
const { component, loading, error } = useStudioComponent('button');

// Utiliser la structure pour le rendu
const element = parseComponent(component.structure, { label: "Save" });
```

**Voir [`STUDIO_COMPONENT_SCHEMA.md`](../runtime/STUDIO_COMPONENT_SCHEMA.md) pour la documentation complète.**

---

## 2️⃣ studio_menu

**Rôle** : Définition de la structure de navigation (menus hiérarchiques).

```surql
-- Définition de la table
DEFINE TABLE studio_menu SCHEMAFULL
  COMMENT 'Structure de navigation dynamique';

-- Champs
DEFINE FIELD code ON studio_menu
  TYPE string
  ASSERT $value != NONE
  COMMENT 'Code unique du menu';

DEFINE FIELD label ON studio_menu
  TYPE object
  COMMENT 'Label du menu (multilingue)';

DEFINE FIELD icon ON studio_menu
  TYPE option<string>
  COMMENT 'Icône Lucide React';

DEFINE FIELD url ON studio_menu
  TYPE string
  COMMENT 'URL de destination';

DEFINE FIELD parent ON studio_menu
  TYPE option<record<studio_menu>>
  COMMENT 'Menu parent (pour hiérarchie)';

DEFINE FIELD order ON studio_menu
  TYPE int
  DEFAULT 0
  COMMENT 'Ordre d\'affichage';

DEFINE FIELD active ON studio_menu
  TYPE bool
  DEFAULT true
  COMMENT 'Menu actif ou masqué';

DEFINE FIELD permissions ON studio_menu
  TYPE array<string>
  DEFAULT []
  COMMENT 'Rôles autorisés ([], user, admin)';

DEFINE FIELD modules ON studio_menu
  TYPE array<string>
  DEFAULT []
  COMMENT 'Modules requis pour voir ce menu';

DEFINE FIELD badge ON studio_menu
  TYPE option<object>
  COMMENT 'Badge (ex: count notifications)';

DEFINE FIELD metadata ON studio_menu
  TYPE object;

DEFINE FIELD metadata.created_at ON studio_menu
  TYPE datetime
  DEFAULT time::now()
  READONLY;

DEFINE FIELD metadata.updated_at ON studio_menu
  TYPE datetime
  DEFAULT time::now();

-- Index
DEFINE INDEX code_unique ON studio_menu FIELDS code UNIQUE;
DEFINE INDEX parent_idx ON studio_menu FIELDS parent;
DEFINE INDEX order_idx ON studio_menu FIELDS order;
DEFINE INDEX active_idx ON studio_menu FIELDS active;
```

### Exemple de Seeds

```surql
-- Menu CRM (parent)
CREATE studio_menu:crm SET
  code = "crm",
  label = {
    fr: "CRM",
    en: "CRM"
  },
  icon = "Users",
  url = "/crm",
  parent = NONE,
  order = 1,
  active = true,
  permissions = ["user", "admin"],
  modules = ["crm"];

-- Sous-menu Contacts
CREATE studio_menu:crm_contacts SET
  code = "crm_contacts",
  label = {
    fr: "Contacts",
    en: "Contacts"
  },
  icon = "User",
  url = "/crm/contacts",
  parent = studio_menu:crm,
  order = 1,
  active = true,
  permissions = ["user", "admin"],
  modules = ["crm"];

-- Sous-menu Entreprises
CREATE studio_menu:crm_companies SET
  code = "crm_companies",
  label = {
    fr: "Entreprises",
    en: "Companies"
  },
  icon = "Building",
  url = "/crm/companies",
  parent = studio_menu:crm,
  order = 2,
  active = true,
  permissions = ["user", "admin"],
  modules = ["crm"];

-- Menu Admin (visible seulement par admins)
CREATE studio_menu:admin SET
  code = "admin",
  label = {
    fr: "Administration",
    en: "Admin"
  },
  icon = "Settings",
  url = "/admin",
  parent = NONE,
  order = 99,
  active = true,
  permissions = ["admin"],
  modules = [];
```

---

## 3️⃣ studio_page

**Rôle** : Définition complète d'une page 100% DB-driven avec structure JSON.

**Cette table définit des pages complètes où TOUT le contenu (HTML, composants, layout) est stocké en base de données.**

```surql
-- Définition de la table
DEFINE TABLE IF NOT EXISTS studio_page TYPE NORMAL SCHEMAFULL
COMMENT 'Définition des pages dynamiques - Structure complète en JSON';

-- ============================================================================
-- BLOC IDENTITY : Identité de la page
-- ============================================================================

DEFINE FIELD IF NOT EXISTS identity ON TABLE studio_page
  TYPE object
  COMMENT 'Bloc identité : identification unique de la page';

  DEFINE FIELD IF NOT EXISTS identity.code ON TABLE studio_page
    TYPE string
    ASSERT $value != NONE AND $value != "" AND string::len($value) > 0
    COMMENT 'Code unique de la page (snake_case) : "contact_list", "dashboard"';

  DEFINE FIELD IF NOT EXISTS identity.slug ON TABLE studio_page
    TYPE string
    COMMENT 'Slug pour URL friendly : "contact-list"';

  DEFINE FIELD IF NOT EXISTS identity.value ON TABLE studio_page
    TYPE string
    DEFAULT "$before.code"
    COMMENT 'Valeur par défaut = code';

-- ============================================================================
-- BLOC PRESENTATION : Présentation de la page
-- ============================================================================

DEFINE FIELD IF NOT EXISTS presentation ON TABLE studio_page
  TYPE object
  COMMENT 'Bloc présentation : affichage et métadonnées';

  DEFINE FIELD IF NOT EXISTS presentation.title_i18n ON TABLE studio_page
    TYPE option<record<i18n_key>>
    REFERENCE ON DELETE REJECT
    COMMENT 'Titre de la page (i18n)';

  DEFINE FIELD IF NOT EXISTS presentation.description_i18n ON TABLE studio_page
    TYPE option<record<i18n_key>>
    REFERENCE ON DELETE REJECT
    COMMENT 'Description de la page (i18n)';

  DEFINE FIELD IF NOT EXISTS presentation.url ON TABLE studio_page
    TYPE string
    ASSERT $value != NONE AND $value != "" AND string::starts_with($value, '/')
    COMMENT 'URL de la page : "/contacts", "/dashboard"';

  DEFINE FIELD IF NOT EXISTS presentation.layout ON TABLE studio_page
    TYPE string
    DEFAULT 'flex'
    ASSERT $value INSIDE ['flex', 'grid', 'dashboard', 'full']
    COMMENT 'Type de layout : flex, grid, dashboard, full';

  DEFINE FIELD IF NOT EXISTS presentation.breadcrumb ON TABLE studio_page
    TYPE option<array<object>>
    COMMENT 'Fil d\'Ariane : [{label: "...", url: "/..."}]';

-- ============================================================================
-- CONTENT_STRUCTURE : Structure complète de la page (100% DB-Driven)
-- ============================================================================

DEFINE FIELD IF NOT EXISTS content_structure ON TABLE studio_page
  TYPE object
  COMMENT 'Structure JSON complète de la page - RENDU 100% DB-DRIVEN';

  DEFINE FIELD IF NOT EXISTS content_structure.type ON TABLE studio_page
    TYPE string
    DEFAULT 'div'
    COMMENT 'Type de l\'élément racine : "div", "section", etc.';

  DEFINE FIELD IF NOT EXISTS content_structure.props ON TABLE studio_page
    FLEXIBLE
    TYPE option<object>
    COMMENT 'Props de l\'élément racine : {className: [...]}';

  DEFINE FIELD IF NOT EXISTS content_structure.children ON TABLE studio_page
    FLEXIBLE
    TYPE option<array<object>>
    DEFAULT []
    COMMENT 'Children : sections, composants, etc. Définit TOUT le contenu de la page';

-- ============================================================================
-- BLOC CONTEXT : Contexte d'utilisation
-- ============================================================================

DEFINE FIELD IF NOT EXISTS context ON TABLE studio_page
  TYPE object
  COMMENT 'Bloc contexte : contexte d\'utilisation de la page';

  DEFINE FIELD IF NOT EXISTS context.permissions ON TABLE studio_page
    TYPE option<array<string>>
    DEFAULT []
    COMMENT 'Rôles autorisés : ["admin", "user"]';

  DEFINE FIELD IF NOT EXISTS context.modules ON TABLE studio_page
    TYPE option<array<string>>
    DEFAULT []
    COMMENT 'Modules requis : ["crm", "sales"]';

-- ============================================================================
-- BLOC STATUS : Statut de la page
-- ============================================================================

DEFINE FIELD IF NOT EXISTS status ON TABLE studio_page
  TYPE object
  COMMENT 'Bloc statut : état de la page';

  DEFINE FIELD IF NOT EXISTS status.is_active ON TABLE studio_page
    TYPE bool
    DEFAULT true
    COMMENT 'Page active ?';

  DEFINE FIELD IF NOT EXISTS status.is_system_page ON TABLE studio_page
    TYPE bool
    DEFAULT false
    COMMENT 'Page système (non modifiable) ?';

-- ============================================================================
-- BLOC METADATA : Métadonnées
-- ============================================================================

DEFINE FIELD IF NOT EXISTS metadata ON TABLE studio_page
  TYPE object
  COMMENT 'Bloc métadonnées : informations complémentaires';

  DEFINE FIELD IF NOT EXISTS metadata.notes ON TABLE studio_page
    TYPE option<string>
    COMMENT 'Notes internes sur la page';

  DEFINE FIELD IF NOT EXISTS metadata.tags ON TABLE studio_page
    TYPE option<array<string>>
    DEFAULT []
    COMMENT 'Tags pour organisation : ["crm", "contacts", "list"]';

-- ============================================================================
-- TIMESTAMP : Horodatage
-- ============================================================================

DEFINE FIELD IF NOT EXISTS timestamp ON TABLE studio_page
  TYPE object
  COMMENT 'Bloc horodatage : dates de création et modification';

  DEFINE FIELD IF NOT EXISTS timestamp.created_at ON TABLE studio_page
    TYPE datetime
    DEFAULT time::now()
    COMMENT 'Date de création';

  DEFINE FIELD IF NOT EXISTS timestamp.updated_at ON TABLE studio_page
    TYPE datetime
    DEFAULT time::now()
    COMMENT 'Date de dernière modification';

-- ============================================================================
-- ETAG : Version
-- ============================================================================

DEFINE FIELD IF NOT EXISTS etag ON TABLE studio_page
  TYPE string
  DEFAULT rand::uuid::v7()
  COMMENT 'ETag pour gestion de version et cache';

-- ============================================================================
-- INDEXES
-- ============================================================================

DEFINE INDEX IF NOT EXISTS code_unique ON studio_page FIELDS identity.code UNIQUE;
DEFINE INDEX IF NOT EXISTS url_unique ON studio_page FIELDS presentation.url UNIQUE;
DEFINE INDEX IF NOT EXISTS active_idx ON studio_page FIELDS status.is_active;
```

### Structure des Blocs

| Bloc | Rôle | Contenu Principal |
|------|------|-------------------|
| `identity` | Identification | `code`, `slug`, `value` |
| `presentation` | Interface | `title_i18n`, `url`, `layout`, `breadcrumb` |
| `content_structure` | **Contenu 100% DB** | `type`, `props`, `children` |
| `context` | Sécurité | `permissions`, `modules` |
| `status` | État | `is_active`, `is_system_page` |
| `metadata` | Analytics | `tags`, `notes` |
| `timestamp` | Historique | `created_at`, `updated_at` |

### Exemple Complet : Page de Test

```surql
CREATE studio_page:test_page SET
  -- Bloc identité
  identity = {
    code = "test_page",
    slug = "test-page",
    value = "test_page"
  },

  -- Bloc présentation
  presentation = {
    url = "/test",
    layout = "flex",
    title_i18n = i18n_key:studio_page_test_page_title,
    description_i18n = i18n_key:studio_page_test_page_description
  },

  -- Bloc contenu (100% DB-driven)
  content_structure = {
    type = "div",
    props = {
      className = ["container", "mx-auto", "p-6"]
    },
    children = [
      {
        type = "div",
        props = { className = ["mb-6"] },
        children = [
          {
            type = "h1",
            props = { className = ["text-3xl", "font-bold", "mb-4"] },
            children = [
              { type = "text", content = "Page de Test" }
            ]
          },
          {
            type = "p",
            props = { className = ["text-gray-600"] },
            children = [
              { type = "text", content = "Page de démonstration du rendu 100% DB-driven" }
            ]
          }
        ]
      },
      {
        type = "component",
        component = "test_button",
        props = {
          label = "Cliquez-moi !",
          disabled = false
        }
      }
    ]
  },

  -- Bloc contexte
  context = {
    permissions = [],
    modules = []
  },

  -- Bloc statut
  status = {
    is_active = true,
    is_system_page = false
  },

  -- Métadonnées
  metadata = {
    notes = "Page de test pour valider le rendu 100% DB-driven avec test_button",
    tags = ["test", "demo"]
  };
```

**Voir [`STUDIO_PAGE_SCHEMA.md`](../runtime/STUDIO_PAGE_SCHEMA.md) pour la documentation complète.**

---

## 4️⃣ studio_form

**Rôle** : Définition de formulaires dynamiques avec validation.

```surql
-- Définition de la table
DEFINE TABLE studio_form SCHEMAFULL
  COMMENT 'Définition des formulaires dynamiques';

-- Champs
DEFINE FIELD code ON studio_form
  TYPE string
  ASSERT $value != NONE
  COMMENT 'Code unique du formulaire';

DEFINE FIELD title ON studio_form
  TYPE object
  COMMENT 'Titre du formulaire (multilingue)';

DEFINE FIELD table ON studio_form
  TYPE string
  COMMENT 'Table SurrealDB cible pour INSERT/UPDATE';

DEFINE FIELD fields ON studio_form
  TYPE array<object>
  COMMENT 'Liste des champs du formulaire';

DEFINE FIELD validations ON studio_form
  TYPE array<object>
  DEFAULT []
  COMMENT 'Règles de validation';

DEFINE FIELD layout ON studio_form
  TYPE string
  DEFAULT 'vertical'
  ASSERT $value IN ['vertical', 'horizontal', 'grid']
  COMMENT 'Layout du formulaire';

DEFINE FIELD submit_button ON studio_form
  TYPE object
  COMMENT 'Configuration du bouton submit';

DEFINE FIELD cancel_button ON studio_form
  TYPE option<object>
  COMMENT 'Configuration du bouton cancel';

DEFINE FIELD permissions ON studio_form
  TYPE array<string>
  DEFAULT []
  COMMENT 'Rôles autorisés';

DEFINE FIELD active ON studio_form
  TYPE bool
  DEFAULT true;

DEFINE FIELD metadata ON studio_form
  TYPE object;

DEFINE FIELD metadata.created_at ON studio_form
  TYPE datetime
  DEFAULT time::now()
  READONLY;

DEFINE FIELD metadata.updated_at ON studio_form
  TYPE datetime
  DEFAULT time::now();

-- Index
DEFINE INDEX code_unique ON studio_form FIELDS code UNIQUE;
DEFINE INDEX table_idx ON studio_form FIELDS table;
DEFINE INDEX active_idx ON studio_form FIELDS active;
```

### Exemple de Seed

```surql
-- Formulaire de création de contact
CREATE studio_form:contact_create SET
  code = "contact_create",
  title = {
    fr: "Nouveau Contact",
    en: "New Contact"
  },
  table = "contact",
  fields = [
    {
      name: "first_name",
      label: { fr: "Prénom", en: "First Name" },
      type: "text",
      required: true,
      order: 1,
      placeholder: { fr: "Jean", en: "John" }
    },
    {
      name: "last_name",
      label: { fr: "Nom", en: "Last Name" },
      type: "text",
      required: true,
      order: 2,
      placeholder: { fr: "Dupont", en: "Doe" }
    },
    {
      name: "email",
      label: { fr: "Email", en: "Email" },
      type: "email",
      required: true,
      order: 3,
      placeholder: { fr: "jean.dupont@example.com", en: "john.doe@example.com" }
    },
    {
      name: "phone",
      label: { fr: "Téléphone", en: "Phone" },
      type: "tel",
      required: false,
      order: 4,
      placeholder: { fr: "+33 6 12 34 56 78", en: "+1 555-123-4567" }
    },
    {
      name: "company",
      label: { fr: "Entreprise", en: "Company" },
      type: "relation",
      relation_table: "company",
      relation_display: "name",
      required: false,
      order: 5
    },
    {
      name: "status",
      label: { fr: "Statut", en: "Status" },
      type: "select",
      options: [
        { value: "lead", label: { fr: "Lead", en: "Lead" } },
        { value: "prospect", label: { fr: "Prospect", en: "Prospect" } },
        { value: "client", label: { fr: "Client", en: "Client" } }
      ],
      default: "lead",
      required: true,
      order: 6
    },
    {
      name: "notes",
      label: { fr: "Notes", en: "Notes" },
      type: "textarea",
      required: false,
      order: 7,
      rows: 4
    }
  ],
  validations = [
    {
      field: "email",
      rule: "email",
      message: { fr: "Email invalide", en: "Invalid email" }
    },
    {
      field: "phone",
      rule: "regex",
      pattern: "^\\+?[0-9]{10,15}$",
      message: { fr: "Téléphone invalide", en: "Invalid phone number" }
    }
  ],
  layout = "vertical",
  submit_button = {
    label: { fr: "Créer le Contact", en: "Create Contact" },
    icon: "Plus",
    variant: "primary"
  },
  cancel_button = {
    label: { fr: "Annuler", en: "Cancel" },
    variant: "ghost"
  },
  permissions = ["user", "admin"],
  active = true;
```

---

## 5️⃣ studio_widget

**Rôle** : Widgets réutilisables (stat cards, charts, lists, etc.).

```surql
-- Définition de la table
DEFINE TABLE studio_widget SCHEMAFULL
  COMMENT 'Widgets réutilisables pour pages et dashboards';

-- Champs
DEFINE FIELD code ON studio_widget
  TYPE string
  ASSERT $value != NONE
  COMMENT 'Code unique du widget';

DEFINE FIELD title ON studio_widget
  TYPE option<object>
  COMMENT 'Titre du widget (multilingue)';

DEFINE FIELD type ON studio_widget
  TYPE string
  ASSERT $value IN ['stat', 'chart', 'table', 'list', 'card', 'text', 'html', 'custom']
  COMMENT 'Type de widget';

DEFINE FIELD query ON studio_widget
  TYPE option<string>
  COMMENT 'Query SurrealDB pour récupérer les données';

DEFINE FIELD config ON studio_widget
  TYPE object
  COMMENT 'Configuration spécifique au type';

DEFINE FIELD refresh_interval ON studio_widget
  TYPE option<int>
  COMMENT 'Intervalle de rafraîchissement auto (ms)';

DEFINE FIELD permissions ON studio_widget
  TYPE array<string>
  DEFAULT [];

DEFINE FIELD active ON studio_widget
  TYPE bool
  DEFAULT true;

DEFINE FIELD metadata ON studio_widget
  TYPE object;

DEFINE FIELD metadata.created_at ON studio_widget
  TYPE datetime
  DEFAULT time::now()
  READONLY;

DEFINE FIELD metadata.updated_at ON studio_widget
  TYPE datetime
  DEFAULT time::now();

-- Index
DEFINE INDEX code_unique ON studio_widget FIELDS code UNIQUE;
DEFINE INDEX type_idx ON studio_widget FIELDS type;
DEFINE INDEX active_idx ON studio_widget FIELDS active;
```

### Exemples de Seeds

```surql
-- Widget Stat : Nombre de contacts
CREATE studio_widget:contacts_count SET
  code = "contacts_count",
  title = {
    fr: "Contacts Actifs",
    en: "Active Contacts"
  },
  type = "stat",
  query = "SELECT count() AS count FROM contact WHERE status = 'active'",
  config = {
    icon: "Users",
    color: "blue",
    format: "number"
  },
  refresh_interval = 60000,  // 1 minute
  permissions = ["user", "admin"],
  active = true;

-- Widget Chart : Deals par mois
CREATE studio_widget:deals_chart SET
  code = "deals_chart",
  title = {
    fr: "Deals par Mois",
    en: "Deals by Month"
  },
  type = "chart",
  query = "SELECT time::month(created_at) AS month, count() AS count FROM deal GROUP BY month ORDER BY month DESC LIMIT 12",
  config = {
    chart_type: "line",
    x_axis: "month",
    y_axis: "count",
    color: "#3B82F6"
  },
  refresh_interval = 300000,  // 5 minutes
  permissions = ["user", "admin"],
  active = true;

-- Widget Table : Derniers contacts
CREATE studio_widget:recent_contacts SET
  code = "recent_contacts",
  title = {
    fr: "Derniers Contacts",
    en: "Recent Contacts"
  },
  type = "table",
  query = "SELECT first_name, last_name, email, company.name AS company, created_at FROM contact ORDER BY created_at DESC LIMIT 10",
  config = {
    columns: [
      { field: "first_name", label: { fr: "Prénom", en: "First Name" } },
      { field: "last_name", label: { fr: "Nom", en: "Last Name" } },
      { field: "email", label: { fr: "Email", en: "Email" } },
      { field: "company", label: { fr: "Entreprise", en: "Company" } },
      { field: "created_at", label: { fr: "Créé le", en: "Created" }, format: "date" }
    ]
  },
  refresh_interval = 120000,  // 2 minutes
  permissions = ["user", "admin"],
  active = true;
```

---

## 6️⃣ studio_theme

**Rôle** : Thèmes visuels réutilisables (couleurs, fonts, spacing, etc.).

```surql
-- Définition de la table
DEFINE TABLE studio_theme SCHEMAFULL
  COMMENT 'Thèmes visuels pour White-Label';

-- Champs
DEFINE FIELD code ON studio_theme
  TYPE string
  ASSERT $value != NONE
  COMMENT 'Code unique du thème';

DEFINE FIELD name ON studio_theme
  TYPE object
  COMMENT 'Nom du thème (multilingue)';

DEFINE FIELD colors ON studio_theme
  TYPE object
  COMMENT 'Palette de couleurs';

DEFINE FIELD typography ON studio_theme
  TYPE object
  COMMENT 'Configuration typographie';

DEFINE FIELD spacing ON studio_theme
  TYPE option<object>
  COMMENT 'Espacement (margins, paddings)';

DEFINE FIELD border_radius ON studio_theme
  TYPE option<object>
  COMMENT 'Rayons de bordure';

DEFINE FIELD shadows ON studio_theme
  TYPE option<object>
  COMMENT 'Ombres';

DEFINE FIELD active ON studio_theme
  TYPE bool
  DEFAULT true;

DEFINE FIELD metadata ON studio_theme
  TYPE object;

DEFINE FIELD metadata.created_at ON studio_theme
  TYPE datetime
  DEFAULT time::now()
  READONLY;

DEFINE FIELD metadata.updated_at ON studio_theme
  TYPE datetime
  DEFAULT time::now();

-- Index
DEFINE INDEX code_unique ON studio_theme FIELDS code UNIQUE;
DEFINE INDEX active_idx ON studio_theme FIELDS active;
```

### Exemple de Seed

```surql
-- Thème Lyxal par défaut
CREATE studio_theme:lyxal_default SET
  code = "lyxal_default",
  name = {
    fr: "Thème Lyxal",
    en: "Lyxal Theme"
  },
  colors = {
    primary: "#3B82F6",
    secondary: "#10B981",
    accent: "#F59E0B",
    background: "#FFFFFF",
    surface: "#F9FAFB",
    text: "#1F2937",
    text_secondary: "#6B7280",
    border: "#E5E7EB",
    error: "#EF4444",
    success: "#10B981",
    warning: "#F59E0B",
    info: "#3B82F6"
  },
  typography = {
    font_family: "Inter, system-ui, sans-serif",
    font_size_base: "16px",
    font_weight_normal: 400,
    font_weight_medium: 500,
    font_weight_bold: 700,
    line_height: 1.5
  },
  spacing = {
    xs: "0.25rem",
    sm: "0.5rem",
    md: "1rem",
    lg: "1.5rem",
    xl: "2rem"
  },
  border_radius = {
    sm: "0.25rem",
    md: "0.375rem",
    lg: "0.5rem",
    full: "9999px"
  },
  shadows = {
    sm: "0 1px 2px 0 rgb(0 0 0 / 0.05)",
    md: "0 4px 6px -1px rgb(0 0 0 / 0.1)",
    lg: "0 10px 15px -3px rgb(0 0 0 / 0.1)"
  },
  active = true;
```

---

## 🎯 Relations entre Tables

```
studio_config
  ├─> studio_theme (1:1)
  └─> enabled_modules (array<string>)

studio_menu
  └─> studio_menu (parent, hiérarchie)

studio_page
  └─> studio_widget[] (many:many)

studio_form
  └─> table (string, nom de table business)

studio_dashboard
  └─> studio_widget[] (many:many)

studio_widget
  └─> query (string, SurrealQL)
```

---

## 📊 Exemple de Requête Complète

```surql
-- Récupérer toute la config pour un tenant
SELECT *,
  theme.*,
  (SELECT * FROM studio_menu WHERE active = true AND permissions CONTAINS $auth.role ORDER BY order) AS menus
FROM studio_config
WHERE tenant_id = $tenant_id;
```

**Résultat** : Toute la config chargée en 1 query ! ⚡

---

---

## 🎨 Champs Spécifiques Multi-Plateforme

### Web (DaisyUI)

```surql
-- Champs pour Web
web_theme: "light" | "dark" | "corporate" | ... (33 thèmes)
daisy_custom: {
  "primary": "#...",
  "secondary": "#...",
  -- 13 variables CSS au total
}
```

### Mobile (React Native)

```surql
-- Champs pour Mobile
mobile_theme: {
  primary: "#...",
  secondary: "#...",
  accent: "#...",
  background: "#...",
  surface: "#...",
  text: "#...",
  error: "#...",
  success: "#..."
}
```

**Avantage** : 1 config DB → 2 plateformes avec thèmes synchronisés ! 🎨📱

---

## ⚙️ Fonctions SurrealDB

### Vue d'Ensemble des Fonctions

| Fonction | Rôle | Paramètres |
|----------|------|------------|
| `fn::studio_get_config` | Récupérer config tenant | `$tenant_id` |
| `fn::studio_get_menu` | Construire menu utilisateur | `$tenant_id`, `$role`, `$modules` |
| `fn::studio_render_page` | Charger et rendre une page | `$page_code`, `$tenant_id` |
| `fn::studio_validate_form` | Valider données formulaire | `$form_code`, `$data` |
| `fn::studio_submit_form` | Soumettre formulaire | `$form_code`, `$data` |
| `fn::studio_check_permission` | Vérifier permissions | `$resource_type`, `$resource_id`, `$user` |
| `fn::studio_execute_widget_query` | Exécuter query widget | `$widget_code` |
| `fn::studio_get_theme` | Récupérer thème complet | `$theme_id` |

---

### 1️⃣ fn::studio_get_config

**Rôle** : Récupérer toute la configuration d'un tenant.

```surql
DEFINE FUNCTION fn::studio_get_config($tenant_id: string) {
  LET $config = (SELECT
    *,
    theme.* AS theme_details
  FROM studio_config
  WHERE tenant_id = $tenant_id
  AND active = true
  LIMIT 1)[0];

  IF !$config THEN
    RETURN {
      error: true,
      message: "Configuration not found for tenant: " + $tenant_id
    };
  END;

  RETURN {
    success: true,
    config: $config
  };
};
```

---

### 2️⃣ fn::studio_get_menu

**Rôle** : Construire le menu complet pour un utilisateur.

```surql
DEFINE FUNCTION fn::studio_get_menu(
  $tenant_id: string,
  $role: string,
  $modules: array<string>
) {
  LET $menus = SELECT * FROM studio_menu
    WHERE active = true
    AND (
      permissions = []
      OR permissions CONTAINS $role
    )
    AND (
      modules = []
      OR modules CONTAINSANY $modules
    )
    ORDER BY order ASC;

  LET $menu_tree = [];

  FOR $menu IN $menus {
    IF $menu.parent = NONE THEN
      LET $children = SELECT * FROM $menus WHERE parent = $menu.id;

      LET $menu_tree += {
        id: $menu.id,
        code: $menu.code,
        label: $menu.label,
        icon: $menu.icon,
        url: $menu.url,
        badge: $menu.badge,
        children: $children
      };
    END;
  };

  RETURN {
    success: true,
    menu: $menu_tree
  };
};
```

---

### 3️⃣ fn::studio_render_page

**Rôle** : Charger une page complète avec tous ses widgets.

```surql
DEFINE FUNCTION fn::studio_render_page(
  $page_code: string,
  $tenant_id: string
) {
  LET $page = (SELECT * FROM studio_page
    WHERE code = $page_code
    AND active = true
    LIMIT 1)[0];

  IF !$page THEN
    RETURN {
      error: true,
      message: "Page not found: " + $page_code
    };
  END;

  LET $widgets_with_data = [];

  FOR $widget_ref IN $page.widgets {
    LET $widget = (SELECT * FROM $widget_ref LIMIT 1)[0];

    IF $widget AND $widget.query THEN
      LET $data = SELECT VALUE * FROM ($widget.query);

      LET $widgets_with_data += {
        widget: $widget,
        data: $data
      };
    ELSE
      LET $widgets_with_data += {
        widget: $widget,
        data: NONE
      };
    END;
  };

  RETURN {
    success: true,
    page: $page,
    widgets: $widgets_with_data
  };
};
```

---

### 4️⃣ fn::studio_validate_form

**Rôle** : Valider les données d'un formulaire.

```surql
DEFINE FUNCTION fn::studio_validate_form(
  $form_code: string,
  $data: object
) {
  LET $form = (SELECT * FROM studio_form
    WHERE code = $form_code
    AND active = true
    LIMIT 1)[0];

  IF !$form THEN
    RETURN {
      error: true,
      message: "Form not found: " + $form_code
    };
  END;

  LET $errors = [];

  FOR $field IN $form.fields {
    IF $field.required AND !$data[$field.name] THEN
      LET $errors += {
        field: $field.name,
        message: "Field " + $field.name + " is required"
      };
    END;
  };

  FOR $validation IN $form.validations {
    LET $value = $data[$validation.field];

    IF $validation.rule = "email" THEN
      IF !string::contains($value, "@") THEN
        LET $errors += {
          field: $validation.field,
          message: $validation.message
        };
      END;
    END;

    IF $validation.rule = "regex" THEN
      IF !$value ~ $validation.pattern THEN
        LET $errors += {
          field: $validation.field,
          message: $validation.message
        };
      END;
    END;
  };

  IF array::len($errors) > 0 THEN
    RETURN {
      valid: false,
      errors: $errors
    };
  END;

  RETURN {
    valid: true,
    errors: []
  };
};
```

---

### 5️⃣ fn::studio_submit_form

**Rôle** : Soumettre un formulaire avec validation.

```surql
DEFINE FUNCTION fn::studio_submit_form(
  $form_code: string,
  $data: object,
  $record_id: option<record>
) {
  LET $form = (SELECT * FROM studio_form
    WHERE code = $form_code
    AND active = true
    LIMIT 1)[0];

  IF !$form THEN
    RETURN {
      error: true,
      message: "Form not found: " + $form_code
    };
  END;

  LET $validation = fn::studio_validate_form($form_code, $data);

  IF !$validation.valid THEN
    RETURN {
      success: false,
      errors: $validation.errors
    };
  END;

  LET $result = NONE;

  IF $record_id THEN
    LET $result = UPDATE $record_id CONTENT $data RETURN AFTER;
  ELSE
    LET $result = CREATE type::table($form.table) CONTENT $data RETURN AFTER;
  END;

  RETURN {
    success: true,
    record: $result
  };
};
```

---

### 6️⃣ fn::studio_check_permission

**Rôle** : Vérifier les permissions d'accès.

```surql
DEFINE FUNCTION fn::studio_check_permission(
  $resource_type: string,
  $resource_id: record,
  $user_role: string,
  $user_modules: array<string>
) {
  LET $resource = (SELECT * FROM $resource_id LIMIT 1)[0];

  IF !$resource THEN
    RETURN {
      allowed: false,
      reason: "Resource not found"
    };
  END;

  LET $has_role_permission = (
    $resource.permissions = []
    OR $resource.permissions CONTAINS $user_role
  );

  LET $has_module_permission = (
    $resource.modules = []
    OR $resource.modules CONTAINSANY $user_modules
  );

  IF $has_role_permission AND $has_module_permission THEN
    RETURN {
      allowed: true,
      resource: $resource
    };
  END;

  RETURN {
    allowed: false,
    reason: "Insufficient permissions"
  };
};
```

---

### 7️⃣ fn::studio_execute_widget_query

**Rôle** : Exécuter les queries des widgets.

```surql
DEFINE FUNCTION fn::studio_execute_widget_query($widget_code: string) {
  LET $widget = (SELECT * FROM studio_widget
    WHERE code = $widget_code
    AND active = true
    LIMIT 1)[0];

  IF !$widget THEN
    RETURN {
      error: true,
      message: "Widget not found: " + $widget_code
    };
  END;

  IF !$widget.query THEN
    RETURN {
      error: true,
      message: "Widget has no query defined"
    };
  END;

  LET $data = SELECT VALUE * FROM ($widget.query);

  RETURN {
    success: true,
    widget: {
      code: $widget.code,
      title: $widget.title,
      type: $widget.type,
      config: $widget.config
    },
    data: $data
  };
};
```

---

### 8️⃣ fn::studio_get_theme

**Rôle** : Récupérer un thème complet.

```surql
DEFINE FUNCTION fn::studio_get_theme($theme_id: record<studio_theme>) {
  LET $theme = (SELECT * FROM $theme_id WHERE active = true LIMIT 1)[0];

  IF !$theme THEN
    RETURN {
      error: true,
      message: "Theme not found"
    };
  END;

  LET $css_vars = {
    "--color-primary": $theme.colors.primary,
    "--color-secondary": $theme.colors.secondary,
    "--color-accent": $theme.colors.accent,
    "--color-background": $theme.colors.background,
    "--color-surface": $theme.colors.surface,
    "--color-text": $theme.colors.text,
    "--color-text-secondary": $theme.colors.text_secondary,
    "--color-border": $theme.colors.border,
    "--color-error": $theme.colors.error,
    "--color-success": $theme.colors.success,
    "--font-family": $theme.typography.font_family,
    "--font-size-base": $theme.typography.font_size_base,
    "--spacing-xs": $theme.spacing.xs,
    "--spacing-sm": $theme.spacing.sm,
    "--spacing-md": $theme.spacing.md,
    "--spacing-lg": $theme.spacing.lg,
    "--border-radius-sm": $theme.border_radius.sm,
    "--border-radius-md": $theme.border_radius.md,
    "--border-radius-lg": $theme.border_radius.lg
  };

  RETURN {
    success: true,
    theme: $theme,
    css_vars: $css_vars
  };
};
```

---

## 🚀 Prochaines Étapes

1. **[FUNCTIONS.md](./FUNCTIONS.md)** → Toutes les fonctions SurrealDB
2. **[GUIDE.md](./GUIDE.md)** → Guide d'utilisation
3. **[INTEGRATION.md](./INTEGRATION.md)** → Intégration React + React Native + DaisyUI
4. **[MOBILE.md](./MOBILE.md)** → Guide complet React Native
5. **[DAISYUI.md](./DAISYUI.md)** → Guide complet DaisyUI


