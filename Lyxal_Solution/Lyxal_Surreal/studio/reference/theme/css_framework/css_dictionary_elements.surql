-- ============================================================================
-- ÉLÉMENTS CSS DICTIONARY - Éléments UI de Base
-- Description : Définition des éléments CSS abstraits du système
-- Catégories : buttons, inputs, cards, navigation, feedback
-- Total : Éléments essentiels pour le système Database-Driven
-- ============================================================================

-- ============================================================================
-- BOUTONS (Button Elements)
-- ============================================================================

CREATE css_dictionary:primary_button SET
  identity = {
    code = "primary_button",
    name = "Bouton Primaire"
  },
  metadata = {
    category = "button",
    semantic_meaning = "action",
    description = "Bouton principal pour les actions importantes (submit, confirm, etc.)"
  };

CREATE css_dictionary:secondary_button SET
  identity = {
    code = "secondary_button",
    name = "Bouton Secondaire"
  },
  metadata = {
    category = "button",
    semantic_meaning = "action",
    description = "Bouton secondaire pour les actions moins importantes"
  };

CREATE css_dictionary:success_button SET
  identity = {
    code = "success_button",
    name = "Bouton Succès"
  },
  metadata = {
    category = "button",
    semantic_meaning = "feedback",
    description = "Bouton indiquant une action positive ou de validation"
  };

CREATE css_dictionary:danger_button SET
  identity = {
    code = "danger_button",
    name = "Bouton Danger"
  },
  metadata = {
    category = "button",
    semantic_meaning = "warning",
    description = "Bouton pour les actions destructives ou dangereuses"
  };

CREATE css_dictionary:ghost_button SET
  identity = {
    code = "ghost_button",
    name = "Bouton Fantôme"
  },
  metadata = {
    category = "button",
    semantic_meaning = "action",
    description = "Bouton discret avec fond transparent"
  };

CREATE css_dictionary:outline_button SET
  identity = {
    code = "outline_button",
    name = "Bouton Contour"
  },
  metadata = {
    category = "button",
    semantic_meaning = "action",
    description = "Bouton avec bordure et fond transparent"
  };

-- ============================================================================
-- FORMULAIRES (Form Elements)
-- ============================================================================

CREATE css_dictionary:text_input SET
  identity = {
    code = "text_input",
    name = "Champ de Texte"
  },
  metadata = {
    category = "input",
    semantic_meaning = "input",
    description = "Champ de saisie pour le texte simple"
  };

CREATE css_dictionary:email_input SET
  identity = {
    code = "email_input",
    name = "Champ Email"
  },
  metadata = {
    category = "input",
    semantic_meaning = "input",
    description = "Champ de saisie spécialisé pour les adresses email"
  };

CREATE css_dictionary:password_input SET
  identity = {
    code = "password_input",
    name = "Champ Mot de Passe"
  },
  metadata = {
    category = "input",
    semantic_meaning = "input",
    description = "Champ de saisie masqué pour les mots de passe"
  };

CREATE css_dictionary:number_input SET
  identity = {
    code = "number_input",
    name = "Champ Numérique"
  },
  metadata = {
    category = "input",
    semantic_meaning = "input",
    description = "Champ de saisie pour les valeurs numériques"
  };

CREATE css_dictionary:textarea SET
  identity = {
    code = "textarea",
    name = "Zone de Texte"
  },
  metadata = {
    category = "input",
    semantic_meaning = "input",
    description = "Champ de saisie multi-lignes pour le texte long"
  };

CREATE css_dictionary:select SET
  identity = {
    code = "select",
    name = "Sélecteur"
  },
  metadata = {
    category = "input",
    semantic_meaning = "selection",
    description = "Menu déroulant pour sélectionner une option"
  };

CREATE css_dictionary:checkbox SET
  identity = {
    code = "checkbox",
    name = "Case à Cocher"
  },
  metadata = {
    category = "input",
    semantic_meaning = "selection",
    description = "Case à cocher pour sélection binaire oui/non"
  };

CREATE css_dictionary:radio SET
  identity = {
    code = "radio",
    name = "Bouton Radio"
  },
  metadata = {
    category = "input",
    semantic_meaning = "selection",
    description = "Bouton radio pour sélection exclusive dans un groupe"
  };

-- ============================================================================
-- CARTES ET CONTENEURS (Cards & Containers)
-- ============================================================================

CREATE css_dictionary:card SET
  identity = {
    code = "card",
    name = "Carte"
  },
  metadata = {
    category = "card",
    semantic_meaning = "display",
    description = "Conteneur rectangulaire pour grouper du contenu"
  };

CREATE css_dictionary:card_header SET
  identity = {
    code = "card_header",
    name = "En-tête de Carte"
  },
  metadata = {
    category = "card",
    semantic_meaning = "display",
    description = "Section supérieure de la carte (titre, actions)"
  };

