-- ============================================================================
-- SEED : studio_page:circular_menu_demo
-- Description : Page de démonstration du composant circular_menu
-- Module : studio/runtime
-- ============================================================================

CREATE studio_page:circular_menu_demo SET
    identity = {
        code: "circular_menu_demo",
        slug: "circular-menu-demo",
        value: "circular_menu_demo"
    },
    presentation = {
        title_i18n: i18n_key:studio_page_circular_menu_demo_title,
        description_i18n: i18n_key:studio_page_circular_menu_demo_description,
        url: "/demo/circular-menu"
    },
    content_structure = {
        type: "div",
        props: {
            className: ["min-h-screen", "bg-base-100", "p-8"]
        },
        children: [
            {
                -- Header de la page
                type: "div",
                props: {
                    className: ["text-center", "mb-12"]
                },
                children: [
                    {
                        type: "h1",
                        props: {
                            className: ["text-4xl", "font-bold", "mb-4"]
                        },
                        children: [
                            {
                                type: "text",
                                content: "Circular Menu Demo - DB Driven"
                            }
                        ]
                    },
                    {
                        type: "p",
                        props: {
                            className: ["text-lg", "text-base-content/70"]
                        },
                        children: [
                            {
                                type: "text",
                                content: "Démonstration du composant circular_menu entièrement défini en base de données"
                            }
                        ]
                    }
                ]
            },
            {
                -- Section des exemples
                type: "div",
                props: {
                    className: ["max-w-6xl", "mx-auto"]
                },
                children: [
                    {
                        type: "h2",
                        props: {
                            className: ["text-2xl", "font-semibold", "mb-8", "text-center"]
                        },
                        children: [
                            {
                                type: "text",
                                content: "Différentes configurations du même composant"
                            }
                        ]
                    },
                    {
                        -- Grille des exemples
                        type: "div",
                        props: {
                            className: ["grid", "grid-cols-1", "md:grid-cols-2", "lg:grid-cols-3", "gap-8"]
                        },
                        children: [
                            {
                                -- Exemple 1 : Standard (comme dans CircularMenuDemo.jsx)
                                type: "div",
                                props: {
                                    className: ["card", "bg-base-200", "p-6", "text-center"]
                                },
                                children: [
                                    {
                                        type: "h3",
                                        props: {
                                            className: ["text-lg", "font-semibold", "mb-4"]
                                        },
                                        children: [
                                            {
                                                type: "text",
                                                content: "Menu Standard"
                                            }
                                        ]
                                    },
                                    {
                                        type: "p",
                                        props: {
                                            className: ["text-sm", "text-base-content/60", "mb-4"]
                                        },
                                        children: [
                                            {
                                                type: "text",
                                                content: "Configuration par défaut - rayon 80px"
                                            }
                                        ]
                                    },
                                    {
                                        -- Le composant circular_menu avec config standard
                                        type: "component",
                                        component: "circular_menu",
                                        props: {
                                            items: [
                                                {
                                                    icon: "icon_user",
                                                    action: {
                                                        type: "alert",
                                                        message: "Clicked user"
                                                    }
                                                },
                                                {
                                                    icon: "icon_search",
                                                    action: {
                                                        type: "alert",
                                                        message: "Search clicked"
                                                    }
                                                },
                                                {
                                                    icon: "icon_message",
                                                    action: {
                                                        type: "alert",
                                                        message: "Messages clicked"
                                                    }
                                                },
                                                {
                                                    icon: "icon_bell",
                                                    action: {
                                                        type: "alert",
                                                        message: "Notifications clicked"
                                                    }
                                                }
                                            ],
                                        }
                                    }
                                ]
                            },
                            {
                                -- Exemple 2 : Rayon personnalisé
                                type: "div",
                                props: {
                                    className: ["card", "bg-base-200", "p-6", "text-center"]
                                },
                                children: [
                                    {
                                        type: "h3",
                                        props: {
                                            className: ["text-lg", "font-semibold", "mb-4"]
                                        },
                                        children: [
                                            {
                                                type: "text",
                                                content: "Menu Large"
                                            }
                                        ]
                                    },
                                    {
                                        type: "p",
                                        props: {
                                            className: ["text-sm", "text-base-content/60", "mb-4"]
                                        },
                                        children: [
                                            {
                                                type: "text",
                                                content: "Rayon personnalisé - 100px"
                                            }
                                        ]
                                    },
                                    {
                                        type: "component",
                                        component: "circular_menu",
                                        props: {
                                            items: [
                                                {
                                                    icon: "icon_user",
                                                    action: { type: "alert", message: "User (large)" }
                                                },
                                                {
                                                    icon: "icon_search",
                                                    action: { type: "alert", message: "Search (large)" }
                                                },
                                                {
                                                    icon: "icon_message",
                                                    action: { type: "alert", message: "Messages (large)" }
                                                },
                                                {
                                                    icon: "icon_bell",
                                                    action: { type: "alert", message: "Notifications (large)" }
                                                }
                                            ],
                                            radius: 100,  -- Personnalisé !
                                        }
                                    }
                                ]
                            },
                            {
                                -- Exemple 3 : Angle partiel (comme dans CircularMenuDemo.jsx)
                                type: "div",
                                props: {
                                    className: ["card", "bg-base-200", "p-6", "text-center"]
                                },
                                children: [
                                    {
                                        type: "h3",
                                        props: {
                                            className: ["text-lg", "font-semibold", "mb-4"]
                                        },
                                        children: [
                                            {
                                                type: "text",
                                                content: "Menu Semi-circulaire"
                                            }
                                        ]
                                    },
                                    {
                                        type: "p",
                                        props: {
                                            className: ["text-sm", "text-base-content/60", "mb-4"]
                                        },
                                        children: [
                                            {
                                                type: "text",
                                                content: "Angle limité - 0° à 180°"
                                            }
                                        ]
                                    },
                                    {
                                        type: "component",
                                        component: "circular_menu",
                                        props: {
                                            items: [
                                                {
                                                    icon: "icon_user",
                                                    action: { type: "alert", message: "User (semi)" }
                                                },
                                                {
                                                    icon: "icon_search",
                                                    action: { type: "alert", message: "Search (semi)" }
                                                },
                                                {
                                                    icon: "icon_message",
                                                    action: { type: "alert", message: "Messages (semi)" }
                                                },
                                                {
                                                    icon: "icon_bell",
                                                    action: { type: "alert", message: "Notifications (semi)" }
                                                }
                                            ],
                                            startAngle: 0,
                                            endAngle: 180,
                                            endAngleInclusive: true,  -- Comme dans l'original !
                                        }
                                    }
                                ]
                            },
                            {
                                -- Exemple 4 : Position différente
                                type: "div",
                                props: {
                                    className: ["card", "bg-base-200", "p-6", "text-center"]
                                },
                                children: [
                                    {
                                        type: "h3",
                                        props: {
                                            className: ["text-lg", "font-semibold", "mb-4"]
                                        },
                                        children: [
                                            {
                                                type: "text",
                                                content: "Menu Haut-Gauche"
                                            }
                                        ]
                                    },
                                    {
                                        type: "p",
                                        props: {
                                            className: ["text-sm", "text-base-content/60", "mb-4"]
                                        },
                                        children: [
                                            {
                                                type: "text",
                                                content: "Position personnalisée"
                                            }
                                        ]
                                    },
                                    {
                                        type: "component",
                                        component: "circular_menu",
                                        props: {
                                            items: [
                                                {
                                                    icon: "icon_user",
                                                    action: { type: "alert", message: "User (top-left)" }
                                                },
                                                {
                                                    icon: "icon_search",
                                                    action: { type: "alert", message: "Search (top-left)" }
                                                }
                                            ],
                                            position: "top-left",  -- Position différente !
                                            radius: 60,
                                        }
                                    }
                                ]
                            },
                            {
                                -- Exemple 5 : Actions réelles (navigation)
                                type: "div",
                                props: {
                                    className: ["card", "bg-base-200", "p-6", "text-center"]
                                },
                                children: [
                                    {
                                        type: "h3",
                                        props: {
                                            className: ["text-lg", "font-semibold", "mb-4"]
                                        },
                                        children: [
                                            {
                                                type: "text",
                                                content: "Menu Navigation"
                                            }
                                        ]
                                    },
                                    {
                                        type: "p",
                                        props: {
                                            className: ["text-sm", "text-base-content/60", "mb-4"]
                                        },
                                        children: [
                                            {
                                                type: "text",
                                                content: "Actions de navigation réelles"
                                            }
                                        ]
                                    },
                                    {
                                        type: "component",
                                        component: "circular_menu",
                                        props: {
                                            items: [
                                                {
                                                    icon: "icon_home",
                                                    action: {
                                                        type: "navigation",
                                                        url: "/dashboard"
                                                    }
                                                },
                                                {
                                                    icon: "icon_user",
                                                    action: {
                                                        type: "navigation",
                                                        url: "/profile"
                                                    }
                                                },
                                                {
                                                    icon: "icon_settings",
                                                    action: {
                                                        type: "navigation",
                                                        url: "/settings"
                                                    }
                                                }
                                            ],
                                            position: "bottom-left",
                                        }
                                    }
                                ]
                            },
                            {
                                -- Exemple 6 : Moins d'items
                                type: "div",
                                props: {
                                    className: ["card", "bg-base-200", "p-6", "text-center"]
                                },
                                children: [
                                    {
                                        type: "h3",
                                        props: {
                                            className: ["text-lg", "font-semibold", "mb-4"]
                                        },
                                        children: [
                                            {
                                                type: "text",
                                                content: "Menu Compact"
                                            }
                                        ]
                                    },
                                    {
                                        type: "p",
                                        props: {
                                            className: ["text-sm", "text-base-content/60", "mb-4"]
                                        },
                                        children: [
                                            {
                                                type: "text",
                                                content: "Seulement 3 actions essentielles"
                                            }
                                        ]
                                    },
                                    {
                                        type: "component",
                                        component: "circular_menu",
                                        props: {
                                            items: [
                                                {
                                                    icon: "icon_plus",
                                                    action: {
                                                        type: "modal",
                                                        modal: "create_new"
                                                    }
                                                },
                                                {
                                                    icon: "icon_search",
                                                    action: {
                                                        type: "modal",
                                                        modal: "quick_search"
                                                    }
                                                },
                                                {
                                                    icon: "icon_help",
                                                    action: {
                                                        type: "modal",
                                                        modal: "help_center"
                                                    }
                                                }
                                            ],
                                            radius: 70,
                                        }
                                    }
                                ]
                            }
                        ]
                    }
                ]
            }
        ]
    },
    context = {
        permissions: [],
        modules: ["circular_menu"]
    },
    status = {
        is_active: true,
        is_system_page: false
    },
    metadata = {
        notes: "Page de démonstration complète du composant circular_menu avec différentes configurations",
        tags: ["demo", "circular_menu", "db_driven"],
        created_by: "system"
    },
    timestamp = {
        created_at: time::now(),
        updated_at: time::now()
    },
    etag = rand::uuid::v7();
