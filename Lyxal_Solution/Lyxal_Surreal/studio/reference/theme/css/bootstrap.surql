-- ============================================================================
-- FRAMEWORK : Bootstrap CSS
-- Description : Framework CSS component-based populaire
-- Status : Framework alternatif, actif
-- ============================================================================

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
-- EXEMPLES D'UTILISATION
-- ============================================================================

-- Récupérer Bootstrap spécifiquement
-- SELECT * FROM css_framework WHERE identity.value = "bootstrap";

-- Lister les frameworks avec JavaScript
-- SELECT identity.value FROM css_framework
-- WHERE config.supported_features CONTAINS "javascript_components";

-- Obtenir la configuration par défaut
-- SELECT config.default_config FROM css_framework WHERE identity.value = "bootstrap";
