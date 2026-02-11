-- ============================================================================
-- CATEGORIES DE COMPOSANTS - Données de référence
-- ============================================================================

-- Catégorie Layout
CREATE ui_component_library_category:layout SET
    identity = {
        value: "layout",
        slug: "layout",
        code: "layout"
    },
    presentation = {
        name_i18n: i18n_key:ui_component_library_category_layout_name,
        description_i18n: i18n_key:ui_component_library_category_layout_description,
        icon: icon:layout,
        color: "#3b82f6"
    },
    config = {
        order: 1,
        is_visible: true
    },
    status = {
        is_active: true,
        is_system_category: true
    },
    metadata = {
        component_count: 0,
        usage_count: 0
    };

-- Catégorie Input
CREATE ui_component_library_category:input SET
    identity = {
        value: "input",
        slug: "input",
        code: "input"
    },
    presentation = {
        name_i18n: i18n_key:ui_component_library_category_input_name,
        description_i18n: i18n_key:ui_component_library_category_input_description,
        icon: icon:input,
        color: "#10b981"
    },
    config = {
        order: 2,
        is_visible: true
    },
    status = {
        is_active: true,
        is_system_category: true
    },
    metadata = {
        component_count: 0,
        usage_count: 0
    };

-- Catégorie Data Display
CREATE ui_component_library_category:data_display SET
    identity = {
        value: "data-display",
        slug: "data-display",
        code: "data_display"
    },
    presentation = {
        name_i18n: i18n_key:ui_component_library_category_data_display_name,
        description_i18n: i18n_key:ui_component_library_category_data_display_description,
        icon: icon:table,
        color: "#f59e0b"
    },
    config = {
        order: 3,
        is_visible: true
    },
    status = {
        is_active: true,
        is_system_category: true
    },
    metadata = {
        component_count: 0,
        usage_count: 0
    };

-- Catégorie Navigation
CREATE ui_component_library_category:navigation SET
    identity = {
        value: "navigation",
        slug: "navigation",
        code: "navigation"
    },
    presentation = {
        name_i18n: i18n_key:ui_component_library_category_navigation_name,
        description_i18n: i18n_key:ui_component_library_category_navigation_description,
        icon: icon:navigation,
        color: "#8b5cf6"
    },
    config = {
        order: 4,
        is_visible: true
    },
    status = {
        is_active: true,
        is_system_category: true
    },
    metadata = {
        component_count: 0,
        usage_count: 0
    };

-- Catégorie Feedback
CREATE ui_component_library_category:feedback SET
    identity = {
        value: "feedback",
        slug: "feedback",
        code: "feedback"
    },
    presentation = {
        name_i18n: i18n_key:ui_component_library_category_feedback_name,
        description_i18n: i18n_key:ui_component_library_category_feedback_description,
        icon: icon:alert_triangle,
        color: "#ef4444"
    },
    config = {
        order: 5,
        is_visible: true
    },
    status = {
        is_active: true,
        is_system_category: true
    },
    metadata = {
        component_count: 0,
        usage_count: 0
    };

-- Catégorie Overlay
CREATE ui_component_library_category:overlay SET
    identity = {
        value: "overlay",
        slug: "overlay",
        code: "overlay"
    },
    presentation = {
        name_i18n: i18n_key:ui_component_library_category_overlay_name,
        description_i18n: i18n_key:ui_component_library_category_overlay_description,
        icon: icon:layers,
        color: "#06b6d4"
    },
    config = {
        order: 6,
        is_visible: true
    },
    status = {
        is_active: true,
        is_system_category: true
    },
    metadata = {
        component_count: 0,
        usage_count: 0
    };
