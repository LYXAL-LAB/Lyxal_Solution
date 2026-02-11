-- =============================================================================
-- SEEDS: i18n_key for icon_style
-- =============================================================================
-- Clés i18n pour les styles d'icônes
-- Ordre de déploiement : Avant icon_style_seeds.surql
-- =============================================================================

-- 1. Stroke (Outline)
CREATE i18n_key:icon_style_stroke_name CONTENT {
  context: 'icon_style',
  description: 'Nom du style Stroke'
};

CREATE i18n_key:icon_style_stroke_description CONTENT {
  context: 'icon_style',
  description: 'Description du style Stroke'
};

-- 2. Solid (Filled)
CREATE i18n_key:icon_style_solid_name CONTENT {
  context: 'icon_style',
  description: 'Nom du style Solid'
};

CREATE i18n_key:icon_style_solid_description CONTENT {
  context: 'icon_style',
  description: 'Description du style Solid'
};

-- 3. Duotone
CREATE i18n_key:icon_style_duotone_name CONTENT {
  context: 'icon_style',
  description: 'Nom du style Duotone'
};

CREATE i18n_key:icon_style_duotone_description CONTENT {
  context: 'icon_style',
  description: 'Description du style Duotone'
};

-- 4. Mixed
CREATE i18n_key:icon_style_mixed_name CONTENT {
  context: 'icon_style',
  description: 'Nom du style Mixed'
};

CREATE i18n_key:icon_style_mixed_description CONTENT {
  context: 'icon_style',
  description: 'Description du style Mixed'
};

-- 5. Custom
CREATE i18n_key:icon_style_custom_name CONTENT {
  context: 'icon_style',
  description: 'Nom du style Custom'
};

CREATE i18n_key:icon_style_custom_description CONTENT {
  context: 'icon_style',
  description: 'Description du style Custom'
};

