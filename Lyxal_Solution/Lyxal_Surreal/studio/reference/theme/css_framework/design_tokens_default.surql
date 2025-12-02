-- ============================================================================
-- DESIGN TOKENS PAR DÉFAUT
-- Description : Valeurs par défaut des design tokens pour le thème de base
-- Catégories : spacing (16), typography (12), layout (10), component (15), utility (8)
-- Total : 61 design tokens
-- ============================================================================

-- ============================================================================
-- ESPACEMENT (16 tokens)
-- ============================================================================

-- Spacing scale (comme Tailwind CSS)
CREATE css_token_design:spacing_0 SET
  identity = { name = "--spacing-0", slug = "spacing-0" },
  category = css_token_category:spacing,
  value = "0",
  unit = "none",
  computed_value = "0",
  theme = theme:default,
  is_default = true,
  metadata = {
    description = "Aucun espacement",
    scale = "spacing",
    order = 0,
    compatibility = ["tailwind", "bootstrap", "material"]
  };

CREATE css_token_design:spacing_0_5 SET
  identity = { name = "--spacing-0.5", slug = "spacing-0-5" },
  category = css_token_category:spacing,
  value = "0.125",
  unit = "rem",
  computed_value = "0.125rem",
  theme = theme:default,
  is_default = true,
  metadata = {
    description = "Espacement minimal (2px)",
    scale = "spacing",
    order = 1,
    compatibility = ["tailwind", "bootstrap", "material"]
  };

CREATE css_token_design:spacing_1 SET
  identity = { name = "--spacing-1", slug = "spacing-1" },
  category = css_token_category:spacing,
  value = "0.25",
  unit = "rem",
  computed_value = "0.25rem",
  theme = theme:default,
  is_default = true,
  metadata = {
    description = "Espacement petit (4px)",
    scale = "spacing",
    order = 2,
    compatibility = ["tailwind", "bootstrap", "material"]
  };

CREATE css_token_design:spacing_1_5 SET
  identity = { name = "--spacing-1.5", slug = "spacing-1-5" },
  category = css_token_category:spacing,
  value = "0.375",
  unit = "rem",
  computed_value = "0.375rem",
  theme = theme:default,
  is_default = true,
  metadata = {
    description = "Espacement intermédiaire (6px)",
    scale = "spacing",
    order = 3,
    compatibility = ["tailwind", "bootstrap", "material"]
  };

CREATE css_token_design:spacing_2 SET
  identity = { name = "--spacing-2", slug = "spacing-2" },
  category = css_token_category:spacing,
  value = "0.5",
  unit = "rem",
  computed_value = "0.5rem",
  theme = theme:default,
  is_default = true,
  metadata = {
    description = "Espacement standard (8px)",
    scale = "spacing",
    order = 4,
    compatibility = ["tailwind", "bootstrap", "material"]
  };

CREATE css_token_design:spacing_2_5 SET
  identity = { name = "--spacing-2.5", slug = "spacing-2-5" },
  category = css_token_category:spacing,
  value = "0.625",
  unit = "rem",
  computed_value = "0.625rem",
  theme = theme:default,
  is_default = true,
  metadata = {
    description = "Espacement large (10px)",
    scale = "spacing",
    order = 5,
    compatibility = ["tailwind", "bootstrap", "material"]
  };

CREATE css_token_design:spacing_3 SET
  identity = { name = "--spacing-3", slug = "spacing-3" },
  category = css_token_category:spacing,
  value = "0.75",
  unit = "rem",
  computed_value = "0.75rem",
  theme = theme:default,
  is_default = true,
  metadata = {
    description = "Espacement moyen (12px)",
    scale = "spacing",
    order = 6,
    compatibility = ["tailwind", "bootstrap", "material"]
  };

CREATE css_token_design:spacing_4 SET
  identity = { name = "--spacing-4", slug = "spacing-4" },
  category = css_token_category:spacing,
  value = "1",
  unit = "rem",
  computed_value = "1rem",
  theme = theme:default,
  is_default = true,
  metadata = {
    description = "Espacement recommandé (16px)",
    scale = "spacing",
    order = 7,
    compatibility = ["tailwind", "bootstrap", "material"]
  };

