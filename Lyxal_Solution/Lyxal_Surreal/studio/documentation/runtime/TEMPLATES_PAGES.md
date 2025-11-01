# 📐 Système de Templates de Pages - Documentation de Réflexion

**Status :** 🟡 En réflexion - Schéma proposé

Cette documentation définit le système de **templates de pages** pour le Studio Runtime. Les templates permettent de réutiliser et catégoriser des structures de pages complètes pour différents cas d'usage (ecommerce, SaaS, portfolio, etc.).

---

## 🎯 Concept

### Qu'est-ce qu'un Template ?

Un **template** = Un **modèle réutilisable** contenant :
- ✅ Une ou plusieurs **pages** (`studio_page`) pré-configurées
- ✅ Une **catégorisation** (ecommerce, SaaS, portfolio, etc.)
- ✅ Des **métadonnées** (nom, description, tags, version)
- ✅ Des **prérequis** (modules nécessaires, configurations)
- ✅ Une **structure standardisée** pour un cas d'usage spécifique

### Cas d'Usage

**Exemples :**
- **Template "Ecommerce"** → Contient : page catalogue, page produit, panier, checkout
  - **Sous-catégorie "HiTech"** → Variante pour produits tech avec sections spécifiques
  - **Sous-catégorie "Mode"** → Variante pour vêtements avec galerie différente
  
- **Template "SaaS Dashboard"** → Contient : dashboard, settings, billing, users
  - **Sous-catégorie "CRM"** → Variante avec sections CRM
  - **Sous-catégorie "Analytics"** → Variante avec focus analytics

- **Template "Portfolio"** → Contient : page d'accueil, projets, contact
  - **Sous-catégorie "Designer"** → Variante visuelle
  - **Sous-catégorie "Développeur"** → Variante technique

---

## 🏗️ Architecture Proposée

```
studio_template_category (Catégorie)
    ├── Gère i18n pour les catégories (ecommerce, saas, portfolio, etc.)
    └── Exemples : studio_template_category:ecommerce, studio_template_category:saas

studio_template_subcategory (Sous-catégorie)
    ├── Gère i18n pour les sous-catégories (hitech, mode, designer, etc.)
    ├── Relation vers studio_template_category (parent)
    └── Exemples : studio_template_subcategory:hitech, studio_template_subcategory:designer

studio_template (Template)
    ├── Référence vers studio_template_category
    ├── Référence optionnelle vers studio_template_subcategory
    ├── Contient des références vers studio_page
    └── Métadonnées (nom, description, tags, version)

studio_page (Pages individuelles)
    ├── Peut être créée depuis un template
    └── Peut être liée à un template
```

### Relations

```
studio_template_category:1 → N studio_template_subcategory (1 catégorie a N sous-catégories)
studio_template_category:1 → N studio_template (1 catégorie a N templates)
studio_template_subcategory:1 → N studio_template (1 sous-catégorie a N templates)
studio_template:1 → N studio_page (1 template peut contenir plusieurs pages)
studio_page:N → 0..1 studio_template (1 page peut provenir d'un template)
```

**Exemple :**
```surql
-- Template Ecommerce HiTech
studio_template:ecommerce_hitech {
  category: "ecommerce",
  subcategory: "hitech",
  pages: [
    studio_page:product_catalog,
    studio_page:product_detail,
    studio_page:shopping_cart,
    studio_page:checkout
  ]
}
```

---

## 📋 Schéma SurrealDB

### Tables de Catégorisation

**`studio_template_category`** - Catégories principales avec i18n

**`studio_template_subcategory`** - Sous-catégories avec i18n (liées à une catégorie)

### Table `studio_template`

