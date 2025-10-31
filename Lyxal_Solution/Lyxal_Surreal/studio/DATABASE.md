# 📊 Database Schema - Lyxal Studio

Ce document décrit toutes les tables et leurs schémas complets pour Lyxal Studio.

---

## 📋 Vue d'Ensemble des Tables

| Table | Rôle | Relations |
|-------|------|-----------|
| `studio_config` | Configuration globale par tenant | → `studio_theme` |
| `studio_menu` | Structure de navigation | → `studio_menu` (parent) |
| `studio_page` | Définition des pages | → `studio_widget[]` |
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

**Rôle** : Définition complète d'une page (layout, widgets, queries).

```surql
-- Définition de la table
DEFINE TABLE studio_page SCHEMAFULL
  COMMENT 'Définition des pages dynamiques';

-- Champs
DEFINE FIELD code ON studio_page
  TYPE string
  ASSERT $value != NONE
  COMMENT 'Code unique de la page';

DEFINE FIELD title ON studio_page
  TYPE object
  COMMENT 'Titre de la page (multilingue)';

DEFINE FIELD description ON studio_page
  TYPE option<object>
  COMMENT 'Description de la page (multilingue)';

DEFINE FIELD url ON studio_page
  TYPE string
  ASSERT $value != NONE
  COMMENT 'URL de la page';

DEFINE FIELD layout ON studio_page
  TYPE string
  DEFAULT 'flex'
  ASSERT $value IN ['flex', 'grid', 'dashboard', 'full']
  COMMENT 'Type de layout';

DEFINE FIELD widgets ON studio_page
  TYPE array<record<studio_widget>>
  DEFAULT []
  COMMENT 'Widgets affichés sur cette page';

DEFINE FIELD breadcrumb ON studio_page
  TYPE option<array<object>>
  COMMENT 'Fil d\'Ariane';

DEFINE FIELD permissions ON studio_page
  TYPE array<string>
  DEFAULT []
  COMMENT 'Rôles autorisés';

DEFINE FIELD modules ON studio_page
  TYPE array<string>
  DEFAULT []
  COMMENT 'Modules requis';

DEFINE FIELD active ON studio_page
  TYPE bool
  DEFAULT true;

DEFINE FIELD metadata ON studio_page
  TYPE object;

DEFINE FIELD metadata.created_at ON studio_page
  TYPE datetime
  DEFAULT time::now()
  READONLY;

DEFINE FIELD metadata.updated_at ON studio_page
  TYPE datetime
  DEFAULT time::now();

-- Index
DEFINE INDEX code_unique ON studio_page FIELDS code UNIQUE;
DEFINE INDEX url_unique ON studio_page FIELDS url UNIQUE;
DEFINE INDEX active_idx ON studio_page FIELDS active;
```

### Exemple de Seed

```surql
-- Page Dashboard CRM
CREATE studio_page:crm_dashboard SET
  code = "crm_dashboard",
  title = {
    fr: "Tableau de Bord CRM",
    en: "CRM Dashboard"
  },
  description = {
    fr: "Vue d'ensemble de votre activité CRM",
    en: "Overview of your CRM activity"
  },
  url = "/crm/dashboard",
  layout = "grid",
  widgets = [
    studio_widget:contacts_count,
    studio_widget:companies_count,
    studio_widget:deals_chart,
    studio_widget:recent_contacts
  ],
  breadcrumb = [
    { label: { fr: "Accueil", en: "Home" }, url: "/" },
    { label: { fr: "CRM", en: "CRM" }, url: "/crm" },
    { label: { fr: "Dashboard", en: "Dashboard" }, url: "/crm/dashboard" }
  ],
  permissions = ["user", "admin"],
  modules = ["crm"],
  active = true;
```

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

## 🚀 Prochaines Étapes

1. **[FUNCTIONS.md](./FUNCTIONS.md)** → Toutes les fonctions SurrealDB
2. **[GUIDE.md](./GUIDE.md)** → Guide d'utilisation
3. **[INTEGRATION.md](./INTEGRATION.md)** → Intégration React + React Native + DaisyUI
4. **[MOBILE.md](./MOBILE.md)** → Guide complet React Native
5. **[DAISYUI.md](./DAISYUI.md)** → Guide complet DaisyUI


