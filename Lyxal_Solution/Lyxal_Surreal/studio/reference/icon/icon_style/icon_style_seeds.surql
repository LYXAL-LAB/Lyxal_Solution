-- =============================================================================
-- SEEDS: icon_style
-- =============================================================================
-- Styles d'icônes disponibles dans Lyxal
-- Ordre de déploiement : Après icon_style_i18n_key_seeds.surql
-- =============================================================================

-- 1. Stroke (Outline)
CREATE icon_style:stroke CONTENT {
  identity: {
    value: 'stroke',
    slug: 'stroke'
  },
  presentation: {
    name_i18n: i18n_key:icon_style_stroke_name,
    description_i18n: i18n_key:icon_style_stroke_description
  },
  metadata: {
    technical_name: 'outline',
    preview_example: '<path stroke="currentColor" fill="none" />',
    display_order: 1,
    notes: 'Style par défaut pour la plupart des fournisseurs (Lucide, Heroicons Outline, etc.)'
  },
  status: {
    is_active: true,
    is_system: true,
    source: 'system'
  },
  timestamp: {}
};

-- 2. Solid (Filled)
CREATE icon_style:solid CONTENT {
  identity: {
    value: 'solid',
    slug: 'solid'
  },
  presentation: {
    name_i18n: i18n_key:icon_style_solid_name,
    description_i18n: i18n_key:icon_style_solid_description
  },
  metadata: {
    technical_name: 'filled',
    preview_example: '<path fill="currentColor" stroke="none" />',
    display_order: 2,
    notes: 'Style rempli (Heroicons Solid, Material Icons Filled, etc.)'
  },
  status: {
    is_active: true,
    is_system: true,
    source: 'system'
  },
  timestamp: {}
};

-- 3. Duotone
CREATE icon_style:duotone CONTENT {
  identity: {
    value: 'duotone',
    slug: 'duotone'
  },
  presentation: {
    name_i18n: i18n_key:icon_style_duotone_name,
    description_i18n: i18n_key:icon_style_duotone_description
  },
  metadata: {
    technical_name: 'duo-tone',
    preview_example: '<path fill="currentColor" opacity="0.3" /><path fill="currentColor" />',
    display_order: 3,
    notes: 'Style bicolore avec opacités différentes (Font Awesome Duotone, etc.)'
  },
  status: {
    is_active: true,
    is_system: true,
    source: 'system'
  },
  timestamp: {}
};

-- 4. Mixed
CREATE icon_style:mixed CONTENT {
  identity: {
    value: 'mixed',
    slug: 'mixed'
  },
  presentation: {
    name_i18n: i18n_key:icon_style_mixed_name,
    description_i18n: i18n_key:icon_style_mixed_description
  },
  metadata: {
    technical_name: 'mixed',
    preview_example: '<path stroke="currentColor" /><path fill="currentColor" />',
    display_order: 4,
    notes: 'Combinaison de stroke et solid dans le même pack'
  },
  status: {
    is_active: true,
    is_system: true,
    source: 'system'
  },
  timestamp: {}
};

-- 5. Custom
CREATE icon_style:custom CONTENT {
  identity: {
    value: 'custom',
    slug: 'custom'
  },
  presentation: {
    name_i18n: i18n_key:icon_style_custom_name,
    description_i18n: i18n_key:icon_style_custom_description
  },
  metadata: {
    technical_name: 'custom',
    preview_example: NONE,
    display_order: 5,
    notes: 'Style personnalisé Lyxal ou packs avec styles spécifiques'
  },
  status: {
    is_active: true,
    is_system: true,
    source: 'system'
  },
  timestamp: {}
};

