-- ============================================================================
-- TYPES DE COULEURS CSS DE BASE
-- Description : Types de couleurs système (semantic, ui, state, etc.)
-- Total : 23 types de couleurs de base
-- ============================================================================

-- ============================================================================
-- SEMANTIC COLORS (7 types)
-- ============================================================================

-- Primary - Couleur principale de l'interface
CREATE css_color_type:primary SET
  identity = {
    value = "primary",
    slug = "primary"
  },
  presentation = {
    name_i18n = i18n_key:color_type_primary_name,
    description_i18n = i18n_key:color_type_primary_description
  },
  context = {
    category = "semantic",
    usage_hints = ["buttons", "links", "accents"],
    semantic_meaning = "Couleur principale de l'interface utilisateur"
  },
  config = {
    requires_variants = true,
    default_variants = ["main", "light", "dark"],
    supports_alpha = true,
    is_system_type = true
  },
  status = {
    is_active = true,
    is_default = true,
    order = 1
  };

-- Secondary - Couleur secondaire complémentaire
CREATE css_color_type:secondary SET
  identity = {
    value = "secondary",
    slug = "secondary"
  },
  presentation = {
    name_i18n = i18n_key:color_type_secondary_name,
    description_i18n = i18n_key:color_type_secondary_description
  },
  context = {
    category = "semantic",
    usage_hints = ["buttons", "accents", "decorations"],
    semantic_meaning = "Couleur secondaire pour différenciation"
  },
  config = {
    requires_variants = true,
    default_variants = ["main", "light", "dark"],
    supports_alpha = true,
    is_system_type = true
  },
  status = {
    is_active = true,
    order = 2
  };

-- Error - Couleur pour les erreurs et problèmes
CREATE css_color_type:error SET
  identity = {
    value = "error",
    slug = "error"
  },
  presentation = {
    name_i18n = i18n_key:color_type_error_name,
    description_i18n = i18n_key:color_type_error_description
  },
  context = {
    category = "semantic",
    usage_hints = ["alerts", "error_messages", "validation"],
    semantic_meaning = "Indique une erreur ou un problème critique"
  },
  config = {
    requires_variants = true,
    default_variants = ["main", "light", "dark"],
    supports_alpha = true,
    is_system_type = true
  },
  status = {
    is_active = true,
    order = 3
  };

-- Warning - Couleur pour les avertissements
CREATE css_color_type:warning SET
  identity = {
    value = "warning",
    slug = "warning"
  },
  presentation = {
    name_i18n = i18n_key:color_type_warning_name,
    description_i18n = i18n_key:color_type_warning_description
  },
  context = {
    category = "semantic",
    usage_hints = ["alerts", "warnings", "cautions"],
    semantic_meaning = "Attire l'attention sur quelque chose d'important"
  },
  config = {
    requires_variants = true,
    default_variants = ["main", "light", "dark"],
    supports_alpha = true,
    is_system_type = true
  },
  status = {
    is_active = true,
    order = 4
  };

-- Success - Couleur pour les succès et validations
CREATE css_color_type:success SET
  identity = {
    value = "success",
    slug = "success"
  },
  presentation = {
    name_i18n = i18n_key:color_type_success_name,
    description_i18n = i18n_key:color_type_success_description
  },
  context = {
    category = "semantic",
    usage_hints = ["success_messages", "validations", "confirmations"],
    semantic_meaning = "Indique une action réussie ou une validation"
  },
  config = {
    requires_variants = true,
    default_variants = ["main", "light", "dark"],
    supports_alpha = true,
    is_system_type = true
  },
  status = {
    is_active = true,
    order = 5
  };

