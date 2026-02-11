-- ============================================================================
-- FICHIER : components_base.surql
-- Description : Seeds pour les composants UI de base
-- Module : studio/theme
-- Approche : "Riche et stricte" - Normalisation des composants
-- ============================================================================

-- ============================================================================
-- COMPOSANTS INTERACTIFS (priorité haute)
-- ============================================================================

-- Bouton - Composant fondamental d'interaction
CREATE css_component:button SET
  identity = {
    code = "button",
    name = "Bouton",
    slug = "button"
  },
  metadata = {
    description = "Composant interactif pour déclencher des actions utilisateur (clic, soumission, navigation)",
    category = "interactive",
    priority = 10,
    is_core = true,
    compatibility = [css_framework:tailwind, css_framework:bootstrap, css_framework:material]
  };

-- Champ de saisie - Entrée utilisateur de base
CREATE css_component:input SET
  identity = {
    code = "input",
    name = "Champ de saisie",
    slug = "input"
  },
  metadata = {
    description = "Champ de saisie texte pour la collecte d'informations utilisateur",
    category = "interactive",
    priority = 9,
    is_core = true,
    compatibility = [css_framework:tailwind, css_framework:bootstrap, css_framework:material]
  };

-- Zone de texte - Saisie multi-ligne
CREATE css_component:textarea SET
  identity = {
    code = "textarea",
    name = "Zone de texte",
    slug = "textarea"
  },
  metadata = {
    description = "Champ de saisie multi-ligne pour textes longs",
    category = "interactive",
    priority = 8,
    is_core = true,
    compatibility = [css_framework:tailwind, css_framework:bootstrap, css_framework:material]
  };

-- Case à cocher - Sélection binaire
CREATE css_component:checkbox SET
  identity = {
    code = "checkbox",
    name = "Case à cocher",
    slug = "checkbox"
  },
  metadata = {
    description = "Composant de sélection binaire (coché/non coché)",
    category = "interactive",
    priority = 7,
    is_core = true,
    compatibility = [css_framework:tailwind, css_framework:bootstrap, css_framework:material]
  };

-- Bouton radio - Sélection unique
CREATE css_component:radio SET
  identity = {
    code = "radio",
    name = "Bouton radio",
    slug = "radio"
  },
  metadata = {
    description = "Composant de sélection unique dans un groupe d'options",
    category = "interactive",
    priority = 7,
    is_core = true,
    compatibility = [css_framework:tailwind, css_framework:bootstrap, css_framework:material]
  };

-- Liste déroulante - Sélection dans une liste
CREATE css_component:select SET
  identity = {
    code = "select",
    name = "Liste déroulante",
    slug = "select"
  },
  metadata = {
    description = "Composant de sélection dans une liste d'options",
    category = "interactive",
    priority = 7,
    is_core = true,
    compatibility = [css_framework:tailwind, css_framework:bootstrap, css_framework:material]
  };

-- ============================================================================
-- COMPOSANTS DE CONTENU (priorité moyenne-haute)
-- ============================================================================

-- Carte - Conteneur de contenu
CREATE css_component:card SET
  identity = {
    code = "card",
    name = "Carte",
    slug = "card"
  },
  metadata = {
    description = "Conteneur flexible pour grouper du contenu connexe avec titre, image et actions",
    category = "content",
    priority = 9,
    is_core = true,
    compatibility = [css_framework:tailwind, css_framework:bootstrap, css_framework:material]
  };

-- Badge - Indicateur compact
CREATE css_component:badge SET
  identity = {
    code = "badge",
    name = "Badge",
    slug = "badge"
  },
  metadata = {
    description = "Petit indicateur compact pour afficher des informations secondaires (statut, nombre, etc.)",
    category = "content",
    priority = 6,
    is_core = true,
    compatibility = [css_framework:tailwind, css_framework:bootstrap, css_framework:material]
  };

