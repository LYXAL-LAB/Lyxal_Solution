-- ============================================================================
-- CATÉGORIES DE BASE POUR LES DESIGN TOKENS
-- Description : Catégories système pour les design tokens CSS
-- Statut : Catégories par défaut du système
-- ============================================================================

-- ============================================================================
-- CATÉGORIE : SPACING
-- ============================================================================

CREATE css_token_category:spacing SET
  identity = {
    name = "spacing",
    slug = "spacing"
  },
  presentation = {
    name_i18n = i18n_key:token_category_spacing_name,
    description_i18n = i18n_key:token_category_spacing_description
  },
  metadata = {
    description = "Tokens d'espacement et de dimension (padding, margin, width, height)",
    color = theme_color:primary_500,
    order = 1,
    is_system = true
  };

-- ============================================================================
-- CATÉGORIE : TYPOGRAPHY
-- ============================================================================

CREATE css_token_category:typography SET
  identity = {
    name = "typography",
    slug = "typography"
  },
  presentation = {
    name_i18n = i18n_key:token_category_typography_name,
    description_i18n = i18n_key:token_category_typography_description
  },
  metadata = {
    description = "Tokens typographiques (font-size, line-height, font-weight)",
    color = theme_color:success_500,
    order = 2,
    is_system = true
  };

-- ============================================================================
-- CATÉGORIE : LAYOUT
-- ============================================================================

CREATE css_token_category:layout SET
  identity = {
    name = "layout",
    slug = "layout"
  },
  presentation = {
    name_i18n = i18n_key:token_category_layout_name,
    description_i18n = i18n_key:token_category_layout_description
  },
  metadata = {
    description = "Tokens de mise en page (border-radius, box-shadow, border-width)",
    color = theme_color:warning_500,
    order = 3,
    is_system = true
  };

-- ============================================================================
-- CATÉGORIE : COMPONENT
-- ============================================================================

CREATE css_token_category:component SET
  identity = {
    name = "component",
    slug = "component"
  },
  presentation = {
    name_i18n = i18n_key:token_category_component_name,
    description_i18n = i18n_key:token_category_component_description
  },
  metadata = {
    description = "Tokens spécifiques aux composants (boutons, inputs, cartes)",
    color = theme_color:secondary_500,
    order = 4,
    is_system = true
  };

-- ============================================================================
-- CATÉGORIE : UTILITY
-- ============================================================================

CREATE css_token_category:utility SET
  identity = {
    name = "utility",
    slug = "utility"
  },
  presentation = {
    name_i18n = i18n_key:token_category_utility_name,
    description_i18n = i18n_key:token_category_utility_description
  },
  metadata = {
    description = "Tokens utilitaires (animations, z-index, etc.)",
    color = theme_color:error_500,
    order = 5,
    is_system = true
  };

-- ============================================================================
-- VÉRIFICATIONS
-- ============================================================================

-- Compter les catégories créées
-- SELECT count() FROM css_token_category;
-- Résultat attendu : 5

-- Lister toutes les catégories système
-- SELECT identity.name, metadata.order FROM css_token_category WHERE metadata.is_system = true ORDER BY metadata.order;
-- Résultats attendus : spacing(1), typography(2), layout(3), component(4), utility(5)
