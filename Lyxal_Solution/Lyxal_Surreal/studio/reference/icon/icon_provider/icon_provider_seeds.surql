-- =============================================================================
-- SEEDS: icon_provider
-- =============================================================================
-- Fournisseurs d'icônes disponibles dans Lyxal
-- Ordre de déploiement : Après icon_provider_i18n_key_seeds.surql
-- =============================================================================

-- 1. Lucide (Recommandé)
CREATE icon_provider:lucide CONTENT {
  identity: {
    value: 'lucide',
    slug: 'lucide'
  },
  presentation: {
    name_i18n: i18n_key:icon_provider_lucide_name,
    description_i18n: i18n_key:icon_provider_lucide_description,
    logo: icon:lucide_logo
  },
  config: {
    base_url: url:icon_provider_lucide_base_cdn,  -- https://icons.lyxal.b-cdn.net/lucide/
    version: '0.344.0',
    license: 'ISC',
    total_icons: 1400,
    style: icon_style:stroke,
    formats: ['svg'],
    is_recommended: true,
    auto_import: false
  },
  documentation: {
    official_url: url:icon_provider_lucide_official,  -- https://lucide.dev
    docs_url: url:icon_provider_lucide_docs,  -- https://lucide.dev/guide
    github_url: url:icon_provider_lucide_github,  -- https://github.com/lucide-icons/lucide
    npm_package: 'lucide-react'
  },
  metadata: {
    notes: 'Fournisseur par défaut recommandé pour Lyxal. Fork moderne de Feather Icons avec plus d\'icônes.',
    order: 1,
    defaults: {
      viewBox: '0 0 24 24',
      stroke_width: 2,
      stroke: 'currentColor',
      fill: 'none'
    }
  },
  status: {
    is_active: true,
    is_default: true,
    is_custom: false,
    is_maintained: true,
    source: 'system'
  },
  timestamp: {}
};

-- 2. Heroicons
CREATE icon_provider:heroicons CONTENT {
  identity: {
    value: 'heroicons',
    slug: 'heroicons'
  },
  presentation: {
    name_i18n: i18n_key:icon_provider_heroicons_name,
    description_i18n: i18n_key:icon_provider_heroicons_description,
    logo: icon:heroicons_logo
  },
  config: {
    base_url: url:icon_provider_heroicons_base_cdn,  -- https://icons.lyxal.b-cdn.net/heroicons/
    version: '2.0.18',
    license: 'MIT',
    total_icons: 292,
    style: icon_style:mixed,
    formats: ['svg'],
    is_recommended: true,
    auto_import: false
  },
  documentation: {
    official_url: url:icon_provider_heroicons_official,  -- https://heroicons.com
    docs_url: url:icon_provider_heroicons_docs,  -- https://heroicons.com
    github_url: url:icon_provider_heroicons_github,  -- https://github.com/tailwindlabs/heroicons
    npm_package: '@heroicons/react'
  },
  metadata: {
    notes: 'Par Tailwind Labs. Disponible en Outline (stroke) et Solid (filled).',
    order: 2,
    defaults: {
      viewBox: '0 0 24 24',
      stroke_width: 1.5,
      stroke: 'currentColor',
      fill: 'none'
    }
  },
  status: {
    is_active: true,
    is_default: false,
    is_custom: false,
    is_maintained: true,
    source: 'system'
  },
  timestamp: {}
};

-- 3. Material Icons
CREATE icon_provider:material_icons CONTENT {
  identity: {
    value: 'material_icons',
    slug: 'material-icons'
  },
  presentation: {
    name_i18n: i18n_key:icon_provider_material_icons_name,
    description_i18n: i18n_key:icon_provider_material_icons_description,
    logo: icon:material_icons_logo
  },
  config: {
    base_url: url:icon_provider_material_icons_base_cdn,  -- https://icons.lyxal.b-cdn.net/material-icons/
    version: '4.0.0',
    license: 'Apache-2.0',
    total_icons: 2500,
    style: icon_style:mixed,
    formats: ['svg', 'font'],
    is_recommended: false,
    auto_import: false
  },
  documentation: {
    official_url: url:icon_provider_material_icons_official,  -- https://fonts.google.com/icons
    docs_url: url:icon_provider_material_icons_docs,  -- https://developers.google.com/fonts/docs/material_icons
    github_url: url:icon_provider_material_icons_github,  -- https://github.com/google/material-design-icons
    npm_package: '@mui/icons-material'
  },
  metadata: {
    notes: 'Par Google. Icônes Material Design. Disponible en Filled, Outlined, Rounded, Sharp, Two-tone.',
    order: 3,
    defaults: {
      viewBox: '0 0 24 24',
      stroke_width: NONE,
      stroke: NONE,
      fill: 'currentColor'
    }
  },
  status: {
    is_active: true,
    is_default: false,
    is_custom: false,
    is_maintained: true,
    source: 'system'
  },
  timestamp: {}
};

