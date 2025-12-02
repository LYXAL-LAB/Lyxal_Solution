-- ============================================================================
-- FICHIER : component_tokens_base.surql
-- Description : Seeds pour les design tokens dédiés par composant
-- Module : studio/theme
-- Approche : "Riche et stricte" - Variables complètes par élément
-- ============================================================================

-- ============================================================================
-- COMPOSANT BUTTON - Variables complètes (14 tokens)
-- ============================================================================

-- Couleurs principales
CREATE css_token_design:button_primary_bg SET
  identity = { name = "--button-primary-bg", slug = "button-primary-bg" },
  category = css_token_category:component,
  subcategory = css_token_subcategory:button,
  component = css_component:button,
  property = "background-color",
  value = "45% 0.2 250",
  unit = "oklch_function",
  computed_value = "oklch(45% 0.2 250)",
  theme = NONE,
  is_default = true,
  metadata = {
    description = "Couleur de fond des boutons primaires",
    order = 1,
    compatibility = [css_framework:tailwind, css_framework:bootstrap, css_framework:material]
  };

CREATE css_token_design:button_primary_text SET
  identity = { name = "--button-primary-text", slug = "button-primary-text" },
  category = css_token_category:component,
  subcategory = css_token_subcategory:button,
  component = css_component:button,
  property = "color",
  value = "95% 0.05 250",
  unit = "oklch_function",
  computed_value = "oklch(95% 0.05 250)",
  theme = NONE,
  is_default = true,
  metadata = {
    description = "Couleur du texte des boutons primaires",
    order = 2,
    compatibility = [css_framework:tailwind, css_framework:bootstrap, css_framework:material]
  };

CREATE css_token_design:button_primary_border SET
  identity = { name = "--button-primary-border", slug = "button-primary-border" },
  category = css_token_category:component,
  subcategory = css_token_subcategory:button,
  component = "button",
  property = "border-color",
  value = "40% 0.15 250",
  unit = "oklch_function",
  computed_value = "oklch(40% 0.15 250)",
  theme = NONE,
  is_default = true,
  metadata = {
    description = "Couleur de bordure des boutons primaires",
    order = 3,
    compatibility = [css_framework:tailwind, css_framework:bootstrap, css_framework:material]
  };

-- États interactifs
CREATE css_token_design:button_primary_shadow SET
  identity = { name = "--button-primary-shadow", slug = "button-primary-shadow" },
  category = css_token_category:component,
  subcategory = css_token_subcategory:button,
  component = "button",
  property = "box-shadow",
  value = "0 2px 4px oklch(45% 0.2 250 / 0.2)",
  unit = "none",
  computed_value = "0 2px 4px oklch(45% 0.2 250 / 0.2)",
  theme = NONE,
  is_default = true,
  metadata = {
    description = "Ombre des boutons primaires",
    order = 4,
    compatibility = [css_framework:tailwind, css_framework:bootstrap, css_framework:material]
  };

CREATE css_token_design:button_primary_hover_bg SET
  identity = { name = "--button-primary-hover-bg", slug = "button-primary-hover-bg" },
  category = css_token_category:component,
  subcategory = css_token_subcategory:button,
  component = "button",
  property = "background-color",
  value = "50% 0.22 250",
  unit = "oklch_function",
  computed_value = "oklch(50% 0.22 250)",
  theme = NONE,
  is_default = true,
  metadata = {
    description = "Couleur de fond au survol des boutons primaires",
    order = 5,
    compatibility = [css_framework:tailwind, css_framework:bootstrap, css_framework:material]
  };

CREATE css_token_design:button_primary_active_bg SET
  identity = { name = "--button-primary-active-bg", slug = "button-primary-active-bg" },
  category = css_token_category:component,
  subcategory = css_token_subcategory:button,
  component = "button",
  property = "background-color",
  value = "40% 0.18 250",
  unit = "oklch_function",
  computed_value = "oklch(40% 0.18 250)",
  theme = NONE,
  is_default = true,
  metadata = {
    description = "Couleur de fond au clic des boutons primaires",
    order = 6,
    compatibility = [css_framework:tailwind, css_framework:bootstrap, css_framework:material]
  };

