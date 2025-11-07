-- ============================================================================
-- FRAMEWORK : Tailwind CSS
-- Description : Framework CSS utility-first par défaut du système Lyxal
-- Status : Framework par défaut, actif
-- ============================================================================

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