CREATE css_dictionary:card_body SET
  identity = {
    code = "card_body",
    name = "Corps de Carte"
  },
  metadata = {
    category = "card",
    semantic_meaning = "display",
    description = "Section principale de la carte (contenu)"
  };

CREATE css_dictionary:card_footer SET
  identity = {
    code = "card_footer",
    name = "Pied de Carte"
  },
  metadata = {
    category = "card",
    semantic_meaning = "display",
    description = "Section inférieure de la carte (actions, métadonnées)"
  };

-- ============================================================================
-- FEEDBACK ET ÉTATS (Feedback & States)
-- ============================================================================

CREATE css_dictionary:alert_success SET
  identity = {
    code = "alert_success",
    name = "Alerte Succès"
  },
  metadata = {
    category = "alert",
    semantic_meaning = "feedback",
    description = "Message de confirmation ou de succès"
  };

CREATE css_dictionary:alert_warning SET
  identity = {
    code = "alert_warning",
    name = "Alerte Avertissement"
  },
  metadata = {
    category = "alert",
    semantic_meaning = "warning",
    description = "Message d'avertissement ou d'attention"
  };

CREATE css_dictionary:alert_error SET
  identity = {
    code = "alert_error",
    name = "Alerte Erreur"
  },
  metadata = {
    category = "alert",
    semantic_meaning = "feedback",
    description = "Message d'erreur ou d'échec"
  };

CREATE css_dictionary:alert_info SET
  identity = {
    code = "alert_info",
    name = "Alerte Information"
  },
  metadata = {
    category = "alert",
    semantic_meaning = "feedback",
    description = "Message informatif"
  };

-- ============================================================================
-- BADGES ET ÉTIQUETTES (Badges & Tags)
-- ============================================================================

CREATE css_dictionary:badge SET
  identity = {
    code = "badge",
    name = "Badge"
  },
  metadata = {
    category = "badge",
    semantic_meaning = "display",
    description = "Petit élément pour afficher des informations courtes (compteurs, statuts)"
  };

CREATE css_dictionary:badge_primary SET
  identity = {
    code = "badge_primary",
    name = "Badge Primaire"
  },
  metadata = {
    category = "badge",
    semantic_meaning = "display",
    description = "Badge avec couleur principale"
  };

CREATE css_dictionary:badge_secondary SET
  identity = {
    code = "badge_secondary",
    name = "Badge Secondaire"
  },
  metadata = {
    category = "badge",
    semantic_meaning = "display",
    description = "Badge avec couleur secondaire"
  };

CREATE css_dictionary:badge_success SET
  identity = {
    code = "badge_success",
    name = "Badge Succès"
  },
  metadata = {
    category = "badge",
    semantic_meaning = "feedback",
    description = "Badge indiquant un état positif"
  };

CREATE css_dictionary:badge_warning SET
  identity = {
    code = "badge_warning",
    name = "Badge Avertissement"
  },
  metadata = {
    category = "badge",
    semantic_meaning = "warning",
    description = "Badge indiquant un avertissement"
  };

CREATE css_dictionary:badge_error SET
  identity = {
    code = "badge_error",
    name = "Badge Erreur"
  },
  metadata = {
    category = "badge",
    semantic_meaning = "feedback",
    description = "Badge indiquant une erreur"
  };

-- ============================================================================
-- NAVIGATION (Navigation Elements)
-- ============================================================================

CREATE css_dictionary:nav_link SET
  identity = {
    code = "nav_link",
    name = "Lien de Navigation"
  },
  metadata = {
    category = "navigation",
    semantic_meaning = "navigation",
    description = "Lien pour la navigation dans l'application"
  };

CREATE css_dictionary:nav_link_active SET
  identity = {
    code = "nav_link_active",
    name = "Lien de Navigation Actif"
  },
  metadata = {
    category = "navigation",
    semantic_meaning = "navigation",
    description = "Lien de navigation actuellement actif/sélectionné"
  };

CREATE css_dictionary:breadcrumb SET
  identity = {
    code = "breadcrumb",
    name = "Fil d'Ariane"
  },
  metadata = {
    category = "navigation",
    semantic_meaning = "navigation",
    description = "Navigation hiérarchique montrant le chemin actuel"
  };

-- ============================================================================
-- MODALES ET OVERLAYS (Modals & Overlays)
-- ============================================================================

CREATE css_dictionary:modal SET
  identity = {
    code = "modal",
    name = "Modale"
  },
  metadata = {
    category = "modal",
    semantic_meaning = "display",
    description = "Fenêtre superposée pour contenu important ou actions"
  };

