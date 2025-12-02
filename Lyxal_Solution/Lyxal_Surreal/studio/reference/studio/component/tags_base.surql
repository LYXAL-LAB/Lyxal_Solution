-- ============================================================================
-- TAGS DE BASE : Classification des composants
-- Description : Tags système pour classifier les composants studio
-- Module : studio/component
-- ============================================================================

-- Tag UI - Interface utilisateur
CREATE tag:ui SET
    identity = {
        code: "ui",
        name: "Interface Utilisateur",
        slug: "ui"
    },
    metadata = {
        description: "Éléments d'interface utilisateur généraux",
        color: "#3B82F6",
        category: "component"
    };

-- Tag Navigation - Éléments de navigation
CREATE tag:navigation SET
    identity = {
        code: "navigation",
        name: "Navigation",
        slug: "navigation"
    },
    metadata = {
        description: "Éléments de navigation et menus",
        color: "#10B981",
        category: "component"
    };

-- Tag Floating - Éléments flottants
CREATE tag:floating SET
    identity = {
        code: "floating",
        name: "Flottant",
        slug: "floating"
    },
    metadata = {
        description: "Éléments flottants et superposés",
        color: "#F59E0B",
        category: "component"
    };

-- Tag Form - Éléments de formulaire
CREATE tag:form SET
    identity = {
        code: "form",
        name: "Formulaire",
        slug: "form"
    },
    metadata = {
        description: "Éléments de formulaires et saisie",
        color: "#EF4444",
        category: "component"
    };

-- Tag Data Display - Affichage de données
CREATE tag:data_display SET
    identity = {
        code: "data_display",
        name: "Affichage Données",
        slug: "data-display"
    },
    metadata = {
        description: "Éléments d'affichage de données",
        color: "#8B5CF6",
        category: "component"
    };
