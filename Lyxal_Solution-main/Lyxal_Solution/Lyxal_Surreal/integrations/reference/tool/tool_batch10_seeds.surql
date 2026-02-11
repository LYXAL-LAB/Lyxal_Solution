-- Batch 10: 100 tools Lyxal

CREATE tool:harvest_timeentry_get SET
    identity = {
        name: "get",
        slug: "harvest_timeentry_get",
        display_name_i18n: i18n_key:tool_harvest_timeentry_get_name,
        description_i18n: i18n_key:tool_harvest_timeentry_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 901,
        tooltip_i18n: i18n_key:tool_harvest_timeentry_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_harvest_timeentry_get_success,
        error_message_i18n: i18n_key:tool_harvest_timeentry_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:harvest_timeentry,
    is_active: true;

CREATE tool:harvest_timeentry_getMany SET
    identity = {
        name: "getMany",
        slug: "harvest_timeentry_getMany",
        display_name_i18n: i18n_key:tool_harvest_timeentry_getMany_name,
        description_i18n: i18n_key:tool_harvest_timeentry_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 902,
        tooltip_i18n: i18n_key:tool_harvest_timeentry_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_harvest_timeentry_getMany_success,
        error_message_i18n: i18n_key:tool_harvest_timeentry_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:harvest_timeentry,
    is_active: true;

CREATE tool:helpscout_conversation_get SET
    identity = {
        name: "get",
        slug: "helpscout_conversation_get",
        display_name_i18n: i18n_key:tool_helpscout_conversation_get_name,
        description_i18n: i18n_key:tool_helpscout_conversation_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 903,
        tooltip_i18n: i18n_key:tool_helpscout_conversation_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_helpscout_conversation_get_success,
        error_message_i18n: i18n_key:tool_helpscout_conversation_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:helpscout_conversation,
    is_active: true;

CREATE tool:helpscout_conversation_getMany SET
    identity = {
        name: "getMany",
        slug: "helpscout_conversation_getMany",
        display_name_i18n: i18n_key:tool_helpscout_conversation_getMany_name,
        description_i18n: i18n_key:tool_helpscout_conversation_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 904,
        tooltip_i18n: i18n_key:tool_helpscout_conversation_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_helpscout_conversation_getMany_success,
        error_message_i18n: i18n_key:tool_helpscout_conversation_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:helpscout_conversation,
    is_active: true;

CREATE tool:helpscout_customer_get SET
    identity = {
        name: "get",
        slug: "helpscout_customer_get",
        display_name_i18n: i18n_key:tool_helpscout_customer_get_name,
        description_i18n: i18n_key:tool_helpscout_customer_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 905,
        tooltip_i18n: i18n_key:tool_helpscout_customer_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_helpscout_customer_get_success,
        error_message_i18n: i18n_key:tool_helpscout_customer_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:helpscout_customer,
    is_active: true;

CREATE tool:helpscout_customer_getMany SET
    identity = {
        name: "getMany",
        slug: "helpscout_customer_getMany",
        display_name_i18n: i18n_key:tool_helpscout_customer_getMany_name,
        description_i18n: i18n_key:tool_helpscout_customer_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 906,
        tooltip_i18n: i18n_key:tool_helpscout_customer_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_helpscout_customer_getMany_success,
        error_message_i18n: i18n_key:tool_helpscout_customer_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:helpscout_customer,
    is_active: true;

CREATE tool:helpscout_mailbox_get SET
    identity = {
        name: "get",
        slug: "helpscout_mailbox_get",
        display_name_i18n: i18n_key:tool_helpscout_mailbox_get_name,
        description_i18n: i18n_key:tool_helpscout_mailbox_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 907,
        tooltip_i18n: i18n_key:tool_helpscout_mailbox_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_helpscout_mailbox_get_success,
        error_message_i18n: i18n_key:tool_helpscout_mailbox_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:helpscout_mailbox,
    is_active: true;

CREATE tool:helpscout_mailbox_getMany SET
    identity = {
        name: "getMany",
        slug: "helpscout_mailbox_getMany",
        display_name_i18n: i18n_key:tool_helpscout_mailbox_getMany_name,
        description_i18n: i18n_key:tool_helpscout_mailbox_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 908,
        tooltip_i18n: i18n_key:tool_helpscout_mailbox_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_helpscout_mailbox_getMany_success,
        error_message_i18n: i18n_key:tool_helpscout_mailbox_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:helpscout_mailbox,
    is_active: true;

CREATE tool:helpscout_thread_get SET
    identity = {
        name: "get",
        slug: "helpscout_thread_get",
        display_name_i18n: i18n_key:tool_helpscout_thread_get_name,
        description_i18n: i18n_key:tool_helpscout_thread_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 909,
        tooltip_i18n: i18n_key:tool_helpscout_thread_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_helpscout_thread_get_success,
        error_message_i18n: i18n_key:tool_helpscout_thread_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:helpscout_thread,
    is_active: true;

CREATE tool:helpscout_thread_getMany SET
    identity = {
        name: "getMany",
        slug: "helpscout_thread_getMany",
        display_name_i18n: i18n_key:tool_helpscout_thread_getMany_name,
        description_i18n: i18n_key:tool_helpscout_thread_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 910,
        tooltip_i18n: i18n_key:tool_helpscout_thread_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_helpscout_thread_getMany_success,
        error_message_i18n: i18n_key:tool_helpscout_thread_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:helpscout_thread,
    is_active: true;

CREATE tool:highlevel_highlevel_get SET
    identity = {
        name: "get",
        slug: "highlevel_highlevel_get",
        display_name_i18n: i18n_key:tool_highlevel_highlevel_get_name,
        description_i18n: i18n_key:tool_highlevel_highlevel_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 911,
        tooltip_i18n: i18n_key:tool_highlevel_highlevel_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_highlevel_highlevel_get_success,
        error_message_i18n: i18n_key:tool_highlevel_highlevel_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:highlevel_highlevel,
    is_active: true;

CREATE tool:highlevel_highlevel_getMany SET
    identity = {
        name: "getMany",
        slug: "highlevel_highlevel_getMany",
        display_name_i18n: i18n_key:tool_highlevel_highlevel_getMany_name,
        description_i18n: i18n_key:tool_highlevel_highlevel_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 912,
        tooltip_i18n: i18n_key:tool_highlevel_highlevel_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_highlevel_highlevel_getMany_success,
        error_message_i18n: i18n_key:tool_highlevel_highlevel_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:highlevel_highlevel,
    is_active: true;

CREATE tool:highlevelv1_contact_get SET
    identity = {
        name: "get",
        slug: "highlevelv1_contact_get",
        display_name_i18n: i18n_key:tool_highlevelv1_contact_get_name,
        description_i18n: i18n_key:tool_highlevelv1_contact_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 913,
        tooltip_i18n: i18n_key:tool_highlevelv1_contact_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_highlevelv1_contact_get_success,
        error_message_i18n: i18n_key:tool_highlevelv1_contact_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:highlevelv1_contact,
    is_active: true;

CREATE tool:highlevelv1_contact_getMany SET
    identity = {
        name: "getMany",
        slug: "highlevelv1_contact_getMany",
        display_name_i18n: i18n_key:tool_highlevelv1_contact_getMany_name,
        description_i18n: i18n_key:tool_highlevelv1_contact_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 914,
        tooltip_i18n: i18n_key:tool_highlevelv1_contact_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_highlevelv1_contact_getMany_success,
        error_message_i18n: i18n_key:tool_highlevelv1_contact_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:highlevelv1_contact,
    is_active: true;

CREATE tool:highlevelv1_opportunity_get SET
    identity = {
        name: "get",
        slug: "highlevelv1_opportunity_get",
        display_name_i18n: i18n_key:tool_highlevelv1_opportunity_get_name,
        description_i18n: i18n_key:tool_highlevelv1_opportunity_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 915,
        tooltip_i18n: i18n_key:tool_highlevelv1_opportunity_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_highlevelv1_opportunity_get_success,
        error_message_i18n: i18n_key:tool_highlevelv1_opportunity_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:highlevelv1_opportunity,
    is_active: true;

CREATE tool:highlevelv1_opportunity_getMany SET
    identity = {
        name: "getMany",
        slug: "highlevelv1_opportunity_getMany",
        display_name_i18n: i18n_key:tool_highlevelv1_opportunity_getMany_name,
        description_i18n: i18n_key:tool_highlevelv1_opportunity_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 916,
        tooltip_i18n: i18n_key:tool_highlevelv1_opportunity_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_highlevelv1_opportunity_getMany_success,
        error_message_i18n: i18n_key:tool_highlevelv1_opportunity_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:highlevelv1_opportunity,
    is_active: true;

CREATE tool:highlevelv1_task_get SET
    identity = {
        name: "get",
        slug: "highlevelv1_task_get",
        display_name_i18n: i18n_key:tool_highlevelv1_task_get_name,
        description_i18n: i18n_key:tool_highlevelv1_task_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 917,
        tooltip_i18n: i18n_key:tool_highlevelv1_task_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_highlevelv1_task_get_success,
        error_message_i18n: i18n_key:tool_highlevelv1_task_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:highlevelv1_task,
    is_active: true;

CREATE tool:highlevelv1_task_getMany SET
    identity = {
        name: "getMany",
        slug: "highlevelv1_task_getMany",
        display_name_i18n: i18n_key:tool_highlevelv1_task_getMany_name,
        description_i18n: i18n_key:tool_highlevelv1_task_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 918,
        tooltip_i18n: i18n_key:tool_highlevelv1_task_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_highlevelv1_task_getMany_success,
        error_message_i18n: i18n_key:tool_highlevelv1_task_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:highlevelv1_task,
    is_active: true;

CREATE tool:highlevelv2_contact_get SET
    identity = {
        name: "get",
        slug: "highlevelv2_contact_get",
        display_name_i18n: i18n_key:tool_highlevelv2_contact_get_name,
        description_i18n: i18n_key:tool_highlevelv2_contact_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 919,
        tooltip_i18n: i18n_key:tool_highlevelv2_contact_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_highlevelv2_contact_get_success,
        error_message_i18n: i18n_key:tool_highlevelv2_contact_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:highlevelv2_contact,
    is_active: true;

CREATE tool:highlevelv2_contact_getMany SET
    identity = {
        name: "getMany",
        slug: "highlevelv2_contact_getMany",
        display_name_i18n: i18n_key:tool_highlevelv2_contact_getMany_name,
        description_i18n: i18n_key:tool_highlevelv2_contact_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 920,
        tooltip_i18n: i18n_key:tool_highlevelv2_contact_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_highlevelv2_contact_getMany_success,
        error_message_i18n: i18n_key:tool_highlevelv2_contact_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:highlevelv2_contact,
    is_active: true;

CREATE tool:highlevelv2_opportunity_get SET
    identity = {
        name: "get",
        slug: "highlevelv2_opportunity_get",
        display_name_i18n: i18n_key:tool_highlevelv2_opportunity_get_name,
        description_i18n: i18n_key:tool_highlevelv2_opportunity_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 921,
        tooltip_i18n: i18n_key:tool_highlevelv2_opportunity_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_highlevelv2_opportunity_get_success,
        error_message_i18n: i18n_key:tool_highlevelv2_opportunity_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:highlevelv2_opportunity,
    is_active: true;

CREATE tool:highlevelv2_opportunity_getMany SET
    identity = {
        name: "getMany",
        slug: "highlevelv2_opportunity_getMany",
        display_name_i18n: i18n_key:tool_highlevelv2_opportunity_getMany_name,
        description_i18n: i18n_key:tool_highlevelv2_opportunity_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 922,
        tooltip_i18n: i18n_key:tool_highlevelv2_opportunity_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_highlevelv2_opportunity_getMany_success,
        error_message_i18n: i18n_key:tool_highlevelv2_opportunity_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:highlevelv2_opportunity,
    is_active: true;

CREATE tool:highlevelv2_task_get SET
    identity = {
        name: "get",
        slug: "highlevelv2_task_get",
        display_name_i18n: i18n_key:tool_highlevelv2_task_get_name,
        description_i18n: i18n_key:tool_highlevelv2_task_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 923,
        tooltip_i18n: i18n_key:tool_highlevelv2_task_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_highlevelv2_task_get_success,
        error_message_i18n: i18n_key:tool_highlevelv2_task_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:highlevelv2_task,
    is_active: true;

CREATE tool:highlevelv2_task_getMany SET
    identity = {
        name: "getMany",
        slug: "highlevelv2_task_getMany",
        display_name_i18n: i18n_key:tool_highlevelv2_task_getMany_name,
        description_i18n: i18n_key:tool_highlevelv2_task_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 924,
        tooltip_i18n: i18n_key:tool_highlevelv2_task_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_highlevelv2_task_getMany_success,
        error_message_i18n: i18n_key:tool_highlevelv2_task_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:highlevelv2_task,
    is_active: true;

CREATE tool:highlevelv2_calendar_get SET
    identity = {
        name: "get",
        slug: "highlevelv2_calendar_get",
        display_name_i18n: i18n_key:tool_highlevelv2_calendar_get_name,
        description_i18n: i18n_key:tool_highlevelv2_calendar_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 925,
        tooltip_i18n: i18n_key:tool_highlevelv2_calendar_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_highlevelv2_calendar_get_success,
        error_message_i18n: i18n_key:tool_highlevelv2_calendar_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:highlevelv2_calendar,
    is_active: true;

CREATE tool:highlevelv2_calendar_getMany SET
    identity = {
        name: "getMany",
        slug: "highlevelv2_calendar_getMany",
        display_name_i18n: i18n_key:tool_highlevelv2_calendar_getMany_name,
        description_i18n: i18n_key:tool_highlevelv2_calendar_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 926,
        tooltip_i18n: i18n_key:tool_highlevelv2_calendar_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_highlevelv2_calendar_getMany_success,
        error_message_i18n: i18n_key:tool_highlevelv2_calendar_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:highlevelv2_calendar,
    is_active: true;

CREATE tool:homeassistant_cameraProxy_get SET
    identity = {
        name: "get",
        slug: "homeassistant_cameraProxy_get",
        display_name_i18n: i18n_key:tool_homeassistant_cameraProxy_get_name,
        description_i18n: i18n_key:tool_homeassistant_cameraProxy_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 927,
        tooltip_i18n: i18n_key:tool_homeassistant_cameraProxy_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_homeassistant_cameraProxy_get_success,
        error_message_i18n: i18n_key:tool_homeassistant_cameraProxy_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:homeassistant_cameraProxy,
    is_active: true;

CREATE tool:homeassistant_cameraProxy_getMany SET
    identity = {
        name: "getMany",
        slug: "homeassistant_cameraProxy_getMany",
        display_name_i18n: i18n_key:tool_homeassistant_cameraProxy_getMany_name,
        description_i18n: i18n_key:tool_homeassistant_cameraProxy_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 928,
        tooltip_i18n: i18n_key:tool_homeassistant_cameraProxy_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_homeassistant_cameraProxy_getMany_success,
        error_message_i18n: i18n_key:tool_homeassistant_cameraProxy_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:homeassistant_cameraProxy,
    is_active: true;

CREATE tool:homeassistant_config_get SET
    identity = {
        name: "get",
        slug: "homeassistant_config_get",
        display_name_i18n: i18n_key:tool_homeassistant_config_get_name,
        description_i18n: i18n_key:tool_homeassistant_config_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 929,
        tooltip_i18n: i18n_key:tool_homeassistant_config_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_homeassistant_config_get_success,
        error_message_i18n: i18n_key:tool_homeassistant_config_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:homeassistant_config,
    is_active: true;

CREATE tool:homeassistant_config_getMany SET
    identity = {
        name: "getMany",
        slug: "homeassistant_config_getMany",
        display_name_i18n: i18n_key:tool_homeassistant_config_getMany_name,
        description_i18n: i18n_key:tool_homeassistant_config_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 930,
        tooltip_i18n: i18n_key:tool_homeassistant_config_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_homeassistant_config_getMany_success,
        error_message_i18n: i18n_key:tool_homeassistant_config_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:homeassistant_config,
    is_active: true;

CREATE tool:homeassistant_event_get SET
    identity = {
        name: "get",
        slug: "homeassistant_event_get",
        display_name_i18n: i18n_key:tool_homeassistant_event_get_name,
        description_i18n: i18n_key:tool_homeassistant_event_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 931,
        tooltip_i18n: i18n_key:tool_homeassistant_event_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_homeassistant_event_get_success,
        error_message_i18n: i18n_key:tool_homeassistant_event_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:homeassistant_event,
    is_active: true;

CREATE tool:homeassistant_event_getMany SET
    identity = {
        name: "getMany",
        slug: "homeassistant_event_getMany",
        display_name_i18n: i18n_key:tool_homeassistant_event_getMany_name,
        description_i18n: i18n_key:tool_homeassistant_event_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 932,
        tooltip_i18n: i18n_key:tool_homeassistant_event_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_homeassistant_event_getMany_success,
        error_message_i18n: i18n_key:tool_homeassistant_event_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:homeassistant_event,
    is_active: true;

CREATE tool:homeassistant_log_get SET
    identity = {
        name: "get",
        slug: "homeassistant_log_get",
        display_name_i18n: i18n_key:tool_homeassistant_log_get_name,
        description_i18n: i18n_key:tool_homeassistant_log_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 933,
        tooltip_i18n: i18n_key:tool_homeassistant_log_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_homeassistant_log_get_success,
        error_message_i18n: i18n_key:tool_homeassistant_log_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:homeassistant_log,
    is_active: true;

CREATE tool:homeassistant_log_getMany SET
    identity = {
        name: "getMany",
        slug: "homeassistant_log_getMany",
        display_name_i18n: i18n_key:tool_homeassistant_log_getMany_name,
        description_i18n: i18n_key:tool_homeassistant_log_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 934,
        tooltip_i18n: i18n_key:tool_homeassistant_log_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_homeassistant_log_getMany_success,
        error_message_i18n: i18n_key:tool_homeassistant_log_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:homeassistant_log,
    is_active: true;

CREATE tool:homeassistant_service_get SET
    identity = {
        name: "get",
        slug: "homeassistant_service_get",
        display_name_i18n: i18n_key:tool_homeassistant_service_get_name,
        description_i18n: i18n_key:tool_homeassistant_service_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 935,
        tooltip_i18n: i18n_key:tool_homeassistant_service_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_homeassistant_service_get_success,
        error_message_i18n: i18n_key:tool_homeassistant_service_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:homeassistant_service,
    is_active: true;

CREATE tool:homeassistant_service_getMany SET
    identity = {
        name: "getMany",
        slug: "homeassistant_service_getMany",
        display_name_i18n: i18n_key:tool_homeassistant_service_getMany_name,
        description_i18n: i18n_key:tool_homeassistant_service_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 936,
        tooltip_i18n: i18n_key:tool_homeassistant_service_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_homeassistant_service_getMany_success,
        error_message_i18n: i18n_key:tool_homeassistant_service_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:homeassistant_service,
    is_active: true;

CREATE tool:homeassistant_state_get SET
    identity = {
        name: "get",
        slug: "homeassistant_state_get",
        display_name_i18n: i18n_key:tool_homeassistant_state_get_name,
        description_i18n: i18n_key:tool_homeassistant_state_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 937,
        tooltip_i18n: i18n_key:tool_homeassistant_state_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_homeassistant_state_get_success,
        error_message_i18n: i18n_key:tool_homeassistant_state_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:homeassistant_state,
    is_active: true;

CREATE tool:homeassistant_state_getMany SET
    identity = {
        name: "getMany",
        slug: "homeassistant_state_getMany",
        display_name_i18n: i18n_key:tool_homeassistant_state_getMany_name,
        description_i18n: i18n_key:tool_homeassistant_state_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 938,
        tooltip_i18n: i18n_key:tool_homeassistant_state_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_homeassistant_state_getMany_success,
        error_message_i18n: i18n_key:tool_homeassistant_state_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:homeassistant_state,
    is_active: true;

CREATE tool:homeassistant_template_get SET
    identity = {
        name: "get",
        slug: "homeassistant_template_get",
        display_name_i18n: i18n_key:tool_homeassistant_template_get_name,
        description_i18n: i18n_key:tool_homeassistant_template_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 939,
        tooltip_i18n: i18n_key:tool_homeassistant_template_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_homeassistant_template_get_success,
        error_message_i18n: i18n_key:tool_homeassistant_template_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:homeassistant_template,
    is_active: true;

CREATE tool:homeassistant_template_getMany SET
    identity = {
        name: "getMany",
        slug: "homeassistant_template_getMany",
        display_name_i18n: i18n_key:tool_homeassistant_template_getMany_name,
        description_i18n: i18n_key:tool_homeassistant_template_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 940,
        tooltip_i18n: i18n_key:tool_homeassistant_template_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_homeassistant_template_getMany_success,
        error_message_i18n: i18n_key:tool_homeassistant_template_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:homeassistant_template,
    is_active: true;

CREATE tool:homeassistant_cameraproxy_get SET
    identity = {
        name: "get",
        slug: "homeassistant_cameraproxy_get",
        display_name_i18n: i18n_key:tool_homeassistant_cameraproxy_get_name,
        description_i18n: i18n_key:tool_homeassistant_cameraproxy_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 941,
        tooltip_i18n: i18n_key:tool_homeassistant_cameraproxy_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_homeassistant_cameraproxy_get_success,
        error_message_i18n: i18n_key:tool_homeassistant_cameraproxy_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:homeassistant_cameraproxy,
    is_active: true;

CREATE tool:homeassistant_cameraproxy_getMany SET
    identity = {
        name: "getMany",
        slug: "homeassistant_cameraproxy_getMany",
        display_name_i18n: i18n_key:tool_homeassistant_cameraproxy_getMany_name,
        description_i18n: i18n_key:tool_homeassistant_cameraproxy_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 942,
        tooltip_i18n: i18n_key:tool_homeassistant_cameraproxy_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_homeassistant_cameraproxy_getMany_success,
        error_message_i18n: i18n_key:tool_homeassistant_cameraproxy_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:homeassistant_cameraproxy,
    is_active: true;

CREATE tool:homeassistant_history_get SET
    identity = {
        name: "get",
        slug: "homeassistant_history_get",
        display_name_i18n: i18n_key:tool_homeassistant_history_get_name,
        description_i18n: i18n_key:tool_homeassistant_history_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 943,
        tooltip_i18n: i18n_key:tool_homeassistant_history_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_homeassistant_history_get_success,
        error_message_i18n: i18n_key:tool_homeassistant_history_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:homeassistant_history,
    is_active: true;

CREATE tool:homeassistant_history_getMany SET
    identity = {
        name: "getMany",
        slug: "homeassistant_history_getMany",
        display_name_i18n: i18n_key:tool_homeassistant_history_getMany_name,
        description_i18n: i18n_key:tool_homeassistant_history_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 944,
        tooltip_i18n: i18n_key:tool_homeassistant_history_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_homeassistant_history_getMany_success,
        error_message_i18n: i18n_key:tool_homeassistant_history_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:homeassistant_history,
    is_active: true;

CREATE tool:html_html_generateHtmlTemplate SET
    identity = {
        name: "generateHtmlTemplate",
        slug: "html_html_generateHtmlTemplate",
        display_name_i18n: i18n_key:tool_html_html_generateHtmlTemplate_name,
        description_i18n: i18n_key:tool_html_html_generateHtmlTemplate_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 945,
        tooltip_i18n: i18n_key:tool_html_html_generateHtmlTemplate_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_html_html_generateHtmlTemplate_success,
        error_message_i18n: i18n_key:tool_html_html_generateHtmlTemplate_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "POST",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:html_html,
    is_active: true;

CREATE tool:html_html_extractHtmlContent SET
    identity = {
        name: "extractHtmlContent",
        slug: "html_html_extractHtmlContent",
        display_name_i18n: i18n_key:tool_html_html_extractHtmlContent_name,
        description_i18n: i18n_key:tool_html_html_extractHtmlContent_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 946,
        tooltip_i18n: i18n_key:tool_html_html_extractHtmlContent_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_html_html_extractHtmlContent_success,
        error_message_i18n: i18n_key:tool_html_html_extractHtmlContent_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "POST",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:html_html,
    is_active: true;

CREATE tool:html_html_convertToHtmlTable SET
    identity = {
        name: "convertToHtmlTable",
        slug: "html_html_convertToHtmlTable",
        display_name_i18n: i18n_key:tool_html_html_convertToHtmlTable_name,
        description_i18n: i18n_key:tool_html_html_convertToHtmlTable_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 947,
        tooltip_i18n: i18n_key:tool_html_html_convertToHtmlTable_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_html_html_convertToHtmlTable_success,
        error_message_i18n: i18n_key:tool_html_html_convertToHtmlTable_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "POST",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:html_html,
    is_active: true;

CREATE tool:htmlextract_htmlextract_get SET
    identity = {
        name: "get",
        slug: "htmlextract_htmlextract_get",
        display_name_i18n: i18n_key:tool_htmlextract_htmlextract_get_name,
        description_i18n: i18n_key:tool_htmlextract_htmlextract_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 948,
        tooltip_i18n: i18n_key:tool_htmlextract_htmlextract_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_htmlextract_htmlextract_get_success,
        error_message_i18n: i18n_key:tool_htmlextract_htmlextract_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:htmlextract_htmlextract,
    is_active: true;

CREATE tool:htmlextract_htmlextract_getMany SET
    identity = {
        name: "getMany",
        slug: "htmlextract_htmlextract_getMany",
        display_name_i18n: i18n_key:tool_htmlextract_htmlextract_getMany_name,
        description_i18n: i18n_key:tool_htmlextract_htmlextract_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 949,
        tooltip_i18n: i18n_key:tool_htmlextract_htmlextract_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_htmlextract_htmlextract_getMany_success,
        error_message_i18n: i18n_key:tool_htmlextract_htmlextract_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:htmlextract_htmlextract,
    is_active: true;

CREATE tool:httprequest_httprequest_get SET
    identity = {
        name: "get",
        slug: "httprequest_httprequest_get",
        display_name_i18n: i18n_key:tool_httprequest_httprequest_get_name,
        description_i18n: i18n_key:tool_httprequest_httprequest_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 950,
        tooltip_i18n: i18n_key:tool_httprequest_httprequest_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_httprequest_httprequest_get_success,
        error_message_i18n: i18n_key:tool_httprequest_httprequest_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:httprequest_httprequest,
    is_active: true;

CREATE tool:httprequest_httprequest_getMany SET
    identity = {
        name: "getMany",
        slug: "httprequest_httprequest_getMany",
        display_name_i18n: i18n_key:tool_httprequest_httprequest_getMany_name,
        description_i18n: i18n_key:tool_httprequest_httprequest_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 951,
        tooltip_i18n: i18n_key:tool_httprequest_httprequest_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_httprequest_httprequest_getMany_success,
        error_message_i18n: i18n_key:tool_httprequest_httprequest_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:httprequest_httprequest,
    is_active: true;

CREATE tool:httprequestv1_httprequestv1_get SET
    identity = {
        name: "get",
        slug: "httprequestv1_httprequestv1_get",
        display_name_i18n: i18n_key:tool_httprequestv1_httprequestv1_get_name,
        description_i18n: i18n_key:tool_httprequestv1_httprequestv1_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 952,
        tooltip_i18n: i18n_key:tool_httprequestv1_httprequestv1_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_httprequestv1_httprequestv1_get_success,
        error_message_i18n: i18n_key:tool_httprequestv1_httprequestv1_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:httprequestv1_httprequestv1,
    is_active: true;

CREATE tool:httprequestv1_httprequestv1_getMany SET
    identity = {
        name: "getMany",
        slug: "httprequestv1_httprequestv1_getMany",
        display_name_i18n: i18n_key:tool_httprequestv1_httprequestv1_getMany_name,
        description_i18n: i18n_key:tool_httprequestv1_httprequestv1_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 953,
        tooltip_i18n: i18n_key:tool_httprequestv1_httprequestv1_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_httprequestv1_httprequestv1_getMany_success,
        error_message_i18n: i18n_key:tool_httprequestv1_httprequestv1_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:httprequestv1_httprequestv1,
    is_active: true;

CREATE tool:httprequestv2_httprequestv2_get SET
    identity = {
        name: "get",
        slug: "httprequestv2_httprequestv2_get",
        display_name_i18n: i18n_key:tool_httprequestv2_httprequestv2_get_name,
        description_i18n: i18n_key:tool_httprequestv2_httprequestv2_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 954,
        tooltip_i18n: i18n_key:tool_httprequestv2_httprequestv2_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_httprequestv2_httprequestv2_get_success,
        error_message_i18n: i18n_key:tool_httprequestv2_httprequestv2_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:httprequestv2_httprequestv2,
    is_active: true;

CREATE tool:httprequestv2_httprequestv2_getMany SET
    identity = {
        name: "getMany",
        slug: "httprequestv2_httprequestv2_getMany",
        display_name_i18n: i18n_key:tool_httprequestv2_httprequestv2_getMany_name,
        description_i18n: i18n_key:tool_httprequestv2_httprequestv2_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 955,
        tooltip_i18n: i18n_key:tool_httprequestv2_httprequestv2_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_httprequestv2_httprequestv2_getMany_success,
        error_message_i18n: i18n_key:tool_httprequestv2_httprequestv2_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:httprequestv2_httprequestv2,
    is_active: true;

CREATE tool:httprequestv3_httprequestv3_get SET
    identity = {
        name: "get",
        slug: "httprequestv3_httprequestv3_get",
        display_name_i18n: i18n_key:tool_httprequestv3_httprequestv3_get_name,
        description_i18n: i18n_key:tool_httprequestv3_httprequestv3_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 956,
        tooltip_i18n: i18n_key:tool_httprequestv3_httprequestv3_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_httprequestv3_httprequestv3_get_success,
        error_message_i18n: i18n_key:tool_httprequestv3_httprequestv3_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:httprequestv3_httprequestv3,
    is_active: true;

CREATE tool:httprequestv3_httprequestv3_getMany SET
    identity = {
        name: "getMany",
        slug: "httprequestv3_httprequestv3_getMany",
        display_name_i18n: i18n_key:tool_httprequestv3_httprequestv3_getMany_name,
        description_i18n: i18n_key:tool_httprequestv3_httprequestv3_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 957,
        tooltip_i18n: i18n_key:tool_httprequestv3_httprequestv3_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_httprequestv3_httprequestv3_getMany_success,
        error_message_i18n: i18n_key:tool_httprequestv3_httprequestv3_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:httprequestv3_httprequestv3,
    is_active: true;

CREATE tool:hubspot_hubspot_get SET
    identity = {
        name: "get",
        slug: "hubspot_hubspot_get",
        display_name_i18n: i18n_key:tool_hubspot_hubspot_get_name,
        description_i18n: i18n_key:tool_hubspot_hubspot_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 958,
        tooltip_i18n: i18n_key:tool_hubspot_hubspot_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_hubspot_hubspot_get_success,
        error_message_i18n: i18n_key:tool_hubspot_hubspot_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:hubspot_hubspot,
    is_active: true;

CREATE tool:hubspot_hubspot_getMany SET
    identity = {
        name: "getMany",
        slug: "hubspot_hubspot_getMany",
        display_name_i18n: i18n_key:tool_hubspot_hubspot_getMany_name,
        description_i18n: i18n_key:tool_hubspot_hubspot_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 959,
        tooltip_i18n: i18n_key:tool_hubspot_hubspot_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_hubspot_hubspot_getMany_success,
        error_message_i18n: i18n_key:tool_hubspot_hubspot_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:hubspot_hubspot,
    is_active: true;

CREATE tool:hubspotv1_company_get SET
    identity = {
        name: "get",
        slug: "hubspotv1_company_get",
        display_name_i18n: i18n_key:tool_hubspotv1_company_get_name,
        description_i18n: i18n_key:tool_hubspotv1_company_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 960,
        tooltip_i18n: i18n_key:tool_hubspotv1_company_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_hubspotv1_company_get_success,
        error_message_i18n: i18n_key:tool_hubspotv1_company_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:hubspotv1_company,
    is_active: true;

CREATE tool:hubspotv1_company_getMany SET
    identity = {
        name: "getMany",
        slug: "hubspotv1_company_getMany",
        display_name_i18n: i18n_key:tool_hubspotv1_company_getMany_name,
        description_i18n: i18n_key:tool_hubspotv1_company_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 961,
        tooltip_i18n: i18n_key:tool_hubspotv1_company_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_hubspotv1_company_getMany_success,
        error_message_i18n: i18n_key:tool_hubspotv1_company_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:hubspotv1_company,
    is_active: true;

CREATE tool:hubspotv1_contact_get SET
    identity = {
        name: "get",
        slug: "hubspotv1_contact_get",
        display_name_i18n: i18n_key:tool_hubspotv1_contact_get_name,
        description_i18n: i18n_key:tool_hubspotv1_contact_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 962,
        tooltip_i18n: i18n_key:tool_hubspotv1_contact_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_hubspotv1_contact_get_success,
        error_message_i18n: i18n_key:tool_hubspotv1_contact_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:hubspotv1_contact,
    is_active: true;

CREATE tool:hubspotv1_contact_getMany SET
    identity = {
        name: "getMany",
        slug: "hubspotv1_contact_getMany",
        display_name_i18n: i18n_key:tool_hubspotv1_contact_getMany_name,
        description_i18n: i18n_key:tool_hubspotv1_contact_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 963,
        tooltip_i18n: i18n_key:tool_hubspotv1_contact_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_hubspotv1_contact_getMany_success,
        error_message_i18n: i18n_key:tool_hubspotv1_contact_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:hubspotv1_contact,
    is_active: true;

CREATE tool:hubspotv1_contactList_get SET
    identity = {
        name: "get",
        slug: "hubspotv1_contactList_get",
        display_name_i18n: i18n_key:tool_hubspotv1_contactList_get_name,
        description_i18n: i18n_key:tool_hubspotv1_contactList_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 964,
        tooltip_i18n: i18n_key:tool_hubspotv1_contactList_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_hubspotv1_contactList_get_success,
        error_message_i18n: i18n_key:tool_hubspotv1_contactList_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:hubspotv1_contactList,
    is_active: true;

CREATE tool:hubspotv1_contactList_getMany SET
    identity = {
        name: "getMany",
        slug: "hubspotv1_contactList_getMany",
        display_name_i18n: i18n_key:tool_hubspotv1_contactList_getMany_name,
        description_i18n: i18n_key:tool_hubspotv1_contactList_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 965,
        tooltip_i18n: i18n_key:tool_hubspotv1_contactList_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_hubspotv1_contactList_getMany_success,
        error_message_i18n: i18n_key:tool_hubspotv1_contactList_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:hubspotv1_contactList,
    is_active: true;

CREATE tool:hubspotv1_deal_get SET
    identity = {
        name: "get",
        slug: "hubspotv1_deal_get",
        display_name_i18n: i18n_key:tool_hubspotv1_deal_get_name,
        description_i18n: i18n_key:tool_hubspotv1_deal_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 966,
        tooltip_i18n: i18n_key:tool_hubspotv1_deal_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_hubspotv1_deal_get_success,
        error_message_i18n: i18n_key:tool_hubspotv1_deal_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:hubspotv1_deal,
    is_active: true;

CREATE tool:hubspotv1_deal_getMany SET
    identity = {
        name: "getMany",
        slug: "hubspotv1_deal_getMany",
        display_name_i18n: i18n_key:tool_hubspotv1_deal_getMany_name,
        description_i18n: i18n_key:tool_hubspotv1_deal_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 967,
        tooltip_i18n: i18n_key:tool_hubspotv1_deal_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_hubspotv1_deal_getMany_success,
        error_message_i18n: i18n_key:tool_hubspotv1_deal_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:hubspotv1_deal,
    is_active: true;

CREATE tool:hubspotv1_engagement_get SET
    identity = {
        name: "get",
        slug: "hubspotv1_engagement_get",
        display_name_i18n: i18n_key:tool_hubspotv1_engagement_get_name,
        description_i18n: i18n_key:tool_hubspotv1_engagement_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 968,
        tooltip_i18n: i18n_key:tool_hubspotv1_engagement_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_hubspotv1_engagement_get_success,
        error_message_i18n: i18n_key:tool_hubspotv1_engagement_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:hubspotv1_engagement,
    is_active: true;

CREATE tool:hubspotv1_engagement_getMany SET
    identity = {
        name: "getMany",
        slug: "hubspotv1_engagement_getMany",
        display_name_i18n: i18n_key:tool_hubspotv1_engagement_getMany_name,
        description_i18n: i18n_key:tool_hubspotv1_engagement_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 969,
        tooltip_i18n: i18n_key:tool_hubspotv1_engagement_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_hubspotv1_engagement_getMany_success,
        error_message_i18n: i18n_key:tool_hubspotv1_engagement_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:hubspotv1_engagement,
    is_active: true;

CREATE tool:hubspotv1_form_get SET
    identity = {
        name: "get",
        slug: "hubspotv1_form_get",
        display_name_i18n: i18n_key:tool_hubspotv1_form_get_name,
        description_i18n: i18n_key:tool_hubspotv1_form_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 970,
        tooltip_i18n: i18n_key:tool_hubspotv1_form_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_hubspotv1_form_get_success,
        error_message_i18n: i18n_key:tool_hubspotv1_form_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:hubspotv1_form,
    is_active: true;

CREATE tool:hubspotv1_form_getMany SET
    identity = {
        name: "getMany",
        slug: "hubspotv1_form_getMany",
        display_name_i18n: i18n_key:tool_hubspotv1_form_getMany_name,
        description_i18n: i18n_key:tool_hubspotv1_form_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 971,
        tooltip_i18n: i18n_key:tool_hubspotv1_form_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_hubspotv1_form_getMany_success,
        error_message_i18n: i18n_key:tool_hubspotv1_form_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:hubspotv1_form,
    is_active: true;

CREATE tool:hubspotv1_ticket_get SET
    identity = {
        name: "get",
        slug: "hubspotv1_ticket_get",
        display_name_i18n: i18n_key:tool_hubspotv1_ticket_get_name,
        description_i18n: i18n_key:tool_hubspotv1_ticket_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 972,
        tooltip_i18n: i18n_key:tool_hubspotv1_ticket_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_hubspotv1_ticket_get_success,
        error_message_i18n: i18n_key:tool_hubspotv1_ticket_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:hubspotv1_ticket,
    is_active: true;

CREATE tool:hubspotv1_ticket_getMany SET
    identity = {
        name: "getMany",
        slug: "hubspotv1_ticket_getMany",
        display_name_i18n: i18n_key:tool_hubspotv1_ticket_getMany_name,
        description_i18n: i18n_key:tool_hubspotv1_ticket_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 973,
        tooltip_i18n: i18n_key:tool_hubspotv1_ticket_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_hubspotv1_ticket_getMany_success,
        error_message_i18n: i18n_key:tool_hubspotv1_ticket_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:hubspotv1_ticket,
    is_active: true;

CREATE tool:hubspotv1_contactlist_get SET
    identity = {
        name: "get",
        slug: "hubspotv1_contactlist_get",
        display_name_i18n: i18n_key:tool_hubspotv1_contactlist_get_name,
        description_i18n: i18n_key:tool_hubspotv1_contactlist_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 974,
        tooltip_i18n: i18n_key:tool_hubspotv1_contactlist_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_hubspotv1_contactlist_get_success,
        error_message_i18n: i18n_key:tool_hubspotv1_contactlist_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:hubspotv1_contactlist,
    is_active: true;

CREATE tool:hubspotv1_contactlist_getMany SET
    identity = {
        name: "getMany",
        slug: "hubspotv1_contactlist_getMany",
        display_name_i18n: i18n_key:tool_hubspotv1_contactlist_getMany_name,
        description_i18n: i18n_key:tool_hubspotv1_contactlist_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 975,
        tooltip_i18n: i18n_key:tool_hubspotv1_contactlist_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_hubspotv1_contactlist_getMany_success,
        error_message_i18n: i18n_key:tool_hubspotv1_contactlist_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:hubspotv1_contactlist,
    is_active: true;

CREATE tool:hubspotv2_company_get SET
    identity = {
        name: "get",
        slug: "hubspotv2_company_get",
        display_name_i18n: i18n_key:tool_hubspotv2_company_get_name,
        description_i18n: i18n_key:tool_hubspotv2_company_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 976,
        tooltip_i18n: i18n_key:tool_hubspotv2_company_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_hubspotv2_company_get_success,
        error_message_i18n: i18n_key:tool_hubspotv2_company_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:hubspotv2_company,
    is_active: true;

CREATE tool:hubspotv2_company_getMany SET
    identity = {
        name: "getMany",
        slug: "hubspotv2_company_getMany",
        display_name_i18n: i18n_key:tool_hubspotv2_company_getMany_name,
        description_i18n: i18n_key:tool_hubspotv2_company_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 977,
        tooltip_i18n: i18n_key:tool_hubspotv2_company_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_hubspotv2_company_getMany_success,
        error_message_i18n: i18n_key:tool_hubspotv2_company_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:hubspotv2_company,
    is_active: true;

CREATE tool:hubspotv2_contact_get SET
    identity = {
        name: "get",
        slug: "hubspotv2_contact_get",
        display_name_i18n: i18n_key:tool_hubspotv2_contact_get_name,
        description_i18n: i18n_key:tool_hubspotv2_contact_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 978,
        tooltip_i18n: i18n_key:tool_hubspotv2_contact_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_hubspotv2_contact_get_success,
        error_message_i18n: i18n_key:tool_hubspotv2_contact_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:hubspotv2_contact,
    is_active: true;

CREATE tool:hubspotv2_contact_getMany SET
    identity = {
        name: "getMany",
        slug: "hubspotv2_contact_getMany",
        display_name_i18n: i18n_key:tool_hubspotv2_contact_getMany_name,
        description_i18n: i18n_key:tool_hubspotv2_contact_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 979,
        tooltip_i18n: i18n_key:tool_hubspotv2_contact_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_hubspotv2_contact_getMany_success,
        error_message_i18n: i18n_key:tool_hubspotv2_contact_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:hubspotv2_contact,
    is_active: true;

CREATE tool:hubspotv2_contactList_get SET
    identity = {
        name: "get",
        slug: "hubspotv2_contactList_get",
        display_name_i18n: i18n_key:tool_hubspotv2_contactList_get_name,
        description_i18n: i18n_key:tool_hubspotv2_contactList_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 980,
        tooltip_i18n: i18n_key:tool_hubspotv2_contactList_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_hubspotv2_contactList_get_success,
        error_message_i18n: i18n_key:tool_hubspotv2_contactList_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:hubspotv2_contactList,
    is_active: true;

CREATE tool:hubspotv2_contactList_getMany SET
    identity = {
        name: "getMany",
        slug: "hubspotv2_contactList_getMany",
        display_name_i18n: i18n_key:tool_hubspotv2_contactList_getMany_name,
        description_i18n: i18n_key:tool_hubspotv2_contactList_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 981,
        tooltip_i18n: i18n_key:tool_hubspotv2_contactList_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_hubspotv2_contactList_getMany_success,
        error_message_i18n: i18n_key:tool_hubspotv2_contactList_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:hubspotv2_contactList,
    is_active: true;

CREATE tool:hubspotv2_deal_get SET
    identity = {
        name: "get",
        slug: "hubspotv2_deal_get",
        display_name_i18n: i18n_key:tool_hubspotv2_deal_get_name,
        description_i18n: i18n_key:tool_hubspotv2_deal_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 982,
        tooltip_i18n: i18n_key:tool_hubspotv2_deal_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_hubspotv2_deal_get_success,
        error_message_i18n: i18n_key:tool_hubspotv2_deal_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:hubspotv2_deal,
    is_active: true;

CREATE tool:hubspotv2_deal_getMany SET
    identity = {
        name: "getMany",
        slug: "hubspotv2_deal_getMany",
        display_name_i18n: i18n_key:tool_hubspotv2_deal_getMany_name,
        description_i18n: i18n_key:tool_hubspotv2_deal_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 983,
        tooltip_i18n: i18n_key:tool_hubspotv2_deal_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_hubspotv2_deal_getMany_success,
        error_message_i18n: i18n_key:tool_hubspotv2_deal_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:hubspotv2_deal,
    is_active: true;

CREATE tool:hubspotv2_engagement_get SET
    identity = {
        name: "get",
        slug: "hubspotv2_engagement_get",
        display_name_i18n: i18n_key:tool_hubspotv2_engagement_get_name,
        description_i18n: i18n_key:tool_hubspotv2_engagement_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 984,
        tooltip_i18n: i18n_key:tool_hubspotv2_engagement_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_hubspotv2_engagement_get_success,
        error_message_i18n: i18n_key:tool_hubspotv2_engagement_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:hubspotv2_engagement,
    is_active: true;

CREATE tool:hubspotv2_engagement_getMany SET
    identity = {
        name: "getMany",
        slug: "hubspotv2_engagement_getMany",
        display_name_i18n: i18n_key:tool_hubspotv2_engagement_getMany_name,
        description_i18n: i18n_key:tool_hubspotv2_engagement_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 985,
        tooltip_i18n: i18n_key:tool_hubspotv2_engagement_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_hubspotv2_engagement_getMany_success,
        error_message_i18n: i18n_key:tool_hubspotv2_engagement_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:hubspotv2_engagement,
    is_active: true;

CREATE tool:hubspotv2_ticket_get SET
    identity = {
        name: "get",
        slug: "hubspotv2_ticket_get",
        display_name_i18n: i18n_key:tool_hubspotv2_ticket_get_name,
        description_i18n: i18n_key:tool_hubspotv2_ticket_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 986,
        tooltip_i18n: i18n_key:tool_hubspotv2_ticket_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_hubspotv2_ticket_get_success,
        error_message_i18n: i18n_key:tool_hubspotv2_ticket_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:hubspotv2_ticket,
    is_active: true;

CREATE tool:hubspotv2_ticket_getMany SET
    identity = {
        name: "getMany",
        slug: "hubspotv2_ticket_getMany",
        display_name_i18n: i18n_key:tool_hubspotv2_ticket_getMany_name,
        description_i18n: i18n_key:tool_hubspotv2_ticket_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 987,
        tooltip_i18n: i18n_key:tool_hubspotv2_ticket_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_hubspotv2_ticket_getMany_success,
        error_message_i18n: i18n_key:tool_hubspotv2_ticket_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:hubspotv2_ticket,
    is_active: true;

CREATE tool:hubspotv2_contactlist_get SET
    identity = {
        name: "get",
        slug: "hubspotv2_contactlist_get",
        display_name_i18n: i18n_key:tool_hubspotv2_contactlist_get_name,
        description_i18n: i18n_key:tool_hubspotv2_contactlist_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 988,
        tooltip_i18n: i18n_key:tool_hubspotv2_contactlist_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_hubspotv2_contactlist_get_success,
        error_message_i18n: i18n_key:tool_hubspotv2_contactlist_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:hubspotv2_contactlist,
    is_active: true;

CREATE tool:hubspotv2_contactlist_getMany SET
    identity = {
        name: "getMany",
        slug: "hubspotv2_contactlist_getMany",
        display_name_i18n: i18n_key:tool_hubspotv2_contactlist_getMany_name,
        description_i18n: i18n_key:tool_hubspotv2_contactlist_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 989,
        tooltip_i18n: i18n_key:tool_hubspotv2_contactlist_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_hubspotv2_contactlist_getMany_success,
        error_message_i18n: i18n_key:tool_hubspotv2_contactlist_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:hubspotv2_contactlist,
    is_active: true;

CREATE tool:humanticai_profile_get SET
    identity = {
        name: "get",
        slug: "humanticai_profile_get",
        display_name_i18n: i18n_key:tool_humanticai_profile_get_name,
        description_i18n: i18n_key:tool_humanticai_profile_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 990,
        tooltip_i18n: i18n_key:tool_humanticai_profile_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_humanticai_profile_get_success,
        error_message_i18n: i18n_key:tool_humanticai_profile_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:humanticai_profile,
    is_active: true;

CREATE tool:humanticai_profile_getMany SET
    identity = {
        name: "getMany",
        slug: "humanticai_profile_getMany",
        display_name_i18n: i18n_key:tool_humanticai_profile_getMany_name,
        description_i18n: i18n_key:tool_humanticai_profile_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 991,
        tooltip_i18n: i18n_key:tool_humanticai_profile_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_humanticai_profile_getMany_success,
        error_message_i18n: i18n_key:tool_humanticai_profile_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:humanticai_profile,
    is_active: true;

CREATE tool:hunter_hunter_domainSearch SET
    identity = {
        name: "domainSearch",
        slug: "hunter_hunter_domainSearch",
        display_name_i18n: i18n_key:tool_hunter_hunter_domainSearch_name,
        description_i18n: i18n_key:tool_hunter_hunter_domainSearch_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 992,
        tooltip_i18n: i18n_key:tool_hunter_hunter_domainSearch_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_hunter_hunter_domainSearch_success,
        error_message_i18n: i18n_key:tool_hunter_hunter_domainSearch_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:hunter_hunter,
    is_active: true;

CREATE tool:hunter_hunter_emailFinder SET
    identity = {
        name: "emailFinder",
        slug: "hunter_hunter_emailFinder",
        display_name_i18n: i18n_key:tool_hunter_hunter_emailFinder_name,
        description_i18n: i18n_key:tool_hunter_hunter_emailFinder_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 993,
        tooltip_i18n: i18n_key:tool_hunter_hunter_emailFinder_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_hunter_hunter_emailFinder_success,
        error_message_i18n: i18n_key:tool_hunter_hunter_emailFinder_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:hunter_hunter,
    is_active: true;

CREATE tool:hunter_hunter_emailVerifier SET
    identity = {
        name: "emailVerifier",
        slug: "hunter_hunter_emailVerifier",
        display_name_i18n: i18n_key:tool_hunter_hunter_emailVerifier_name,
        description_i18n: i18n_key:tool_hunter_hunter_emailVerifier_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 994,
        tooltip_i18n: i18n_key:tool_hunter_hunter_emailVerifier_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_hunter_hunter_emailVerifier_success,
        error_message_i18n: i18n_key:tool_hunter_hunter_emailVerifier_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "POST",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:hunter_hunter,
    is_active: true;

CREATE tool:icalendar_icalendar_createEventFile SET
    identity = {
        name: "createEventFile",
        slug: "icalendar_icalendar_createEventFile",
        display_name_i18n: i18n_key:tool_icalendar_icalendar_createEventFile_name,
        description_i18n: i18n_key:tool_icalendar_icalendar_createEventFile_desc,
        operation_type: "create",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#4CAF50",
        display_order: 995,
        tooltip_i18n: i18n_key:tool_icalendar_icalendar_createEventFile_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_icalendar_icalendar_createEventFile_success,
        error_message_i18n: i18n_key:tool_icalendar_icalendar_createEventFile_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "POST",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:icalendar_icalendar,
    is_active: true;

CREATE tool:if_if_get SET
    identity = {
        name: "get",
        slug: "if_if_get",
        display_name_i18n: i18n_key:tool_if_if_get_name,
        description_i18n: i18n_key:tool_if_if_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 996,
        tooltip_i18n: i18n_key:tool_if_if_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_if_if_get_success,
        error_message_i18n: i18n_key:tool_if_if_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:if_if,
    is_active: true;

CREATE tool:if_if_getMany SET
    identity = {
        name: "getMany",
        slug: "if_if_getMany",
        display_name_i18n: i18n_key:tool_if_if_getMany_name,
        description_i18n: i18n_key:tool_if_if_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 997,
        tooltip_i18n: i18n_key:tool_if_if_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_if_if_getMany_success,
        error_message_i18n: i18n_key:tool_if_if_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:if_if,
    is_active: true;

CREATE tool:ifv1_ifv1_equal SET
    identity = {
        name: "equal",
        slug: "ifv1_ifv1_equal",
        display_name_i18n: i18n_key:tool_ifv1_ifv1_equal_name,
        description_i18n: i18n_key:tool_ifv1_ifv1_equal_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 998,
        tooltip_i18n: i18n_key:tool_ifv1_ifv1_equal_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_ifv1_ifv1_equal_success,
        error_message_i18n: i18n_key:tool_ifv1_ifv1_equal_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "POST",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:ifv1_ifv1,
    is_active: true;

CREATE tool:ifv1_ifv1_notEqual SET
    identity = {
        name: "notEqual",
        slug: "ifv1_ifv1_notEqual",
        display_name_i18n: i18n_key:tool_ifv1_ifv1_notEqual_name,
        description_i18n: i18n_key:tool_ifv1_ifv1_notEqual_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 999,
        tooltip_i18n: i18n_key:tool_ifv1_ifv1_notEqual_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_ifv1_ifv1_notEqual_success,
        error_message_i18n: i18n_key:tool_ifv1_ifv1_notEqual_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "POST",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:ifv1_ifv1,
    is_active: true;

CREATE tool:ifv2_ifv2_get SET
    identity = {
        name: "get",
        slug: "ifv2_ifv2_get",
        display_name_i18n: i18n_key:tool_ifv2_ifv2_get_name,
        description_i18n: i18n_key:tool_ifv2_ifv2_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1000,
        tooltip_i18n: i18n_key:tool_ifv2_ifv2_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_ifv2_ifv2_get_success,
        error_message_i18n: i18n_key:tool_ifv2_ifv2_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:ifv2_ifv2,
    is_active: true;