-- États disabled
CREATE css_token_design:button_primary_disabled_bg SET
  identity = { name = "--button-primary-disabled-bg", slug = "button-primary-disabled-bg" },
  category = css_token_category:component,
  subcategory = css_token_subcategory:button,
  component = "button",
  property = "background-color",
  value = "95% 0.01 250",
  unit = "oklch_function",
  computed_value = "oklch(95% 0.01 250)",
  theme = NONE,
  is_default = true,
  metadata = {
    description = "Couleur de fond des boutons primaires désactivés",
    order = 7,
    compatibility = [css_framework:tailwind, css_framework:bootstrap, css_framework:material]
  };

CREATE css_token_design:button_primary_disabled_text SET
  identity = { name = "--button-primary-disabled-text", slug = "button-primary-disabled-text" },
  category = css_token_category:component,
  subcategory = css_token_subcategory:button,
  component = "button",
  property = "color",
  value = "65% 0.05 250",
  unit = "oklch_function",
  computed_value = "oklch(65% 0.05 250)",
  theme = NONE,
  is_default = true,
  metadata = {
    description = "Couleur du texte des boutons primaires désactivés",
    order = 8,
    compatibility = [css_framework:tailwind, css_framework:bootstrap, css_framework:material]
  };

-- Propriétés structurelles
CREATE css_token_design:button_primary_font_size SET
  identity = { name = "--button-primary-font-size", slug = "button-primary-font-size" },
  category = css_token_category:component,
  subcategory = css_token_subcategory:button,
  component = "button",
  property = "font-size",
  value = "0.875",
  unit = "rem",
  computed_value = "0.875rem",
  theme = NONE,
  is_default = true,
  metadata = {
    description = "Taille de police des boutons primaires",
    order = 9,
    compatibility = [css_framework:tailwind, css_framework:bootstrap, css_framework:material]
  };

CREATE css_token_design:button_primary_font_weight SET
  identity = { name = "--button-primary-font-weight", slug = "button-primary-font-weight" },
  category = css_token_category:component,
  subcategory = css_token_subcategory:button,
  component = "button",
  property = "font-weight",
  value = "600",
  unit = "none",
  computed_value = "600",
  theme = NONE,
  is_default = true,
  metadata = {
    description = "Épaisseur de police des boutons primaires",
    order = 10,
    compatibility = [css_framework:tailwind, css_framework:bootstrap, css_framework:material]
  };

-- Espacement
CREATE css_token_design:button_primary_padding_x SET
  identity = { name = "--button-primary-padding-x", slug = "button-primary-padding-x" },
  category = css_token_category:component,
  subcategory = css_token_subcategory:button,
  component = "button",
  property = "padding-left",
  value = "1",
  unit = "rem",
  computed_value = "1rem",
  theme = NONE,
  is_default = true,
  metadata = {
    description = "Marge horizontale interne des boutons primaires",
    order = 11,
    compatibility = [css_framework:tailwind, css_framework:bootstrap, css_framework:material]
  };

CREATE css_token_design:button_primary_padding_y SET
  identity = { name = "--button-primary-padding-y", slug = "button-primary-padding-y" },
  category = css_token_category:component,
  subcategory = css_token_subcategory:button,
  component = "button",
  property = "padding-top",
  value = "0.5",
  unit = "rem",
  computed_value = "0.5rem",
  theme = NONE,
  is_default = true,
  metadata = {
    description = "Marge verticale interne des boutons primaires",
    order = 12,
    compatibility = [css_framework:tailwind, css_framework:bootstrap, css_framework:material]
  };

-- Forme et animation
CREATE css_token_design:button_primary_border_radius SET
  identity = { name = "--button-primary-border-radius", slug = "button-primary-border-radius" },
  category = css_token_category:component,
  subcategory = css_token_subcategory:button,
  component = "button",
  property = "border-radius",
  value = "0.375",
  unit = "rem",
  computed_value = "0.375rem",
  theme = NONE,
  is_default = true,
  metadata = {
    description = "Rayon de bordure des boutons primaires",
    order = 13,
    compatibility = [css_framework:tailwind, css_framework:bootstrap, css_framework:material]
  };

CREATE css_token_design:button_primary_transition SET
  identity = { name = "--button-primary-transition", slug = "button-primary-transition" },
  category = css_token_category:component,
  subcategory = css_token_subcategory:button,
  component = "button",
  property = "transition",
  value = "all 0.2s ease",
  unit = "none",
  computed_value = "all 0.2s ease",
  theme = NONE,
  is_default = true,
  metadata = {
    description = "Transition des boutons primaires",
    order = 14,
    compatibility = [css_framework:tailwind, css_framework:bootstrap, css_framework:material]
  };