```surql
DEFINE TABLE studio_template SCHEMAFULL
    COMMENT 'Templates de pages - Modèles réutilisables pour différents cas d\'usage';

-- ============================================================================
-- IDENTITY : Identification unique du template
-- ============================================================================

DEFINE FIELD identity ON studio_template
    TYPE object
    COMMENT 'Bloc identité : identification unique du template';

    DEFINE FIELD identity.code ON studio_template
        TYPE string
        ASSERT $value != NONE AND $value != "" AND string::len($value) > 0
        COMMENT 'Code unique du template (snake_case) : "ecommerce_hitech", "saas_crm"';

    DEFINE FIELD identity.slug ON studio_template
        TYPE string
        COMMENT 'Slug pour URL friendly : "ecommerce-hitech"';

    DEFINE FIELD identity.value ON studio_template
        TYPE string
        DEFAULT "$before.code"
        COMMENT 'Valeur par défaut = code';

-- ============================================================================
-- PRESENTATION : Présentation du template
-- ============================================================================

DEFINE FIELD presentation ON studio_template
    TYPE object
    COMMENT 'Bloc présentation : affichage et métadonnées';

    DEFINE FIELD presentation.name_i18n ON studio_template
        TYPE option<record<i18n_key>>
        REFERENCE ON DELETE REJECT
        COMMENT 'Nom du template (i18n) : "Template Ecommerce HiTech"';

    DEFINE FIELD presentation.description_i18n ON studio_template
        TYPE option<record<i18n_key>>
        REFERENCE ON DELETE REJECT
        COMMENT 'Description du template (i18n)';

    DEFINE FIELD presentation.preview_url ON studio_template
        TYPE option<record<url>>
        REFERENCE ON DELETE SET NULL
        COMMENT 'URL de preview/screenshot du template';

    DEFINE FIELD presentation.keywords ON studio_template
        TYPE option<array<string>>
        DEFAULT []
        COMMENT 'Mots-clés : ["ecommerce", "hitech", "responsive", "modern"]';

-- ============================================================================
-- CATEGORIZATION : Catégorisation du template
-- ============================================================================

DEFINE FIELD categorization ON studio_template
    TYPE object
    COMMENT 'Bloc catégorisation : organisation par cas d\'usage';

    DEFINE FIELD categorization.category ON studio_template
        TYPE string
        ASSERT $value != NONE AND $value != ""
        COMMENT 'Catégorie principale : "ecommerce", "saas", "portfolio", "blog", "landing", "corporate"';

    DEFINE FIELD categorization.subcategory ON studio_template
        TYPE option<string>
        COMMENT 'Sous-catégorie : "hitech", "mode", "designer", "developer", "crm", "analytics"';

    DEFINE FIELD categorization.tags ON studio_template
        TYPE option<array<record<tag>>>
        DEFAULT []
        COMMENT 'Tags additionnels pour recherche et filtrage';

-- ============================================================================
-- PAGES : Pages incluses dans le template
-- ============================================================================

DEFINE FIELD pages ON studio_template
    TYPE array<record<studio_page>>
    DEFAULT []
    COMMENT 'Liste des pages incluses dans ce template';

    -- Exemple :
    -- pages: [
    --   studio_page:product_catalog,
    --   studio_page:product_detail,
    --   studio_page:shopping_cart
    -- ]

-- ============================================================================
-- CONFIG : Configuration du template
-- ============================================================================

DEFINE FIELD config ON studio_template
    TYPE object
    COMMENT 'Bloc configuration : prérequis et configuration';

    DEFINE FIELD config.required_modules ON studio_template
        TYPE option<array<string>>
        DEFAULT []
        COMMENT 'Modules requis : ["crm", "sales", "inventory"]';

    DEFINE FIELD config.required_components ON studio_template
        TYPE option<array<record<studio_component>>>
        DEFAULT []
        COMMENT 'Composants requis par le template';

    DEFINE FIELD config.theme ON studio_template
        TYPE option<record<theme>>
        REFERENCE ON DELETE SET NULL
        COMMENT 'Thème recommandé pour ce template';

    DEFINE FIELD config.is_multi_tenant ON studio_template
        TYPE bool
        DEFAULT false
        COMMENT 'Template compatible multi-tenant ?';

    DEFINE FIELD config.is_responsive ON studio_template
        TYPE bool
        DEFAULT true
        COMMENT 'Template responsive ?';

-- ============================================================================
-- CONTEXT : Contexte d'utilisation
-- ============================================================================

DEFINE FIELD context ON studio_template
    TYPE object
    COMMENT 'Bloc contexte : contexte d\'utilisation du template';

    DEFINE FIELD context.usage_hints ON studio_template
        TYPE option<array<string>>
        DEFAULT []
        COMMENT 'Indices d\'utilisation : ["small_business", "enterprise", "startup"]';

    DEFINE FIELD context.target_audience ON studio_template
        TYPE option<array<string>>
        DEFAULT []
        COMMENT 'Audience cible : ["b2c", "b2b", "b2b2c"]';

-- ============================================================================
-- STATUS : Statut du template
-- ============================================================================

DEFINE FIELD status ON studio_template
    TYPE object
    COMMENT 'Bloc statut : état du template';

    DEFINE FIELD status.is_active ON studio_template
        TYPE bool
        DEFAULT true
        COMMENT 'Template actif (disponible) ?';

    DEFINE FIELD status.is_featured ON studio_template
        TYPE bool
        DEFAULT false
        COMMENT 'Template mis en avant ?';

    DEFINE FIELD status.is_system_template ON studio_template
        TYPE bool
        DEFAULT false
        COMMENT 'Template système (fourni par défaut) ?';

-- ============================================================================
-- METADATA : Métadonnées
-- ============================================================================

DEFINE FIELD metadata ON studio_template
    TYPE object
    COMMENT 'Bloc métadonnées : informations système';

    DEFINE FIELD metadata.version ON studio_template
        TYPE string
        DEFAULT '1.0.0'
        COMMENT 'Version du template : "1.0.0", "2.1.3"';

    DEFINE FIELD metadata.author_user_id ON studio_template
        TYPE option<record<identity>>
        REFERENCE ON DELETE SET NULL
        COMMENT 'Utilisateur créateur du template (si custom)';

    DEFINE FIELD metadata.notes ON studio_template
        TYPE option<string>
        COMMENT 'Notes internes libres';

    DEFINE FIELD metadata.usage_count ON studio_template
        TYPE int
        DEFAULT 0
        COMMENT 'Nombre de fois que le template a été utilisé';

-- ============================================================================
-- TIMESTAMPS & ETAG
-- ============================================================================

DEFINE FIELD timestamp ON studio_template
    TYPE object
    COMMENT 'Bloc timestamp : dates de création et modification';

    DEFINE FIELD timestamp.created_at ON studio_template
        TYPE datetime
        READONLY
        DEFAULT time::now()
        COMMENT 'Date de création (readonly)';

    DEFINE FIELD timestamp.updated_at ON studio_template
        TYPE datetime
        READONLY
        DEFAULT ALWAYS time::now()
        COMMENT 'Date de dernière modification (readonly)';

DEFINE FIELD etag ON studio_template
    TYPE string
    READONLY
    DEFAULT ALWAYS rand::uuid::v7()
    COMMENT 'ETag pour optimistic locking (readonly)';

-- ============================================================================
-- INDEX
-- ============================================================================

DEFINE INDEX code_unique ON studio_template FIELDS identity.code UNIQUE;
DEFINE INDEX category_idx ON studio_template FIELDS categorization.category;
DEFINE INDEX category_subcategory_idx ON studio_template 
    FIELDS categorization.category, categorization.subcategory;
```