CREATE css_dictionary:modal_header SET
  identity = {
    code = "modal_header",
    name = "En-tête de Modale"
  },
  metadata = {
    category = "modal",
    semantic_meaning = "display",
    description = "Section supérieure de la modale (titre, bouton fermer)"
  };

CREATE css_dictionary:modal_body SET
  identity = {
    code = "modal_body",
    name = "Corps de Modale"
  },
  metadata = {
    category = "modal",
    semantic_meaning = "display",
    description = "Section principale de la modale (contenu)"
  };

CREATE css_dictionary:modal_footer SET
  identity = {
    code = "modal_footer",
    name = "Pied de Modale"
  },
  metadata = {
    category = "modal",
    semantic_meaning = "display",
    description = "Section inférieure de la modale (boutons d'action)"
  };

CREATE css_dictionary:overlay SET
  identity = {
    code = "overlay",
    name = "Overlay"
  },
  metadata = {
    category = "modal",
    semantic_meaning = "display",
    description = "Couche de superposition derrière les modales/dropdowns"
  };

-- ============================================================================
-- DROPDOWNS ET MENUS (Dropdowns & Menus)
-- ============================================================================

CREATE css_dictionary:dropdown SET
  identity = {
    code = "dropdown",
    name = "Menu Déroulant"
  },
  metadata = {
    category = "menu",
    semantic_meaning = "selection",
    description = "Menu déroulant avec options sélectionnables"
  };

CREATE css_dictionary:dropdown_item SET
  identity = {
    code = "dropdown_item",
    name = "Élément de Menu"
  },
  metadata = {
    category = "menu",
    semantic_meaning = "selection",
    description = "Élément individuel dans un menu déroulant"
  };

CREATE css_dictionary:dropdown_item_active SET
  identity = {
    code = "dropdown_item_active",
    name = "Élément de Menu Actif"
  },
  metadata = {
    category = "menu",
    semantic_meaning = "selection",
    description = "Élément de menu actuellement sélectionné/survolé"
  };

-- ============================================================================
-- UTILITAIRES (Utility Elements)
-- ============================================================================

CREATE css_dictionary:divider SET
  identity = {
    code = "divider",
    name = "Séparateur"
  },
  metadata = {
    category = "utility",
    semantic_meaning = "decoration",
    description = "Ligne de séparation entre sections de contenu"
  };

CREATE css_dictionary:spacer SET
  identity = {
    code = "spacer",
    name = "Espaceur"
  },
  metadata = {
    category = "utility",
    semantic_meaning = "layout",
    description = "Élément invisible pour créer de l'espace"
  };

CREATE css_dictionary:loading_spinner SET
  identity = {
    code = "loading_spinner",
    name = "Spinner de Chargement"
  },
  metadata = {
    category = "utility",
    semantic_meaning = "feedback",
    description = "Indicateur visuel de chargement en cours"
  };

-- ============================================================================
-- TYPOGRAPHIE (Typography Elements)
-- ============================================================================

CREATE css_dictionary:heading_1 SET
  identity = {
    code = "heading_1",
    name = "Titre 1"
  },
  metadata = {
    category = "typography",
    semantic_meaning = "display",
    description = "Titre principal de page/section"
  };

CREATE css_dictionary:heading_2 SET
  identity = {
    code = "heading_2",
    name = "Titre 2"
  },
  metadata = {
    category = "typography",
    semantic_meaning = "display",
    description = "Titre de section secondaire"
  };

CREATE css_dictionary:heading_3 SET
  identity = {
    code = "heading_3",
    name = "Titre 3"
  },
  metadata = {
    category = "typography",
    semantic_meaning = "display",
    description = "Titre de sous-section"
  };

CREATE css_dictionary:body_text SET
  identity = {
    code = "body_text",
    name = "Texte Principal"
  },
  metadata = {
    category = "typography",
    semantic_meaning = "display",
    description = "Texte de contenu principal"
  };

CREATE css_dictionary:caption SET
  identity = {
    code = "caption",
    name = "Légende"
  },
  metadata = {
    category = "typography",
    semantic_meaning = "display",
    description = "Texte secondaire ou de légende"
  };

-- ============================================================================
-- VÉRIFICATIONS
-- ============================================================================

-- Compter le nombre total d'éléments
-- SELECT count() FROM css_dictionary;
-- Résultat attendu : 47

-- Lister par catégorie
-- SELECT metadata.category, count() FROM css_dictionary GROUP BY metadata.category ORDER BY count() DESC;
-- Résultats attendus :
-- button: 6
-- input: 7
-- card: 4
-- alert: 4
-- badge: 6
-- navigation: 3
-- modal: 5
-- menu: 3
-- utility: 3
-- typography: 5

-- Vérifier l'unicité des codes
-- SELECT count() FROM css_dictionary GROUP BY identity.code HAVING count() > 1;
-- Résultat attendu : 0 (pas de doublons)