-- Info - Couleur pour les informations générales
CREATE css_color_type:info SET
  identity = {
    value = "info",
    slug = "info"
  },
  presentation = {
    name_i18n = i18n_key:color_type_info_name,
    description_i18n = i18n_key:color_type_info_description
  },
  context = {
    category = "semantic",
    usage_hints = ["info_messages", "help", "tips"],
    semantic_meaning = "Fournit des informations générales ou des conseils"
  },
  config = {
    requires_variants = true,
    default_variants = ["main", "light", "dark"],
    supports_alpha = true,
    is_system_type = true
  },
  status = {
    is_active = true,
    order = 6
  };

-- Accent - Couleur d'accentuation complémentaire
CREATE css_color_type:accent SET
  identity = {
    value = "accent",
    slug = "accent"
  },
  presentation = {
    name_i18n = i18n_key:color_type_accent_name,
    description_i18n = i18n_key:color_type_accent_description
  },
  context = {
    category = "semantic",
    usage_hints = ["highlights", "special_elements", "branding"],
    semantic_meaning = "Accentue des éléments importants ou spéciaux"
  },
  config = {
    requires_variants = true,
    default_variants = ["main", "light", "dark"],
    supports_alpha = true,
    is_system_type = true
  },
  status = {
    is_active = true,
    order = 7
  };

-- ============================================================================
-- UI COLORS (4 types)
-- ============================================================================

-- Background - Couleur de fond principale
CREATE css_color_type:background SET
  identity = {
    value = "background",
    slug = "background"
  },
  presentation = {
    name_i18n = i18n_key:color_type_background_name,
    description_i18n = i18n_key:color_type_background_description
  },
  context = {
    category = "ui",
    usage_hints = ["page_background", "container_background"],
    semantic_meaning = "Couleur de fond de base de l'interface"
  },
  config = {
    requires_variants = false,
    supports_alpha = false,
    is_system_type = true
  },
  status = {
    is_active = true,
    order = 8
  };

-- Surface - Couleur des surfaces élevées
CREATE css_color_type:surface SET
  identity = {
    value = "surface",
    slug = "surface"
  },
  presentation = {
    name_i18n = i18n_key:color_type_surface_name,
    description_i18n = i18n_key:color_type_surface_description
  },
  context = {
    category = "ui",
    usage_hints = ["cards", "panels", "elevated_elements"],
    semantic_meaning = "Couleur des éléments en relief (cartes, panneaux)"
  },
  config = {
    requires_variants = false,
    supports_alpha = false,
    is_system_type = true
  },
  status = {
    is_active = true,
    order = 9
  };

-- Border - Couleur des bordures
CREATE css_color_type:border SET
  identity = {
    value = "border",
    slug = "border"
  },
  presentation = {
    name_i18n = i18n_key:color_type_border_name,
    description_i18n = i18n_key:color_type_border_description
  },
  context = {
    category = "ui",
    usage_hints = ["input_borders", "card_borders", "separators"],
    semantic_meaning = "Couleur des bordures et séparateurs"
  },
  config = {
    requires_variants = false,
    supports_alpha = true,
    is_system_type = true
  },
  status = {
    is_active = true,
    order = 10
  };

-- Text - Couleur du texte principal
CREATE css_color_type:text SET
  identity = {
    value = "text",
    slug = "text"
  },
  presentation = {
    name_i18n = i18n_key:color_type_text_name,
    description_i18n = i18n_key:color_type_text_description
  },
  context = {
    category = "ui",
    usage_hints = ["body_text", "headings", "labels"],
    semantic_meaning = "Couleur du texte principal"
  },
  config = {
    requires_variants = false,
    supports_alpha = true,
    is_system_type = true
  },
  status = {
    is_active = true,
    order = 11
  };

-- ============================================================================
-- STATE COLORS (4 types)
-- ============================================================================

-- Hover - Couleur pour l'état hover
CREATE css_color_type:hover SET
  identity = {
    value = "hover",
    slug = "hover"
  },
  presentation = {
    name_i18n = i18n_key:color_type_hover_name,
    description_i18n = i18n_key:color_type_hover_description
  },
  context = {
    category = "state",
    theme_mode = "both",
    usage_hints = ["buttons", "links", "interactive_elements"],
    semantic_meaning = "État au survol de la souris"
  },
  config = {
    requires_variants = false,
    supports_alpha = true,
    is_system_type = true
  },
  status = {
    is_active = true,
    order = 12
  };