CREATE css_token_design:spacing_5 SET
  identity = { name = "--spacing-5", slug = "spacing-5" },
  category = css_token_category:spacing,
  value = "1.25",
  unit = "rem",
  computed_value = "1.25rem",
  theme = theme:default,
  is_default = true,
  metadata = {
    description = "Espacement grand (20px)",
    scale = "spacing",
    order = 8,
    compatibility = ["tailwind", "bootstrap", "material"]
  };

CREATE css_token_design:spacing_6 SET
  identity = { name = "--spacing-6", slug = "spacing-6" },
  category = css_token_category:spacing,
  value = "1.5",
  unit = "rem",
  computed_value = "1.5rem",
  theme = theme:default,
  is_default = true,
  metadata = {
    description = "Espacement très grand (24px)",
    scale = "spacing",
    order = 9,
    compatibility = ["tailwind", "bootstrap", "material"]
  };

CREATE css_token_design:spacing_8 SET
  identity = { name = "--spacing-8", slug = "spacing-8" },
  category = css_token_category:spacing,
  value = "2",
  unit = "rem",
  computed_value = "2rem",
  theme = theme:default,
  is_default = true,
  metadata = {
    description = "Espacement double (32px)",
    scale = "spacing",
    order = 10,
    compatibility = ["tailwind", "bootstrap", "material"]
  };

CREATE css_token_design:spacing_10 SET
  identity = { name = "--spacing-10", slug = "spacing-10" },
  category = css_token_category:spacing,
  value = "2.5",
  unit = "rem",
  computed_value = "2.5rem",
  theme = theme:default,
  is_default = true,
  metadata = {
    description = "Espacement triple (40px)",
    scale = "spacing",
    order = 11,
    compatibility = ["tailwind", "bootstrap", "material"]
  };

CREATE css_token_design:spacing_12 SET
  identity = { name = "--spacing-12", slug = "spacing-12" },
  category = css_token_category:spacing,
  value = "3",
  unit = "rem",
  computed_value = "3rem",
  theme = theme:default,
  is_default = true,
  metadata = {
    description = "Espacement quadruple (48px)",
    scale = "spacing",
    order = 12,
    compatibility = ["tailwind", "bootstrap", "material"]
  };

CREATE css_token_design:spacing_16 SET
  identity = { name = "--spacing-16", slug = "spacing-16" },
  category = css_token_category:spacing,
  value = "4",
  unit = "rem",
  computed_value = "4rem",
  theme = theme:default,
  is_default = true,
  metadata = {
    description = "Espacement majeur (64px)",
    scale = "spacing",
    order = 13,
    compatibility = ["tailwind", "bootstrap", "material"]
  };

CREATE css_token_design:spacing_20 SET
  identity = { name = "--spacing-20", slug = "spacing-20" },
  category = css_token_category:spacing,
  value = "5",
  unit = "rem",
  computed_value = "5rem",
  theme = theme:default,
  is_default = true,
  metadata = {
    description = "Espacement énorme (80px)",
    scale = "spacing",
    order = 14,
    compatibility = ["tailwind", "bootstrap", "material"]
  };

CREATE css_token_design:spacing_24 SET
  identity = { name = "--spacing-24", slug = "spacing-24" },
  category = css_token_category:spacing,
  value = "6",
  unit = "rem",
  computed_value = "6rem",
  theme = theme:default,
  is_default = true,
  metadata = {
    description = "Espacement maximal (96px)",
    scale = "spacing",
    order = 15,
    compatibility = ["tailwind", "bootstrap", "material"]
  };

CREATE css_token_design:spacing_32 SET
  identity = { name = "--spacing-32", slug = "spacing-32" },
  category = css_token_category:spacing,
  value = "8",
  unit = "rem",
  computed_value = "8rem",
  theme = theme:default,
  is_default = true,
  metadata = {
    description = "Espacement extrême (128px)",
    scale = "spacing",
    order = 16,
    compatibility = ["tailwind", "bootstrap", "material"]
  };

-- ============================================================================
-- TYPOGRAPHIE (12 tokens)
-- ============================================================================

-- Tailles de police
CREATE css_token_design:font_size_xs SET
  identity = { name = "--font-size-xs", slug = "font-size-xs" },
  category = css_token_category:typography,
  subcategory = css_token_subcategory:font_size,
  value = "0.75",
  unit = "rem",
  computed_value = "0.75rem",
  theme = theme:default,
  is_default = true,
  metadata = {
    description = "Police extra petite (12px)",
    scale = "font-size",
    order = 1,
    compatibility = ["tailwind", "bootstrap", "material"]
  };