---

## 📝 Exemples de Templates

### Exemple 1 : Template Ecommerce HiTech

```surql
-- D'abord créer les catégories avec i18n
CREATE studio_template_category:ecommerce SET
    identity = {
        code = "ecommerce",
        slug = "ecommerce",
        value = "ecommerce"
    },
    presentation = {
        name_i18n = i18n_key:category_ecommerce_name,
        description_i18n = i18n_key:category_ecommerce_description
    },
    status = {
        is_active = true
    };

CREATE studio_template_subcategory:hitech SET
    identity = {
        code = "hitech",
        slug = "hitech",
        value = "hitech"
    },
    presentation = {
        name_i18n = i18n_key:subcategory_hitech_name,
        description_i18n = i18n_key:subcategory_hitech_description
    },
    relation = {
        category = studio_template_category:ecommerce
    },
    status = {
        is_active = true
    };

-- Ensuite créer le template avec références vers les catégories
CREATE studio_template:ecommerce_hitech SET
    identity = {
        code = "ecommerce_hitech",
        slug = "ecommerce-hitech",
        value = "ecommerce_hitech"
    },
    presentation = {
        name_i18n = i18n_key:template_ecommerce_hitech_name,
        description_i18n = i18n_key:template_ecommerce_hitech_description,
        keywords = ["ecommerce", "hitech", "technology", "responsive", "modern"]
    },
    categorization = {
        category = studio_template_category:ecommerce,
        subcategory = studio_template_subcategory:hitech,
        tags = [tag:modern, tag:responsive]
    },
    pages = [
        studio_page:product_catalog,
        studio_page:product_detail_hitech,
        studio_page:shopping_cart,
        studio_page:checkout,
        studio_page:order_confirmation
    ],
    config = {
        required_modules = [],
        theme = theme:modern_tech,
        is_responsive = true,
        is_multi_tenant = true
    },
    context = {
        usage_hints = ["small_business", "enterprise"],
        target_audience = ["b2c", "b2b"]
    },
    status = {
        is_active = true,
        is_featured = true,
        is_system_template = true
    },
    metadata = {
        version = "1.0.0",
        usage_count = 0
    };
```

