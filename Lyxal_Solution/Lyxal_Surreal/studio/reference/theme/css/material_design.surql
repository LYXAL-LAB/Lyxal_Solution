-- ============================================================================
-- FRAMEWORK : Material Design
-- Description : Framework CSS basé sur les guidelines Material Design de Google
-- Status : Framework alternatif, actif
-- ============================================================================

-- Création du framework Material Design
CREATE css_framework:material_design SET
  identity = {
    value = "material_design",
    slug = "material-design"
  },

  presentation = {
    name_i18n = i18n_key:framework_material_name,
    description_i18n = i18n_key:framework_material_description,
    icon_light = icon:material_icon_light,
    icon_dark = icon:material_icon_dark
  },

  config = {
    type = "component_based",
    default_config = {
      theme = {
        primary = "#6200ee",
        secondary = "#03dac6",
        surface = "#ffffff",
        background = "#fafafa"
      },
      typography = {
        font_family = "Roboto, sans-serif",
        font_size = "14px"
      },
      shape = {
        border_radius = "4px"
      }
    },
    supported_features = ["dark_mode", "responsive", "animations", "custom_colors", "elevation", "typography"],
    version = "14.0.0",
    dependencies = {
      css_urls = [url:material_css_cdn],
      js_urls = [url:material_js_cdn],
      font_urls = [url:roboto_font]
    }
  },

  documentation = {
    official_url = url:material_official,
    docs_url = url:material_docs,
    github_url = url:material_github
  },

  status = {
    is_active = true,
    is_default = false,
    source = "system"
  },

  metadata = {
    order = 3,
    notes = "Framework basé sur les Material Design guidelines de Google. Excellent pour les applications enterprise avec une identité visuelle cohérente.",
    examples = [
      {
        title = "Bouton elevated",
        description = "Bouton avec élévation Material Design",
        code = "mdc-button mdc-button--raised"
      },
      {
        title = "Carte Material",
        description = "Carte avec ombres Material",
        code = "mdc-card mdc-card--outlined"
      },
      {
        title = "Champ de texte",
        description = "Input Material Design",
        code = "mdc-text-field mdc-text-field--outlined"
      }
    ]
  };

-- ============================================================================
-- EXEMPLES D'UTILISATION
-- ============================================================================

-- Récupérer Material Design
-- SELECT * FROM css_framework WHERE identity.value = "material_design";

-- Lister les frameworks avec support de l'élévation
-- SELECT identity.value FROM css_framework
-- WHERE config.supported_features CONTAINS "elevation";

-- Obtenir la configuration typographique
-- SELECT config.default_config.typography FROM css_framework
-- WHERE identity.value = "material_design";
