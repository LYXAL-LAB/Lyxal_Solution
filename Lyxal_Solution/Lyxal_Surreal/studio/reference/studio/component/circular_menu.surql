-- ============================================================================
-- SEED : studio_component:circular_menu
-- Description : Menu circulaire flottant DB-driven
-- Module : studio/runtime
-- ============================================================================

CREATE studio_component:circular_menu SET
    identity = {
        value: "circular_menu",
        slug: "circular-menu",
        code: "circular_menu"
    },
    presentation = {
        name_i18n: i18n_key:studio_component_circular_menu_name,
        description_i18n: i18n_key:studio_component_circular_menu_description,
        keywords: ["menu", "circular", "floating", "navigation", "fab"]
    },
    structure = {
        type: "div",
        props: {
            className: ["inline-block", "relative", "w-fit", "h-fit"],
            onClick: "{{props.toggleAction}}",
            style: {
                position: "fixed",
                bottom: "20px",
                right: "20px",
                zIndex: "9999"
            }
        },
        children: [
            {
                -- Bouton principal (toggle)
                type: "span",
                props: {
                    className: [
                        "rounded-full",
                        "bg-teal-500",
                        "hover:bg-teal-600",
                        "text-white",
                        "w-12",
                        "h-12",
                        "flex",
                        "justify-center",
                        "items-center",
                        "cursor-pointer",
                        "transition-colors",
                        "duration-200",
                        "shadow-lg"
                    ]
                },
                children: [
                    {
                        type: "i",
                        props: {
                            className: ["{{props.show ? 'fas fa-times' : 'fas fa-bars'}}", "text-lg"]
                        }
                    }
                ]
            },
            {
                -- Liste des items circulaires
                type: "ul",
                props: {
                    className: [
                        "transition-all",
                        "duration-500",
                        "ease-in-out"
                    ],
                    style: {
                        opacity: "{{props.show ? 1 : 0}}",
                        transform: "{{props.show ? 'scale(1)' : 'scale(0.8)'}}",
                        pointerEvents: "{{props.show ? 'auto' : 'none'}}",
                        transition: "all 0.5s ease-in-out"
                    }
                },
                children: [
                    {
                        type: "div",
                        props: {
                            className: ["circular-menu-items"]
                        },
                        children: [
                            -- Premier item (Nord)
                            {
                                type: "span",
                                props: {
                                    className: [
                                        "absolute",
                                        "bg-rose-500",
                                        "hover:bg-rose-600",
                                        "text-white",
                                        "w-10",
                                        "h-10",
                                        "flex",
                                        "justify-center",
                                        "items-center",
                                        "cursor-pointer",
                                        "transition-all",
                                        "duration-500",
                                        "shadow-md",
                                        "{{props.show ? 'opacity-100 scale-100' : 'opacity-0 scale-0'}}"
                                    ],
                                    style: {
                                        top: "-80px",
                                        left: "50%",
                                        transform: "translateX(-50%)"
                                    },
                                    onClick: "{{props.items[0]?.action}}"
                                },
                                children: [
                                    {
                                        type: "i",
                                        props: {
                                            className: ["{{props.items[0]?.icon || 'fas fa-star'}}", "text-sm"]
                                        }
                                    }
                                ]
                            },
                            -- Deuxième item (Nord-Est)
                            {
                                type: "span",
                                props: {
                                    className: [
                                        "absolute",
                                        "bg-rose-500",
                                        "hover:bg-rose-600",
                                        "text-white",
                                        "w-10",
                                        "h-10",
                                        "flex",
                                        "justify-center",
                                        "items-center",
                                        "cursor-pointer",
                                        "transition-all",
                                        "duration-500",
                                        "shadow-md",
                                        "{{props.show ? 'opacity-100 scale-100' : 'opacity-0 scale-0'}}"
                                    ],
                                    style: {
                                        top: "-56px",
                                        right: "-56px"
                                    },
                                    onClick: "{{props.items[1]?.action}}"
                                },
                                children: [
                                    {
                                        type: "i",
                                        props: {
                                            className: ["{{props.items[1]?.icon || 'fas fa-search'}}", "text-sm"]
                                        }
                                    }
                                ]
                            },
                            -- Troisième item (Est)
                            {
                                type: "span",
                                props: {
                                    className: [
                                        "absolute",
                                        "bg-rose-500",
                                        "hover:bg-rose-600",
                                        "text-white",
                                        "w-10",
                                        "h-10",
                                        "flex",
                                        "justify-center",
                                        "items-center",
                                        "cursor-pointer",
                                        "transition-all",
                                        "duration-500",
                                        "shadow-md",
                                        "{{props.show ? 'opacity-100 scale-100' : 'opacity-0 scale-0'}}"
                                    ],
                                    style: {
                                        top: "50%",
                                        right: "-80px",
                                        transform: "translateY(-50%)"
                                    },
                                    onClick: "{{props.items[2]?.action}}"
                                },
                                children: [
                                    {
                                        type: "i",
                                        props: {
                                            className: ["{{props.items[2]?.icon || 'fas fa-envelope'}}", "text-sm"]
                                        }
                                    }
                                ]
                            },
                            -- Quatrième item (Sud-Est)
                            {
                                type: "span",
                                props: {
                                    className: [
                                        "absolute",
                                        "bg-rose-500",
                                        "hover:bg-rose-600",
                                        "text-white",
                                        "w-10",
                                        "h-10",
                                        "flex",
                                        "justify-center",
                                        "items-center",
                                        "cursor-pointer",
                                        "transition-all",
                                        "duration-500",
                                        "shadow-md",
                                        "{{props.show ? 'opacity-100 scale-100' : 'opacity-0 scale-0'}}"
                                    ],
                                    style: {
                                        bottom: "-56px",
                                        right: "-56px"
                                    },
                                    onClick: "{{props.items[3]?.action}}"
                                },
                                children: [
                                    {
                                        type: "i",
                                        props: {
                                            className: ["{{props.items[3]?.icon || 'fas fa-bell'}}", "text-sm"]
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
    config = {
        category: "molecule",
        version: "1.0.0",
        props_schema: [
            {
                name: "items",
                type: "array",
                required: true,
                description: "Liste des items du menu [{icon: 'icon_name', action: {...}}]"
            },
            {
                name: "radius",
                type: "number",
                default: 80,
                description: "Rayon du cercle en pixels"
            },
            {
                name: "startAngle",
                type: "number",
                default: 0,
                description: "Angle de départ en degrés"
            },
            {
                name: "endAngle",
                type: "number",
                default: 360,
                description: "Angle de fin en degrés"
            },
            {
                name: "show",
                type: "boolean",
                default: false,
                description: "État d'affichage du menu"
            },
            {
                name: "toggleAction",
                type: "object",
                description: "Action lors du clic sur le bouton principal"
            },
            {
                name: "position",
                type: "string",
                default: "bottom-right",
                options: ["bottom-right", "bottom-left", "top-right", "top-left"],
                description: "Position du menu sur l'écran"
            }
        ],
        supports_slots: false,
        slots: []
    },
    context = {
        usage_hints: ["navigation", "floating-action", "quick-access"],
        semantic_meaning: "Menu circulaire flottant pour actions rapides",
        dependencies: []
    },
    status = {
        is_active: true,
        is_system_component: true,
        is_deprecated: false,
        source: "system"
    },
    metadata = {
        notes: "Menu circulaire inspiré de Material Design FAB avec expansion circulaire",
        tags: [tag:navigation, tag:ui, tag:floating],
        usage_count: 0
    },
    timestamp = {
        created_at: time::now(),
        updated_at: time::now()
    },
    etag = rand::uuid::v7();