### Exemple 2 : Template SaaS CRM

```surql
-- Créer les catégories si elles n'existent pas
CREATE studio_template_category:saas SET
    identity = { code = "saas", slug = "saas", value = "saas" },
    presentation = {
        name_i18n = i18n_key:category_saas_name,
        description_i18n = i18n_key:category_saas_description
    };

CREATE studio_template_subcategory:crm SET
    identity = { code = "crm", slug = "crm", value = "crm" },
    presentation = {
        name_i18n = i18n_key:subcategory_crm_name,
        description_i18n = i18n_key:subcategory_crm_description
    },
    relation = {
        category = studio_template_category:saas
    };

-- Créer le template
CREATE studio_template:saas_crm SET
    identity = {
        code = "saas_crm",
        slug = "saas-crm",
        value = "saas_crm"
    },
    presentation = {
        name_i18n = i18n_key:template_saas_crm_name,
        description_i18n = i18n_key:template_saas_crm_description,
        keywords = ["saas", "crm", "dashboard", "b2b"]
    },
    categorization = {
        category = studio_template_category:saas,
        subcategory = studio_template_subcategory:crm,
        tags = [tag:business, tag:dashboard]
    },
    pages = [
        studio_page:crm_dashboard,
        studio_page:contact_list,
        studio_page:contact_detail,
        studio_page:deal_pipeline,
        studio_page:settings_crm
    ],
    config = {
        required_modules = ["crm", "contacts"],
        theme = theme:corporate,
        is_responsive = true,
        is_multi_tenant = true
    },
    context = {
        usage_hints = ["enterprise", "startup"],
        target_audience = ["b2b"]
    },
    status = {
        is_active = true,
        is_featured = false,
        is_system_template = true
    },
    metadata = {
        version = "1.0.0",
        usage_count = 0
    };
```

### Exemple 3 : Template Portfolio Designer