-- Étiquette - Texte descriptif
CREATE css_component:label SET
  identity = {
    code = "label",
    name = "Étiquette",
    slug = "label"
  },
  metadata = {
    description = "Texte descriptif associé à un champ de formulaire ou élément interactif",
    category = "content",
    priority = 5,
    is_core = true,
    compatibility = [css_framework:tailwind, css_framework:bootstrap, css_framework:material]
  };

-- ============================================================================
-- COMPOSANTS DE LAYOUT (priorité moyenne-haute)
-- ============================================================================

-- Mise en page - Structure globale
CREATE css_component:layout SET
  identity = {
    code = "layout",
    name = "Mise en page",
    slug = "layout"
  },
  metadata = {
    description = "Structure et organisation globale de l'espace visuel (conteneur, grille, responsive)",
    category = "layout",
    priority = 8,
    is_core = true,
    compatibility = [css_framework:tailwind, css_framework:bootstrap, css_framework:material]
  };

-- Conteneur - Wrapper principal
CREATE css_component:container SET
  identity = {
    code = "container",
    name = "Conteneur",
    slug = "container"
  },
  metadata = {
    description = "Conteneur principal pour limiter la largeur maximale du contenu",
    category = "layout",
    priority = 7,
    is_core = true,
    compatibility = [css_framework:tailwind, css_framework:bootstrap, css_framework:material]
  };

-- Grille - Système de mise en page
CREATE css_component:grid SET
  identity = {
    code = "grid",
    name = "Grille",
    slug = "grid"
  },
  metadata = {
    description = "Système de grille pour organiser le contenu en colonnes et rangées",
    category = "layout",
    priority = 6,
    is_core = true,
    compatibility = [css_framework:tailwind, css_framework:bootstrap, css_framework:material]
  };

-- ============================================================================
-- COMPOSANTS DE NAVIGATION (priorité moyenne)
-- ============================================================================

-- Barre de navigation - Navigation principale
CREATE css_component:navbar SET
  identity = {
    code = "navbar",
    name = "Barre de navigation",
    slug = "navbar"
  },
  metadata = {
    description = "Barre de navigation principale avec liens, logo et menu",
    category = "navigation",
    priority = 6,
    is_core = true,
    compatibility = [css_framework:tailwind, css_framework:bootstrap, css_framework:material]
  };

-- Onglets - Navigation tabulée
CREATE css_component:tabs SET
  identity = {
    code = "tabs",
    name = "Onglets",
    slug = "tabs"
  },
  metadata = {
    description = "Système d'onglets pour basculer entre différentes vues de contenu",
    category = "navigation",
    priority = 5,
    is_core = true,
    compatibility = [css_framework:tailwind, css_framework:bootstrap, css_framework:material]
  };

-- Fil d'Ariane - Navigation hiérarchique
CREATE css_component:breadcrumb SET
  identity = {
    code = "breadcrumb",
    name = "Fil d'Ariane",
    slug = "breadcrumb"
  },
  metadata = {
    description = "Navigation hiérarchique indiquant la position actuelle dans la structure du site",
    category = "navigation",
    priority = 4,
    is_core = false,
    compatibility = [css_framework:tailwind, css_framework:bootstrap, css_framework:material]
  };

-- ============================================================================
-- COMPOSANTS DE FEEDBACK (priorité moyenne)
-- ============================================================================

-- Modal - Fenêtre superposée
CREATE css_component:modal SET
  identity = {
    code = "modal",
    name = "Modal",
    slug = "modal"
  },
  metadata = {
    description = "Fenêtre superposée pour afficher du contenu important ou des actions critiques",
    category = "feedback",
    priority = 6,
    is_core = true,
    compatibility = [css_framework:tailwind, css_framework:bootstrap, css_framework:material]
  };

-- Tooltip - Info-bulle
CREATE css_component:tooltip SET
  identity = {
    code = "tooltip",
    name = "Info-bulle",
    slug = "tooltip"
  },
  metadata = {
    description = "Petite fenêtre contextuelle affichant des informations supplémentaires",
    category = "feedback",
    priority = 4,
    is_core = false,
    compatibility = [css_framework:tailwind, css_framework:bootstrap, css_framework:material]
  };