-- 4. Font Awesome
CREATE icon_provider:font_awesome CONTENT {
  identity: {
    value: 'font_awesome',
    slug: 'font-awesome'
  },
  presentation: {
    name_i18n: i18n_key:icon_provider_font_awesome_name,
    description_i18n: i18n_key:icon_provider_font_awesome_description,
    logo: icon:font_awesome_logo
  },
  config: {
    base_url: url:icon_provider_font_awesome_base_cdn,  -- https://icons.lyxal.b-cdn.net/font-awesome/
    version: '6.5.1',
    license: 'MIT',
    total_icons: 2016,
    style: icon_style:mixed,
    formats: ['svg', 'font'],
    is_recommended: false,
    auto_import: false
  },
  documentation: {
    official_url: url:icon_provider_font_awesome_official,  -- https://fontawesome.com
    docs_url: url:icon_provider_font_awesome_docs,  -- https://fontawesome.com/docs
    github_url: url:icon_provider_font_awesome_github,  -- https://github.com/FortAwesome/Font-Awesome
    npm_package: '@fortawesome/react-fontawesome'
  },
  metadata: {
    notes: 'Le plus connu. Gratuit (Free) avec 2016 icônes. Pro disponible avec plus d\'icônes.',
    order: 4,
    defaults: {
      viewBox: '0 0 512 512',
      stroke_width: NONE,
      stroke: NONE,
      fill: 'currentColor'
    }
  },
  status: {
    is_active: true,
    is_default: false,
    is_custom: false,
    is_maintained: true,
    source: 'system'
  },
  timestamp: {}
};

-- 5. Feather Icons
CREATE icon_provider:feather CONTENT {
  identity: {
    value: 'feather',
    slug: 'feather'
  },
  presentation: {
    name_i18n: i18n_key:icon_provider_feather_name,
    description_i18n: i18n_key:icon_provider_feather_description,
    logo: icon:feather_logo
  },
  config: {
    base_url: url:icon_provider_feather_base_cdn,  -- https://icons.lyxal.b-cdn.net/feather/
    version: '4.29.0',
    license: 'MIT',
    total_icons: 287,
    style: icon_style:stroke,
    formats: ['svg'],
    is_recommended: false,
    auto_import: false
  },
  documentation: {
    official_url: url:icon_provider_feather_official,  -- https://feathericons.com
    docs_url: url:icon_provider_feather_docs,  -- https://feathericons.com
    github_url: url:icon_provider_feather_github,  -- https://github.com/feathericons/feather
    npm_package: 'react-feather'
  },
  metadata: {
    notes: 'Simple et élégant. Ancêtre de Lucide.',
    order: 5,
    defaults: {
      viewBox: '0 0 24 24',
      stroke_width: 2,
      stroke: 'currentColor',
      fill: 'none'
    }
  },
  status: {
    is_active: true,
    is_default: false,
    is_custom: false,
    is_maintained: false,
    source: 'system'
  },
  timestamp: {}
};