CREATE css_token_design:font_size_sm SET
  identity = { name = "--font-size-sm", slug = "font-size-sm" },
  category = css_token_category:typography,
  subcategory = css_token_subcategory:font_size,
  value = "0.875",
  unit = "rem",
  computed_value = "0.875rem",
  theme = theme:default,
  is_default = true,
  metadata = {
    description = "Police petite (14px)",
    scale = "font-size",
    order = 2,
    compatibility = ["tailwind", "bootstrap", "material"]
  };

CREATE css_token_design:font_size_base SET
  identity = { name = "--font-size-base", slug = "font-size-base" },
  category = css_token_category:typography,
  subcategory = css_token_subcategory:font_size,
  value = "1",
  unit = "rem",
  computed_value = "1rem",
  theme = theme:default,
  is_default = true,
  metadata = {
    description = "Police de base (16px)",
    scale = "font-size",
    order = 3,
    compatibility = ["tailwind", "bootstrap", "material"]
  };

CREATE css_token_design:font_size_lg SET
  identity = { name = "--font-size-lg", slug = "font-size-lg" },
  category = css_token_category:typography,
  subcategory = css_token_subcategory:font_size,
  value = "1.125",
  unit = "rem",
  computed_value = "1.125rem",
  theme = theme:default,
  is_default = true,
  metadata = {
    description = "Police large (18px)",
    scale = "font-size",
    order = 4,
    compatibility = ["tailwind", "bootstrap", "material"]
  };

CREATE css_token_design:font_size_xl SET
  identity = { name = "--font-size-xl", slug = "font-size-xl" },
  category = css_token_category:typography,
  subcategory = css_token_subcategory:font_size,
  value = "1.25",
  unit = "rem",
  computed_value = "1.25rem",
  theme = theme:default,
  is_default = true,
  metadata = {
    description = "Police extra large (20px)",
    scale = "font-size",
    order = 5,
    compatibility = ["tailwind", "bootstrap", "material"]
  };

CREATE css_token_design:font_size_2xl SET
  identity = { name = "--font-size-2xl", slug = "font-size-2xl" },
  category = css_token_category:typography,
  subcategory = css_token_subcategory:font_size,
  value = "1.5",
  unit = "rem",
  computed_value = "1.5rem",
  theme = theme:default,
  is_default = true,
  metadata = {
    description = "Police 2x large (24px)",
    scale = "font-size",
    order = 6,
    compatibility = ["tailwind", "bootstrap", "material"]
  };

CREATE css_token_design:font_size_3xl SET
  identity = { name = "--font-size-3xl", slug = "font-size-3xl" },
  category = css_token_category:typography,
  subcategory = css_token_subcategory:font_size,
  value = "1.875",
  unit = "rem",
  computed_value = "1.875rem",
  theme = theme:default,
  is_default = true,
  metadata = {
    description = "Police 3x large (30px)",
    scale = "font-size",
    order = 7,
    compatibility = ["tailwind", "bootstrap", "material"]
  };

CREATE css_token_design:font_size_4xl SET
  identity = { name = "--font-size-4xl", slug = "font-size-4xl" },
  category = css_token_category:typography,
  subcategory = css_token_subcategory:font_size,
  value = "2.25",
  unit = "rem",
  computed_value = "2.25rem",
  theme = theme:default,
  is_default = true,
  metadata = {
    description = "Police 4x large (36px)",
    scale = "font-size",
    order = 8,
    compatibility = ["tailwind", "bootstrap", "material"]
  };

-- Interligne
CREATE css_token_design:line_height_tight SET
  identity = { name = "--line-height-tight", slug = "line-height-tight" },
  category = css_token_category:typography,
  subcategory = "line-height",
  value = "1.25",
  unit = "none",
  computed_value = "1.25",
  theme = theme:default,
  is_default = true,
  metadata = {
    description = "Interligne serré",
    scale = "line-height",
    order = 1,
    compatibility = ["tailwind", "bootstrap", "material"]
  };

CREATE css_token_design:line_height_snug SET
  identity = { name = "--line-height-snug", slug = "line-height-snug" },
  category = css_token_category:typography,
  subcategory = "line-height",
  value = "1.375",
  unit = "none",
  computed_value = "1.375",
  theme = theme:default,
  is_default = true,
  metadata = {
    description = "Interligne compact",
    scale = "line-height",
    order = 2,
    compatibility = ["tailwind", "bootstrap", "material"]
  };

