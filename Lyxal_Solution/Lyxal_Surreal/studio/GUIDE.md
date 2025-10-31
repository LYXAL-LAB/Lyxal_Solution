# 📖 Guide d'Utilisation - Lyxal Studio

Ce guide pratique vous montre comment utiliser Lyxal Studio pas à pas.

---

## 🎯 Cas d'Usage 1 : Créer un Nouveau Tenant White-Label

### Objectif
Créer une configuration complète pour un nouveau partenaire "BatiPro".

### Étape 1 : Créer la Configuration

```surql
-- Connexion à SurrealDB Cloud
surreal sql --endpoint wss://cloud.surrealdb.com:443/rpc \
  --namespace lyxal_solution --database main

-- Créer la configuration BatiPro
SELECT fn::studio_create_default_config(
  'batipro',
  { fr: "BatiPro", en: "BatiPro" },
  '#FF6B35'
);

-- Ou manuellement pour plus de contrôle
CREATE studio_config:batipro SET
  tenant_id = "batipro",
  app_name = { fr: "BatiPro", en: "BatiPro" },
  logo = "https://cdn.batipro.com/logo.svg",
  primary_color = "#FF6B35",
  secondary_color = "#004E89",
  theme = studio_theme:lyxal_default,
  language_default = "fr",
  enabled_modules = ["crm", "project"],
  custom_domain = "app.batipro.com",
  active = true;
```

### Étape 2 : Personnaliser les Menus

```surql
-- Personnaliser le label "CRM" → "Clients" pour BatiPro
-- Option 1 : Créer un menu spécifique
CREATE studio_menu:batipro_clients SET
  code = "batipro_clients",
  label = { fr: "Clients", en: "Clients" },
  icon = "Users",
  url = "/crm",
  order = 1,
  permissions = ["user", "admin"],
  modules = ["crm"];

-- Option 2 : Utiliser les menus par défaut (recommandé)
-- Les menus sont partagés, seul le tenant_id et modules changent
```

### Étape 3 : Tester le Nouveau Tenant

```typescript
// Frontend - Accéder au tenant BatiPro
const App = () => {
  return (
    <StudioEngine tenant="batipro">
      {/* Interface complète pour BatiPro */}
    </StudioEngine>
  );
};
```

**Résultat** : BatiPro a son propre SaaS avec logo, couleurs et modules ! 🎨

---

## 🎯 Cas d'Usage 2 : Créer une Page Dashboard

### Objectif
Créer un dashboard de ventes avec KPIs et graphiques.

### Étape 1 : Créer les Widgets

```surql
-- Widget 1 : Revenue total ce mois
CREATE studio_widget:sales_revenue_month SET
  code = "sales_revenue_month",
  title = { fr: "CA du Mois", en: "Monthly Revenue" },
  type = "stat",
  query = "SELECT SUM(amount) AS total FROM invoice WHERE MONTH(created_at) = MONTH(time::now()) AND status = 'paid'",
  config = {
    icon: "DollarSign",
    color: "green",
    format: "currency",
    currency: "EUR"
  },
  refresh_interval = 300000,  // 5 minutes
  permissions = ["user", "admin"],
  active = true;

-- Widget 2 : Nombre de devis ce mois
CREATE studio_widget:quotes_count_month SET
  code = "quotes_count_month",
  title = { fr: "Devis du Mois", en: "Monthly Quotes" },
  type = "stat",
  query = "SELECT COUNT() AS count FROM quote WHERE MONTH(created_at) = MONTH(time::now())",
  config = {
    icon: "FileText",
    color: "blue",
    format: "number"
  },
  refresh_interval = 300000,
  permissions = ["user", "admin"],
  active = true;

-- Widget 3 : Évolution CA (graphique)
CREATE studio_widget:sales_evolution_chart SET
  code = "sales_evolution_chart",
  title = { fr: "Évolution du CA", en: "Revenue Evolution" },
  type = "chart",
  query = "SELECT time::month(created_at) AS month, SUM(amount) AS revenue FROM invoice WHERE status = 'paid' GROUP BY month ORDER BY month DESC LIMIT 12",
  config = {
    chart_type: "line",
    x_axis: "month",
    y_axis: "revenue",
    color: "#10B981",
    format_y: "currency"
  },
  refresh_interval = 600000,  // 10 minutes
  permissions = ["user", "admin"],
  active = true;

-- Widget 4 : Top clients (table)
CREATE studio_widget:top_clients_table SET
  code = "top_clients_table",
  title = { fr: "Top 10 Clients", en: "Top 10 Clients" },
  type = "table",
  query = "SELECT company.name AS client, SUM(amount) AS revenue FROM invoice WHERE status = 'paid' GROUP BY client ORDER BY revenue DESC LIMIT 10",
  config = {
    columns: [
      { field: "client", label: { fr: "Client", en: "Client" } },
      { field: "revenue", label: { fr: "CA Total", en: "Total Revenue" }, format: "currency" }
    ]
  },
  refresh_interval = 600000,
  permissions = ["user", "admin"],
  active = true;
```