-- Indicateur de chargement - Spinner
CREATE css_component:spinner SET
  identity = {
    code = "spinner",
    name = "Indicateur de chargement",
    slug = "spinner"
  },
  metadata = {
    description = "Animation indiquant qu'une opération est en cours",
    category = "feedback",
    priority = 5,
    is_core = true,
    compatibility = [css_framework:tailwind, css_framework:bootstrap, css_framework:material]
  };

-- Alerte - Message de notification
CREATE css_component:alert SET
  identity = {
    code = "alert",
    name = "Alerte",
    slug = "alert"
  },
  metadata = {
    description = "Message de notification pour informer l'utilisateur d'événements importants",
    category = "feedback",
    priority = 5,
    is_core = true,
    compatibility = [css_framework:tailwind, css_framework:bootstrap, css_framework:material]
  };

-- Barre de progression - Indicateur d'avancement
CREATE css_component:progress SET
  identity = {
    code = "progress",
    name = "Barre de progression",
    slug = "progress"
  },
  metadata = {
    description = "Indicateur visuel de la progression d'une opération",
    category = "feedback",
    priority = 4,
    is_core = false,
    compatibility = [css_framework:tailwind, css_framework:bootstrap, css_framework:material]
  };

-- ============================================================================
-- COMPOSANTS D'AFFICHAGE DE DONNÉES (priorité moyenne-basse)
-- ============================================================================

-- Tableau - Affichage tabulaire
CREATE css_component:table SET
  identity = {
    code = "table",
    name = "Tableau",
    slug = "table"
  },
  metadata = {
    description = "Affichage structuré de données sous forme de tableau avec en-têtes et cellules",
    category = "data_display",
    priority = 5,
    is_core = true,
    compatibility = [css_framework:tailwind, css_framework:bootstrap, css_framework:material]
  };

-- Liste - Affichage linéaire
CREATE css_component:list SET
  identity = {
    code = "list",
    name = "Liste",
    slug = "list"
  },
  metadata = {
    description = "Affichage linéaire d'éléments avec organisation hiérarchique possible",
    category = "data_display",
    priority = 4,
    is_core = true,
    compatibility = [css_framework:tailwind, css_framework:bootstrap, css_framework:material]
  };

-- Pagination - Navigation dans les données
CREATE css_component:pagination SET
  identity = {
    code = "pagination",
    name = "Pagination",
    slug = "pagination"
  },
  metadata = {
    description = "Navigation pour parcourir de grandes quantités de données par pages",
    category = "data_display",
    priority = 4,
    is_core = false,
    compatibility = [css_framework:tailwind, css_framework:bootstrap, css_framework:material]
  };

-- Avatar - Image utilisateur
CREATE css_component:avatar SET
  identity = {
    code = "avatar",
    name = "Avatar",
    slug = "avatar"
  },
  metadata = {
    description = "Image représentant un utilisateur ou une entité",
    category = "data_display",
    priority = 3,
    is_core = false,
    compatibility = [css_framework:tailwind, css_framework:bootstrap, css_framework:material]
  };

-- Statistiques - Métriques numériques
CREATE css_component:stats SET
  identity = {
    code = "stats",
    name = "Statistiques",
    slug = "stats"
  },
  metadata = {
    description = "Affichage de métriques et statistiques avec valeurs et tendances",
    category = "data_display",
    priority = 4,
    is_core = false,
    compatibility = [css_framework:tailwind, css_framework:bootstrap, css_framework:material]
  };

-- ============================================================================
-- TOTAL : 23 composants de base
-- Répartition par catégorie :
-- - Interactive : 6 (button, input, textarea, checkbox, radio, select)
-- - Content : 3 (card, badge, label)
-- - Layout : 3 (layout, container, grid)
-- - Navigation : 3 (navbar, tabs, breadcrumb)
-- - Feedback : 5 (modal, tooltip, spinner, alert, progress)
-- - Data Display : 5 (table, list, pagination, avatar, stats)
-- ============================================================================
