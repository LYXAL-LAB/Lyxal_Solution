-- ============================================================================
-- I18N KEYS : studio_page:circular_menu_demo
-- Description : Clés i18n pour la page de démonstration circular_menu
-- Module : studio/i18n
-- ============================================================================

-- Titre de la page
CREATE i18n_key:studio_page_circular_menu_demo_title SET
    identity = {
        key: "studio.page.circular_menu_demo.title",
        slug: "studio-page-circular-menu-demo-title"
    },
    context = {
        domain: "studio",
        page: "circular_menu_demo",
        usage: "page_title"
    },
    metadata = {
        created_at: time::now(),
        updated_at: time::now()
    };

-- Description de la page
CREATE i18n_key:studio_page_circular_menu_demo_description SET
    identity = {
        key: "studio.page.circular_menu_demo.description",
        slug: "studio-page-circular-menu-demo-description"
    },
    context = {
        domain: "studio",
        page: "circular_menu_demo",
        usage: "page_description"
    },
    metadata = {
        created_at: time::now(),
        updated_at: time::now()
    };
