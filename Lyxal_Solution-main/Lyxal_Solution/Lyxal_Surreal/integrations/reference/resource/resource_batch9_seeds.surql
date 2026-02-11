-- Batch 9: 50 ressources Lyxal

CREATE resource:highlevel_highlevel SET
    identity = {
        name: "highlevel",
        slug: "highlevel_highlevel",
        display_name_i18n: i18n_key:resource_highlevel_highlevel_name,
        description_i18n: i18n_key:resource_highlevel_highlevel_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 401,
        tooltip_i18n: i18n_key:resource_highlevel_highlevel_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:highlevel,
    is_active: true;

CREATE resource:highlevelv1_contact SET
    identity = {
        name: "contact",
        slug: "highlevelv1_contact",
        display_name_i18n: i18n_key:resource_highlevelv1_contact_name,
        description_i18n: i18n_key:resource_highlevelv1_contact_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 402,
        tooltip_i18n: i18n_key:resource_highlevelv1_contact_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:highlevelv1,
    is_active: true;

CREATE resource:highlevelv1_opportunity SET
    identity = {
        name: "opportunity",
        slug: "highlevelv1_opportunity",
        display_name_i18n: i18n_key:resource_highlevelv1_opportunity_name,
        description_i18n: i18n_key:resource_highlevelv1_opportunity_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 403,
        tooltip_i18n: i18n_key:resource_highlevelv1_opportunity_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:highlevelv1,
    is_active: true;

CREATE resource:highlevelv1_task SET
    identity = {
        name: "task",
        slug: "highlevelv1_task",
        display_name_i18n: i18n_key:resource_highlevelv1_task_name,
        description_i18n: i18n_key:resource_highlevelv1_task_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 404,
        tooltip_i18n: i18n_key:resource_highlevelv1_task_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:highlevelv1,
    is_active: true;

CREATE resource:highlevelv2_contact SET
    identity = {
        name: "contact",
        slug: "highlevelv2_contact",
        display_name_i18n: i18n_key:resource_highlevelv2_contact_name,
        description_i18n: i18n_key:resource_highlevelv2_contact_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 405,
        tooltip_i18n: i18n_key:resource_highlevelv2_contact_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:highlevelv2,
    is_active: true;

CREATE resource:highlevelv2_opportunity SET
    identity = {
        name: "opportunity",
        slug: "highlevelv2_opportunity",
        display_name_i18n: i18n_key:resource_highlevelv2_opportunity_name,
        description_i18n: i18n_key:resource_highlevelv2_opportunity_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 406,
        tooltip_i18n: i18n_key:resource_highlevelv2_opportunity_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:highlevelv2,
    is_active: true;

CREATE resource:highlevelv2_task SET
    identity = {
        name: "task",
        slug: "highlevelv2_task",
        display_name_i18n: i18n_key:resource_highlevelv2_task_name,
        description_i18n: i18n_key:resource_highlevelv2_task_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 407,
        tooltip_i18n: i18n_key:resource_highlevelv2_task_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:highlevelv2,
    is_active: true;

CREATE resource:highlevelv2_calendar SET
    identity = {
        name: "calendar",
        slug: "highlevelv2_calendar",
        display_name_i18n: i18n_key:resource_highlevelv2_calendar_name,
        description_i18n: i18n_key:resource_highlevelv2_calendar_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 408,
        tooltip_i18n: i18n_key:resource_highlevelv2_calendar_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:highlevelv2,
    is_active: true;

CREATE resource:homeassistant_cameraProxy SET
    identity = {
        name: "cameraProxy",
        slug: "homeassistant_cameraProxy",
        display_name_i18n: i18n_key:resource_homeassistant_cameraProxy_name,
        description_i18n: i18n_key:resource_homeassistant_cameraProxy_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 409,
        tooltip_i18n: i18n_key:resource_homeassistant_cameraProxy_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:homeassistant,
    is_active: true;

CREATE resource:homeassistant_config SET
    identity = {
        name: "config",
        slug: "homeassistant_config",
        display_name_i18n: i18n_key:resource_homeassistant_config_name,
        description_i18n: i18n_key:resource_homeassistant_config_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 410,
        tooltip_i18n: i18n_key:resource_homeassistant_config_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:homeassistant,
    is_active: true;

CREATE resource:homeassistant_event SET
    identity = {
        name: "event",
        slug: "homeassistant_event",
        display_name_i18n: i18n_key:resource_homeassistant_event_name,
        description_i18n: i18n_key:resource_homeassistant_event_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 411,
        tooltip_i18n: i18n_key:resource_homeassistant_event_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:homeassistant,
    is_active: true;

CREATE resource:homeassistant_log SET
    identity = {
        name: "log",
        slug: "homeassistant_log",
        display_name_i18n: i18n_key:resource_homeassistant_log_name,
        description_i18n: i18n_key:resource_homeassistant_log_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 412,
        tooltip_i18n: i18n_key:resource_homeassistant_log_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: false,
            supports_read: true,
            supports_update: false,
            supports_delete: false,
            supports_list: true,
            supports_search: true
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:homeassistant,
    is_active: true;

CREATE resource:homeassistant_service SET
    identity = {
        name: "service",
        slug: "homeassistant_service",
        display_name_i18n: i18n_key:resource_homeassistant_service_name,
        description_i18n: i18n_key:resource_homeassistant_service_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 413,
        tooltip_i18n: i18n_key:resource_homeassistant_service_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:homeassistant,
    is_active: true;

CREATE resource:homeassistant_state SET
    identity = {
        name: "state",
        slug: "homeassistant_state",
        display_name_i18n: i18n_key:resource_homeassistant_state_name,
        description_i18n: i18n_key:resource_homeassistant_state_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 414,
        tooltip_i18n: i18n_key:resource_homeassistant_state_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:homeassistant,
    is_active: true;

CREATE resource:homeassistant_template SET
    identity = {
        name: "template",
        slug: "homeassistant_template",
        display_name_i18n: i18n_key:resource_homeassistant_template_name,
        description_i18n: i18n_key:resource_homeassistant_template_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 415,
        tooltip_i18n: i18n_key:resource_homeassistant_template_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:homeassistant,
    is_active: true;

CREATE resource:homeassistant_cameraproxy SET
    identity = {
        name: "cameraproxy",
        slug: "homeassistant_cameraproxy",
        display_name_i18n: i18n_key:resource_homeassistant_cameraproxy_name,
        description_i18n: i18n_key:resource_homeassistant_cameraproxy_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 416,
        tooltip_i18n: i18n_key:resource_homeassistant_cameraproxy_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:homeassistant,
    is_active: true;

CREATE resource:homeassistant_history SET
    identity = {
        name: "history",
        slug: "homeassistant_history",
        display_name_i18n: i18n_key:resource_homeassistant_history_name,
        description_i18n: i18n_key:resource_homeassistant_history_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 417,
        tooltip_i18n: i18n_key:resource_homeassistant_history_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: false,
            supports_read: true,
            supports_update: false,
            supports_delete: false,
            supports_list: true,
            supports_search: true
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:homeassistant,
    is_active: true;

CREATE resource:html_html SET
    identity = {
        name: "html",
        slug: "html_html",
        display_name_i18n: i18n_key:resource_html_html_name,
        description_i18n: i18n_key:resource_html_html_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 418,
        tooltip_i18n: i18n_key:resource_html_html_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:html,
    is_active: true;

CREATE resource:htmlextract_htmlextract SET
    identity = {
        name: "htmlextract",
        slug: "htmlextract_htmlextract",
        display_name_i18n: i18n_key:resource_htmlextract_htmlextract_name,
        description_i18n: i18n_key:resource_htmlextract_htmlextract_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 419,
        tooltip_i18n: i18n_key:resource_htmlextract_htmlextract_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:htmlextract,
    is_active: true;

CREATE resource:httprequest_httprequest SET
    identity = {
        name: "httprequest",
        slug: "httprequest_httprequest",
        display_name_i18n: i18n_key:resource_httprequest_httprequest_name,
        description_i18n: i18n_key:resource_httprequest_httprequest_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 420,
        tooltip_i18n: i18n_key:resource_httprequest_httprequest_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:httprequest,
    is_active: true;

CREATE resource:httprequestv1_httprequestv1 SET
    identity = {
        name: "httprequestv1",
        slug: "httprequestv1_httprequestv1",
        display_name_i18n: i18n_key:resource_httprequestv1_httprequestv1_name,
        description_i18n: i18n_key:resource_httprequestv1_httprequestv1_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 421,
        tooltip_i18n: i18n_key:resource_httprequestv1_httprequestv1_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:httprequestv1,
    is_active: true;

CREATE resource:httprequestv2_httprequestv2 SET
    identity = {
        name: "httprequestv2",
        slug: "httprequestv2_httprequestv2",
        display_name_i18n: i18n_key:resource_httprequestv2_httprequestv2_name,
        description_i18n: i18n_key:resource_httprequestv2_httprequestv2_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 422,
        tooltip_i18n: i18n_key:resource_httprequestv2_httprequestv2_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:httprequestv2,
    is_active: true;

CREATE resource:httprequestv3_httprequestv3 SET
    identity = {
        name: "httprequestv3",
        slug: "httprequestv3_httprequestv3",
        display_name_i18n: i18n_key:resource_httprequestv3_httprequestv3_name,
        description_i18n: i18n_key:resource_httprequestv3_httprequestv3_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 423,
        tooltip_i18n: i18n_key:resource_httprequestv3_httprequestv3_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:httprequestv3,
    is_active: true;

CREATE resource:hubspot_hubspot SET
    identity = {
        name: "hubspot",
        slug: "hubspot_hubspot",
        display_name_i18n: i18n_key:resource_hubspot_hubspot_name,
        description_i18n: i18n_key:resource_hubspot_hubspot_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 424,
        tooltip_i18n: i18n_key:resource_hubspot_hubspot_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:hubspot,
    is_active: true;

CREATE resource:hubspotv1_company SET
    identity = {
        name: "company",
        slug: "hubspotv1_company",
        display_name_i18n: i18n_key:resource_hubspotv1_company_name,
        description_i18n: i18n_key:resource_hubspotv1_company_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 425,
        tooltip_i18n: i18n_key:resource_hubspotv1_company_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:hubspotv1,
    is_active: true;

CREATE resource:hubspotv1_contact SET
    identity = {
        name: "contact",
        slug: "hubspotv1_contact",
        display_name_i18n: i18n_key:resource_hubspotv1_contact_name,
        description_i18n: i18n_key:resource_hubspotv1_contact_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 426,
        tooltip_i18n: i18n_key:resource_hubspotv1_contact_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:hubspotv1,
    is_active: true;

CREATE resource:hubspotv1_contactList SET
    identity = {
        name: "contactList",
        slug: "hubspotv1_contactList",
        display_name_i18n: i18n_key:resource_hubspotv1_contactList_name,
        description_i18n: i18n_key:resource_hubspotv1_contactList_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 427,
        tooltip_i18n: i18n_key:resource_hubspotv1_contactList_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:hubspotv1,
    is_active: true;

CREATE resource:hubspotv1_deal SET
    identity = {
        name: "deal",
        slug: "hubspotv1_deal",
        display_name_i18n: i18n_key:resource_hubspotv1_deal_name,
        description_i18n: i18n_key:resource_hubspotv1_deal_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 428,
        tooltip_i18n: i18n_key:resource_hubspotv1_deal_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:hubspotv1,
    is_active: true;

CREATE resource:hubspotv1_engagement SET
    identity = {
        name: "engagement",
        slug: "hubspotv1_engagement",
        display_name_i18n: i18n_key:resource_hubspotv1_engagement_name,
        description_i18n: i18n_key:resource_hubspotv1_engagement_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 429,
        tooltip_i18n: i18n_key:resource_hubspotv1_engagement_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:hubspotv1,
    is_active: true;

CREATE resource:hubspotv1_form SET
    identity = {
        name: "form",
        slug: "hubspotv1_form",
        display_name_i18n: i18n_key:resource_hubspotv1_form_name,
        description_i18n: i18n_key:resource_hubspotv1_form_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 430,
        tooltip_i18n: i18n_key:resource_hubspotv1_form_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:hubspotv1,
    is_active: true;

CREATE resource:hubspotv1_ticket SET
    identity = {
        name: "ticket",
        slug: "hubspotv1_ticket",
        display_name_i18n: i18n_key:resource_hubspotv1_ticket_name,
        description_i18n: i18n_key:resource_hubspotv1_ticket_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 431,
        tooltip_i18n: i18n_key:resource_hubspotv1_ticket_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:hubspotv1,
    is_active: true;

CREATE resource:hubspotv1_contactlist SET
    identity = {
        name: "contactlist",
        slug: "hubspotv1_contactlist",
        display_name_i18n: i18n_key:resource_hubspotv1_contactlist_name,
        description_i18n: i18n_key:resource_hubspotv1_contactlist_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 432,
        tooltip_i18n: i18n_key:resource_hubspotv1_contactlist_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:hubspotv1,
    is_active: true;

CREATE resource:hubspotv2_company SET
    identity = {
        name: "company",
        slug: "hubspotv2_company",
        display_name_i18n: i18n_key:resource_hubspotv2_company_name,
        description_i18n: i18n_key:resource_hubspotv2_company_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 433,
        tooltip_i18n: i18n_key:resource_hubspotv2_company_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:hubspotv2,
    is_active: true;

CREATE resource:hubspotv2_contact SET
    identity = {
        name: "contact",
        slug: "hubspotv2_contact",
        display_name_i18n: i18n_key:resource_hubspotv2_contact_name,
        description_i18n: i18n_key:resource_hubspotv2_contact_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 434,
        tooltip_i18n: i18n_key:resource_hubspotv2_contact_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:hubspotv2,
    is_active: true;

CREATE resource:hubspotv2_contactList SET
    identity = {
        name: "contactList",
        slug: "hubspotv2_contactList",
        display_name_i18n: i18n_key:resource_hubspotv2_contactList_name,
        description_i18n: i18n_key:resource_hubspotv2_contactList_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 435,
        tooltip_i18n: i18n_key:resource_hubspotv2_contactList_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:hubspotv2,
    is_active: true;

CREATE resource:hubspotv2_deal SET
    identity = {
        name: "deal",
        slug: "hubspotv2_deal",
        display_name_i18n: i18n_key:resource_hubspotv2_deal_name,
        description_i18n: i18n_key:resource_hubspotv2_deal_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 436,
        tooltip_i18n: i18n_key:resource_hubspotv2_deal_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:hubspotv2,
    is_active: true;

CREATE resource:hubspotv2_engagement SET
    identity = {
        name: "engagement",
        slug: "hubspotv2_engagement",
        display_name_i18n: i18n_key:resource_hubspotv2_engagement_name,
        description_i18n: i18n_key:resource_hubspotv2_engagement_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 437,
        tooltip_i18n: i18n_key:resource_hubspotv2_engagement_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:hubspotv2,
    is_active: true;

CREATE resource:hubspotv2_ticket SET
    identity = {
        name: "ticket",
        slug: "hubspotv2_ticket",
        display_name_i18n: i18n_key:resource_hubspotv2_ticket_name,
        description_i18n: i18n_key:resource_hubspotv2_ticket_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 438,
        tooltip_i18n: i18n_key:resource_hubspotv2_ticket_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:hubspotv2,
    is_active: true;

CREATE resource:hubspotv2_contactlist SET
    identity = {
        name: "contactlist",
        slug: "hubspotv2_contactlist",
        display_name_i18n: i18n_key:resource_hubspotv2_contactlist_name,
        description_i18n: i18n_key:resource_hubspotv2_contactlist_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 439,
        tooltip_i18n: i18n_key:resource_hubspotv2_contactlist_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:hubspotv2,
    is_active: true;

CREATE resource:humanticai_profile SET
    identity = {
        name: "profile",
        slug: "humanticai_profile",
        display_name_i18n: i18n_key:resource_humanticai_profile_name,
        description_i18n: i18n_key:resource_humanticai_profile_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 440,
        tooltip_i18n: i18n_key:resource_humanticai_profile_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:humanticai,
    is_active: true;

CREATE resource:hunter_hunter SET
    identity = {
        name: "hunter",
        slug: "hunter_hunter",
        display_name_i18n: i18n_key:resource_hunter_hunter_name,
        description_i18n: i18n_key:resource_hunter_hunter_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 441,
        tooltip_i18n: i18n_key:resource_hunter_hunter_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:hunter,
    is_active: true;

CREATE resource:icalendar_icalendar SET
    identity = {
        name: "icalendar",
        slug: "icalendar_icalendar",
        display_name_i18n: i18n_key:resource_icalendar_icalendar_name,
        description_i18n: i18n_key:resource_icalendar_icalendar_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 442,
        tooltip_i18n: i18n_key:resource_icalendar_icalendar_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:icalendar,
    is_active: true;

CREATE resource:if_if SET
    identity = {
        name: "if",
        slug: "if_if",
        display_name_i18n: i18n_key:resource_if_if_name,
        description_i18n: i18n_key:resource_if_if_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 443,
        tooltip_i18n: i18n_key:resource_if_if_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:if,
    is_active: true;

CREATE resource:ifv1_ifv1 SET
    identity = {
        name: "ifv1",
        slug: "ifv1_ifv1",
        display_name_i18n: i18n_key:resource_ifv1_ifv1_name,
        description_i18n: i18n_key:resource_ifv1_ifv1_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 444,
        tooltip_i18n: i18n_key:resource_ifv1_ifv1_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:ifv1,
    is_active: true;

CREATE resource:ifv2_ifv2 SET
    identity = {
        name: "ifv2",
        slug: "ifv2_ifv2",
        display_name_i18n: i18n_key:resource_ifv2_ifv2_name,
        description_i18n: i18n_key:resource_ifv2_ifv2_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 445,
        tooltip_i18n: i18n_key:resource_ifv2_ifv2_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:ifv2,
    is_active: true;

CREATE resource:intercom_company SET
    identity = {
        name: "company",
        slug: "intercom_company",
        display_name_i18n: i18n_key:resource_intercom_company_name,
        description_i18n: i18n_key:resource_intercom_company_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 446,
        tooltip_i18n: i18n_key:resource_intercom_company_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:intercom,
    is_active: true;

CREATE resource:intercom_lead SET
    identity = {
        name: "lead",
        slug: "intercom_lead",
        display_name_i18n: i18n_key:resource_intercom_lead_name,
        description_i18n: i18n_key:resource_intercom_lead_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 447,
        tooltip_i18n: i18n_key:resource_intercom_lead_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:intercom,
    is_active: true;

CREATE resource:intercom_user SET
    identity = {
        name: "user",
        slug: "intercom_user",
        display_name_i18n: i18n_key:resource_intercom_user_name,
        description_i18n: i18n_key:resource_intercom_user_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 448,
        tooltip_i18n: i18n_key:resource_intercom_user_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:intercom,
    is_active: true;

CREATE resource:interval_interval SET
    identity = {
        name: "interval",
        slug: "interval_interval",
        display_name_i18n: i18n_key:resource_interval_interval_name,
        description_i18n: i18n_key:resource_interval_interval_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 449,
        tooltip_i18n: i18n_key:resource_interval_interval_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:interval,
    is_active: true;

CREATE resource:invoiceninja_bank_transaction SET
    identity = {
        name: "bank_transaction",
        slug: "invoiceninja_bank_transaction",
        display_name_i18n: i18n_key:resource_invoiceninja_bank_transaction_name,
        description_i18n: i18n_key:resource_invoiceninja_bank_transaction_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 450,
        tooltip_i18n: i18n_key:resource_invoiceninja_bank_transaction_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:invoiceninja,
    is_active: true;

