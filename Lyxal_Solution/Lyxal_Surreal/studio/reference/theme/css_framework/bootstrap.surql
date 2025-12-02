-- ============================================================================
-- FRAMEWORK : Bootstrap CSS
-- Description : Framework CSS component-based populaire
-- Status : Framework alternatif, actif
-- ============================================================================

BEGIN;

-- Création du framework Bootstrap CSS
CREATE css_framework:bootstrap SET
  identity = {
    value = "bootstrap",
    slug = "bootstrap"
  },

  presentation = {
    name_i18n = i18n_key:framework_bootstrap_name,
    description_i18n = i18n_key:framework_bootstrap_description,
    icon_light = icon:bootstrap_icon_light,
    icon_dark = icon:bootstrap_icon_dark
  },

  config = {
    type = "component_based",
    default_config = {
      breakpoints = ["xs", "sm", "md", "lg", "xl", "xxl"],
      container_max_widths = {
        sm = "540px",
        md = "720px",
        lg = "960px",
        xl = "1140px",
        xxl = "1320px"
      }
    },
    supported_features = ["dark_mode", "responsive", "animations", "custom_colors", "hover", "focus", "javascript_components"],
    version = "5.3.0",
    dependencies = {
      css_urls = [url:bootstrap_css_cdn],
      js_urls = [url:bootstrap_js_cdn],
      font_urls = []
    }
  },

  documentation = {
    official_url = url:bootstrap_official,
    docs_url = url:bootstrap_docs,
    github_url = url:bootstrap_github
  },

  status = {
    is_active = true,
    is_default = false,
    source = "system"
  },

  metadata = {
    order = 2,
    notes = "Framework component-based avec JavaScript inclus. Bon choix pour les projets nécessitant des composants interactifs prêts à l'emploi.",
    examples = [
      {
        title = "Bouton primaire",
        description = "Style de bouton primaire avec Bootstrap",
        code = "btn btn-primary"
      },
      {
        title = "Carte avec contenu",
        description = "Carte stylée avec Bootstrap",
        code = "card shadow-sm"
      },
      {
        title = "Grille responsive",
        description = "Système de grille Bootstrap",
        code = "row g-3"
      }
    ]
  };


-- ============================================================================
-- I18N KEYS FOR BOOTSTRAP CSS
-- ============================================================================

-- Nom du framework Bootstrap
CREATE i18n_key:framework_bootstrap_name SET
  context = "css_framework",
  description = "Nom d'affichage du framework Bootstrap CSS";

-- Description du framework Bootstrap
CREATE i18n_key:framework_bootstrap_description SET
  context = "css_framework",
  description = "Description détaillée du framework Bootstrap CSS";

-- ============================================================================
-- I18N TRANSLATIONS FOR BOOTSTRAP CSS
-- ============================================================================

-- Translation du nom du framework Bootstrap
RELATE i18n_key:framework_bootstrap_name->translation->language:fr SET text = "Bootstrap";
RELATE i18n_key:framework_bootstrap_name->translation->language:en SET text = "Bootstrap";
RELATE i18n_key:framework_bootstrap_name->translation->language:it SET text = "Bootstrap";
RELATE i18n_key:framework_bootstrap_name->translation->language:es SET text = "Bootstrap";
RELATE i18n_key:framework_bootstrap_name->translation->language:de SET text = "Bootstrap";

-- Translation de la description du framework Bootstrap
RELATE i18n_key:framework_bootstrap_description->translation->language:en SET text = "Popular component-based CSS framework with JavaScript";
RELATE i18n_key:framework_bootstrap_description->translation->language:fr SET text = "Framework CSS component-based populaire avec JavaScript";
RELATE i18n_key:framework_bootstrap_description->translation->language:it SET text = "Framework CSS basato su componenti popolare con JavaScript";
RELATE i18n_key:framework_bootstrap_description->translation->language:es SET text = "Framework CSS basado en componentes popular con JavaScript";
RELATE i18n_key:framework_bootstrap_description->translation->language:de SET text = "Beliebtes komponentenbasiertes CSS Framework mit JavaScript";



-- ============================================================================
-- BOOTSTRAP CSS ICONS A IMPLEMENTER
-- ============================================================================

-- Icône Bootstrap - Mode clair
-- CREATE icon:bootstrap_icon_light SET
--   identity = {
--     name = "Bootstrap CSS Light",
--     slug = "bootstrap-light",
--     provider = "bunny"
--   },
--   urls = {
--     original = url:bootstrap_icon_light_original,
--     webp = url:bootstrap_icon_light_webp,
--     avif = url:bootstrap_icon_light_avif
--   },
--   metadata = {
--     category = "framework",
--     tags = ["css", "bootstrap", "framework", "light"],
--     width = 64,
--     height = 64,
--     format = "svg"
--   };

-- Icône Bootstrap - Mode sombre
-- CREATE icon:bootstrap_icon_dark SET
--   identity = {
--     name = "Bootstrap CSS Dark",
--     slug = "bootstrap-dark",
--     provider = "bunny"
--   },
--   urls = {
--     original = url:bootstrap_icon_dark_original,
--     webp = url:bootstrap_icon_dark_webp,
--     avif = url:bootstrap_icon_dark_avif
--   },
--   metadata = {
--     category = "framework",
--     tags = ["css", "bootstrap", "framework", "dark"],
--     width = 64,
--     height = 64,
--     format = "svg"
--   };

