-- ============================================================================
-- SEED : studio_page:test_page
-- Description : Page de test pour valider le rendu 100% DB-driven
-- Module : studio/runtime
-- ============================================================================

CREATE studio_page:test_page SET
    identity = {
        value: "test_page",
        slug: "test-page",
        code: "test_page"
    },
    presentation = {
        url: "/test",
        layout: "flex",
        title_i18n: i18n_key:studio_page_test_page_title,
        description_i18n: i18n_key:studio_page_test_page_description
    },
    -- ✅ Structure complète de la page en DB (100% DB-driven)
    -- Cette structure définit TOUT le contenu de la page sans code React
    content_structure = {
        type: "div",
        props: {
            className: ["container", "mx-auto", "p-6"]
        },
        children: [
            {
                -- Header de la page
                type: "div",
                props: {
                    className: ["mb-6"]
                },
                children: [
                    {
                        type: "h1",
                        props: {
                            className: ["text-3xl", "font-bold", "mb-4"]
                        },
                        children: [
                            {
                                type: "text",
                                content: "Page de Test"
                            }
                        ]
                    },
                    {
                        type: "p",
                        props: {
                            className: ["text-gray-600"]
                        },
                        children: [
                            {
                                type: "text",
                                content: "Page de démonstration du rendu 100% DB-driven"
                            }
                        ]
                    }
                ]
            },
            {
                -- Section avec le bouton de test
                type: "div",
                props: {
                    className: ["mb-4"]
                },
                children: [
                    {
                        type: "h2",
                        props: {
                            className: ["text-xl", "font-semibold", "mb-2"]
                        },
                        children: [
                            {
                                type: "text",
                                content: "Test du composant test_button depuis la DB"
                            }
                        ]
                    },
                    {
                        -- ✅ Composant DB utilisé dans la page
                        type: "component",
                        component: "test_button",
                        props: {
                            label: "Cliquez-moi !",
                            disabled: false
                        }
                    }
                ]
            },
            {
                -- Section avec plusieurs boutons
                type: "div",
                props: {
                    className: ["flex", "gap-2"]
                },
                children: [
                    {
                        type: "component",
                        component: "test_button",
                        props: {
                            label: "Bouton 1",
                            disabled: false
                        }
                    },
                    {
                        type: "component",
                        component: "test_button",
                        props: {
                            label: "Bouton 2",
                            disabled: true
                        }
                    }
                ]
            }
        ]
    },
    context = {
        permissions: [],
        modules: []
    },
    status = {
        is_active: true,
        is_system_page: false
    },
    metadata = {
        notes: "Page de test pour valider le rendu 100% DB-driven avec test_button",
        tags: ["test", "demo"]
    },
    timestamp = {
        created_at: time::now(),
        updated_at: time::now()
    },
    etag = rand::uuid::v7();

