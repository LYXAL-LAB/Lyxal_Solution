-- ============================================================================
-- I18N KEYS : studio_component:circular_menu
-- Description : Clés i18n pour le composant circular_menu
-- Module : studio/i18n
-- ============================================================================

-- Nom du composant
CREATE i18n_key:studio_component_circular_menu_name SET
    identity = {
        key: "studio.component.circular_menu.name",
        slug: "studio-component-circular-menu-name"
    },
    context = {
        domain: "studio",
        component: "circular_menu",
        usage: "component_name"
    },
    metadata = {
        created_at: time::now(),
        updated_at: time::now()
    };

-- Description du composant
CREATE i18n_key:studio_component_circular_menu_description SET
    identity = {
        key: "studio.component.circular_menu.description",
        slug: "studio-component-circular-menu-description"
    },
    context = {
        domain: "studio",
        component: "circular_menu",
        usage: "component_description"
    },
    metadata = {
        created_at: time::now(),
        updated_at: time::now()
    };