CREATE css_token_design:line_height_normal SET
  identity = { name = "--line-height-normal", slug = "line-height-normal" },
  category = css_token_category:typography,
  subcategory = "line-height",
  value = "1.5",
  unit = "none",
  computed_value = "1.5",
  theme = theme:default,
  is_default = true,
  metadata = {
    description = "Interligne normal",
    scale = "line-height",
    order = 3,
    compatibility = ["tailwind", "bootstrap", "material"]
  };

CREATE css_token_design:line_height_relaxed SET
  identity = { name = "--line-height-relaxed", slug = "line-height-relaxed" },
  category = css_token_category:typography,
  subcategory = "line-height",
  value = "1.625",
  unit = "none",
  computed_value = "1.625",
  theme = theme:default,
  is_default = true,
  metadata = {
    description = "Interligne aéré",
    scale = "line-height",
    order = 4,
    compatibility = ["tailwind", "bootstrap", "material"]
  };

-- Poids de police
CREATE css_token_design:font_weight_light SET
  identity = { name = "--font-weight-light", slug = "font-weight-light" },
  category = css_token_category:typography,
  subcategory = "font-weight",
  value = "300",
  unit = "none",
  computed_value = "300",
  theme = theme:default,
  is_default = true,
  metadata = {
    description = "Police fine",
    scale = "font-weight",
    order = 1,
    compatibility = ["tailwind", "bootstrap", "material"]
  };

CREATE css_token_design:font_weight_normal SET
  identity = { name = "--font-weight-normal", slug = "font-weight-normal" },
  category = css_token_category:typography,
  subcategory = "font-weight",
  value = "400",
  unit = "none",
  computed_value = "400",
  theme = theme:default,
  is_default = true,
  metadata = {
    description = "Police normale",
    scale = "font-weight",
    order = 2,
    compatibility = ["tailwind", "bootstrap", "material"]
  };

CREATE css_token_design:font_weight_medium SET
  identity = { name = "--font-weight-medium", slug = "font-weight-medium" },
  category = css_token_category:typography,
  subcategory = "font-weight",
  value = "500",
  unit = "none",
  computed_value = "500",
  theme = theme:default,
  is_default = true,
  metadata = {
    description = "Police moyenne",
    scale = "font-weight",
    order = 3,
    compatibility = ["tailwind", "bootstrap", "material"]
  };

CREATE css_token_design:font_weight_semibold SET
  identity = { name = "--font-weight-semibold", slug = "font-weight-semibold" },
  category = css_token_category:typography,
  subcategory = "font-weight",
  value = "600",
  unit = "none",
  computed_value = "600",
  theme = theme:default,
  is_default = true,
  metadata = {
    description = "Police demi-grasse",
    scale = "font-weight",
    order = 4,
    compatibility = ["tailwind", "bootstrap", "material"]
  };

CREATE css_token_design:font_weight_bold SET
  identity = { name = "--font-weight-bold", slug = "font-weight-bold" },
  category = css_token_category:typography,
  subcategory = "font-weight",
  value = "700",
  unit = "none",
  computed_value = "700",
  theme = theme:default,
  is_default = true,
  metadata = {
    description = "Police grasse",
    scale = "font-weight",
    order = 5,
    compatibility = ["tailwind", "bootstrap", "material"]
  };

-- ============================================================================
-- LAYOUT (10 tokens)
-- ============================================================================

-- Border radius
CREATE css_token_design:border_radius_none SET
  identity = { name = "--border-radius-none", slug = "border-radius-none" },
  category = css_token_category:layout,
  subcategory = "border-radius",
  value = "0",
  unit = "none",
  computed_value = "0",
  theme = theme:default,
  is_default = true,
  metadata = {
    description = "Bordures carrées",
    scale = "border-radius",
    order = 1,
    compatibility = ["tailwind", "bootstrap", "material"]
  };

CREATE css_token_design:border_radius_sm SET
  identity = { name = "--border-radius-sm", slug = "border-radius-sm" },
  category = css_token_category:layout,
  subcategory = "border-radius",
  value = "0.125",
  unit = "rem",
  computed_value = "0.125rem",
  theme = theme:default,
  is_default = true,
  metadata = {
    description = "Bordures légèrement arrondies (2px)",
    scale = "border-radius",
    order = 2,
    compatibility = ["tailwind", "bootstrap", "material"]
  };