### Étape 2 : Créer la Page Dashboard

```surql
-- Page Dashboard Sales
CREATE studio_page:sales_dashboard SET
  code = "sales_dashboard",
  title = { fr: "Tableau de Bord Ventes", en: "Sales Dashboard" },
  description = { fr: "Vue d'ensemble de vos ventes", en: "Overview of your sales" },
  url = "/sales/dashboard",
  layout = "grid",
  widgets = [
    studio_widget:sales_revenue_month,
    studio_widget:quotes_count_month,
    studio_widget:sales_evolution_chart,
    studio_widget:top_clients_table
  ],
  breadcrumb = [
    { label: { fr: "Accueil", en: "Home" }, url: "/" },
    { label: { fr: "Ventes", en: "Sales" }, url: "/sales" },
    { label: { fr: "Dashboard", en: "Dashboard" }, url: "/sales/dashboard" }
  ],
  permissions = ["user", "admin"],
  modules = ["sales"],
  active = true;
```

### Étape 3 : Ajouter le Menu

```surql
-- Menu Sales → Dashboard
CREATE studio_menu:sales_dashboard SET
  code = "sales_dashboard",
  label = { fr: "Dashboard", en: "Dashboard" },
  icon = "LayoutDashboard",
  url = "/sales/dashboard",
  parent = studio_menu:sales,  -- Sous-menu de "Sales"
  order = 1,
  permissions = ["user", "admin"],
  modules = ["sales"],
  active = true;
```

**Résultat** : Dashboard complet créé sans coder ! 📊

---

## 🎯 Cas d'Usage 3 : Créer un Formulaire de Contact

### Objectif
Formulaire de création de contact avec validation.

### Étape 1 : Définir le Formulaire

```surql
CREATE studio_form:contact_create SET
  code = "contact_create",
  title = { fr: "Nouveau Contact", en: "New Contact" },
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
      message: { fr: "Format de téléphone invalide", en: "Invalid phone format" }
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

### Étape 2 : Utiliser le Formulaire

```typescript
// Frontend React
const ContactCreatePage = () => {
  return (
    <StudioForm 
      formCode="contact_create"
      onSubmit={(result) => {
        if (result.success) {
          alert('Contact créé !');
          navigate('/crm/contacts');
        } else {
          alert('Erreur : ' + result.errors.join(', '));
        }
      }}
    />
  );
};
```

**Résultat** : Formulaire complet avec validation ! 📝

---

## 🎯 Cas d'Usage 4 : Activer/Désactiver un Module

### Objectif
Activer le module "Marketing" pour BatiPro.

### Méthode 1 : Via Fonction

```surql
-- Activer Marketing
SELECT fn::studio_activate_module('batipro', 'marketing');

-- Désactiver Project
SELECT fn::studio_deactivate_module('batipro', 'project');
```

### Méthode 2 : UPDATE Direct

```surql
-- Activer Marketing
UPDATE studio_config:batipro SET
  enabled_modules += "marketing",
  metadata.updated_at = time::now();

-- Désactiver Project
UPDATE studio_config:batipro SET
  enabled_modules -= "project",
  metadata.updated_at = time::now();
```

### Résultat en Frontend

```typescript
// Le menu Marketing apparaît automatiquement (LIVE QUERY)
// Les pages Marketing deviennent accessibles
// Tout est instantané !
```

**Résultat** : Module activé/désactivé en temps réel ! ⚡

---

## 🎯 Cas d'Usage 5 : A/B Testing de Pages

### Objectif
Tester 2 versions d'une page dashboard.

### Étape 1 : Dupliquer la Page

```surql
-- Créer version B (variante)
SELECT fn::studio_duplicate_page(
  'crm_dashboard',
  'crm_dashboard_v2',
  { fr: "Dashboard CRM v2", en: "CRM Dashboard v2" }
);
```

### Étape 2 : Modifier la Version B

```surql
-- Ajouter/retirer des widgets dans v2
UPDATE studio_page:crm_dashboard_v2 SET
  widgets = [
    studio_widget:contacts_count,
    studio_widget:new_experimental_widget,  // ← Nouveau widget
    studio_widget:deals_chart
  ];
