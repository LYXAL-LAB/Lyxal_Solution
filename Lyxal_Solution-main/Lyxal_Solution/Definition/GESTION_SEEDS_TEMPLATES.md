# 🌱 Gestion des Seeds et Templates

> **Documentation fondamentale** : Comprendre quels seeds restent dans Lyxal Solution et lesquels sont copiés aux applications clientes

---

## 📋 Table des matières

1. [Principe fondamental](#principe-fondamental)
2. [Seeds Lyxal Solution uniquement](#seeds-lyxal-solution-uniquement)
3. [Seeds copiés aux clients](#seeds-copiés-aux-clients)
4. [Mécanisme de filtrage](#mécanisme-de-filtrage)
5. [Structure des dossiers](#structure-des-dossiers)
6. [Exemples concrets](#exemples-concrets)
7. [Tableau récapitulatif](#tableau-récapitulatif)
8. [Implémentation technique](#implémentation-technique)

---

## 🎯 Principe fondamental

```
┌──────────────────────────────────────────────────────────────┐
│           LYXAL SOLUTION (namespace: lyxal)                   │
│          = TOUT le catalogue de ressources                    │
├──────────────────────────────────────────────────────────────┤
│                                                               │
│  Seeds BUILDER (administration)                              │
│  ├── builder_type           ← RESTE dans lyxal ✅            │
│  ├── builder_status         ← RESTE dans lyxal ✅            │
│  ├── builder_template       ← RESTE dans lyxal ✅            │
│  └── builder_action         ← RESTE dans lyxal ✅            │
│                                                               │
│  Seeds STUDIO (métadonnées UI)                               │
│  ├── icon_library           ← RESTE dans lyxal ✅            │
│  ├── icon_category          ← RESTE dans lyxal ✅            │
│  ├── icon                   ← RESTE dans lyxal ✅            │
│  └── studio_widget          ← RESTE dans lyxal ✅            │
│                                                               │
│  Seeds INFRASTRUCTURE (APIs externes)                        │
│  ├── bunny_dns_zone         ← RESTE dans lyxal ✅            │
│  ├── bunny_pull_zone        ← RESTE dans lyxal ✅            │
│  └── bunny_storage_zone     ← RESTE dans lyxal ✅            │
│                                                               │
│  Seeds SYSTÈME (base commune)                                │
│  ├── language               → Copié aux clients ✅           │
│  ├── i18n_key (toutes)      → Filtrées et copiées ✅        │
│  └── translation (toutes)   → Filtrées et copiées ✅        │
│                                                               │
│  Seeds TEMPLATES (métier)                                    │
│  ├── crm_basic/             → Copiés si template utilisé ✅  │
│  ├── ecommerce/             → Copiés si template utilisé ✅  │
│  └── accounting/            → Copiés si template utilisé ✅  │
│                                                               │
└──────────────────────────────────────────────────────────────┘
                            │
                            │ Filtrage et copie sélective
                            ↓
┌──────────────────────────────────────────────────────────────┐
│      APPLICATIONS CLIENTES (namespace: batipro, comptapro)    │
│     = UNIQUEMENT ce qui est nécessaire pour l'application    │
├──────────────────────────────────────────────────────────────┤
│                                                               │
│  ❌ PAS de seeds Builder                                     │
│  ❌ PAS de seeds Studio (icon, icon_library, etc.)          │
│  ❌ PAS de seeds Infrastructure                              │
│                                                               │
│  ✅ Seeds système (langues)                                  │
│  ✅ Seeds i18n (filtrés par template)                        │
│  ✅ Seeds métier (du template utilisé uniquement)            │
│                                                               │
└──────────────────────────────────────────────────────────────┘
```

---

## 🔒 Seeds Lyxal Solution uniquement

Ces seeds restent **EXCLUSIVEMENT** dans le namespace `lyxal` et ne sont **JAMAIS** copiés aux applications clientes.

### 1. Seeds Builder (Système de génération)

#### Tables concernées
```
builder_type
builder_status
builder_template
builder_action
builder_dependency
builder_sequence
builder_event
```

#### Fichiers seeds
```
Lyxal_Surreal/builder/reference/
├── builder_type_seeds.surql
├── builder_status_seeds.surql
├── builder_template_seeds.surql
├── builder_action_seeds.surql
├── builder_dependency_seeds.surql
└── builder_sequence_seeds.surql
```

#### Exemple : builder_type_seeds.surql
```sql
-- =============================================================================
-- SEEDS: builder_type
-- =============================================================================
-- Types de ressources du Builder (table, function, module, template, etc.)
-- Ordre de déploiement : Après i18n_key seeds
-- Déployé dans : namespace LYXAL uniquement (jamais copié aux clients)
-- =============================================================================

USE NS lyxal DB lyxal;

CREATE builder_type:table CONTENT {
  code: {
    prefix: 'table_',
    search: 'table'
  },
  i18n_key: {
    name: i18n_key:builder_type_table_name,
    description: i18n_key:builder_type_table_description
  },
  metadata: {
    interface: {
      icon: "⚡",
      color: "#8B5CF6"
    },
    structure: {
      fields: [...],
      indexes: [...],
      relations: [...]
    }
  },
  state: {
    isactive: true,
    status: builder_status:active
  }
};

-- ... autres types (function, module, template, etc.)
```

#### Pourquoi ces seeds restent dans Lyxal ?

**Raison 1 : Sécurité**
- ❌ Les clients ne doivent PAS accéder aux templates des autres clients
- ❌ Les clients ne doivent PAS voir la liste de tous les modules disponibles
- ❌ Les clients ne doivent PAS connaître la structure du Builder

**Raison 2 : Pertinence**
- ❌ BatiPro n'a PAS besoin de savoir ce qu'est un `builder_type`
- ❌ BatiPro n'a PAS besoin de la liste des templates (CRM, E-Commerce, etc.)
- ❌ BatiPro utilise le RÉSULTAT du Builder, pas le Builder lui-même

**Raison 3 : Performance**
- ✅ Évite de copier des données inutiles (~10 MB par client)
- ✅ Réduit la taille de la base client

---

### 2. Seeds Studio (Métadonnées UI)

#### Tables concernées
```
icon
icon_library
icon_category
studio_widget
studio_component
studio_color_palette
studio_theme
```

#### Fichiers seeds
```
Lyxal_Surreal/studio/reference/
├── icon/
│   ├── icon_library_seeds.surql
│   ├── icon_category_seeds.surql
│   └── icon_seeds.surql
├── studio_widget_seeds.surql
├── studio_component_seeds.surql
└── studio_theme_seeds.surql
```

#### Exemple : icon_library_seeds.surql
```sql
-- =============================================================================
-- SEEDS: icon_library
-- =============================================================================
-- Bibliothèques d'icônes SVG (Lucide, Heroicons, etc.)
-- Déployé dans : namespace LYXAL uniquement (jamais copié aux clients)
-- =============================================================================

USE NS lyxal DB lyxal;

CREATE icon_library:lucide CONTENT {
  code: 'lucide',
  name: 'Lucide Icons',
  base_url: 'https://icons.lyxal.b-cdn.net/lucide/',
  repository_url: 'https://github.com/lucide-icons/lucide',
  documentation_url: 'https://lucide.dev',
  total_icons: 1200,
  style: 'Minimaliste, outline',
  license: 'ISC License',
  version: '0.400.0',
  metadata: {
    default_viewBox: '0 0 24 24',
    default_stroke_width: 2,
    default_stroke: 'currentColor',
    default_fill: 'none'
  },
  config: {
    priority: 0,
    is_recommended: true,
    auto_import: true
  },
  state: {
    isactive: true,
    is_custom: false,
    is_maintained: true
  }
};

CREATE icon_library:heroicons CONTENT {
  code: 'heroicons',
  name: 'Heroicons',
  base_url: 'https://icons.lyxal.b-cdn.net/heroicons/',
  repository_url: 'https://github.com/tailwindlabs/heroicons',
  documentation_url: 'https://heroicons.com',
  total_icons: 292,
  style: 'Moderne, TailwindCSS',
  license: 'MIT License',
  version: '2.0.18',
  // ...
};

-- ... autres bibliothèques
```

#### Exemple : icon_seeds.surql
```sql
-- =============================================================================
-- SEEDS: icon
-- =============================================================================
-- Catalogue des icônes SVG (5000+ icônes)
-- Déployé dans : namespace LYXAL uniquement (jamais copié aux clients)
-- =============================================================================

USE NS lyxal DB lyxal;

-- Lucide Icons
CREATE icon:lucide_zap CONTENT {
  code: 'lucide_zap',
  name: 'Zap',
  library: icon_library:lucide,
  url: 'https://icons.lyxal.b-cdn.net/lucide/zap.svg',
  tags: ['action', 'energy', 'fast', 'lightning'],
  category: icon_category:action,
  metadata: {
    viewBox: '0 0 24 24',
    stroke: 'currentColor',
    fill: 'none',
    stroke_width: 2
  },
  state: {
    isactive: true,
    is_custom: false,
    is_deprecated: false
  }
};

CREATE icon:lucide_users CONTENT {
  code: 'lucide_users',
  name: 'Users',
  library: icon_library:lucide,
  url: 'https://icons.lyxal.b-cdn.net/lucide/users.svg',
  tags: ['user', 'people', 'group', 'team'],
  category: icon_category:user,
  // ...
};

-- ... 5000+ autres icônes
```

#### Pourquoi ces seeds restent dans Lyxal ?

**Raison 1 : Volume**
- ❌ 5000+ icônes représentent ~20 MB de données
- ❌ BatiPro n'utilise que ~50 icônes (0.5 MB)
- ✅ Copier uniquement les URLs nécessaires

**Raison 2 : Les clients reçoivent les URLs directement**

```sql
-- ❌ BatiPro ne reçoit PAS la table icon
-- ✅ BatiPro reçoit les URLs directement dans les menus

USE NS batipro DB batipro;

CREATE studio_menu:crm CONTENT {
  code: 'crm',
  label: { fr: "CRM", en: "CRM" },
  icon_url: 'https://icons.lyxal.b-cdn.net/lucide/users.svg',  ← URL directe
  items: [
    {
      code: 'contacts',
      label: { fr: "Contacts", en: "Contacts" },
      icon_url: 'https://icons.lyxal.b-cdn.net/lucide/user.svg',  ← URL directe
      route: '/crm/contacts'
    }
  ]
};
```

**Raison 3 : Maintenance**
- ✅ Ajouter une nouvelle bibliothèque d'icônes dans Lyxal → Tous les clients en bénéficient
- ✅ Pas besoin de mettre à jour chaque client individuellement

---

### 3. Seeds Infrastructure (APIs externes)

#### Tables concernées
```
bunny_dns_zone
bunny_pull_zone
bunny_storage_zone
bunny_shield_zone
bunny_waf_rule
tiktok_business_account
email_provider_config
```

#### Fichiers seeds
```
Lyxal_Surreal/infrastructure/reference/
├── bunny/
│   ├── bunny_dns_zone_seeds.surql
│   ├── bunny_pull_zone_seeds.surql
│   └── bunny_storage_zone_seeds.surql
├── tiktok/
│   └── tiktok_business_account_seeds.surql
└── email/
    └── email_provider_seeds.surql
```

#### Exemple : bunny_dns_zone_seeds.surql
```sql
-- =============================================================================
-- SEEDS: bunny_dns_zone
-- =============================================================================
-- Zones DNS Bunny.net (infrastructure Lyxal)
-- Déployé dans : namespace LYXAL uniquement (jamais copié aux clients)
-- =============================================================================

USE NS lyxal DB lyxal;

-- Zone DNS Lyxal principale
CREATE bunny_dns_zone:lyxal_com CONTENT {
  id: 12345,
  domain: 'lyxal.com',
  name_servers: [
    'ns1.bunny.net',
    'ns2.bunny.net'
  ],
  dnssec_config: {
    enabled: true,
    ds_record: 'xxx',
    algorithm: 13
  },
  records: [
    // ... enregistrements DNS
  ]
};

-- Zone DNS pour les clients (wildcard)
CREATE bunny_dns_zone:clients_lyxal_io CONTENT {
  id: 12346,
  domain: 'clients.lyxal.io',
  name_servers: [
    'ns1.bunny.net',
    'ns2.bunny.net'
  ],
  // ...
};
```

#### Pourquoi ces seeds restent dans Lyxal ?

**Raison 1 : Sécurité**
- ❌ Les clients ne doivent PAS accéder à l'infrastructure Bunny.net
- ❌ Les clients ne doivent PAS voir les clés API
- ❌ Les clients ne doivent PAS modifier les configurations DNS/CDN

**Raison 2 : Gestion centralisée**
- ✅ Lyxal gère l'infrastructure pour tous les clients
- ✅ Les clients consomment les services (domaine, CDN) sans gérer l'infra
- ✅ Un seul compte Bunny.net pour tous les clients

**Raison 3 : Abstraction**
- ✅ BatiPro ne sait même pas que Bunny.net est utilisé
- ✅ BatiPro voit juste son domaine `app.batipro.com` fonctionner
- ✅ Lyxal peut changer de provider (Bunny → Cloudflare) sans affecter les clients

---

## ✅ Seeds copiés aux clients

Ces seeds sont **copiés** (ou **générés**) dans les applications clientes, car elles en ont besoin pour fonctionner.

### 1. Seeds Système (Base commune)

#### Tables concernées
```
language
currency
country
timezone
```

#### Fichiers seeds
```
Lyxal_Surreal/base/reference/
├── system/
│   ├── language_seeds.surql
│   ├── currency_seeds.surql
│   ├── country_seeds.surql
│   └── timezone_seeds.surql
```

#### Exemple : language_seeds.surql
```sql
-- =============================================================================
-- SEEDS: language
-- =============================================================================
-- Langues disponibles dans le système
-- Déployé dans : namespace LYXAL + tous les clients
-- =============================================================================

USE NS lyxal DB lyxal;

CREATE language:fr CONTENT {
  code: 'fr',
  name: 'Français',
  native_name: 'Français',
  iso_639_1: 'fr',
  iso_639_2: 'fra',
  direction: 'ltr',
  is_default: true,
  is_active: true
};

CREATE language:en CONTENT {
  code: 'en',
  name: 'English',
  native_name: 'English',
  iso_639_1: 'en',
  iso_639_2: 'eng',
  direction: 'ltr',
  is_default: false,
  is_active: true
};

CREATE language:es CONTENT {
  code: 'es',
  name: 'Espagnol',
  native_name: 'Español',
  iso_639_1: 'es',
  iso_639_2: 'spa',
  direction: 'ltr',
  is_default: false,
  is_active: true
};

-- ... autres langues (ar, de, it, pt, etc.)
```

#### Copie dans les applications clientes
```sql
-- Ces seeds sont copiés IDENTIQUEMENT dans chaque client
USE NS batipro DB batipro;

CREATE language:fr CONTENT { /* ... même contenu ... */ };
CREATE language:en CONTENT { /* ... même contenu ... */ };
CREATE language:es CONTENT { /* ... même contenu ... */ };

-- Même chose pour ComptaPro, ShopMode, etc.
USE NS comptapro DB comptapro;

CREATE language:fr CONTENT { /* ... même contenu ... */ };
CREATE language:en CONTENT { /* ... même contenu ... */ };
CREATE language:es CONTENT { /* ... même contenu ... */ };
```

#### Pourquoi ces seeds sont copiés ?

**Raison 1 : Nécessité**
- ✅ Chaque client a besoin du système de langues pour l'i18n
- ✅ Les traductions dépendent de la table `language`

**Raison 2 : Autonomie**
- ✅ Le client peut fonctionner même si Lyxal Solution est hors ligne
- ✅ Pas de dépendance au namespace `lyxal`

**Raison 3 : Taille raisonnable**
- ✅ ~10 langues = ~2 KB de données
- ✅ Négligeable comparé à 5000 icônes

---

### 2. Seeds i18n (Filtrés par template)

#### Tables concernées
```
i18n_key
translation
```

#### Fichiers seeds (organisés par module/template)
```
Lyxal_Surreal/base/reference/i18n/
├── modules/
│   ├── crm/
│   │   ├── crm_i18n_key_seeds.surql
│   │   └── crm_translation_seeds.surql
│   ├── ecommerce/
│   │   ├── ecommerce_i18n_key_seeds.surql
│   │   └── ecommerce_translation_seeds.surql
│   ├── accounting/
│   │   ├── accounting_i18n_key_seeds.surql
│   │   └── accounting_translation_seeds.surql
│   └── production/
│       ├── production_i18n_key_seeds.surql
│       └── production_translation_seeds.surql
└── common/
    ├── common_i18n_key_seeds.surql
    └── common_translation_seeds.surql
```

#### Exemple : crm_i18n_key_seeds.surql
```sql
-- =============================================================================
-- SEEDS: i18n_key (Module CRM)
-- =============================================================================
-- Clés i18n pour le module CRM
-- Déployé dans : namespace LYXAL + clients utilisant le template CRM
-- =============================================================================

USE NS lyxal DB lyxal;

-- ============================================================================
-- CONTACT
-- ============================================================================
CREATE i18n_key:contact_title_singular CONTENT {
  code: 'contact_title_singular',
  description: 'Titre singulier : Contact',
  module: 'crm'
};

CREATE i18n_key:contact_title_plural CONTENT {
  code: 'contact_title_plural',
  description: 'Titre pluriel : Contacts',
  module: 'crm'
};

CREATE i18n_key:contact_field_first_name CONTENT {
  code: 'contact_field_first_name',
  description: 'Champ : Prénom',
  module: 'crm'
};

CREATE i18n_key:contact_field_last_name CONTENT {
  code: 'contact_field_last_name',
  description: 'Champ : Nom',
  module: 'crm'
};

-- ============================================================================
-- LEAD
-- ============================================================================
CREATE i18n_key:lead_title_singular CONTENT {
  code: 'lead_title_singular',
  description: 'Titre singulier : Lead',
  module: 'crm'
};

CREATE i18n_key:lead_status_new CONTENT {
  code: 'lead_status_new',
  description: 'Statut lead : Nouveau',
  module: 'crm'
};

-- ... 300 autres clés CRM
```

#### Exemple : crm_translation_seeds.surql
```sql
-- =============================================================================
-- SEEDS: translation (Module CRM)
-- =============================================================================
-- Traductions pour le module CRM
-- Déployé dans : namespace LYXAL + clients utilisant le template CRM
-- =============================================================================

USE NS lyxal DB lyxal;

-- ============================================================================
-- CONTACT (Français)
-- ============================================================================
CREATE translation CONTENT {
  i18n_key: i18n_key:contact_title_singular,
  language: language:fr,
  value: 'Contact'
};

CREATE translation CONTENT {
  i18n_key: i18n_key:contact_title_plural,
  language: language:fr,
  value: 'Contacts'
};

-- ============================================================================
-- CONTACT (Anglais)
-- ============================================================================
CREATE translation CONTENT {
  i18n_key: i18n_key:contact_title_singular,
  language: language:en,
  value: 'Contact'
};

CREATE translation CONTENT {
  i18n_key: i18n_key:contact_title_plural,
  language: language:en,
  value: 'Contacts'
};

-- ... 900 autres traductions (300 clés × 3 langues)
```

#### Filtrage et copie dans BatiPro (utilise template CRM)

```typescript
async function copyI18nForTenant(tenantId: string, template: Template) {
  
  USE NS ${tenantId} DB ${tenantId};
  
  // 1. Récupérer les modules du template
  const modules = template.modules; // ['crm', 'devis', 'chantiers']
  
  // 2. Récupérer UNIQUEMENT les i18n_key de ces modules
  const i18nKeys = await db.query(`
    USE NS lyxal DB lyxal;
    SELECT * FROM i18n_key WHERE module IN $modules;
  `, { modules });
  
  // 3. Copier les clés dans le tenant
  for (const key of i18nKeys) {
    await db.query(`
      USE NS ${tenantId} DB ${tenantId};
      CREATE i18n_key:${key.code} CONTENT ${JSON.stringify(key)};
    `);
  }
  
  // 4. Récupérer les traductions associées
  const translations = await db.query(`
    USE NS lyxal DB lyxal;
    SELECT * FROM translation WHERE i18n_key IN $keyIds;
  `, { keyIds: i18nKeys.map(k => k.id) });
  
  // 5. Copier les traductions dans le tenant
  for (const translation of translations) {
    await db.query(`
      USE NS ${tenantId} DB ${tenantId};
      CREATE translation CONTENT ${JSON.stringify(translation)};
    `);
  }
}
```

#### Résultat dans BatiPro
```sql
USE NS batipro DB batipro;

-- BatiPro reçoit UNIQUEMENT les clés des modules CRM, Devis, Chantiers
SELECT * FROM i18n_key;
// 300 clés (modules: crm, devis, chantiers)

-- ❌ PAS de clés E-Commerce
// ❌ PAS de clés Comptabilité
// ❌ PAS de clés Production

SELECT * FROM translation;
// 900 traductions (300 clés × 3 langues)
```

#### Résultat dans ComptaPro (utilise template Accounting)
```sql
USE NS comptapro DB comptapro;

-- ComptaPro reçoit UNIQUEMENT les clés du module Comptabilité
SELECT * FROM i18n_key;
// 500 clés (module: accounting)

-- ❌ PAS de clés CRM
// ❌ PAS de clés E-Commerce
// ❌ PAS de clés Production

SELECT * FROM translation;
// 1500 traductions (500 clés × 3 langues)
```

---

### 3. Seeds Métier (Générés depuis template)

#### Organisation des seeds par template

```
Lyxal_Surreal/templates/
├── crm_basic/
│   ├── reference/
│   │   ├── contact_status_seeds.surql
│   │   ├── lead_status_seeds.surql
│   │   ├── opportunity_status_seeds.surql
│   │   └── activity_type_seeds.surql
│   └── template_definition.json
│
├── ecommerce/
│   ├── reference/
│   │   ├── product_status_seeds.surql
│   │   ├── order_status_seeds.surql
│   │   ├── payment_method_seeds.surql
│   │   └── shipping_method_seeds.surql
│   └── template_definition.json
│
├── accounting/
│   ├── reference/
│   │   ├── account_type_seeds.surql
│   │   ├── invoice_status_seeds.surql
│   │   ├── payment_term_seeds.surql
│   │   └── tax_rate_seeds.surql
│   └── template_definition.json
│
└── production/
    ├── reference/
    │   ├── workorder_status_seeds.surql
    │   ├── machine_type_seeds.surql
    │   └── production_phase_seeds.surql
    └── template_definition.json
```

#### Exemple : Template CRM Basic

**Définition du template**
```json
// templates/crm_basic/template_definition.json
{
  "code": "crm_basic",
  "name": {
    "fr": "CRM Basic",
    "en": "Basic CRM"
  },
  "version": "1.0.0",
  "modules": ["crm"],
  "tables": [
    {
      "name": "contact",
      "fields": [...]
    },
    {
      "name": "lead",
      "fields": [...]
    },
    {
      "name": "opportunity",
      "fields": [...]
    }
  ],
  "seeds": [
    {
      "file": "reference/contact_status_seeds.surql",
      "table": "contact_status"
    },
    {
      "file": "reference/lead_status_seeds.surql",
      "table": "lead_status"
    },
    {
      "file": "reference/opportunity_status_seeds.surql",
      "table": "opportunity_status"
    },
    {
      "file": "reference/activity_type_seeds.surql",
      "table": "activity_type"
    }
  ]
}
```

**Seeds : contact_status_seeds.surql**
```sql
-- =============================================================================
-- SEEDS: contact_status (Template CRM Basic)
-- =============================================================================
-- Statuts de contact
-- Déployé dans : clients utilisant le template CRM Basic
-- =============================================================================

CREATE contact_status:new CONTENT {
  code: 'new',
  i18n_key: {
    name: i18n_key:contact_status_new_name,
    description: i18n_key:contact_status_new_description
  },
  color: '#3B82F6',
  color_daisy: 'info',
  icon_url: 'https://icons.lyxal.b-cdn.net/lucide/user-plus.svg',
  order: 1,
  is_default: true,
  is_active: true
};

CREATE contact_status:qualified CONTENT {
  code: 'qualified',
  i18n_key: {
    name: i18n_key:contact_status_qualified_name,
    description: i18n_key:contact_status_qualified_description
  },
  color: '#10B981',
  color_daisy: 'success',
  icon_url: 'https://icons.lyxal.b-cdn.net/lucide/check-circle.svg',
  order: 2,
  is_default: false,
  is_active: true
};

CREATE contact_status:inactive CONTENT {
  code: 'inactive',
  i18n_key: {
    name: i18n_key:contact_status_inactive_name,
    description: i18n_key:contact_status_inactive_description
  },
  color: '#6B7280',
  color_daisy: 'neutral',
  icon_url: 'https://icons.lyxal.b-cdn.net/lucide/user-x.svg',
  order: 3,
  is_default: false,
  is_active: true
};
```

**Seeds : lead_status_seeds.surql**
```sql
-- =============================================================================
-- SEEDS: lead_status (Template CRM Basic)
-- =============================================================================
-- Statuts de lead
-- Déployé dans : clients utilisant le template CRM Basic
-- =============================================================================

CREATE lead_status:new CONTENT {
  code: 'new',
  i18n_key: {
    name: i18n_key:lead_status_new_name,
    description: i18n_key:lead_status_new_description
  },
  color: '#3B82F6',
  color_daisy: 'info',
  icon_url: 'https://icons.lyxal.b-cdn.net/lucide/inbox.svg',
  order: 1,
  is_default: true,
  is_active: true
};

CREATE lead_status:contacted CONTENT {
  code: 'contacted',
  i18n_key: {
    name: i18n_key:lead_status_contacted_name,
    description: i18n_key:lead_status_contacted_description
  },
  color: '#F59E0B',
  color_daisy: 'warning',
  icon_url: 'https://icons.lyxal.b-cdn.net/lucide/phone.svg',
  order: 2,
  is_default: false,
  is_active: true
};

CREATE lead_status:qualified CONTENT {
  code: 'qualified',
  i18n_key: {
    name: i18n_key:lead_status_qualified_name,
    description: i18n_key:lead_status_qualified_description
  },
  color: '#8B5CF6',
  color_daisy: 'secondary',
  icon_url: 'https://icons.lyxal.b-cdn.net/lucide/star.svg',
  order: 3,
  is_default: false,
  is_active: true
};

CREATE lead_status:converted CONTENT {
  code: 'converted',
  i18n_key: {
    name: i18n_key:lead_status_converted_name,
    description: i18n_key:lead_status_converted_description
  },
  color: '#10B981',
  color_daisy: 'success',
  icon_url: 'https://icons.lyxal.b-cdn.net/lucide/check-circle-2.svg',
  order: 4,
  is_default: false,
  is_active: true
};

CREATE lead_status:lost CONTENT {
  code: 'lost',
  i18n_key: {
    name: i18n_key:lead_status_lost_name,
    description: i18n_key:lead_status_lost_description
  },
  color: '#EF4444',
  color_daisy: 'error',
  icon_url: 'https://icons.lyxal.b-cdn.net/lucide/x-circle.svg',
  order: 5,
  is_default: false,
  is_active: true
};
```

#### Génération dans BatiPro
```typescript
async function generateSeedsForTenant(tenantId: string, template: Template) {
  
  USE NS ${tenantId} DB ${tenantId};
  
  // 1. Lire les fichiers seeds du template
  const seedFiles = template.seeds; // Liste des fichiers seeds
  
  // 2. Pour chaque fichier seed
  for (const seedFile of seedFiles) {
    
    // 3. Lire le contenu du fichier
    const content = fs.readFileSync(`templates/${template.code}/${seedFile.file}`, 'utf8');
    
    // 4. Remplacer le namespace
    const adaptedContent = content.replace(/USE NS lyxal DB lyxal/g, `USE NS ${tenantId} DB ${tenantId}`);
    
    // 5. Exécuter le seed dans le namespace client
    await db.query(adaptedContent);
    
    console.log(`✅ Seeds ${seedFile.table} créés dans ${tenantId}`);
  }
}
```

#### Résultat dans BatiPro
```sql
USE NS batipro DB batipro;

-- Seeds métier générés depuis le template CRM Basic
SELECT * FROM contact_status;
// new, qualified, inactive

SELECT * FROM lead_status;
// new, contacted, qualified, converted, lost

SELECT * FROM opportunity_status;
// prospecting, qualification, proposal, negotiation, won, lost

SELECT * FROM activity_type;
// call, email, meeting, task, note
```

---

## 🔄 Mécanisme de filtrage

### Workflow complet de génération

```
┌────────────────────────────────────────────────────────────┐
│  ÉTAPE 1 : Création du tenant (dans Lyxal Studio)          │
├────────────────────────────────────────────────────────────┤
│                                                             │
│  Admin Lyxal crée un nouveau tenant :                      │
│  - tenant_id: "batipro"                                    │
│  - template: "crm_basic"                                   │
│  - domain: "app.batipro.com"                               │
│  - languages: ["fr", "en", "es"]                           │
│                                                             │
└──────────────────────┬─────────────────────────────────────┘
                       │
                       ↓
┌────────────────────────────────────────────────────────────┐
│  ÉTAPE 2 : Création du namespace SurrealDB                 │
├────────────────────────────────────────────────────────────┤
│                                                             │
│  DEFINE NAMESPACE batipro;                                 │
│  USE NS batipro DB batipro;                                │
│                                                             │
└──────────────────────┬─────────────────────────────────────┘
                       │
                       ↓
┌────────────────────────────────────────────────────────────┐
│  ÉTAPE 3 : Copie des seeds système (langues)               │
├────────────────────────────────────────────────────────────┤
│                                                             │
│  ✅ Copie language (fr, en, es)                            │
│  ✅ Copie currency (EUR, USD, GBP, etc.)                   │
│  ✅ Copie country (tous les pays)                          │
│  ✅ Copie timezone (tous les fuseaux)                      │
│                                                             │
└──────────────────────┬─────────────────────────────────────┘
                       │
                       ↓
┌────────────────────────────────────────────────────────────┐
│  ÉTAPE 4 : Génération des tables depuis le template        │
├────────────────────────────────────────────────────────────┤
│                                                             │
│  Template CRM Basic définit :                              │
│  - Table contact (structure)                               │
│  - Table lead (structure)                                  │
│  - Table opportunity (structure)                           │
│  - Table activity (structure)                              │
│                                                             │
│  → Génère les DEFINE TABLE dans batipro                    │
│                                                             │
└──────────────────────┬─────────────────────────────────────┘
                       │
                       ↓
┌────────────────────────────────────────────────────────────┐
│  ÉTAPE 5 : Filtrage et copie des i18n_key                  │
├────────────────────────────────────────────────────────────┤
│                                                             │
│  1. Récupérer les modules du template : ["crm"]           │
│  2. Filtrer les i18n_key : WHERE module = 'crm'           │
│  3. Copier uniquement ces clés dans batipro               │
│     → 300 clés (au lieu de 5000)                           │
│                                                             │
└──────────────────────┬─────────────────────────────────────┘
                       │
                       ↓
┌────────────────────────────────────────────────────────────┐
│  ÉTAPE 6 : Filtrage et copie des translations              │
├────────────────────────────────────────────────────────────┤
│                                                             │
│  1. Récupérer les i18n_key copiées (300 clés)             │
│  2. Récupérer les traductions associées                   │
│     - Langues : fr, en, es (configurées pour batipro)     │
│     - Résultat : 300 clés × 3 langues = 900 traductions   │
│  3. Copier ces traductions dans batipro                    │
│                                                             │
└──────────────────────┬─────────────────────────────────────┘
                       │
                       ↓
┌────────────────────────────────────────────────────────────┐
│  ÉTAPE 7 : Génération des seeds métier depuis le template  │
├────────────────────────────────────────────────────────────┤
│                                                             │
│  Template CRM Basic contient :                             │
│  - Seeds contact_status (new, qualified, inactive)        │
│  - Seeds lead_status (new, contacted, converted, lost)    │
│  - Seeds opportunity_status (prospecting, won, lost)      │
│  - Seeds activity_type (call, email, meeting, task)       │
│                                                             │
│  → Génère ces seeds dans batipro                           │
│                                                             │
└──────────────────────┬─────────────────────────────────────┘
                       │
                       ↓
┌────────────────────────────────────────────────────────────┐
│  ÉTAPE 8 : Génération des menus/pages avec URLs d'icônes   │
├────────────────────────────────────────────────────────────┤
│                                                             │
│  Template CRM Basic définit :                              │
│  - Menu CRM                                                │
│    - Icône : lucide_users                                  │
│    - Items : Contacts, Leads, Opportunités                │
│                                                             │
│  → Récupère les URLs d'icônes depuis Lyxal                │
│  → Génère les menus avec URLs directes                     │
│                                                             │
└──────────────────────┬─────────────────────────────────────┘
                       │
                       ↓
┌────────────────────────────────────────────────────────────┐
│  ÉTAPE 9 : Génération des fonctions métier                 │
├────────────────────────────────────────────────────────────┤
│                                                             │
│  Template CRM Basic définit :                              │
│  - fn::create_contact                                      │
│  - fn::update_contact                                      │
│  - fn::create_lead                                         │
│  - fn::convert_lead_to_contact                             │
│                                                             │
│  → Génère ces fonctions dans batipro                       │
│                                                             │
└──────────────────────┬─────────────────────────────────────┘
                       │
                       ↓
┌────────────────────────────────────────────────────────────┐
│  ÉTAPE 10 : Configuration du tenant                        │
├────────────────────────────────────────────────────────────┤
│                                                             │
│  Enregistre la configuration dans Lyxal Solution :         │
│  - studio_config:batipro                                   │
│    - template: crm_basic                                   │
│    - domain: app.batipro.com                               │
│    - theme: { primary: "#FF6B35", ... }                    │
│    - languages: ["fr", "en", "es"]                         │
│                                                             │
└──────────────────────┬─────────────────────────────────────┘
                       │
                       ↓
┌────────────────────────────────────────────────────────────┐
│  RÉSULTAT : Application BatiPro opérationnelle             │
├────────────────────────────────────────────────────────────┤
│                                                             │
│  ✅ Database batipro (namespace séparé)                    │
│  ✅ Tables métier (contact, lead, opportunity)             │
│  ✅ Seeds métier (statuts, types)                          │
│  ✅ Traductions (300 clés, 3 langues)                      │
│  ✅ Menus/Pages (générés avec icônes)                      │
│  ✅ Fonctions métier (générées depuis template)            │
│                                                             │
│  ❌ PAS de builder_type, icon_library, bunny_dns_zone     │
│                                                             │
└────────────────────────────────────────────────────────────┘
```

---

## 📁 Structure des dossiers

### Organisation recommandée

```
Lyxal_Surreal/
│
├── builder/                              ← Module Builder
│   ├── database/
│   │   ├── builder_catalogue.surql
│   │   ├── builder_type.surql
│   │   ├── builder_status.surql
│   │   ├── builder_template.surql
│   │   └── ...
│   └── reference/                        ← Seeds Builder (Lyxal uniquement)
│       ├── builder_type_seeds.surql
│       ├── builder_status_seeds.surql
│       └── builder_template_seeds.surql
│
├── studio/                               ← Module Studio
│   ├── database/
│   │   ├── studio_config.surql
│   │   ├── studio_menu.surql
│   │   ├── studio_page.surql
│   │   └── icon/
│   │       ├── icon.surql
│   │       ├── icon_library.surql
│   │       └── icon_category.surql
│   └── reference/                        ← Seeds Studio (Lyxal uniquement)
│       └── icon/
│           ├── icon_library_seeds.surql
│           ├── icon_category_seeds.surql
│           └── icon_seeds.surql
│
├── infrastructure/                       ← Module Infrastructure
│   ├── database/
│   │   ├── dns/
│   │   │   ├── bunny_dns_zone.surql
│   │   │   └── bunny_dns_record.surql
│   │   └── cdn/
│   │       ├── bunny_pull_zone.surql
│   │       └── bunny_storage_zone.surql
│   └── reference/                        ← Seeds Infra (Lyxal uniquement)
│       └── bunny/
│           ├── bunny_dns_zone_seeds.surql
│           └── bunny_pull_zone_seeds.surql
│
├── base/                                 ← Module Base (système)
│   ├── database/
│   │   ├── i18n/
│   │   │   ├── language.surql
│   │   │   ├── i18n_key.surql
│   │   │   └── translation.surql
│   │   └── system/
│   │       ├── currency.surql
│   │       ├── country.surql
│   │       └── timezone.surql
│   └── reference/                        ← Seeds système (copiés aux clients)
│       ├── system/
│       │   ├── language_seeds.surql
│       │   ├── currency_seeds.surql
│       │   ├── country_seeds.surql
│       │   └── timezone_seeds.surql
│       └── i18n/
│           ├── common/                   ← Traductions communes
│           │   ├── common_i18n_key_seeds.surql
│           │   └── common_translation_seeds.surql
│           └── modules/                  ← Traductions par module
│               ├── crm/
│               │   ├── crm_i18n_key_seeds.surql
│               │   └── crm_translation_seeds.surql
│               ├── ecommerce/
│               │   ├── ecommerce_i18n_key_seeds.surql
│               │   └── ecommerce_translation_seeds.surql
│               └── accounting/
│                   ├── accounting_i18n_key_seeds.surql
│                   └── accounting_translation_seeds.surql
│
└── templates/                            ← Templates d'applications
    ├── crm_basic/
    │   ├── template_definition.json
    │   ├── tables/
    │   │   ├── contact.surql
    │   │   ├── lead.surql
    │   │   └── opportunity.surql
    │   ├── functions/
    │   │   ├── fn_create_contact.surql
    │   │   ├── fn_create_lead.surql
    │   │   └── fn_convert_lead.surql
    │   ├── menus/
    │   │   └── crm_menu.json
    │   └── reference/                    ← Seeds métier (copiés aux clients)
    │       ├── contact_status_seeds.surql
    │       ├── lead_status_seeds.surql
    │       ├── opportunity_status_seeds.surql
    │       └── activity_type_seeds.surql
    │
    ├── ecommerce/
    │   ├── template_definition.json
    │   ├── tables/
    │   ├── functions/
    │   ├── menus/
    │   └── reference/
    │       ├── product_status_seeds.surql
    │       ├── order_status_seeds.surql
    │       ├── payment_method_seeds.surql
    │       └── shipping_method_seeds.surql
    │
    └── accounting/
        ├── template_definition.json
        ├── tables/
        ├── functions/
        ├── menus/
        └── reference/
            ├── account_type_seeds.surql
            ├── invoice_status_seeds.surql
            ├── payment_term_seeds.surql
            └── tax_rate_seeds.surql
```

---

## 📊 Tableau récapitulatif

| Catégorie | Tables/Seeds | Namespace Lyxal | Namespace BatiPro | Namespace ComptaPro | Raison |
|-----------|--------------|-----------------|-------------------|---------------------|--------|
| **Builder** | builder_type | ✅ Oui | ❌ Non | ❌ Non | Administration uniquement |
| **Builder** | builder_status | ✅ Oui | ❌ Non | ❌ Non | Administration uniquement |
| **Builder** | builder_template | ✅ Oui | ❌ Non | ❌ Non | Administration uniquement |
| **Builder** | builder_action | ✅ Oui | ❌ Non | ❌ Non | Administration uniquement |
| **Studio** | icon_library | ✅ Oui | ❌ Non | ❌ Non | URLs copiées directement |
| **Studio** | icon_category | ✅ Oui | ❌ Non | ❌ Non | URLs copiées directement |
| **Studio** | icon | ✅ Oui (5000+) | ❌ Non | ❌ Non | URLs copiées directement |
| **Infra** | bunny_dns_zone | ✅ Oui | ❌ Non | ❌ Non | Gestion centralisée |
| **Infra** | bunny_pull_zone | ✅ Oui | ❌ Non | ❌ Non | Gestion centralisée |
| **Système** | language | ✅ Oui (toutes) | ✅ Oui (toutes) | ✅ Oui (toutes) | Système i18n |
| **Système** | currency | ✅ Oui (toutes) | ✅ Oui (toutes) | ✅ Oui (toutes) | Données de référence |
| **i18n** | i18n_key | ✅ Oui (5000) | ✅ Oui (300) | ✅ Oui (500) | Filtrées par template |
| **i18n** | translation | ✅ Oui (15000) | ✅ Oui (900) | ✅ Oui (1500) | Filtrées par template |
| **CRM** | contact_status | ❌ Non | ✅ Oui | ❌ Non | Template CRM uniquement |
| **CRM** | lead_status | ❌ Non | ✅ Oui | ❌ Non | Template CRM uniquement |
| **Compta** | invoice_status | ❌ Non | ❌ Non | ✅ Oui | Template Compta uniquement |
| **Compta** | account_type | ❌ Non | ❌ Non | ✅ Oui | Template Compta uniquement |

---

## 🛠️ Implémentation technique

### Script de génération complet

```typescript
// generate_tenant_application.ts

import { Surreal } from 'surrealdb.js';
import fs from 'fs';
import path from 'path';

interface TenantConfig {
  tenant_id: string;
  template_code: string;
  domain: string;
  languages: string[];
  theme: {
    primary: string;
    secondary: string;
    logo_url: string;
  };
}

class TenantGenerator {
  
  private db: Surreal;
  
  constructor() {
    this.db = new Surreal();
  }
  
  async connect() {
    await this.db.connect('ws://localhost:8000/rpc');
    await this.db.use({ ns: 'lyxal', db: 'lyxal' });
  }
  
  async generateApplication(config: TenantConfig) {
    
    console.log(`🚀 Génération de l'application ${config.tenant_id}...`);
    
    // 1. Créer le namespace
    await this.createNamespace(config.tenant_id);
    
    // 2. Récupérer le template
    const template = await this.getTemplate(config.template_code);
    
    // 3. Copier les seeds système (langues)
    await this.copySystemSeeds(config.tenant_id, config.languages);
    
    // 4. Générer les tables depuis le template
    await this.generateTables(config.tenant_id, template);
    
    // 5. Filtrer et copier les i18n
    await this.copyFilteredI18n(config.tenant_id, template, config.languages);
    
    // 6. Générer les seeds métier
    await this.generateBusinessSeeds(config.tenant_id, template);
    
    // 7. Générer les menus/pages
    await this.generateMenusPages(config.tenant_id, template);
    
    // 8. Générer les fonctions
    await this.generateFunctions(config.tenant_id, template);
    
    // 9. Enregistrer la configuration
    await this.saveConfig(config);
    
    console.log(`✅ Application ${config.tenant_id} générée avec succès !`);
  }
  
  private async createNamespace(tenantId: string) {
    console.log(`  📦 Création du namespace ${tenantId}...`);
    await this.db.query(`DEFINE NAMESPACE ${tenantId};`);
    await this.db.use({ ns: tenantId, db: tenantId });
  }
  
  private async getTemplate(templateCode: string) {
    console.log(`  📄 Récupération du template ${templateCode}...`);
    await this.db.use({ ns: 'lyxal', db: 'lyxal' });
    const result = await this.db.query(
      `SELECT * FROM builder_template WHERE code = $code`,
      { code: templateCode }
    );
    return result[0][0];
  }
  
  private async copySystemSeeds(tenantId: string, languages: string[]) {
    console.log(`  🌍 Copie des seeds système (${languages.join(', ')})...`);
    
    await this.db.use({ ns: tenantId, db: tenantId });
    
    // Copier les langues
    await this.db.use({ ns: 'lyxal', db: 'lyxal' });
    const languageSeeds = await this.db.query(
      `SELECT * FROM language WHERE code IN $codes`,
      { codes: languages }
    );
    
    await this.db.use({ ns: tenantId, db: tenantId });
    for (const lang of languageSeeds[0]) {
      await this.db.create(`language:${lang.code}`, lang);
    }
    
    // Copier les devises, pays, etc. (similaire)
    // ...
  }
  
  private async generateTables(tenantId: string, template: any) {
    console.log(`  📊 Génération des tables...`);
    
    await this.db.use({ ns: tenantId, db: tenantId });
    
    for (const table of template.tables) {
      // Générer DEFINE TABLE
      let tableSQL = `DEFINE TABLE ${table.name} SCHEMAFULL;\n`;
      
      // Générer DEFINE FIELD
      for (const field of table.fields) {
        tableSQL += `DEFINE FIELD ${field.name} ON ${table.name} TYPE ${field.type};\n`;
      }
      
      // Générer DEFINE INDEX
      for (const index of table.indexes || []) {
        tableSQL += `DEFINE INDEX ${index.name} ON ${table.name} FIELDS ${index.fields.join(', ')};\n`;
      }
      
      await this.db.query(tableSQL);
      console.log(`    ✅ Table ${table.name} créée`);
    }
  }
  
  private async copyFilteredI18n(tenantId: string, template: any, languages: string[]) {
    console.log(`  🌐 Copie des traductions (modules: ${template.modules.join(', ')})...`);
    
    // 1. Récupérer les i18n_key des modules du template
    await this.db.use({ ns: 'lyxal', db: 'lyxal' });
    const i18nKeys = await this.db.query(
      `SELECT * FROM i18n_key WHERE module IN $modules`,
      { modules: template.modules }
    );
    
    // 2. Copier les clés dans le tenant
    await this.db.use({ ns: tenantId, db: tenantId });
    for (const key of i18nKeys[0]) {
      await this.db.create(`i18n_key:${key.code}`, key);
    }
    
    console.log(`    ✅ ${i18nKeys[0].length} clés i18n copiées`);
    
    // 3. Récupérer les traductions associées
    await this.db.use({ ns: 'lyxal', db: 'lyxal' });
    const keyIds = i18nKeys[0].map((k: any) => k.id);
    const translations = await this.db.query(
      `SELECT * FROM translation WHERE i18n_key IN $keyIds AND language IN $languages`,
      { keyIds, languages: languages.map(l => `language:${l}`) }
    );
    
    // 4. Copier les traductions dans le tenant
    await this.db.use({ ns: tenantId, db: tenantId });
    for (const translation of translations[0]) {
      await this.db.create('translation', translation);
    }
    
    console.log(`    ✅ ${translations[0].length} traductions copiées`);
  }
  
  private async generateBusinessSeeds(tenantId: string, template: any) {
    console.log(`  🌱 Génération des seeds métier...`);
    
    await this.db.use({ ns: tenantId, db: tenantId });
    
    for (const seed of template.seeds) {
      // Lire le fichier seed
      const seedPath = path.join(__dirname, '..', 'templates', template.code, seed.file);
      let seedContent = fs.readFileSync(seedPath, 'utf8');
      
      // Adapter le namespace
      seedContent = seedContent.replace(/USE NS lyxal DB lyxal/g, `USE NS ${tenantId} DB ${tenantId}`);
      
      // Exécuter le seed
      await this.db.query(seedContent);
      
      console.log(`    ✅ Seeds ${seed.table} créés`);
    }
  }
  
  private async generateMenusPages(tenantId: string, template: any) {
    console.log(`  📋 Génération des menus et pages...`);
    
    await this.db.use({ ns: tenantId, db: tenantId });
    
    for (const menu of template.menus) {
      // Récupérer l'URL de l'icône depuis Lyxal
      await this.db.use({ ns: 'lyxal', db: 'lyxal' });
      const icon = await this.db.query(
        `SELECT url FROM icon WHERE code = $code`,
        { code: menu.icon_code }
      );
      
      // Créer le menu avec l'URL directe
      await this.db.use({ ns: tenantId, db: tenantId });
      await this.db.create(`studio_menu:${menu.code}`, {
        ...menu,
        icon_url: icon[0][0]?.url || '',
      });
      
      console.log(`    ✅ Menu ${menu.code} créé`);
    }
    
    // Similaire pour les pages
    // ...
  }
  
  private async generateFunctions(tenantId: string, template: any) {
    console.log(`  ⚙️ Génération des fonctions...`);
    
    await this.db.use({ ns: tenantId, db: tenantId });
    
    for (const func of template.functions) {
      const funcPath = path.join(__dirname, '..', 'templates', template.code, func.file);
      let funcContent = fs.readFileSync(funcPath, 'utf8');
      
      // Adapter le namespace
      funcContent = funcContent.replace(/USE NS lyxal DB lyxal/g, `USE NS ${tenantId} DB ${tenantId}`);
      
      // Exécuter la définition de fonction
      await this.db.query(funcContent);
      
      console.log(`    ✅ Fonction ${func.name} créée`);
    }
  }
  
  private async saveConfig(config: TenantConfig) {
    console.log(`  💾 Sauvegarde de la configuration...`);
    
    await this.db.use({ ns: 'lyxal', db: 'lyxal' });
    await this.db.create(`studio_config:${config.tenant_id}`, config);
  }
}

// Utilisation
(async () => {
  const generator = new TenantGenerator();
  await generator.connect();
  
  await generator.generateApplication({
    tenant_id: 'batipro',
    template_code: 'crm_basic',
    domain: 'app.batipro.com',
    languages: ['fr', 'en', 'es'],
    theme: {
      primary: '#FF6B35',
      secondary: '#004E89',
      logo_url: 'https://cdn.batipro.com/logo.svg'
    }
  });
})();
```

---

## 🎯 Récapitulatif final

### ✅ Seeds qui RESTENT dans Lyxal Solution (namespace `lyxal`)

```
builder_type              ← Administration
builder_status            ← Administration
builder_template          ← Administration
builder_action            ← Administration
icon_library              ← Studio (URLs copiées)
icon_category             ← Studio (URLs copiées)
icon (5000+)              ← Studio (URLs copiées)
studio_widget             ← Studio
bunny_dns_zone            ← Infrastructure
bunny_pull_zone           ← Infrastructure
```

**Taille estimée** : ~500 MB (tout le catalogue)

---

### ✅ Seeds COPIÉS aux applications clientes

```
language                  ← Système (toutes)
currency                  ← Système (toutes)
country                   ← Système (toutes)
i18n_key                  ← Filtrées par template/modules
translation               ← Filtrées par template/modules/langues
contact_status            ← Générées si template CRM
lead_status               ← Générées si template CRM
order_status              ← Générées si template E-Commerce
invoice_status            ← Générées si template Comptabilité
```

**Taille estimée (BatiPro avec CRM)** : ~50 MB
**Taille estimée (ComptaPro avec Accounting)** : ~80 MB

---

### 🎓 Principe clé

**Lyxal Solution = Le catalogue complet**
- Tout est disponible
- Toutes les icônes, tous les templates, toutes les traductions
- Uniquement pour l'administration

**Applications clientes = Filtrage intelligent**
- Uniquement ce qui est nécessaire
- Seeds métier du template utilisé
- Traductions des modules activés
- URLs d'icônes (pas les tables icon)
- Autonomie complète (pas de dépendance à Lyxal)

---

**Dernière mise à jour** : 27 octobre 2025
**Auteur** : Équipe Lyxal (via AI Assistant)
**Version** : 1.0