CREATE css_token_design:border_radius_md SET
  identity = { name = "--border-radius-md", slug = "border-radius-md" },
  category = css_token_category:layout,
  subcategory = "border-radius",
  value = "0.375",
  unit = "rem",
  computed_value = "0.375rem",
  theme = theme:default,
  is_default = true,
  metadata = {
    description = "Bordures moyennement arrondies (6px)",
    scale = "border-radius",
    order = 3,
    compatibility = ["tailwind", "bootstrap", "material"]
  };

CREATE css_token_design:border_radius_lg SET
  identity = { name = "--border-radius-lg", slug = "border-radius-lg" },
  category = css_token_category:layout,
  subcategory = "border-radius",
  value = "0.5",
  unit = "rem",
  computed_value = "0.5rem",
  theme = theme:default,
  is_default = true,
  metadata = {
    description = "Bordures bien arrondies (8px)",
    scale = "border-radius",
    order = 4,
    compatibility = ["tailwind", "bootstrap", "material"]
  };

CREATE css_token_design:border_radius_xl SET
  identity = { name = "--border-radius-xl", slug = "border-radius-xl" },
  category = css_token_category:layout,
  subcategory = "border-radius",
  value = "0.75",
  unit = "rem",
  computed_value = "0.75rem",
  theme = theme:default,
  is_default = true,
  metadata = {
    description = "Bordures très arrondies (12px)",
    scale = "border-radius",
    order = 5,
    compatibility = ["tailwind", "bootstrap", "material"]
  };

CREATE css_token_design:border_radius_2xl SET
  identity = { name = "--border-radius-2xl", slug = "border-radius-2xl" },
  category = css_token_category:layout,
  subcategory = "border-radius",
  value = "1",
  unit = "rem",
  computed_value = "1rem",
  theme = theme:default,
  is_default = true,
  metadata = {
    description = "Bordures extra arrondies (16px)",
    scale = "border-radius",
    order = 6,
    compatibility = ["tailwind", "bootstrap", "material"]
  };

CREATE css_token_design:border_radius_full SET
  identity = { name = "--border-radius-full", slug = "border-radius-full" },
  category = css_token_category:layout,
  subcategory = "border-radius",
  value = "9999",
  unit = "px",
  computed_value = "9999px",
  theme = theme:default,
  is_default = true,
  metadata = {
    description = "Bordures complètement rondes",
    scale = "border-radius",
    order = 7,
    compatibility = ["tailwind", "bootstrap", "material"]
  };

-- Box shadow
CREATE css_token_design:box_shadow_sm SET
  identity = { name = "--box-shadow-sm", slug = "box-shadow-sm" },
  category = css_token_category:layout,
  subcategory = "box-shadow",
  value = "0 1px 2px 0 rgb(0 0 0 / 0.05)",
  unit = "none",
  computed_value = "0 1px 2px 0 rgb(0 0 0 / 0.05)",
  theme = theme:default,
  is_default = true,
  metadata = {
    description = "Ombre petite",
    scale = "box-shadow",
    order = 1,
    compatibility = ["tailwind", "bootstrap", "material"]
  };

CREATE css_token_design:box_shadow_md SET
  identity = { name = "--box-shadow-md", slug = "box-shadow-md" },
  category = css_token_category:layout,
  subcategory = "box-shadow",
  value = "0 4px 6px -1px rgb(0 0 0 / 0.1)",
  unit = "none",
  computed_value = "0 4px 6px -1px rgb(0 0 0 / 0.1)",
  theme = theme:default,
  is_default = true,
  metadata = {
    description = "Ombre moyenne",
    scale = "box-shadow",
    order = 2,
    compatibility = ["tailwind", "bootstrap", "material"]
  };

CREATE css_token_design:box_shadow_lg SET
  identity = { name = "--box-shadow-lg", slug = "box-shadow-lg" },
  category = css_token_category:layout,
  subcategory = "box-shadow",
  value = "0 10px 15px -3px rgb(0 0 0 / 0.1)",
  unit = "none",
  computed_value = "0 10px 15px -3px rgb(0 0 0 / 0.1)",
  theme = theme:default,
  is_default = true,
  metadata = {
    description = "Ombre large",
    scale = "box-shadow",
    order = 3,
    compatibility = ["tailwind", "bootstrap", "material"]
  };