-- Focus - Couleur pour l'état focus
CREATE css_color_type:focus SET
  identity = {
    value = "focus",
    slug = "focus"
  },
  presentation = {
    name_i18n = i18n_key:color_type_focus_name,
    description_i18n = i18n_key:color_type_focus_description
  },
  context = {
    category = "state",
    theme_mode = "both",
    usage_hints = ["inputs", "buttons", "keyboard_navigation"],
    semantic_meaning = "Indique l'élément focalisé au clavier"
  },
  config = {
    requires_variants = false,
    supports_alpha = true,
    is_system_type = true
  },
  status = {
    is_active = true,
    order = 13
  };

-- Active - Couleur pour l'état actif
CREATE css_color_type:active SET
  identity = {
    value = "active",
    slug = "active"
  },
  presentation = {
    name_i18n = i18n_key:color_type_active_name,
    description_i18n = i18n_key:color_type_active_description
  },
  context = {
    category = "state",
    theme_mode = "both",
    usage_hints = ["buttons", "tabs", "selected_items"],
    semantic_meaning = "Indique l'élément actuellement actif/sélectionné"
  },
  config = {
    requires_variants = false,
    supports_alpha = true,
    is_system_type = true
  },
  status = {
    is_active = true,
    order = 14
  };

-- Disabled - Couleur pour l'état désactivé
CREATE css_color_type:disabled SET
  identity = {
    value = "disabled",
    slug = "disabled"
  },
  presentation = {
    name_i18n = i18n_key:color_type_disabled_name,
    description_i18n = i18n_key:color_type_disabled_description
  },
  context = {
    category = "state",
    theme_mode = "both",
    usage_hints = ["disabled_inputs", "disabled_buttons", "inactive_elements"],
    semantic_meaning = "Éléments non interactifs ou désactivés"
  },
  config = {
    requires_variants = false,
    supports_alpha = true,
    is_system_type = true
  },
  status = {
    is_active = true,
    order = 15
  };

-- ============================================================================
-- NEUTRAL COLORS (4 types)
-- ============================================================================

-- Gray - Échelle de gris
CREATE css_color_type:gray SET
  identity = {
    value = "gray",
    slug = "gray"
  },
  presentation = {
    name_i18n = i18n_key:color_type_gray_name,
    description_i18n = i18n_key:color_type_gray_description
  },
  context = {
    category = "neutral",
    usage_hints = ["text", "borders", "backgrounds"],
    semantic_meaning = "Échelle de gris pour le texte et les éléments neutres"
  },
  config = {
    requires_variants = true,
    default_variants = ["50", "100", "200", "300", "400", "500", "600", "700", "800", "900"],
    supports_alpha = true,
    is_system_type = true
  },
  status = {
    is_active = true,
    order = 16
  };

-- White - Blanc pur
CREATE css_color_type:white SET
  identity = {
    value = "white",
    slug = "white"
  },
  presentation = {
    name_i18n = i18n_key:color_type_white_name,
    description_i18n = i18n_key:color_type_white_description
  },
  context = {
    category = "neutral",
    usage_hints = ["backgrounds", "text_on_dark"],
    semantic_meaning = "Blanc pur pour contrastes élevés"
  },
  config = {
    requires_variants = false,
    supports_alpha = true,
    is_system_type = true
  },
  status = {
    is_active = true,
    order = 17
  };

-- Black - Noir pur
CREATE css_color_type:black SET
  identity = {
    value = "black",
    slug = "black"
  },
  presentation = {
    name_i18n = i18n_key:color_type_black_name,
    description_i18n = i18n_key:color_type_black_description
  },
  context = {
    category = "neutral",
    usage_hints = ["text", "shadows", "borders"],
    semantic_meaning = "Noir pur pour contrastes élevés"
  },
  config = {
    requires_variants = false,
    supports_alpha = true,
    is_system_type = true
  },
  status = {
    is_active = true,
    order = 18
  };