-- 6. Bootstrap Icons
CREATE icon_provider:bootstrap_icons CONTENT {
  identity: {
    value: 'bootstrap_icons',
    slug: 'bootstrap-icons'
  },
  presentation: {
    name_i18n: i18n_key:icon_provider_bootstrap_icons_name,
    description_i18n: i18n_key:icon_provider_bootstrap_icons_description,
    logo: icon:bootstrap_icons_logo
  },
  config: {
    base_url: url:icon_provider_bootstrap_icons_base_cdn,  -- https://icons.lyxal.b-cdn.net/bootstrap-icons/
    version: '1.11.3',
    license: 'MIT',
    total_icons: 2000,
    style: icon_style:mixed,
    formats: ['svg', 'font'],
    is_recommended: false,
    auto_import: false
  },
  documentation: {
    official_url: url:icon_provider_bootstrap_icons_official,  -- https://icons.getbootstrap.com
    docs_url: url:icon_provider_bootstrap_icons_docs,  -- https://icons.getbootstrap.com
    github_url: url:icon_provider_bootstrap_icons_github,  -- https://github.com/twbs/icons
    npm_package: 'bootstrap-icons'
  },
  metadata: {
    notes: 'Par Bootstrap Team. Grande collection avec style consistant.',
    order: 6,
    defaults: {
      viewBox: '0 0 16 16',
      stroke_width: NONE,
      stroke: NONE,
      fill: 'currentColor'
    }
  },
  status: {
    is_active: true,
    is_default: false,
    is_custom: false,
    is_maintained: true,
    source: 'system'
  },
  timestamp: {}
};

-- 7. Phosphor Icons
CREATE icon_provider:phosphor CONTENT {
  identity: {
    value: 'phosphor',
    slug: 'phosphor'
  },
  presentation: {
    name_i18n: i18n_key:icon_provider_phosphor_name,
    description_i18n: i18n_key:icon_provider_phosphor_description,
    logo: icon:phosphor_logo
  },
  config: {
    base_url: url:icon_provider_phosphor_base_cdn,  -- https://icons.lyxal.b-cdn.net/phosphor/
    version: '2.0.8',
    license: 'MIT',
    total_icons: 1248,
    style: icon_style:mixed,
    formats: ['svg'],
    is_recommended: false,
    auto_import: false
  },
  documentation: {
    official_url: url:icon_provider_phosphor_official,  -- https://phosphoricons.com
    docs_url: url:icon_provider_phosphor_docs,  -- https://phosphoricons.com
    github_url: url:icon_provider_phosphor_github,  -- https://github.com/phosphor-icons/core
    npm_package: '@phosphor-icons/react'
  },
  metadata: {
    notes: 'Flexible avec 6 poids différents (Thin, Light, Regular, Bold, Fill, Duotone).',
    order: 7,
    defaults: {
      viewBox: '0 0 256 256',
      stroke_width: 2,
      stroke: 'currentColor',
      fill: 'none'
    }
  },
  status: {
    is_active: true,
    is_default: false,
    is_custom: false,
    is_maintained: true,
    source: 'system'
  },
  timestamp: {}
};

-- 8. Tabler Icons
CREATE icon_provider:tabler CONTENT {
  identity: {
    value: 'tabler',
    slug: 'tabler'
  },
  presentation: {
    name_i18n: i18n_key:icon_provider_tabler_name,
    description_i18n: i18n_key:icon_provider_tabler_description,
    logo: icon:tabler_logo
  },
  config: {
    base_url: url:icon_provider_tabler_base_cdn,  -- https://icons.lyxal.b-cdn.net/tabler/
    version: '2.47.0',
    license: 'MIT',
    total_icons: 4800,
    style: icon_style:stroke,
    formats: ['svg'],
    is_recommended: true,
    auto_import: false
  },
  documentation: {
    official_url: url:icon_provider_tabler_official,  -- https://tabler-icons.io
    docs_url: url:icon_provider_tabler_docs,  -- https://tabler-icons.io
    github_url: url:icon_provider_tabler_github,  -- https://github.com/tabler/tabler-icons
    npm_package: '@tabler/icons-react'
  },
  metadata: {
    notes: 'La plus grande collection d\'icônes stroke. Parfait pour les dashboards.',
    order: 8,
    defaults: {
      viewBox: '0 0 24 24',
      stroke_width: 2,
      stroke: 'currentColor',
      fill: 'none'
    }
  },
  status: {
    is_active: true,
    is_default: false,
    is_custom: false,
    is_maintained: true,
    source: 'system'
  },
  timestamp: {}
};