CREATE css_token_design:box_shadow_xl SET
  identity = { name = "--box-shadow-xl", slug = "box-shadow-xl" },
  category = css_token_category:layout,
  subcategory = "box-shadow",
  value = "0 20px 25px -5px rgb(0 0 0 / 0.1)",
  unit = "none",
  computed_value = "0 20px 25px -5px rgb(0 0 0 / 0.1)",
  theme = theme:default,
  is_default = true,
  metadata = {
    description = "Ombre extra large",
    scale = "box-shadow",
    order = 4,
    compatibility = ["tailwind", "bootstrap", "material"]
  };

-- Border width
CREATE css_token_design:border_width_0 SET
  identity = { name = "--border-width-0", slug = "border-width-0" },
  category = css_token_category:layout,
  subcategory = "border-width",
  value = "0",
  unit = "none",
  computed_value = "0",
  theme = theme:default,
  is_default = true,
  metadata = {
    description = "Pas de bordure",
    scale = "border-width",
    order = 1,
    compatibility = ["tailwind", "bootstrap", "material"]
  };

CREATE css_token_design:border_width_1 SET
  identity = { name = "--border-width-1", slug = "border-width-1" },
  category = css_token_category:layout,
  subcategory = "border-width",
  value = "1",
  unit = "px",
  computed_value = "1px",
  theme = theme:default,
  is_default = true,
  metadata = {
    description = "Bordure fine",
    scale = "border-width",
    order = 2,
    compatibility = ["tailwind", "bootstrap", "material"]
  };

CREATE css_token_design:border_width_2 SET
  identity = { name = "--border-width-2", slug = "border-width-2" },
  category = css_token_category:layout,
  subcategory = "border-width",
  value = "2",
  unit = "px",
  computed_value = "2px",
  theme = theme:default,
  is_default = true,
  metadata = {
    description = "Bordure moyenne",
    scale = "border-width",
    order = 3,
    compatibility = ["tailwind", "bootstrap", "material"]
  };

CREATE css_token_design:border_width_4 SET
  identity = { name = "--border-width-4", slug = "border-width-4" },
  category = css_token_category:layout,
  subcategory = "border-width",
  value = "4",
  unit = "px",
  computed_value = "4px",
  theme = theme:default,
  is_default = true,
  metadata = {
    description = "Bordure épaisse",
    scale = "border-width",
    order = 4,
    compatibility = ["tailwind", "bootstrap", "material"]
  };

-- ============================================================================
-- COMPOSANTS (15 tokens)
-- ============================================================================

-- Boutons
CREATE css_token_design:btn_height_sm SET
  identity = { name = "--btn-height-sm", slug = "btn-height-sm" },
  category = css_token_category:component,
  subcategory = "height",
  value = "2",
  unit = "rem",
  computed_value = "2rem",
  theme = theme:default,
  is_default = true,
  metadata = {
    description = "Hauteur bouton petit (32px)",
    scale = "btn-height",
    order = 1,
    compatibility = ["tailwind", "bootstrap", "material"]
  };

CREATE css_token_design:btn_height_md SET
  identity = { name = "--btn-height-md", slug = "btn-height-md" },
  category = css_token_category:component,
  subcategory = "height",
  value = "2.5",
  unit = "rem",
  computed_value = "2.5rem",
  theme = theme:default,
  is_default = true,
  metadata = {
    description = "Hauteur bouton moyen (40px)",
    scale = "btn-height",
    order = 2,
    compatibility = ["tailwind", "bootstrap", "material"]
  };

CREATE css_token_design:btn_height_lg SET
  identity = { name = "--btn-height-lg", slug = "btn-height-lg" },
  category = css_token_category:component,
  subcategory = "height",
  value = "3",
  unit = "rem",
  computed_value = "3rem",
  theme = theme:default,
  is_default = true,
  metadata = {
    description = "Hauteur bouton large (48px)",
    scale = "btn-height",
    order = 3,
    compatibility = ["tailwind", "bootstrap", "material"]
  };

CREATE css_token_design:btn_padding_x SET
  identity = { name = "--btn-padding-x", slug = "btn-padding-x" },
  category = css_token_category:component,
  subcategory = "padding",
  value = "1",
  unit = "rem",
  computed_value = "1rem",
  theme = theme:default,
  is_default = true,
  metadata = {
    description = "Padding horizontal bouton (16px)",
    scale = "btn-padding",
    order = 1,
    compatibility = ["tailwind", "bootstrap", "material"]
  };