```surql
-- Créer les catégories si elles n'existent pas
CREATE studio_template_category:portfolio SET
    identity = { code = "portfolio", slug = "portfolio", value = "portfolio" },
    presentation = {
        name_i18n = i18n_key:category_portfolio_name,
        description_i18n = i18n_key:category_portfolio_description
    };

CREATE studio_template_subcategory:designer SET
    identity = { code = "designer", slug = "designer", value = "designer" },
    presentation = {
        name_i18n = i18n_key:subcategory_designer_name,
        description_i18n = i18n_key:subcategory_designer_description
    },
    relation = {
        category = studio_template_category:portfolio
    };

-- Créer le template
CREATE studio_template:portfolio_designer SET
    identity = {
        code = "portfolio_designer",
        slug = "portfolio-designer",
        value = "portfolio_designer"
    },
    presentation = {
        name_i18n = i18n_key:template_portfolio_designer_name,
        description_i18n = i18n_key:template_portfolio_designer_description,
        keywords = ["portfolio", "designer", "creative", "showcase"]
    },
    categorization = {
        category = studio_template_category:portfolio,
        subcategory = studio_template_subcategory:designer,
        tags = [tag:creative, tag:visual]
    },
    pages = [
        studio_page:portfolio_home,
        studio_page:portfolio_projects,
        studio_page:portfolio_project_detail,
        studio_page:portfolio_about,
        studio_page:portfolio_contact
    ],
    config = {
        required_modules = [],
        theme = theme:creative_minimal,
        is_responsive = true,
        is_multi_tenant = false
    },
    context = {
        usage_hints = ["freelancer", "agency"],
        target_audience = ["b2c"]
    },
    status = {
        is_active = true,
        is_featured = true,
        is_system_template = true
    },
    metadata = {
        version = "1.0.0",
        usage_count = 0
    };
```

---

## 🔗 Relation avec `studio_page`

### Option 1 : Pages liées explicitement

```surql
-- Template contient des références vers des pages existantes
studio_template:ecommerce_hitech {
    pages: [
        studio_page:product_catalog,    -- Page existante
        studio_page:product_detail,     -- Page existante
        studio_page:shopping_cart       -- Page existante
    ]
}
```

### Option 2 : Pages créées depuis template (future)

```surql
-- Template contient la structure des pages (clonage)
studio_template:ecommerce_hitech {
    page_structures: {
        product_catalog: { /* structure JSON */ },
        product_detail: { /* structure JSON */ }
    }
}

-- Lors de l'utilisation, créer les pages depuis le template
CREATE studio_page:my_product_catalog FROM studio_template:ecommerce_hitech.page_structures.product_catalog;
```

**Recommandation initiale :** Option 1 (références explicites), puis évoluer vers Option 2 si besoin.

---

## 🎯 Cas d'Usage

### 1. Sélection de Template

```typescript
// Hook React pour charger les templates
const { templates } = useStudioTemplates({
  category: "ecommerce",
  subcategory: "hitech"
});

// Afficher les templates disponibles
templates.map(template => (
  <TemplateCard 
    key={template.id}
    template={template}
    onClick={() => applyTemplate(template.code)}
  />
));
```

### 2. Application d'un Template

```typescript
// Appliquer un template = créer/associer les pages du template
const applyTemplate = async (templateCode: string) => {
  const template = await db.query(`
    SELECT * FROM studio_template WHERE identity.code = $code
    FETCH pages
  `, { code: templateCode });

  // Option A : Associer les pages existantes
  // Les pages sont déjà créées, juste les associer au tenant

  // Option B : Cloner les pages depuis le template
  // Créer des copies personnalisées pour le tenant
};
```

### 3. Recherche et Filtrage

```surql
-- Rechercher tous les templates ecommerce (avec FETCH pour charger les catégories)
SELECT * FROM studio_template 
WHERE categorization.category = studio_template_category:ecommerce
AND status.is_active = true
FETCH categorization.category, categorization.subcategory;

-- Rechercher templates avec sous-catégorie hitech
SELECT * FROM studio_template 
WHERE categorization.category = studio_template_category:ecommerce
AND categorization.subcategory = studio_template_subcategory:hitech
FETCH categorization.category, categorization.subcategory;

-- Templates mis en avant avec catégories
SELECT * FROM studio_template 
WHERE status.is_featured = true
FETCH categorization.category, categorization.subcategory
ORDER BY metadata.usage_count DESC;

-- Lister toutes les catégories disponibles
SELECT * FROM studio_template_category 
WHERE status.is_active = true
ORDER BY config.order;

-- Lister les sous-catégories d'une catégorie
SELECT * FROM studio_template_subcategory
WHERE relation.category = studio_template_category:ecommerce
AND status.is_active = true
ORDER BY relation.order;
```