-- ============================================================================
-- COMPOSANT CARD - Variables complètes (11 tokens)
-- ============================================================================

CREATE css_token_design:card_background SET
  identity = { name = "--card-background", slug = "card-background" },
  category = css_token_category:component,
  subcategory = css_token_subcategory:card,
  component = css_component:card,
  property = "background-color",
  value = "100% 0 0",
  unit = "oklch_function",
  computed_value = "oklch(100% 0 0)",
  theme = NONE,
  is_default = true,
  metadata = {
    description = "Couleur de fond des cartes",
    order = 1,
    compatibility = [css_framework:tailwind, css_framework:bootstrap, css_framework:material]
  };

CREATE css_token_design:card_border SET
  identity = { name = "--card-border", slug = "card-border" },
  category = css_token_category:component,
  subcategory = css_token_subcategory:card,
  component = css_component:card,
  property = "border-color",
  value = "90% 0.02 250",
  unit = "oklch_function",
  computed_value = "oklch(90% 0.02 250)",
  theme = NONE,
  is_default = true,
  metadata = {
    description = "Couleur de bordure des cartes",
    order = 2,
    compatibility = [css_framework:tailwind, css_framework:bootstrap, css_framework:material]
  };

CREATE css_token_design:card_border_radius SET
  identity = { name = "--card-border-radius", slug = "card-border-radius" },
  category = css_token_category:component,
  subcategory = css_token_subcategory:card,
  component = css_component:card,
  property = "border-radius",
  value = "0.5",
  unit = "rem",
  computed_value = "0.5rem",
  theme = NONE,
  is_default = true,
  metadata = {
    description = "Rayon de bordure des cartes",
    order = 3,
    compatibility = [css_framework:tailwind, css_framework:bootstrap, css_framework:material]
  };

CREATE css_token_design:card_shadow SET
  identity = { name = "--card-shadow", slug = "card-shadow" },
  category = css_token_category:component,
  subcategory = css_token_subcategory:card,
  component = css_component:card,
  property = "box-shadow",
  value = "0 1px 3px oklch(0% 0 0 / 0.1)",
  unit = "none",
  computed_value = "0 1px 3px oklch(0% 0 0 / 0.1)",
  theme = NONE,
  is_default = true,
  metadata = {
    description = "Ombre des cartes",
    order = 4,
    compatibility = [css_framework:tailwind, css_framework:bootstrap, css_framework:material]
  };

CREATE css_token_design:card_padding SET
  identity = { name = "--card-padding", slug = "card-padding" },
  category = css_token_category:component,
  subcategory = css_token_subcategory:card,
  component = css_component:card,
  property = "padding",
  value = "1.5",
  unit = "rem",
  computed_value = "1.5rem",
  theme = NONE,
  is_default = true,
  metadata = {
    description = "Marge interne des cartes",
    order = 5,
    compatibility = [css_framework:tailwind, css_framework:bootstrap, css_framework:material]
  };

CREATE css_token_design:card_hover_shadow SET
  identity = { name = "--card-hover-shadow", slug = "card-hover-shadow" },
  category = css_token_category:component,
  subcategory = css_token_subcategory:card,
  component = css_component:card,
  property = "box-shadow",
  value = "0 4px 6px oklch(0% 0 0 / 0.1)",
  unit = "none",
  computed_value = "0 4px 6px oklch(0% 0 0 / 0.1)",
  theme = NONE,
  is_default = true,
  metadata = {
    description = "Ombre au survol des cartes",
    order = 6,
    compatibility = [css_framework:tailwind, css_framework:bootstrap, css_framework:material]
  };

CREATE css_token_design:card_hover_transform SET
  identity = { name = "--card-hover-transform", slug = "card-hover-transform" },
  category = css_token_category:component,
  subcategory = css_token_subcategory:card,
  component = css_component:card,
  property = "transform",
  value = "translateY(-2px)",
  unit = "none",
  computed_value = "translateY(-2px)",
  theme = NONE,
  is_default = true,
  metadata = {
    description = "Transformation au survol des cartes",
    order = 7,
    compatibility = [css_framework:tailwind, css_framework:bootstrap, css_framework:material]
  };

CREATE css_token_design:card_title_font_size SET
  identity = { name = "--card-title-font-size", slug = "card-title-font-size" },
  category = css_token_category:component,
  subcategory = css_token_subcategory:card,
  component = css_component:card,
  property = "font-size",
  value = "1.125",
  unit = "rem",
  computed_value = "1.125rem",
  theme = NONE,
  is_default = true,
  metadata = {
    description = "Taille de police des titres de cartes",
    order = 8,
    compatibility = [css_framework:tailwind, css_framework:bootstrap, css_framework:material]
  };