CREATE css_token_design:btn_font_size SET
  identity = { name = "--btn-font-size", slug = "btn-font-size" },
  category = css_token_category:component,
  subcategory = css_token_subcategory:font_size,
  value = "0.875",
  unit = "rem",
  computed_value = "0.875rem",
  theme = theme:default,
  is_default = true,
  metadata = {
    description = "Taille police bouton (14px)",
    scale = "btn-font-size",
    order = 1,
    compatibility = ["tailwind", "bootstrap", "material"]
  };

-- Formulaires
CREATE css_token_design:input_height SET
  identity = { name = "--input-height", slug = "input-height" },
  category = css_token_category:component,
  subcategory = "height",
  value = "2.5",
  unit = "rem",
  computed_value = "2.5rem",
  theme = theme:default,
  is_default = true,
  metadata = {
    description = "Hauteur input (40px)",
    scale = "input-height",
    order = 1,
    compatibility = ["tailwind", "bootstrap", "material"]
  };

CREATE css_token_design:input_padding_x SET
  identity = { name = "--input-padding-x", slug = "input-padding-x" },
  category = css_token_category:component,
  subcategory = "padding",
  value = "0.75",
  unit = "rem",
  computed_value = "0.75rem",
  theme = theme:default,
  is_default = true,
  metadata = {
    description = "Padding horizontal input (12px)",
    scale = "input-padding",
    order = 1,
    compatibility = ["tailwind", "bootstrap", "material"]
  };

CREATE css_token_design:input_border_width SET
  identity = { name = "--input-border-width", slug = "input-border-width" },
  category = css_token_category:component,
  subcategory = "border-width",
  value = "1",
  unit = "px",
  computed_value = "1px",
  theme = theme:default,
  is_default = true,
  metadata = {
    description = "Épaisseur bordure input",
    scale = "input-border",
    order = 1,
    compatibility = ["tailwind", "bootstrap", "material"]
  };

CREATE css_token_design:input_border_radius SET
  identity = { name = "--input-border-radius", slug = "input-border-radius" },
  category = css_token_category:component,
  subcategory = "border-radius",
  value = "0.375",
  unit = "rem",
  computed_value = "0.375rem",
  theme = theme:default,
  is_default = true,
  metadata = {
    description = "Arrondi bordure input (6px)",
    scale = "input-border",
    order = 1,
    compatibility = ["tailwind", "bootstrap", "material"]
  };

-- Cartes
CREATE css_token_design:card_padding SET
  identity = { name = "--card-padding", slug = "card-padding" },
  category = css_token_category:component,
  subcategory = "padding",
  value = "1.5",
  unit = "rem",
  computed_value = "1.5rem",
  theme = theme:default,
  is_default = true,
  metadata = {
    description = "Padding carte (24px)",
    scale = "card-padding",
    order = 1,
    compatibility = ["tailwind", "bootstrap", "material"]
  };

CREATE css_token_design:card_border_radius SET
  identity = { name = "--card-border-radius", slug = "card-border-radius" },
  category = css_token_category:component,
  subcategory = "border-radius",
  value = "0.5",
  unit = "rem",
  computed_value = "0.5rem",
  theme = theme:default,
  is_default = true,
  metadata = {
    description = "Arrondi carte (8px)",
    scale = "card-border",
    order = 1,
    compatibility = ["tailwind", "bootstrap", "material"]
  };

CREATE css_token_design:card_box_shadow SET
  identity = { name = "--card-box-shadow", slug = "card-box-shadow" },
  category = css_token_category:component,
  subcategory = "box-shadow",
  value = "0 1px 3px 0 rgb(0 0 0 / 0.1)",
  unit = "none",
  computed_value = "0 1px 3px 0 rgb(0 0 0 / 0.1)",
  theme = theme:default,
  is_default = true,
  metadata = {
    description = "Ombre carte",
    scale = "card-shadow",
    order = 1,
    compatibility = ["tailwind", "bootstrap", "material"]
  };

-- ============================================================================
-- UTILITAIRES (8 tokens)
-- ============================================================================