---

## 📊 Structure des Catégories

### Tables de Catégorisation

**Deux tables séparées pour gérer l'i18n :**

1. **`studio_template_category`** - Catégories principales
   - Exemples : `ecommerce`, `saas`, `portfolio`, `blog`, `landing`, `corporate`
   - Gère i18n via `presentation.name_i18n` et `presentation.description_i18n`
   - Peut avoir une icône (`presentation.icon`)

2. **`studio_template_subcategory`** - Sous-catégories
   - Exemples : `hitech`, `mode`, `designer`, `crm`, `analytics`
   - Gère i18n via `presentation.name_i18n` et `presentation.description_i18n`
   - Lien vers catégorie parente via `relation.category`
   - Peut avoir une icône (`presentation.icon`)

### Catégories Principales (Suggérées)

| Catégorie | Code | Sous-catégories possibles |
|-----------|------|---------------------------|
| E-commerce | `ecommerce` | `hitech`, `mode`, `alimentaire`, `luxe` |
| SaaS | `saas` | `crm`, `analytics`, `project_management`, `hr` |
| Portfolio | `portfolio` | `designer`, `developer`, `photographer`, `artist` |
| Blog | `blog` | `news`, `tutorial`, `lifestyle`, `tech` |
| Landing Page | `landing` | `product_launch`, `event`, `webinar`, `app` |
| Corporate | `corporate` | `business`, `agency`, `nonprofit`, `education` |

**Avantages :**
- ✅ i18n complet pour catégories et sous-catégories
- ✅ Extensible (ajout facile de nouvelles catégories)
- ✅ Relations propres (subcategory → category)
- ✅ Icônes et couleurs par catégorie
- ✅ Ordre d'affichage configurable

---

## 🚀 Évolution Future

### Phase 1 (Actuel)
- ✅ Définir le schéma `studio_template`
- ✅ Relier aux `studio_page` existantes
- ✅ Système de catégorisation

### Phase 2
- ⏳ Interface de sélection de templates
- ⏳ Application de template (création de pages)
- ⏳ Clone/copie de templates

### Phase 3
- ⏳ Templates générés par IA
- ⏳ Marketplace de templates
- ⏳ Versioning avancé des templates
- ⏳ Templates personnalisables par tenant

---

## ✅ Validation

**À valider :**
- [x] Structure du schéma `studio_template` ✅
- [x] Tables de catégorisation avec i18n (`studio_template_category`, `studio_template_subcategory`) ✅
- [ ] Relation avec `studio_page` (références vs structures)
- [ ] Cas d'usage spécifiques à votre besoin
- [ ] Métadonnées nécessaires
- [ ] Seeds de test (catégories + sous-catégories + templates)

**Fichiers créés :**
1. ✅ `studio/database/studio/studio_template.surql` - Table principale
2. ✅ `studio/database/studio/studio_template_category.surql` - Catégories avec i18n
3. ✅ `studio/database/studio/studio_template_subcategory.surql` - Sous-catégories avec i18n
4. ✅ Documentation complète (`TEMPLATES_PAGES.md`)

**Prochaines étapes après validation :**
1. Créer les seeds de test :
   - Seeds pour `studio_template_category` (ecommerce, saas, portfolio, etc.)
   - Seeds pour `studio_template_subcategory` (hitech, crm, designer, etc.)
   - Seeds pour `studio_template` (ecommerce_hitech, saas_crm, etc.)
2. Implémenter les hooks React (`useStudioTemplate`, `useStudioTemplateCategory`)
3. Créer l'interface de sélection de templates

---

**Document créé le :** 2025-01-31  
**Status :** 🟡 En réflexion - À valider