CREATE css_token_design:card_title_font_weight SET
  identity = { name = "--card-title-font-weight", slug = "card-title-font-weight" },
  category = css_token_category:component,
  subcategory = css_token_subcategory:card,
  component = css_component:card,
  property = "font-weight",
  value = "600",
  unit = "none",
  computed_value = "600",
  theme = NONE,
  is_default = true,
  metadata = {
    description = "Épaisseur de police des titres de cartes",
    order = 9,
    compatibility = [css_framework:tailwind, css_framework:bootstrap, css_framework:material]
  };

CREATE css_token_design:card_title_color SET
  identity = { name = "--card-title-color", slug = "card-title-color" },
  category = css_token_category:component,
  subcategory = css_token_subcategory:card,
  component = css_component:card,
  property = "color",
  value = "15% 0.05 250",
  unit = "oklch_function",
  computed_value = "oklch(15% 0.05 250)",
  theme = NONE,
  is_default = true,
  metadata = {
    description = "Couleur des titres de cartes",
    order = 10,
    compatibility = [css_framework:tailwind, css_framework:bootstrap, css_framework:material]
  };

CREATE css_token_design:card_text_color SET
  identity = { name = "--card-text-color", slug = "card-text-color" },
  category = css_token_category:component,
  subcategory = css_token_subcategory:card,
  component = css_component:card,
  property = "color",
  value = "45% 0.05 250",
  unit = "oklch_function",
  computed_value = "oklch(45% 0.05 250)",
  theme = NONE,
  is_default = true,
  metadata = {
    description = "Couleur du texte des cartes",
    order = 11,
    compatibility = [css_framework:tailwind, css_framework:bootstrap, css_framework:material]
  };

-- ============================================================================
-- COMPOSANT LAYOUT - Variables structurelles (11 tokens)
-- ============================================================================

CREATE css_token_design:layout_container_max_width SET
  identity = { name = "--layout-container-max-width", slug = "layout-container-max-width" },
  category = css_token_category:layout,
  subcategory = css_token_subcategory:container,
  component = css_component:layout,
  property = "max-width",
  value = "1280",
  unit = "px",
  computed_value = "1280px",
  theme = NONE,
  is_default = true,
  metadata = {
    description = "Largeur maximale du conteneur principal",
    order = 1,
    compatibility = [css_framework:tailwind, css_framework:bootstrap, css_framework:material]
  };

CREATE css_token_design:layout_container_padding_x SET
  identity = { name = "--layout-container-padding-x", slug = "layout-container-padding-x" },
  category = css_token_category:layout,
  subcategory = css_token_subcategory:container,
  component = css_component:layout,
  property = "padding-left",
  value = "1",
  unit = "rem",
  computed_value = "1rem",
  theme = NONE,
  is_default = true,
  metadata = {
    description = "Marge horizontale du conteneur principal",
    order = 2,
    compatibility = [css_framework:tailwind, css_framework:bootstrap, css_framework:material]
  };

CREATE css_token_design:layout_grid_columns SET
  identity = { name = "--layout-grid-columns", slug = "layout-grid-columns" },
  category = css_token_category:layout,
  subcategory = css_token_subcategory:grid,
  component = css_component:layout,
  property = "grid-template-columns",
  value = "12",
  unit = "none",
  computed_value = "repeat(12, 1fr)",
  theme = NONE,
  is_default = true,
  metadata = {
    description = "Nombre de colonnes dans la grille",
    order = 3,
    compatibility = [css_framework:tailwind, css_framework:bootstrap, css_framework:material]
  };

CREATE css_token_design:layout_grid_gutter SET
  identity = { name = "--layout-grid-gutter", slug = "layout-grid-gutter" },
  category = css_token_category:layout,
  subcategory = css_token_subcategory:grid,
  component = css_component:layout,
  property = "gap",
  value = "1.5",
  unit = "rem",
  computed_value = "1.5rem",
  theme = NONE,
  is_default = true,
  metadata = {
    description = "Espacement entre les éléments de grille",
    order = 4,
    compatibility = [css_framework:tailwind, css_framework:bootstrap, css_framework:material]
  };