-- ============================================================================
-- BOOTSTRAP CSS - URLs
-- ============================================================================

-- CDN CSS Bootstrap
-- CREATE url:bootstrap_css_cdn SET
--   value = "https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css",
--   provider = "jsdelivr",
--   type = "cdn",
--   category = "css_framework",
--   metadata = {
--     framework = "bootstrap",
--     version = "5.3.0",
--     integrity = "sha384-...",
--     crossorigin = "anonymous"
--   };

-- CDN JS Bootstrap
-- CREATE url:bootstrap_js_cdn SET
--   value = "https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js",
--   provider = "jsdelivr",
--   type = "cdn",
--   category = "javascript_framework",
--   metadata = {
--     framework = "bootstrap",
--     version = "5.3.0",
--     integrity = "sha384-...",
--     crossorigin = "anonymous"
--   };

-- Site officiel Bootstrap
-- CREATE url:bootstrap_official SET
--   value = "https://getbootstrap.com",
--   provider = "bootstrap",
--   type = "official",
--   category = "documentation",
--   metadata = {
--     framework = "bootstrap",
--     language = "en"
--   };

-- Documentation Bootstrap
-- CREATE url:bootstrap_docs SET
--   value = "https://getbootstrap.com/docs/5.3/getting-started/introduction/",
--   provider = "bootstrap",
--   type = "documentation",
--   category = "documentation",
--   metadata = {
--     framework = "bootstrap",
--     language = "en",
--     version = "5.3"
--   };

-- GitHub Bootstrap
-- CREATE url:bootstrap_github SET
--   value = "https://github.com/twbs/bootstrap",
--   provider = "github",
--   type = "source",
--   category = "source_code",
--   metadata = {
--     framework = "bootstrap",
--     platform = "github"
--   };

-- ============================================================================
-- BOOTSTRAP - Icônes (URLs Bunny CDN) A IMPLEMENTER
-- ============================================================================

-- Icône Bootstrap Light - Original
-- CREATE url:bootstrap_icon_light_original SET
--   value = "https://cdn.bunny.net/frameworks/bootstrap/light/icon.svg",
--   provider = "bunny",
--   type = "icon",
--   category = "framework_icon",
--   metadata = {
--     framework = "bootstrap",
--     theme = "light",
--     format = "svg",
--     optimized = true
--   };

-- Icône Bootstrap Light - WebP
-- CREATE url:bootstrap_icon_light_webp SET
--   value = "https://cdn.bunny.net/frameworks/bootstrap/light/icon.webp",
--   provider = "bunny",
--   type = "icon",
--   category = "framework_icon",
--   metadata = {
--     framework = "bootstrap",
--     theme = "light",
--     format = "webp",
--     optimized = true
--   };

-- Icône Bootstrap Light - AVIF
-- CREATE url:bootstrap_icon_light_avif SET
--   value = "https://cdn.bunny.net/frameworks/bootstrap/light/icon.avif",
--   provider = "bunny",
--   type = "icon",
--   category = "framework_icon",
--   metadata = {
--     framework = "bootstrap",
--     theme = "light",
--     format = "avif",
--     optimized = true
--   };

-- Icône Bootstrap Dark - Original
-- CREATE url:bootstrap_icon_dark_original SET
--   value = "https://cdn.bunny.net/frameworks/bootstrap/dark/icon.svg",
--   provider = "bunny",
--   type = "icon",
--   category = "framework_icon",
--   metadata = {
--     framework = "bootstrap",
--     theme = "dark",
--     format = "svg",
--     optimized = true
--   };

-- Icône Bootstrap Dark - WebP
-- CREATE url:bootstrap_icon_dark_webp SET
--   value = "https://cdn.bunny.net/frameworks/bootstrap/dark/icon.webp",
--   provider = "bunny",
--   type = "icon",
--   category = "framework_icon",
--   metadata = {
--     framework = "bootstrap",
--     theme = "dark",
--     format = "webp",
--     optimized = true
--   };

-- Icône Bootstrap Dark - AVIF
-- CREATE url:bootstrap_icon_dark_avif SET
--   value = "https://cdn.bunny.net/frameworks/bootstrap/dark/icon.avif",
--   provider = "bunny",
--   type = "icon",
--   category = "framework_icon",
--   metadata = {
--     framework = "bootstrap",
--     theme = "dark",
--     format = "avif",
--     optimized = true
--   };

COMMIT;

-- ============================================================================
-- EXEMPLES D'UTILISATION
-- ============================================================================

-- Récupérer Bootstrap spécifiquement
-- SELECT * FROM css_framework WHERE identity.value = "bootstrap";

-- Lister les frameworks avec JavaScript
-- SELECT identity.value FROM css_framework
-- WHERE config.supported_features CONTAINS "javascript_components";

-- Obtenir la configuration par défaut
-- SELECT config.default_config FROM css_framework WHERE identity.value = "bootstrap";
