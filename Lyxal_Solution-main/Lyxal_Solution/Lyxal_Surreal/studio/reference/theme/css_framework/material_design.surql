-- ============================================================================
-- FRAMEWORK : Material Design
-- Description : Framework CSS basé sur les guidelines Material Design de Google
-- Status : Framework alternatif, actif
-- ============================================================================

BEGIN;

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
-- I18N KEYS FOR MATERIAL DESIGN
-- ============================================================================

-- Nom du framework Material Design
CREATE i18n_key:framework_material_name SET
  context = "css_framework",
  description = "Nom d'affichage du framework Material Design";

-- Description du framework Material Design
CREATE i18n_key:framework_material_description SET
  context = "css_framework",
  description = "Description détaillée du framework Material Design";


-- ============================================================================
-- I18N TRANSLATIONS FOR MATERIAL DESIGN
-- ============================================================================

-- Translation du nom du framework Material Design
RELATE i18n_key:framework_material_name->translation->language:fr SET text = "Material Design";
RELATE i18n_key:framework_material_name->translation->language:en SET text = "Material Design";
RELATE i18n_key:framework_material_name->translation->language:it SET text = "Material Design";
RELATE i18n_key:framework_material_name->translation->language:es SET text = "Material Design";
RELATE i18n_key:framework_material_name->translation->language:de SET text = "Material Design";

-- Translation de la description du framework Material Design
RELATE i18n_key:framework_material_description->translation->language:de SET text = "Framework basierend auf Googles Material Design Richtlinien";
RELATE i18n_key:framework_material_description->translation->language:es SET text = "Framework basado en las directrices de Material Design de Google";
RELATE i18n_key:framework_material_description->translation->language:it SET text = "Framework basato sulle linee guida Material Design di Google";
RELATE i18n_key:framework_material_description->translation->language:en SET text = "Framework based on Google's Material Design guidelines";
RELATE i18n_key:framework_material_description->translation->language:fr SET text = "Framework basé sur les guidelines Material Design de Google";

-- ============================================================================
-- ICONS FOR MATERIAL DESIGN
-- ============================================================================

-- Icône Material Design - Mode clair
-- CREATE icon:material_icon_light SET
--   identity = {
--     name = "Material Design Light",
--     slug = "material-light",
--     provider = "bunny"
--   },
--   urls = {
--     original = url:material_icon_light_original,
--     webp = url:material_icon_light_webp,
--     avif = url:material_icon_light_avif
--   },
--   metadata = {
--     category = "framework",
--     tags = ["css", "material", "design", "google", "framework", "light"],
--     width = 64,
--     height = 64,
--     format = "svg"
--   };

-- Icône Material Design - Mode sombre
-- CREATE icon:material_icon_dark SET
--   identity = {
--     name = "Material Design Dark",
--     slug = "material-dark",
--     provider = "bunny"
--   },
--   urls = {
--     original = url:material_icon_dark_original,
--     webp = url:material_icon_dark_webp,
--     avif = url:material_icon_dark_avif
--   },
--   metadata = {
--     category = "framework",
--     tags = ["css", "material", "design", "google", "framework", "dark"],
--     width = 64,
--     height = 64,
--     format = "svg"
--   };

-- ============================================================================
-- URLs FOR MATERIAL DESIGN
-- ============================================================================

-- CDN CSS Material Design
-- CREATE url:material_css_cdn SET
--   value = "https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined",
--   provider = "google_fonts",
--   type = "cdn",
--   category = "css_framework",
--   metadata = {
--     framework = "material_design",
--     type = "icons"
--   };

-- CDN JS Material Design
-- CREATE url:material_js_cdn SET
--   value = "https://unpkg.com/material-components-web@14.0.0/dist/material-components-web.min.js",
--   provider = "unpkg",
--   type = "cdn",
--   category = "javascript_framework",
--   metadata = {
--     framework = "material_design",
--     version = "14.0.0"
--   };

-- Police Roboto (requis pour Material Design)
-- CREATE url:roboto_font SET
--   value = "https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap",
--   provider = "google_fonts",
--   type = "font",
--   category = "typography",
--   metadata = {
--     framework = "material_design",
--     font_family = "Roboto"
--   };

-- Site officiel Material Design
-- CREATE url:material_official SET
--   value = "https://material.io/design",
--   provider = "google",
--   type = "official",
--   category = "documentation",
--   metadata = {
--     framework = "material_design",
--     language = "en"
--   };

-- Documentation Material Design
-- CREATE url:material_docs SET
--   value = "https://material.io/develop",
--   provider = "google",
--   type = "documentation",
--   category = "documentation",
--   metadata = {
--     framework = "material_design",
--     language = "en"
--   };

-- GitHub Material Components Web
-- CREATE url:material_github SET
--   value = "https://github.com/material-components/material-components-web",
--   provider = "github",
--   type = "source",
--   category = "source_code",
--   metadata = {
--     framework = "material_design",
--     platform = "github"
--   };

-- ============================================================================
-- URLs FOR MATERIAL DESIGN
-- ============================================================================

-- Icône Material Design Light - Original
-- CREATE url:material_icon_light_original SET
--   value = "https://cdn.bunny.net/frameworks/material/light/icon.svg",
--   provider = "bunny",
--   type = "icon",
--   category = "framework_icon",
--   metadata = {
--     framework = "material_design",
--     theme = "light",
--     format = "svg",
--     optimized = true
--   };

-- Icône Material Design Light - WebP
-- CREATE url:material_icon_light_webp SET
--   value = "https://cdn.bunny.net/frameworks/material/light/icon.webp",
--   provider = "bunny",
--   type = "icon",
--   category = "framework_icon",
--   metadata = {
--     framework = "material_design",
--     theme = "light",
--     format = "webp",
--     optimized = true
--   };

-- Icône Material Design Light - AVIF
-- CREATE url:material_icon_light_avif SET
--   value = "https://cdn.bunny.net/frameworks/material/light/icon.avif",
--   provider = "bunny",
--   type = "icon",
--   category = "framework_icon",
--   metadata = {
--     framework = "material_design",
--     theme = "light",
--     format = "avif",
--     optimized = true
--   };

-- Icône Material Design Dark - Original
-- CREATE url:material_icon_dark_original SET
--   value = "https://cdn.bunny.net/frameworks/material/dark/icon.svg",
--   provider = "bunny",
--   type = "icon",
--   category = "framework_icon",
--   metadata = {
--     framework = "material_design",
--     theme = "dark",
--     format = "svg",
--     optimized = true
--   };

-- Icône Material Design Dark - WebP
-- CREATE url:material_icon_dark_webp SET
--   value = "https://cdn.bunny.net/frameworks/material/dark/icon.webp",
--   provider = "bunny",
--   type = "icon",
--   category = "framework_icon",
--   metadata = {
--     framework = "material_design",
--     theme = "dark",
--     format = "webp",
--     optimized = true
--   };

-- Icône Material Design Dark - AVIF
-- CREATE url:material_icon_dark_avif SET
--   value = "https://cdn.bunny.net/frameworks/material/dark/icon.avif",
--   provider = "bunny",
--   type = "icon",
--   category = "framework_icon",
--   metadata = {
--     framework = "material_design",
--     theme = "dark",
--     format = "avif",
--     optimized = true
--   };

COMMIT;

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