CREATE css_token_design:layout_header_height SET
  identity = { name = "--layout-header-height", slug = "layout-header-height" },
  category = css_token_category:layout,
  subcategory = css_token_subcategory:header,
  component = css_component:layout,
  property = "height",
  value = "4",
  unit = "rem",
  computed_value = "4rem",
  theme = NONE,
  is_default = true,
  metadata = {
    description = "Hauteur du header",
    order = 5,
    compatibility = [css_framework:tailwind, css_framework:bootstrap, css_framework:material]
  };

CREATE css_token_design:layout_sidebar_width SET
  identity = { name = "--layout-sidebar-width", slug = "layout-sidebar-width" },
  category = css_token_category:layout,
  subcategory = css_token_subcategory:sidebar,
  component = css_component:layout,
  property = "width",
  value = "16",
  unit = "rem",
  computed_value = "16rem",
  theme = NONE,
  is_default = true,
  metadata = {
    description = "Largeur de la sidebar",
    order = 6,
    compatibility = [css_framework:tailwind, css_framework:bootstrap, css_framework:material]
  };

-- Breakpoints responsive
CREATE css_token_design:layout_breakpoint_sm SET
  identity = { name = "--layout-breakpoint-sm", slug = "layout-breakpoint-sm" },
  category = css_token_category:layout,
  subcategory = css_token_subcategory:responsive,
  component = css_component:layout,
  property = "min-width",
  value = "640",
  unit = "px",
  computed_value = "640px",
  theme = NONE,
  is_default = true,
  metadata = {
    description = "Breakpoint smartphone",
    order = 7,
    compatibility = [css_framework:tailwind, css_framework:bootstrap, css_framework:material]
  };

CREATE css_token_design:layout_breakpoint_md SET
  identity = { name = "--layout-breakpoint-md", slug = "layout-breakpoint-md" },
  category = css_token_category:layout,
  subcategory = css_token_subcategory:responsive,
  component = css_component:layout,
  property = "min-width",
  value = "768",
  unit = "px",
  computed_value = "768px",
  theme = NONE,
  is_default = true,
  metadata = {
    description = "Breakpoint tablette",
    order = 8,
    compatibility = [css_framework:tailwind, css_framework:bootstrap, css_framework:material]
  };

CREATE css_token_design:layout_breakpoint_lg SET
  identity = { name = "--layout-breakpoint-lg", slug = "layout-breakpoint-lg" },
  category = css_token_category:layout,
  subcategory = css_token_subcategory:responsive,
  component = css_component:layout,
  property = "min-width",
  value = "1024",
  unit = "px",
  computed_value = "1024px",
  theme = NONE,
  is_default = true,
  metadata = {
    description = "Breakpoint desktop",
    order = 9,
    compatibility = [css_framework:tailwind, css_framework:bootstrap, css_framework:material]
  };

CREATE css_token_design:layout_breakpoint_xl SET
  identity = { name = "--layout-breakpoint-xl", slug = "layout-breakpoint-xl" },
  category = css_token_category:layout,
  subcategory = css_token_subcategory:responsive,
  component = css_component:layout,
  property = "min-width",
  value = "1280",
  unit = "px",
  computed_value = "1280px",
  theme = NONE,
  is_default = true,
  metadata = {
    description = "Breakpoint desktop large",
    order = 10,
    compatibility = [css_framework:tailwind, css_framework:bootstrap, css_framework:material]
  };

-- Z-index pour layering
CREATE css_token_design:layout_z_index_header SET
  identity = { name = "--layout-z-index-header", slug = "layout-z-index-header" },
  category = css_token_category:layout,
  subcategory = css_token_subcategory:layering,
  component = css_component:layout,
  property = "z-index",
  value = "1000",
  unit = "none",
  computed_value = "1000",
  theme = NONE,
  is_default = true,
  metadata = {
    description = "Z-index du header",
    order = 11,
    compatibility = [css_framework:tailwind, css_framework:bootstrap, css_framework:material]
  };

CREATE css_token_design:layout_z_index_modal SET
  identity = { name = "--layout-z-index-modal", slug = "layout-z-index-modal" },
  category = css_token_category:layout,
  subcategory = css_token_subcategory:layering,
  component = css_component:layout,
  property = "z-index",
  value = "1050",
  unit = "none",
  computed_value = "1050",
  theme = NONE,
  is_default = true,
  metadata = {
    description = "Z-index des modals",
    order = 12,
    compatibility = [css_framework:tailwind, css_framework:bootstrap, css_framework:material]
  };
