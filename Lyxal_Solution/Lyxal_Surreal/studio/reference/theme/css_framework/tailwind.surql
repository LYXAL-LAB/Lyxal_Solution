-- ============================================================================
-- FRAMEWORK : Tailwind CSS
-- Description : Framework CSS utility-first par défaut du système Lyxal
-- Status : Framework par défaut, actif
-- ============================================================================

BEGIN;

-- Création du framework Tailwind CSS
CREATE css_framework:tailwind SET
  identity = {
    value = "tailwind",
    slug = "tailwind"
  },

  presentation = {
    name_i18n = i18n_key:framework_tailwind_name,
    description_i18n = i18n_key:framework_tailwind_description,
    icon_light = icon:tailwind_icon_light,
    icon_dark = icon:tailwind_icon_dark
  },

  config = {
    type = "utility_first",
    default_config = {
      darkMode = "class",
      content = ["./src/**/*.{js,ts,jsx,tsx}"],
      theme = {
        extend = {}
      },
      plugins = []
    },
    supported_features = ["dark_mode", "responsive", "animations", "custom_colors", "hover", "focus"],
    version = "3.4.0",
    dependencies = {
      css_urls = [url:tailwind_css_cdn],
      js_urls = [],
      font_urls = []
    }
  },

  documentation = {
    official_url = url:tailwind_official,
    docs_url = url:tailwind_docs,
    github_url = url:tailwind_github
  },

  status = {
    is_active = true,
    is_default = true,
    source = "system"
  },

  metadata = {
    order = 1,
    notes = "Framework par défaut du système Lyxal Studio. Utility-first approach avec support complet des thèmes.",
    examples = [
      {
        title = "Bouton primaire",
        description = "Style de bouton primaire avec Tailwind",
        code = "bg-blue-500 hover:bg-blue-600 text-white font-medium py-2 px-4 rounded"
      },
      {
        title = "Carte responsive",
        description = "Carte adaptative avec Tailwind",
        code = "bg-white dark:bg-gray-800 rounded-lg shadow-md p-6 max-w-sm mx-auto"
      },
      {
        title = "Grille flexible",
        description = "Grille responsive avec Tailwind",
        code = "grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4"
      }
    ]
  };

-- ============================================================================
-- I18N KEYS FOR TAILWIND CSS
-- ============================================================================

-- Nom du framework Tailwind
CREATE i18n_key:framework_tailwind_name SET
  context = "css_framework",
  description = "Nom d'affichage du framework Tailwind CSS";

-- Description du framework Tailwind
CREATE i18n_key:framework_tailwind_description SET
  context = "css_framework",
  description = "Description détaillée du framework Tailwind CSS";

-- ============================================================================
-- I18N TRANSLATIONS FOR TAILWIND CSS
-- ============================================================================

-- Translation du nom du framework Tailwind
RELATE i18n_key:framework_tailwind_name->translation->language:fr SET text = "Tailwind CSS";
RELATE i18n_key:framework_tailwind_name->translation->language:en SET text = "Tailwind CSS";
RELATE i18n_key:framework_tailwind_name->translation->language:it SET text = "Tailwind CSS";
RELATE i18n_key:framework_tailwind_name->translation->language:es SET text = "Tailwind CSS";
RELATE i18n_key:framework_tailwind_name->translation->language:de SET text = "Tailwind CSS";

-- Translation de la description du framework Tailwind
RELATE i18n_key:framework_tailwind_description->translation->language:es SET text = "Framework CSS utility-first moderno y flexible";
RELATE i18n_key:framework_tailwind_description->translation->language:de SET text = "Modernes und flexibles Utility-First CSS Framework";
RELATE i18n_key:framework_tailwind_description->translation->language:it SET text = "Framework CSS utility-first moderno e flessibile";
RELATE i18n_key:framework_tailwind_description->translation->language:en SET text = "Modern and flexible utility-first CSS framework";
RELATE i18n_key:framework_tailwind_description->translation->language:fr SET text = "Framework CSS utility-first moderne et flexible";


-- ============================================================================
-- ICONS FOR TAILWIND CSS
-- ============================================================================

-- Icône Tailwind - Mode clair
-- CREATE icon:tailwind_icon_light SET
--   identity = {
--     name = "Tailwind CSS Light",
--     slug = "tailwind-light",
--     provider = "bunny"
--   },
--   urls = {
--     original = url:tailwind_icon_light_original,
--     webp = url:tailwind_icon_light_webp,
--     avif = url:tailwind_icon_light_avif
--   },
--   metadata = {
--     category = "framework",
--     tags = ["css", "tailwind", "framework", "light"],
--     width = 64,
--     height = 64,
--     format = "svg"
--   };

