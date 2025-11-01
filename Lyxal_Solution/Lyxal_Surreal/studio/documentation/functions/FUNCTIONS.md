# ⚙️ Functions - Lyxal Studio

Ce document décrit toutes les fonctions SurrealDB de Lyxal Studio.

---

## 📋 Vue d'Ensemble des Fonctions

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

## 1️⃣ fn::studio_get_config

**Rôle** : Récupérer toute la configuration d'un tenant.

### Signature

```surql
DEFINE FUNCTION fn::studio_get_config($tenant_id: string) {
  -- Récupérer la config + thème en 1 query
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

### Utilisation

```typescript
// Frontend React
const config = await db.query(`SELECT fn::studio_get_config('lyxal')`);
console.log(config.config.app_name.fr);  // "Lyxal Suite"
console.log(config.config.primary_color);  // "#3B82F6"
```

---

## 2️⃣ fn::studio_get_menu

**Rôle** : Construire le menu complet pour un utilisateur (filtré par rôle et modules).

### Signature

```surql
DEFINE FUNCTION fn::studio_get_menu(
  $tenant_id: string,
  $role: string,
  $modules: array<string>
) {
  -- Récupérer tous les menus autorisés
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
  
  -- Construire la hiérarchie (parents + enfants)
  LET $menu_tree = [];
  
  FOR $menu IN $menus {
    IF $menu.parent = NONE THEN
      -- Menu de niveau 1
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

### Utilisation

```typescript
// Frontend React
const { menu } = await db.query(`
  SELECT fn::studio_get_menu('lyxal', 'admin', ['crm', 'sales'])
`);

// Rendu du menu
menu.forEach(item => {
  console.log(item.label.fr);  // "CRM"
  item.children.forEach(child => {
    console.log(' -', child.label.fr);  // " - Contacts", " - Entreprises"
  });
});
```

---

## 3️⃣ fn::studio_render_page

**Rôle** : Charger une page complète avec tous ses widgets et données.

### Signature

```surql
DEFINE FUNCTION fn::studio_render_page(
  $page_code: string,
  $tenant_id: string
) {
  -- Récupérer la définition de la page
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
  
  -- Charger les widgets avec leurs données
  LET $widgets_with_data = [];
  
  FOR $widget_ref IN $page.widgets {
    LET $widget = (SELECT * FROM $widget_ref LIMIT 1)[0];
    
    IF $widget AND $widget.query THEN
      -- Exécuter la query du widget
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

### Utilisation

```typescript
// Frontend React
const { page, widgets } = await db.query(`
  SELECT fn::studio_render_page('crm_dashboard', 'lyxal')
`);

// Rendu de la page
console.log(page.title.fr);  // "Tableau de Bord CRM"

widgets.forEach(w => {
  console.log(w.widget.title.fr);  // "Contacts Actifs"
  console.log(w.data);  // { count: 523 }
});
```

---

## 4️⃣ fn::studio_validate_form

**Rôle** : Valider les données d'un formulaire selon ses règles.

### Signature

```surql
DEFINE FUNCTION fn::studio_validate_form(
  $form_code: string,
  $data: object
) {
  -- Récupérer la définition du formulaire
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
  
  -- Valider les champs requis
  LET $errors = [];
  
  FOR $field IN $form.fields {
    IF $field.required AND !$data[$field.name] THEN
      LET $errors += {
        field: $field.name,
        message: "Field " + $field.name + " is required"
      };
    END;
  };
  
  -- Valider les règles custom
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

### Utilisation

```typescript
// Frontend React
const result = await db.query(`
  SELECT fn::studio_validate_form('contact_create', {
    first_name: "Jean",
    email: "invalid-email"  // ← Email invalide
  })
`);

if (!result.valid) {
  console.log(result.errors);
  // [{ field: "email", message: "Email invalide" }]
}
```

---

## 5️⃣ fn::studio_submit_form

**Rôle** : Soumettre un formulaire (INSERT ou UPDATE selon le contexte).

### Signature

```surql
DEFINE FUNCTION fn::studio_submit_form(
  $form_code: string,
  $data: object,
  $record_id: option<record>
) {
  -- Récupérer la définition du formulaire
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
  
  -- Valider d'abord
  LET $validation = fn::studio_validate_form($form_code, $data);
  
  IF !$validation.valid THEN
    RETURN {
      success: false,
      errors: $validation.errors
    };
  END;
  
  -- Déterminer si c'est un CREATE ou UPDATE
  LET $result = NONE;
  
  IF $record_id THEN
    -- UPDATE
    LET $result = UPDATE $record_id CONTENT $data RETURN AFTER;
  ELSE
    -- CREATE
    LET $result = CREATE type::table($form.table) CONTENT $data RETURN AFTER;
  END;
  
  RETURN {
    success: true,
    record: $result
  };
};
```

### Utilisation

```typescript
// Frontend React - Créer un contact
const result = await db.query(`
  SELECT fn::studio_submit_form('contact_create', {
    first_name: "Jean",
    last_name: "Dupont",
    email: "jean.dupont@example.com",
    status: "lead"
  }, NONE)
`);

if (result.success) {
  console.log('Contact créé:', result.record);
}

// Frontend React - Modifier un contact
const updateResult = await db.query(`
  SELECT fn::studio_submit_form('contact_create', {
    first_name: "Jean",
    last_name: "DUPONT",
    email: "jean.dupont@example.com"
  }, type::record('contact', 'abc123'))
`);
```

---

## 6️⃣ fn::studio_check_permission

**Rôle** : Vérifier si un utilisateur a accès à une ressource.

### Signature

```surql
DEFINE FUNCTION fn::studio_check_permission(
  $resource_type: string,
  $resource_id: record,
  $user_role: string,
  $user_modules: array<string>
) {
  -- Récupérer la ressource
  LET $resource = (SELECT * FROM $resource_id LIMIT 1)[0];
  
  IF !$resource THEN
    RETURN {
      allowed: false,
      reason: "Resource not found"
    };
  END;
  
  -- Vérifier les permissions
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

### Utilisation

```typescript
// Frontend React
const permission = await db.query(`
  SELECT fn::studio_check_permission(
    'page',
    studio_page:crm_dashboard,
    'user',
    ['crm', 'sales']
  )
`);

if (permission.allowed) {
  // Afficher la page
  renderPage(permission.resource);
} else {
  // Afficher erreur 403
  console.log(permission.reason);
}
```

---

## 7️⃣ fn::studio_execute_widget_query

**Rôle** : Exécuter la query d'un widget et retourner les données.

### Signature

```surql
DEFINE FUNCTION fn::studio_execute_widget_query($widget_code: string) {
  -- Récupérer le widget
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
  
  -- Exécuter la query
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

### Utilisation

```typescript
// Frontend React - Charger un widget
const { widget, data } = await db.query(`
  SELECT fn::studio_execute_widget_query('contacts_count')
`);

console.log(widget.title.fr);  // "Contacts Actifs"
console.log(data);  // { count: 523 }

// Avec auto-refresh
setInterval(async () => {
  const result = await db.query(`
    SELECT fn::studio_execute_widget_query('contacts_count')
  `);
  updateUI(result.data);
}, widget.config.refresh_interval || 60000);
```

---

## 8️⃣ fn::studio_get_theme

**Rôle** : Récupérer un thème complet avec toutes ses variables CSS.

### Signature

```surql
DEFINE FUNCTION fn::studio_get_theme($theme_id: record<studio_theme>) {
  -- Récupérer le thème
  LET $theme = (SELECT * FROM $theme_id WHERE active = true LIMIT 1)[0];
  
  IF !$theme THEN
    RETURN {
      error: true,
      message: "Theme not found"
    };
  END;
  
  -- Générer les variables CSS
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

### Utilisation

```typescript
// Frontend React - Appliquer le thème
const { theme, css_vars } = await db.query(`
  SELECT fn::studio_get_theme(studio_theme:lyxal_default)
`);

// Appliquer les variables CSS
const root = document.documentElement;
Object.entries(css_vars).forEach(([key, value]) => {
  root.style.setProperty(key, value);
});

// Ou avec styled-components
const theme = {
  colors: {
    primary: css_vars['--color-primary'],
    secondary: css_vars['--color-secondary'],
    ...
  }
};
```

---

## 9️⃣ fn::studio_create_default_config

**Rôle** : Créer une configuration par défaut pour un nouveau tenant.

### Signature

```surql
DEFINE FUNCTION fn::studio_create_default_config(
  $tenant_id: string,
  $app_name: object,
  $primary_color: option<string>
) {
  -- Vérifier si existe déjà
  LET $existing = SELECT * FROM studio_config WHERE tenant_id = $tenant_id;
  
  IF array::len($existing) > 0 THEN
    RETURN {
      error: true,
      message: "Config already exists for tenant: " + $tenant_id
    };
  END;
  
  -- Créer config par défaut
  LET $config = CREATE type::record('studio_config', $tenant_id) SET
    tenant_id = $tenant_id,
    app_name = $app_name,
    logo = "https://cdn.lyxal.com/logo-default.svg",
    primary_color = $primary_color OR "#3B82F6",
    secondary_color = "#10B981",
    theme = studio_theme:lyxal_default,
    language_default = "fr",
    enabled_modules = ["crm"],  -- Module CRM par défaut
    active = true,
    metadata = {
      created_at: time::now(),
      updated_at: time::now()
    };
  
  RETURN {
    success: true,
    config: $config
  };
};
```

### Utilisation

```surql
-- Créer config pour un nouveau partenaire
SELECT fn::studio_create_default_config(
  'batipro',
  { fr: "BatiPro", en: "BatiPro" },
  '#FF6B35'
);
```

---

## 🔟 fn::studio_duplicate_page

**Rôle** : Dupliquer une page existante (utile pour créer des variantes).

### Signature

```surql
DEFINE FUNCTION fn::studio_duplicate_page(
  $page_code: string,
  $new_code: string,
  $new_title: object
) {
  -- Récupérer la page source
  LET $source_page = (SELECT * FROM studio_page WHERE code = $page_code LIMIT 1)[0];
  
  IF !$source_page THEN
    RETURN {
      error: true,
      message: "Source page not found: " + $page_code
    };
  END;
  
  -- Créer la nouvelle page
  LET $new_page = CREATE type::record('studio_page', $new_code) SET
    code = $new_code,
    title = $new_title,
    description = $source_page.description,
    url = string::replace($source_page.url, $page_code, $new_code),
    layout = $source_page.layout,
    widgets = $source_page.widgets,
    breadcrumb = $source_page.breadcrumb,
    permissions = $source_page.permissions,
    modules = $source_page.modules,
    active = true,
    metadata = {
      created_at: time::now(),
      updated_at: time::now()
    };
  
  RETURN {
    success: true,
    page: $new_page
  };
};
```

### Utilisation

```surql
-- Créer une variante de la page dashboard
SELECT fn::studio_duplicate_page(
  'crm_dashboard',
  'crm_dashboard_v2',
  { fr: "Dashboard CRM v2", en: "CRM Dashboard v2" }
);
```

---

## 🎯 Fonctions Utilitaires

### fn::studio_get_all_tenants

```surql
DEFINE FUNCTION fn::studio_get_all_tenants() {
  LET $tenants = SELECT tenant_id, app_name, active FROM studio_config ORDER BY tenant_id;
  
  RETURN {
    success: true,
    tenants: $tenants,
    count: array::len($tenants)
  };
};
```

### fn::studio_activate_module

```surql
DEFINE FUNCTION fn::studio_activate_module($tenant_id: string, $module: string) {
  UPDATE studio_config SET
    enabled_modules += $module,
    metadata.updated_at = time::now()
  WHERE tenant_id = $tenant_id;
  
  RETURN {
    success: true,
    message: "Module " + $module + " activated for " + $tenant_id
  };
};
```

### fn::studio_deactivate_module

```surql
DEFINE FUNCTION fn::studio_deactivate_module($tenant_id: string, $module: string) {
  UPDATE studio_config SET
    enabled_modules -= $module,
    metadata.updated_at = time::now()
  WHERE tenant_id = $tenant_id;
  
  RETURN {
    success: true,
    message: "Module " + $module + " deactivated for " + $tenant_id
  };
};
```

---

## 🚀 Prochaines Étapes

1. **[GUIDE.md](./GUIDE.md)** → Guide d'utilisation pas à pas
2. **[INTEGRATION.md](./INTEGRATION.md)** → Intégration React complète
3. **[COMPONENTS.md](./COMPONENTS.md)** → Tous les composants React


