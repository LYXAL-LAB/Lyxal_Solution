-- ============================================================================
-- SOUS-CATÉGORIES DE BASE POUR LES DESIGN TOKENS
-- Description : Sous-catégories système pour les design tokens CSS
-- Statut : Sous-catégories par défaut du système
-- ============================================================================

-- ============================================================================
-- TYPOGRAPHY - SOUS-CATÉGORIES
-- ============================================================================

CREATE css_token_subcategory:font_size SET
  category = css_token_category:typography,
  identity = {
    name = "font-size",
    slug = "font-size"
  },
  presentation = {
    name_i18n = i18n_key:subcategory_font_size_name,
    description_i18n = i18n_key:subcategory_font_size_description
  },
  metadata = {
    description = "Tailles de police (xs, sm, md, lg, xl, 2xl, etc.)",
    unit = "rem",
    scale_type = "exponential",
    order = 1,
    is_system = true
  };

CREATE css_token_subcategory:font_weight SET
  category = css_token_category:typography,
  identity = {
    name = "font-weight",
    slug = "font-weight"
  },
  presentation = {
    name_i18n = i18n_key:subcategory_font_weight_name,
    description_i18n = i18n_key:subcategory_font_weight_description
  },
  metadata = {
    description = "Poids de police (light:300, normal:400, medium:500, semibold:600, bold:700)",
    unit = "none",
    scale_type = "custom",
    order = 2,
    is_system = true
  };

CREATE css_token_subcategory:line_height SET
  category = css_token_category:typography,
  identity = {
    name = "line-height",
    slug = "line-height"
  },
  presentation = {
    name_i18n = i18n_key:subcategory_line_height_name,
    description_i18n = i18n_key:subcategory_line_height_description
  },
  metadata = {
    description = "Interligne (tight:1.25, snug:1.375, normal:1.5, relaxed:1.625)",
    unit = "none",
    scale_type = "custom",
    order = 3,
    is_system = true
  };

CREATE css_token_subcategory:letter_spacing SET
  category = css_token_category:typography,
  identity = {
    name = "letter-spacing",
    slug = "letter-spacing"
  },
  presentation = {
    name_i18n = i18n_key:subcategory_letter_spacing_name,
    description_i18n = i18n_key:subcategory_letter_spacing_description
  },
  metadata = {
    description = "Espacement des lettres",
    unit = "em",
    scale_type = "linear",
    order = 4,
    is_system = true
  };

-- ============================================================================
-- LAYOUT - SOUS-CATÉGORIES
-- ============================================================================

CREATE css_token_subcategory:border_radius SET
  category = css_token_category:layout,
  identity = {
    name = "border-radius",
    slug = "border-radius"
  },
  presentation = {
    name_i18n = i18n_key:subcategory_border_radius_name,
    description_i18n = i18n_key:subcategory_border_radius_description
  },
  metadata = {
    description = "Arrondis des bordures (none, sm, md, lg, xl, 2xl, full)",
    unit = "rem",
    scale_type = "linear",
    order = 1,
    is_system = true
  };

CREATE css_token_subcategory:border_width SET
  category = css_token_category:layout,
  identity = {
    name = "border-width",
    slug = "border-width"
  },
  presentation = {
    name_i18n = i18n_key:subcategory_border_width_name,
    description_i18n = i18n_key:subcategory_border_width_description
  },
  metadata = {
    description = "Épaisseurs de bordure (0, 1px, 2px, 4px, 8px)",
    unit = "px",
    scale_type = "exponential",
    order = 2,
    is_system = true
  };

CREATE css_token_subcategory:box_shadow SET
  category = css_token_category:layout,
  identity = {
    name = "box-shadow",
    slug = "box-shadow"
  },
  presentation = {
    name_i18n = i18n_key:subcategory_box_shadow_name,
    description_i18n = i18n_key:subcategory_box_shadow_description
  },
  metadata = {
    description = "Ombres portées (sm, md, lg, xl)",
    unit = "none",
    scale_type = "linear",
    order = 3,
    is_system = true
  };

-- ============================================================================
-- SPACING - SOUS-CATÉGORIES
-- ============================================================================

CREATE css_token_subcategory:padding SET
  category = css_token_category:spacing,
  identity = {
    name = "padding",
    slug = "padding"
  },
  presentation = {
    name_i18n = i18n_key:subcategory_padding_name,
    description_i18n = i18n_key:subcategory_padding_description
  },
  metadata = {
    description = "Espacement intérieur (padding)",
    unit = "rem",
    scale_type = "linear",
    order = 1,
    is_system = true
  };

CREATE css_token_subcategory:margin SET
  category = css_token_category:spacing,
  identity = {
    name = "margin",
    slug = "margin"
  },
  presentation = {
    name_i18n = i18n_key:subcategory_margin_name,
    description_i18n = i18n_key:subcategory_margin_description
  },
  metadata = {
    description = "Espacement extérieur (margin)",
    unit = "rem",
    scale_type = "linear",
    order = 2,
    is_system = true
  };

