# 🏗️ Pattern de Base de Données Lyxal Kit UI

## Vue d'ensemble

Le système de base de données de **Lyxal Kit UI** suit un pattern architectural inspiré de `studio_component.surql`, adapté à nos besoins spécifiques de design system.

## 🏛️ Architecture Modulaire

### Structure en Blocs Logiques

Chaque table est organisée en **blocs fonctionnels** cohérents :

```
📦 identity      → Identification unique et noms
🎨 presentation  → Affichage et i18n
⚙️  config       → Configuration et paramètres
📊 status        → État et cycle de vie
📈 metadata      → Analytics et métadonnées
⏰ timestamp     → Timestamps automatiques
🔒 etag         → Optimistic locking
```

## 📋 Tables Principales

### 1. `ui_component_library_category`

**Rôle** : Catégories organisationnelles pour les composants UI

```surql
identity: {
    value: "layout",           // Technique
    slug: "layout",            // URL-friendly
    code: "layout"             // Snake_case
},
presentation: {
    name_i18n: i18n_key:...,   // Internationalisation
    icon: icon:layout,         // Référence icône
    color: "#3b82f6"           // Couleur identité
},
config: {
    order: 1,                  // Ordre d'affichage
    is_visible: true           // Visible dans l'UI
},
status: {
    is_active: true,           // Actif/utilisable
    is_system_category: true   // Système ou custom
}
```

### 2. `ui_component_library`

**Rôle** : Composants créés dans Lyxal Kit UI (pas d'import externe)

```surql
identity: {
    value: "button",
    slug: "button",
    code: "button"
},
presentation: {
    name_i18n: i18n_key:...,
    preview_url: url:...,
    keywords: ["button", "action"]
},
structure: {
    "id": "button_default",
    "lang": "fr",
    "version": "1.0.0",
    "category": "input",
    "description": "Bouton d'action interactif",
    "props": {
        "variant": "default",
        "size": "default",
        "disabled": false,
        // ... toutes les props CSS et comportement
    },
    "variants": {
        "primary": { "backgroundColor": "var(--color-primary)" },
        "secondary": { "backgroundColor": "var(--color-secondary)" }
    },
    "i18n": {
        "defaultLabel": { "fr": "Bouton", "en": "Button" }
    }
},
config: {
    category: ui_component_library_category:input,
    version: "1.0.0",
    source: "system"             // system | user_created
},
status: {
    is_active: true,
    is_deprecated: false
}
```

## 🎯 **Copie conforme JSON**

La **vraie innovation** de ce pattern : la DB est la **copie exacte** de tes fichiers JSON !

### **Principe**
- ✅ **structure** = copie conforme du fichier `.defaults.json`
- ✅ **Pas de mapping** : JSON → DB → JSON sans transformation
- ✅ **Évolution libre** : ajoute des propriétés dans le JSON sans changer le schéma

### **Avantages**
- **Fidélité parfaite** : même structure, mêmes données
- **Migration simple** : import direct des fichiers JSON
- **Flexibilité maximale** : structure évolutive sans refactor DB
- **Développement rapide** : code → JSON → DB en un seul endroit

### **Workflow idéal**
```bash
# Développement (exemple avec Accordeon)
1. Coder Accordeon.tsx
2. Créer accordion.defaults.json (avec toutes les props)
3. Tester localement avec le JSON
4. Créer la référence DB dans components.surql
5. Importer en DB quand prêt

# Production (plus tard)
1. Charger depuis DB : SELECT * FROM ui_component_library:accordion
2. Utiliser directement : <Accordeon config={data.structure} />
```

## 🔗 Relations et Références

### Types de Références

- **`record<i18n_key>`** : Clés d'internationalisation
- **`record<icon>`** : Icônes Lucide React
- **`record<url>`** : URLs (previews, CDN)
- **`record<tag>`** : Tags de classification
- **`record<ui_component_library_category>`** : Catégorie parente

### Stratégies de Suppression

- **`REJECT`** : Bloque la suppression si référencé
- **`UNSET`** : Met à `NONE` la référence

## 🗂️ Organisation des Fichiers

```
database/
├── ui_component_library_category.surql    # Schéma catégories
└── ui_component_library.surql             # Schéma composants

reference/
├── categories.surql                       # Seed catégories
└── components.surql                       # Seed composants
```

## ⚡ Optimisations de Performance

### Indexes Stratégiques

```surql
-- Identité (uniques)
idx_ui_component_library_code         → identity.code UNIQUE
idx_ui_component_library_slug         → identity.slug UNIQUE

-- Recherche
idx_ui_component_library_category     → config.category
idx_ui_component_library_active       → status.is_active

-- Analytics
idx_ui_component_library_source       → config.source
```

### Optimistic Locking

```surql
etag: uuid READONLY DEFAULT ALWAYS rand::uuid::v7()
```

## 📊 Métriques et Analytics

### Métriques Automatiques

- **`usage_count`** : Nombre d'utilisations
- **`last_used_at`** : Dernière utilisation
- **`component_count`** : Composants par catégorie (calculé)

### Timestamps

```surql
timestamp: {
    created_at: datetime READONLY DEFAULT time::now(),
    updated_at: datetime READONLY DEFAULT ALWAYS time::now()
}
```

## 🎯 Bonnes Pratiques

### 1. **Validation Stricte**
```surql
ASSERT $value != NONE AND $value != ""
ASSERT $value INSIDE ['system', 'user_created']
```

### 2. **Références Cohérentes**
```surql
TYPE record<ui_component_library_category>
REFERENCE ON DELETE REJECT
```

### 3. **Structure JSON Flexible**
```surql
props_default: FLEXIBLE TYPE option<object>
```

### 4. **Internationalisation**
```surql
name_i18n: record<i18n_key>
description_i18n: record<i18n_key>
```

## 🚀 Utilisation

### Créer une Nouvelle Catégorie

```surql
CREATE ui_component_library_category:my_category SET
    identity = {
        value: "my-category",
        slug: "my-category",
        code: "my_category"
    },
    presentation = {
        name_i18n: i18n_key:category_my_name,
        icon: icon:component,
        color: "#6b7280"
    },
    config = {
        order: 99,
        is_visible: true
    },
    status = {
        is_active: true,
        is_system_category: false
    };
```

### Créer un Nouveau Composant

*(Voir l'exemple complet de l'accordéon dans `reference/components.surql`)*

**Étapes :**
1. **Créer** `src/components/MyComponent/MyComponent.tsx`
2. **Créer** `src/components/MyComponent/mycomponent.defaults.json`
3. **Ajouter** la référence dans `reference/components.surql`
4. **Importer** en DB quand prêt

```surql
CREATE ui_component_library:my_component SET
    identity = {
        value: "my-component",
        slug: "my-component",
        code: "my_component"
    },
    presentation = {
        name_i18n: i18n_key:my_component_name,
        keywords: ["custom", "component"]
    },
    structure = {
        // Copie conforme de mycomponent.defaults.json
        "id": "my_component_default",
        "lang": "fr",
        "version": "1.0.0",
        "category": "custom",
        "props": { /* toutes les props */ },
        "variants": { /* variants */ },
        "i18n": { /* traductions */ }
    },
    config = {
        category: ui_component_library_category:my_category,
        source: "user_created"
    };
```

## 🔄 Évolution Future

Le pattern permet l'ajout de nouveaux blocs sans casser la structure existante :

- **Bloc `context`** : Usage hints, dépendances
- **Bloc `security`** : Permissions, rôles
- **Bloc `analytics`** : Métriques détaillées

Cette architecture modulaire assure la **maintenabilité** et **l'évolutivité** du système. 🎯
