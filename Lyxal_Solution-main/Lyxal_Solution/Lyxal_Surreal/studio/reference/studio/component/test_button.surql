-- ============================================================================
-- SEED : studio_component:test_button
-- Description : Composant bouton de test pour validation du schéma
-- Module : studio/runtime
-- ============================================================================

CREATE studio_component:test_button SET
    identity = {
        value: "test_button",
        slug: "test-button",
        code: "test_button"
    },
    presentation = {
        name_i18n: i18n_key:studio_component_test_button_name,
        description_i18n: i18n_key:studio_component_test_button_description,
        keywords: ["button", "action", "form", "test", "ui"]
    },
    structure = {
        type: "button",
        props: {
            className: ["btn", "btn-primary"],
            onClick: {
                type: "action",
                action: "state_update",
                target: "button_clicked"
            },
            disabled: "{{props.disabled}}"
        },
        children: [
            {
                type: "text",
                content: "{{props.label}}"
            }
        ],
        variants: {}
    },
    config = {
        category: "atom",
        version: "1.0.0",
        props_schema: [
            {
                name: "label",
                type: "string",
                required: true,
                description: "Texte du bouton"
            },
            {
                name: "variant",
                type: "string",
                default: "primary",
                options: ["primary", "secondary", "danger", "ghost"]
            },
            {
                name: "disabled",
                type: "boolean",
                default: false
            }
        ],
        supports_slots: false,
        slots: []
    },
    context = {
        usage_hints: ["form", "action", "button"],
        semantic_meaning: "Bouton d'action de test pour validation",
        dependencies: []
    },
    status = {
        is_active: true,
        is_system_component: true,
        is_deprecated: false,
        source: "system"
    },
    metadata = {
        notes: "Composant de test initial pour valider le schéma studio_component",
        tags: [],
        usage_count: 0
    },
    timestamp = {
    };