-- Transparent - Valeur transparente
CREATE css_color_type:transparent SET
  identity = {
    value = "transparent",
    slug = "transparent"
  },
  presentation = {
    name_i18n = i18n_key:color_type_transparent_name,
    description_i18n = i18n_key:color_type_transparent_description
  },
  context = {
    category = "neutral",
    usage_hints = ["overlays", "placeholders", "effects"],
    semantic_meaning = "Valeur complètement transparente"
  },
  config = {
    requires_variants = false,
    supports_alpha = false,
    is_system_type = true
  },
  status = {
    is_active = true,
    order = 19
  };

-- ============================================================================
-- BRAND COLORS (2 types)
-- ============================================================================

-- Brand Primary - Couleur principale de la marque
CREATE css_color_type:brand_primary SET
  identity = {
    value = "brand_primary",
    slug = "brand-primary"
  },
  presentation = {
    name_i18n = i18n_key:color_type_brand_primary_name,
    description_i18n = i18n_key:color_type_brand_primary_description
  },
  context = {
    category = "brand",
    usage_hints = ["logos", "primary_actions", "brand_elements"],
    semantic_meaning = "Couleur principale identifiant la marque"
  },
  config = {
    requires_variants = true,
    default_variants = ["main", "light", "dark"],
    supports_alpha = true,
    is_system_type = false
  },
  status = {
    is_active = true,
    order = 20
  };

-- Brand Secondary - Couleur secondaire de la marque
CREATE css_color_type:brand_secondary SET
  identity = {
    value = "brand_secondary",
    slug = "brand-secondary"
  },
  presentation = {
    name_i18n = i18n_key:color_type_brand_secondary_name,
    description_i18n = i18n_key:color_type_brand_secondary_description
  },
  context = {
    category = "brand",
    usage_hints = ["accents", "secondary_elements", "decorations"],
    semantic_meaning = "Couleur secondaire complémentaire à la marque"
  },
  config = {
    requires_variants = true,
    default_variants = ["main", "light", "dark"],
    supports_alpha = true,
    is_system_type = false
  },
  status = {
    is_active = true,
    order = 21
  };

-- ============================================================================
-- CUSTOM COLORS (1 type générique)
-- ============================================================================

-- Custom - Couleur personnalisée définie par l'utilisateur
CREATE css_color_type:custom SET
  identity = {
    value = "custom",
    slug = "custom"
  },
  presentation = {
    name_i18n = i18n_key:color_type_custom_name,
    description_i18n = i18n_key:color_type_custom_description
  },
  context = {
    category = "custom",
    usage_hints = ["user_defined", "specific_use_cases"],
    semantic_meaning = "Couleur personnalisée définie par l'utilisateur"
  },
  config = {
    requires_variants = false,
    supports_alpha = true,
    is_system_type = false
  },
  status = {
    is_active = true,
    order = 22
  };

-- ============================================================================
-- VÉRIFICATIONS
-- ============================================================================

-- Compter les types de couleurs créés
-- SELECT count() FROM css_color_type;
-- Résultat attendu : 22

-- Vérifier la répartition par catégorie
-- SELECT context.category, count() FROM css_color_type GROUP BY context.category;
-- Résultats attendus :
-- semantic: 7 (primary, secondary, error, warning, success, info, accent)
-- ui: 4 (background, surface, border, text)
-- state: 4 (hover, focus, active, disabled)
-- neutral: 4 (gray, white, black, transparent)
-- brand: 2 (brand_primary, brand_secondary)
-- custom: 1 (custom)

-- Vérifier les types système actifs
-- SELECT identity.value, status.order FROM css_color_type WHERE config.is_system_type = true ORDER BY status.order;