-- Animations
CREATE css_token_design:animation_duration_fast SET
  identity = { name = "--animation-duration-fast", slug = "animation-duration-fast" },
  category = css_token_category:utility,
  subcategory = "animation-duration",
  value = "150",
  unit = "ms",
  computed_value = "150ms",
  theme = theme:default,
  is_default = true,
  metadata = {
    description = "Animation rapide",
    scale = "animation-duration",
    order = 1,
    compatibility = ["tailwind", "bootstrap", "material"]
  };

CREATE css_token_design:animation_duration_normal SET
  identity = { name = "--animation-duration-normal", slug = "animation-duration-normal" },
  category = css_token_category:utility,
  subcategory = "animation-duration",
  value = "300",
  unit = "ms",
  computed_value = "300ms",
  theme = theme:default,
  is_default = true,
  metadata = {
    description = "Animation normale",
    scale = "animation-duration",
    order = 2,
    compatibility = ["tailwind", "bootstrap", "material"]
  };

CREATE css_token_design:animation_duration_slow SET
  identity = { name = "--animation-duration-slow", slug = "animation-duration-slow" },
  category = css_token_category:utility,
  subcategory = "animation-duration",
  value = "500",
  unit = "ms",
  computed_value = "500ms",
  theme = theme:default,
  is_default = true,
  metadata = {
    description = "Animation lente",
    scale = "animation-duration",
    order = 3,
    compatibility = ["tailwind", "bootstrap", "material"]
  };

-- Z-index
CREATE css_token_design:z_index_dropdown SET
  identity = { name = "--z-index-dropdown", slug = "z-index-dropdown" },
  category = css_token_category:utility,
  subcategory = "z-index",
  value = "1000",
  unit = "none",
  computed_value = "1000",
  theme = theme:default,
  is_default = true,
  metadata = {
    description = "Z-index pour dropdowns",
    scale = "z-index",
    order = 1,
    compatibility = ["tailwind", "bootstrap", "material"]
  };

CREATE css_token_design:z_index_sticky SET
  identity = { name = "--z-index-sticky", slug = "z-index-sticky" },
  category = css_token_category:utility,
  subcategory = "z-index",
  value = "1020",
  unit = "none",
  computed_value = "1020",
  theme = theme:default,
  is_default = true,
  metadata = {
    description = "Z-index pour éléments sticky",
    scale = "z-index",
    order = 2,
    compatibility = ["tailwind", "bootstrap", "material"]
  };

CREATE css_token_design:z_index_fixed SET
  identity = { name = "--z-index-fixed", slug = "z-index-fixed" },
  category = css_token_category:utility,
  subcategory = "z-index",
  value = "1030",
  unit = "none",
  computed_value = "1030",
  theme = theme:default,
  is_default = true,
  metadata = {
    description = "Z-index pour éléments fixed",
    scale = "z-index",
    order = 3,
    compatibility = ["tailwind", "bootstrap", "material"]
  };

CREATE css_token_design:z_index_modal SET
  identity = { name = "--z-index-modal", slug = "z-index-modal" },
  category = css_token_category:utility,
  subcategory = "z-index",
  value = "1040",
  unit = "none",
  computed_value = "1040",
  theme = theme:default,
  is_default = true,
  metadata = {
    description = "Z-index pour modales",
    scale = "z-index",
    order = 4,
    compatibility = ["tailwind", "bootstrap", "material"]
  };

CREATE css_token_design:z_index_popover SET
  identity = { name = "--z-index-popover", slug = "z-index-popover" },
  category = css_token_category:utility,
  subcategory = "z-index",
  value = "1050",
  unit = "none",
  computed_value = "1050",
  theme = theme:default,
  is_default = true,
  metadata = {
    description = "Z-index pour popovers/tooltips",
    scale = "z-index",
    order = 5,
    compatibility = ["tailwind", "bootstrap", "material"]
  };

-- ============================================================================
-- VÉRIFICATIONS
-- ============================================================================

-- Vérifier le nombre total de tokens créés
-- SELECT count() FROM css_design_token WHERE theme = theme:default;
-- Résultat attendu : 61

-- Lister les tokens par catégorie
-- SELECT category, count() FROM css_design_token WHERE theme = theme:default GROUP BY category;
-- Résultats attendus :
-- spacing: 16
-- typography: 12
-- layout: 10
-- component: 15
-- utility: 8

-- Vérifier l'unicité des noms
-- SELECT count() FROM css_design_token WHERE theme = theme:default GROUP BY identity.name HAVING count() > 1;
-- Résultat attendu : 0 (pas de doublons)