CREATE css_token_subcategory:width SET
  category = css_token_category:spacing,
  identity = {
    name = "width",
    slug = "width"
  },
  presentation = {
    name_i18n = i18n_key:subcategory_width_name,
    description_i18n = i18n_key:subcategory_width_description
  },
  metadata = {
    description = "Largeurs d'éléments",
    unit = "rem",
    scale_type = "linear",
    order = 3,
    is_system = true
  };

CREATE css_token_subcategory:height SET
  category = css_token_category:spacing,
  identity = {
    name = "height",
    slug = "height"
  },
  presentation = {
    name_i18n = i18n_key:subcategory_height_name,
    description_i18n = i18n_key:subcategory_height_description
  },
  metadata = {
    description = "Hauteurs d'éléments",
    unit = "rem",
    scale_type = "linear",
    order = 4,
    is_system = true
  };

-- ============================================================================
-- COMPONENT - SOUS-CATÉGORIES
-- ============================================================================

CREATE css_token_subcategory:btn_height SET
  category = css_token_category:component,
  identity = {
    name = "btn-height",
    slug = "btn-height"
  },
  presentation = {
    name_i18n = i18n_key:subcategory_btn_height_name,
    description_i18n = i18n_key:subcategory_btn_height_description
  },
  metadata = {
    description = "Hauteurs des boutons (sm:32px, md:40px, lg:48px)",
    unit = "rem",
    scale_type = "custom",
    order = 1,
    is_system = true
  };

CREATE css_token_subcategory:btn_padding SET
  category = css_token_category:component,
  identity = {
    name = "btn-padding",
    slug = "btn-padding"
  },
  presentation = {
    name_i18n = i18n_key:subcategory_btn_padding_name,
    description_i18n = i18n_key:subcategory_btn_padding_description
  },
  metadata = {
    description = "Padding des boutons",
    unit = "rem",
    scale_type = "linear",
    order = 2,
    is_system = true
  };

CREATE css_token_subcategory:input_height SET
  category = css_token_category:component,
  identity = {
    name = "input-height",
    slug = "input-height"
  },
  presentation = {
    name_i18n = i18n_key:subcategory_input_height_name,
    description_i18n = i18n_key:subcategory_input_height_description
  },
  metadata = {
    description = "Hauteurs des champs de formulaire",
    unit = "rem",
    scale_type = "custom",
    order = 3,
    is_system = true
  };

CREATE css_token_subcategory:card_padding SET
  category = css_token_category:component,
  identity = {
    name = "card-padding",
    slug = "card-padding"
  },
  presentation = {
    name_i18n = i18n_key:subcategory_card_padding_name,
    description_i18n = i18n_key:subcategory_card_padding_description
  },
  metadata = {
    description = "Padding des cartes",
    unit = "rem",
    scale_type = "linear",
    order = 4,
    is_system = true
  };

-- ============================================================================
-- UTILITY - SOUS-CATÉGORIES
-- ============================================================================

CREATE css_token_subcategory:animation_duration SET
  category = css_token_category:utility,
  identity = {
    name = "animation-duration",
    slug = "animation-duration"
  },
  presentation = {
    name_i18n = i18n_key:subcategory_animation_duration_name,
    description_i18n = i18n_key:subcategory_animation_duration_description
  },
  metadata = {
    description = "Durées d'animation (fast:150ms, normal:300ms, slow:500ms)",
    unit = "ms",
    scale_type = "custom",
    order = 1,
    is_system = true
  };

CREATE css_token_subcategory:animation_timing SET
  category = css_token_category:utility,
  identity = {
    name = "animation-timing",
    slug = "animation-timing"
  },
  presentation = {
    name_i18n = i18n_key:subcategory_animation_timing_name,
    description_i18n = i18n_key:subcategory_animation_timing_description
  },
  metadata = {
    description = "Fonctions de timing d'animation (ease, ease-in, ease-out, linear)",
    unit = "none",
    scale_type = "custom",
    order = 2,
    is_system = true
  };

CREATE css_token_subcategory:z_index SET
  category = css_token_category:utility,
  identity = {
    name = "z-index",
    slug = "z-index"
  },
  presentation = {
    name_i18n = i18n_key:subcategory_z_index_name,
    description_i18n = i18n_key:subcategory_z_index_description
  },
  metadata = {
    description = "Niveaux z-index (dropdown:1000, sticky:1020, fixed:1030, modal:1040)",
    unit = "none",
    scale_type = "custom",
    order = 3,
    is_system = true
  };

-- ============================================================================
-- VÉRIFICATIONS
-- ============================================================================

-- Compter les sous-catégories créées
-- SELECT count() FROM css_token_subcategory;
-- Résultat attendu : 17

-- Lister par catégorie
-- SELECT category.identity.name, count() FROM css_token_subcategory GROUP BY category;
-- Résultats attendus :
-- typography: 4 (font-size, font-weight, line-height, letter-spacing)
-- layout: 3 (border-radius, border-width, box-shadow)
-- spacing: 4 (padding, margin, width, height)
-- component: 4 (btn-height, btn-padding, input-height, card-padding)
-- utility: 3 (animation-duration, animation-timing, z-index)

-- Vérifier l'unicité
-- SELECT count() FROM css_token_subcategory GROUP BY identity.name HAVING count() > 1;
-- Résultat attendu : 0 (pas de doublons)