```

### Étape 3 : Assigner aux Utilisateurs

```surql
-- 50% des users voient v1, 50% voient v2
-- Via une table user_preferences
UPDATE user_preferences SET
  dashboard_version = IF math::random() < 0.5 THEN studio_page:crm_dashboard ELSE studio_page:crm_dashboard_v2 END
WHERE user_id = $user_id;
```

### Étape 4 : Analyser les Résultats

```surql
-- Quelle version est la plus consultée ?
SELECT 
  dashboard_version,
  COUNT() AS visits,
  AVG(time_spent) AS avg_time
FROM page_analytics
WHERE created_at > time::now() - 7d
GROUP BY dashboard_version;
```

**Résultat** : A/B testing facile ! 📈

---

## 🎯 Cas d'Usage 6 : Créer un Thème Personnalisé

### Objectif
Créer un thème "Dark Mode" pour Lyxal.

### Étape 1 : Créer le Thème

```surql
CREATE studio_theme:lyxal_dark SET
  code = "lyxal_dark",
  name = { fr: "Thème Sombre Lyxal", en: "Lyxal Dark Theme" },
  colors = {
    primary: "#60A5FA",
    secondary: "#34D399",
    accent: "#FBBF24",
    background: "#111827",
    surface: "#1F2937",
    text: "#F9FAFB",
    text_secondary: "#9CA3AF",
    border: "#374151",
    error: "#F87171",
    success: "#34D399",
    warning: "#FBBF24",
    info: "#60A5FA"
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
  active = true;
```

### Étape 2 : Appliquer le Thème

```surql
-- Appliquer à un tenant
UPDATE studio_config:lyxal SET
  theme = studio_theme:lyxal_dark;

-- Ou permettre aux users de choisir
UPDATE user_preferences SET
  theme = studio_theme:lyxal_dark
WHERE user_id = $user_id;
```

**Résultat** : Dark mode instantané ! 🌙

---

## 🎯 Cas d'Usage 7 : Permissions Granulaires

### Objectif
Le module "Admin" est visible seulement par les admins.

### Configuration

```surql
-- Menu Admin
CREATE studio_menu:admin SET
  code = "admin",
  label = { fr: "Administration", en: "Admin" },
  icon = "Settings",
  url = "/admin",
  order = 99,
  permissions = ["admin"],  // ← Seulement admins
  active = true;

-- Page Admin
CREATE studio_page:admin_dashboard SET
  code = "admin_dashboard",
  title = { fr: "Administration", en: "Admin" },
  url = "/admin/dashboard",
  layout = "flex",
  permissions = ["admin"],  // ← Seulement admins
  active = true;
```

### Vérification Frontend

```typescript
// Hook React pour vérifier les permissions
const useCheckPermission = (resourceType, resourceId) => {
  const { user } = useAuth();
  
  return useQuery(['permission', resourceId], () =>
    db.query(`
      SELECT fn::studio_check_permission(
        '${resourceType}',
        ${resourceId},
        '${user.role}',
        ${JSON.stringify(user.enabled_modules)}
      )
    `)
  );
};

// Utilisation
const AdminPage = () => {
  const { data: permission } = useCheckPermission('page', 'studio_page:admin_dashboard');
  
  if (!permission?.allowed) {
    return <Redirect to="/403" />;
  }
  
  return <AdminDashboard />;
};
```

**Résultat** : Contrôle d'accès granulaire ! 🔒

---

## 🛠️ Commandes Utiles

### Lister Tous les Tenants

```surql
SELECT fn::studio_get_all_tenants();
```

### Voir la Config d'un Tenant

```surql
SELECT * FROM studio_config:batipro;
```

### Voir Tous les Menus Actifs

```surql
SELECT * FROM studio_menu WHERE active = true ORDER BY order;
```

### Voir Toutes les Pages

```surql
SELECT code, title, url, modules FROM studio_page WHERE active = true;
```

### Voir Tous les Formulaires

```surql
SELECT code, title, table FROM studio_form WHERE active = true;
```

---

## 🚀 Prochaines Étapes

1. **[INTEGRATION.md](./INTEGRATION.md)** → Intégration React complète
2. **[COMPONENTS.md](./COMPONENTS.md)** → Documentation des composants React
3. **[DATABASE.md](./DATABASE.md)** → Référence complète des tables


