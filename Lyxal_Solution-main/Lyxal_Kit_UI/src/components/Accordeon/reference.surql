-- ============================================================================
-- COMPOSANTS DE LA BIBLIOTHÈQUE - Données de référence
-- ============================================================================

-- ============================================================================
-- ACCORDEON - Composant d'accordéon pliable
-- ============================================================================
BEGIN;
-- Création du composant Accordéon
CREATE ui_component_library:accordion SET
    identity = {
        value: "accordion",
        slug: "accordion",
        code: "accordion"
    },
    presentation = {
        name_i18n: i18n_key:component_accordion_name,
        description_i18n: i18n_key:component_accordion_description,
        preview_url: url:accordion_preview,
        keywords: ["accordion", "collapse", "expand", "panel", "foldable"]
    },
    structure = {
        "id": "accordion_default",
        "lang": "fr",
        "version": "1.0.0",
        "category": "data-display",
        "description": "Composant d'accordéon pour contenu pliable avec animations fluides",
        "author": "Lyxal Team",
        "tags": ["ui", "interactive", "content", "collapsible"],
        "props": {
            "width": "100%",
            "margin": "0",
            "radius": "var(--radius-md)",
            "shadow": "var(--shadow-md)",
            "backgroundColor": "var(--color-bg-primary)",
            "borderColor": "var(--color-border)",
            "borderStyle": "solid",
            "borderWidth": "1px",
            "headerFontSize": "1rem",
            "bodyFontSize": "0.9rem",
            "headerTextColor": "var(--color-text-primary)",
            "bodyTextColor": "var(--color-text-secondary)",
            "headerBgColor": "transparent",
            "bodyBgColor": "transparent",
            "textAlign": "left",
            "padding": "1rem",
            "iconClosedUrl": "https://cdn.lyxal.b-cdn.net/icons/chevron-down.svg",
            "iconOpenUrl": "https://cdn.lyxal.b-cdn.net/icons/chevron-up.svg",
            "iconPosition": "right",
            "iconAlign": "center",
            "iconSize": "1rem",
            "animationDuration": 400,
            "animationType": "height",
            "expandDirection": "down",
            "allowMultiple": false,
            "defaultOpenIndex": null
        },
        "items": [],
        "variants": {
            "compact": {
                "padding": "0.5rem",
                "headerFontSize": "0.875rem",
                "bodyFontSize": "0.8rem"
            },
            "large": {
                "padding": "1.5rem",
                "headerFontSize": "1.25rem",
                "bodyFontSize": "1rem"
            },
            "bordered": {
                "borderWidth": "2px",
                "shadow": "var(--shadow-lg)"
            },
            "minimal": {
                "borderStyle": "none",
                "shadow": "none",
                "headerBgColor": "var(--color-bg-secondary)"
            }
        },
        "i18n": {
            "emptyText": {
                "fr": "Aucun élément à afficher",
                "en": "No items to display",
                "es": "No hay elementos para mostrar"
            },
            "loadingText": {
                "fr": "Chargement...",
                "en": "Loading...",
                "es": "Cargando..."
            }
        }
    },
    config = {
        category: ui_component_library_category:data_display,
        version: "1.0.0",
        source: "system"
    },
    status = {
        is_active: true,
        is_system_component: true,
        is_deprecated: false
    },
    metadata = {
        usage_count: 0,
        last_used_at: NONE,
        tags: [tag:ui, tag:interactive, tag:content, tag:collapsible]
    };
-- Création des clés i18n
CREATE i18n_key:component_accordion_name SET
    key: "component_accordion_name",
    value: "Accordéon",
    description: "Nom du composant Accordéon";
CREATE i18n_key:component_accordion_description SET
    key: "component_accordion_description",
    value: "Composant d'accordéon pour contenu pliable avec animations fluides",
    description: "Description du composant Accordéon";

-- Création des traductions
RELATE i18n_key:component_accordion_name->translation->language:fr SET text = "Accordéon";
RELATE i18n_key:component_accordion_name->translation->language:en SET text = "Accordion";
RELATE i18n_key:component_accordion_name->translation->language:es SET text = "Accordón";
RELATE i18n_key:component_accordion_name->translation->language:it SET text = "Accordone";
RELATE i18n_key:component_accordion_name->translation->language:de SET text = "Akordion";
RELATE i18n_key:component_accordion_description->translation->language:fr SET text = "Composant d'accordéon pour contenu pliable avec animations fluides";
RELATE i18n_key:component_accordion_description->translation->language:en SET text = "Accordion component for collapsible content with fluid animations";
RELATE i18n_key:component_accordion_description->translation->language:es SET text = "Componente de accordéon para contenido plegable con animaciones fluidas";
RELATE i18n_key:component_accordion_description->translation->language:it SET text = "Componente di accordone per contenuto collapsibile con animazioni fluidi";
RELATE i18n_key:component_accordion_description->translation->language:de SET text = "Akordion-Komponente für einklappbare Inhalte mit flüssigen Animationen";

-- Création de l'URL de prévisualisation
CREATE url:accordion_preview SET
    url: "https://cdn.lyxal.b-cdn.net/icons/accordion.svg",
    description: "URL de prévisualisation du composant Accordéon";


COMMIT;