-- Icône Tailwind - Mode sombre
-- CREATE icon:tailwind_icon_dark SET
--   identity = {
--     name = "Tailwind CSS Dark",
--     slug = "tailwind-dark",
--     provider = "bunny"
--   },
--   urls = {
--     original = url:tailwind_icon_dark_original,
--     webp = url:tailwind_icon_dark_webp,
--     avif = url:tailwind_icon_dark_avif
--   },
--   metadata = {
--     category = "framework",
--     tags = ["css", "tailwind", "framework", "dark"],
--     width = 64,
--     height = 64,
--     format = "svg"
--   };

-- ============================================================================
-- URLs FOR TAILWIND CSS
-- ============================================================================

-- CDN CSS Tailwind
-- CREATE url:tailwind_css_cdn SET
--   value = "https://cdn.tailwindcss.com/3.4.0/tailwind.min.css",
--   provider = "tailwind",
--   type = "cdn",
--   category = "css_framework",
--   metadata = {
--     framework = "tailwind",
--     version = "3.4.0",
--     integrity = "sha384-...",
--     crossorigin = "anonymous"
--   };

-- Site officiel Tailwind
-- CREATE url:tailwind_official SET
--   value = "https://tailwindcss.com",
--   provider = "tailwind",
--   type = "official",
--   category = "documentation",
--   metadata = {
--     framework = "tailwind",
--     language = "en"
--   };

-- Documentation Tailwind
-- CREATE url:tailwind_docs SET
--   value = "https://tailwindcss.com/docs",
--   provider = "tailwind",
--   type = "documentation",
--   category = "documentation",
--   metadata = {
--     framework = "tailwind",
--     language = "en"
--   };

-- GitHub Tailwind
-- CREATE url:tailwind_github SET
--   value = "https://github.com/tailwindlabs/tailwindcss",
--   provider = "github",
--   type = "source",
--   category = "source_code",
--   metadata = {
--     framework = "tailwind",
--     platform = "github"
--   };

-- ============================================================================
-- URLs FOR TAILWIND CSS
-- ============================================================================

-- Icône Tailwind Light - Original
-- CREATE url:tailwind_icon_light_original SET
--   value = "https://cdn.bunny.net/frameworks/tailwind/light/icon.svg",
--   provider = "bunny",
--   type = "icon",
--   category = "framework_icon",
--   metadata = {
--     framework = "tailwind",
--     theme = "light",
--     format = "svg",
--     optimized = true
--   };

-- Icône Tailwind Light - WebP
-- CREATE url:tailwind_icon_light_webp SET
--   value = "https://cdn.bunny.net/frameworks/tailwind/light/icon.webp",
--   provider = "bunny",
--   type = "icon",
--   category = "framework_icon",
--   metadata = {
--     framework = "tailwind",
--     theme = "light",
--     format = "webp",
--     optimized = true
--   };

-- Icône Tailwind Light - AVIF
-- CREATE url:tailwind_icon_light_avif SET
--   value = "https://cdn.bunny.net/frameworks/tailwind/light/icon.avif",
--   provider = "bunny",
--   type = "icon",
--   category = "framework_icon",
--   metadata = {
--     framework = "tailwind",
--     theme = "light",
--     format = "avif",
--     optimized = true
--   };

-- Icône Tailwind Dark - Original
-- CREATE url:tailwind_icon_dark_original SET
--   value = "https://cdn.bunny.net/frameworks/tailwind/dark/icon.svg",
--   provider = "bunny",
--   type = "icon",
--   category = "framework_icon",
--   metadata = {
--     framework = "tailwind",
--     theme = "dark",
--     format = "svg",
--     optimized = true
--   };

-- Icône Tailwind Dark - WebP
-- CREATE url:tailwind_icon_dark_webp SET
--   value = "https://cdn.bunny.net/frameworks/tailwind/dark/icon.webp",
--   provider = "bunny",
--   type = "icon",
--   category = "framework_icon",
--   metadata = {
--     framework = "tailwind",
--     theme = "dark",
--     format = "webp",
--     optimized = true
--   };

-- Icône Tailwind Dark - AVIF
-- CREATE url:tailwind_icon_dark_avif SET
--   value = "https://cdn.bunny.net/frameworks/tailwind/dark/icon.avif",
--   provider = "bunny",
--   type = "icon",
--   category = "framework_icon",
--   metadata = {
--     framework = "tailwind",
--     theme = "dark",
--     format = "avif",
--     optimized = true
--   };

COMMIT;

-- ============================================================================
-- EXEMPLES D'UTILISATION
-- ============================================================================

-- Récupérer le framework par défaut
-- SELECT * FROM css_framework WHERE status.is_default = true;

-- Lister tous les frameworks actifs
-- SELECT identity.value, presentation.name_i18n FROM css_framework WHERE status.is_active = true ORDER BY metadata.order;

-- Obtenir les dépendances d'un framework
-- SELECT config.dependencies FROM css_framework WHERE identity.value = "tailwind";

-- Récupérer les exemples d'usage
-- SELECT metadata.examples FROM css_framework WHERE identity.value = "tailwind";
