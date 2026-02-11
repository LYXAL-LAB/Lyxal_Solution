-- Batch 9: 100 tools Lyxal

CREATE tool:gmailv2_draft_get SET
    identity = {
        name: "get",
        slug: "gmailv2_draft_get",
        display_name_i18n: i18n_key:tool_gmailv2_draft_get_name,
        description_i18n: i18n_key:tool_gmailv2_draft_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 801,
        tooltip_i18n: i18n_key:tool_gmailv2_draft_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_gmailv2_draft_get_success,
        error_message_i18n: i18n_key:tool_gmailv2_draft_get_error,
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
    resource_id: resource:gmailv2_draft,
    is_active: true;

CREATE tool:gmailv2_draft_getMany SET
    identity = {
        name: "getMany",
        slug: "gmailv2_draft_getMany",
        display_name_i18n: i18n_key:tool_gmailv2_draft_getMany_name,
        description_i18n: i18n_key:tool_gmailv2_draft_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 802,
        tooltip_i18n: i18n_key:tool_gmailv2_draft_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_gmailv2_draft_getMany_success,
        error_message_i18n: i18n_key:tool_gmailv2_draft_getMany_error,
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
    resource_id: resource:gmailv2_draft,
    is_active: true;

CREATE tool:gmailv2_thread_get SET
    identity = {
        name: "get",
        slug: "gmailv2_thread_get",
        display_name_i18n: i18n_key:tool_gmailv2_thread_get_name,
        description_i18n: i18n_key:tool_gmailv2_thread_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 803,
        tooltip_i18n: i18n_key:tool_gmailv2_thread_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_gmailv2_thread_get_success,
        error_message_i18n: i18n_key:tool_gmailv2_thread_get_error,
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
    resource_id: resource:gmailv2_thread,
    is_active: true;

CREATE tool:gmailv2_thread_getMany SET
    identity = {
        name: "getMany",
        slug: "gmailv2_thread_getMany",
        display_name_i18n: i18n_key:tool_gmailv2_thread_getMany_name,
        description_i18n: i18n_key:tool_gmailv2_thread_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 804,
        tooltip_i18n: i18n_key:tool_gmailv2_thread_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_gmailv2_thread_getMany_success,
        error_message_i18n: i18n_key:tool_gmailv2_thread_getMany_error,
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
    resource_id: resource:gmailv2_thread,
    is_active: true;

CREATE tool:gsuiteadmin_device_get SET
    identity = {
        name: "get",
        slug: "gsuiteadmin_device_get",
        display_name_i18n: i18n_key:tool_gsuiteadmin_device_get_name,
        description_i18n: i18n_key:tool_gsuiteadmin_device_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 805,
        tooltip_i18n: i18n_key:tool_gsuiteadmin_device_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_gsuiteadmin_device_get_success,
        error_message_i18n: i18n_key:tool_gsuiteadmin_device_get_error,
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
    resource_id: resource:gsuiteadmin_device,
    is_active: true;

CREATE tool:gsuiteadmin_device_getMany SET
    identity = {
        name: "getMany",
        slug: "gsuiteadmin_device_getMany",
        display_name_i18n: i18n_key:tool_gsuiteadmin_device_getMany_name,
        description_i18n: i18n_key:tool_gsuiteadmin_device_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 806,
        tooltip_i18n: i18n_key:tool_gsuiteadmin_device_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_gsuiteadmin_device_getMany_success,
        error_message_i18n: i18n_key:tool_gsuiteadmin_device_getMany_error,
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
    resource_id: resource:gsuiteadmin_device,
    is_active: true;

CREATE tool:gsuiteadmin_group_get SET
    identity = {
        name: "get",
        slug: "gsuiteadmin_group_get",
        display_name_i18n: i18n_key:tool_gsuiteadmin_group_get_name,
        description_i18n: i18n_key:tool_gsuiteadmin_group_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 807,
        tooltip_i18n: i18n_key:tool_gsuiteadmin_group_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_gsuiteadmin_group_get_success,
        error_message_i18n: i18n_key:tool_gsuiteadmin_group_get_error,
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
    resource_id: resource:gsuiteadmin_group,
    is_active: true;

CREATE tool:gsuiteadmin_group_getMany SET
    identity = {
        name: "getMany",
        slug: "gsuiteadmin_group_getMany",
        display_name_i18n: i18n_key:tool_gsuiteadmin_group_getMany_name,
        description_i18n: i18n_key:tool_gsuiteadmin_group_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 808,
        tooltip_i18n: i18n_key:tool_gsuiteadmin_group_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_gsuiteadmin_group_getMany_success,
        error_message_i18n: i18n_key:tool_gsuiteadmin_group_getMany_error,
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
    resource_id: resource:gsuiteadmin_group,
    is_active: true;

CREATE tool:gsuiteadmin_user_get SET
    identity = {
        name: "get",
        slug: "gsuiteadmin_user_get",
        display_name_i18n: i18n_key:tool_gsuiteadmin_user_get_name,
        description_i18n: i18n_key:tool_gsuiteadmin_user_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 809,
        tooltip_i18n: i18n_key:tool_gsuiteadmin_user_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_gsuiteadmin_user_get_success,
        error_message_i18n: i18n_key:tool_gsuiteadmin_user_get_error,
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
    resource_id: resource:gsuiteadmin_user,
    is_active: true;

CREATE tool:gsuiteadmin_user_getMany SET
    identity = {
        name: "getMany",
        slug: "gsuiteadmin_user_getMany",
        display_name_i18n: i18n_key:tool_gsuiteadmin_user_getMany_name,
        description_i18n: i18n_key:tool_gsuiteadmin_user_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 810,
        tooltip_i18n: i18n_key:tool_gsuiteadmin_user_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_gsuiteadmin_user_getMany_success,
        error_message_i18n: i18n_key:tool_gsuiteadmin_user_getMany_error,
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
    resource_id: resource:gsuiteadmin_user,
    is_active: true;

CREATE tool:googleperspective_googleperspective_analyzeComment SET
    identity = {
        name: "analyzeComment",
        slug: "googleperspective_googleperspective_analyzeComment",
        display_name_i18n: i18n_key:tool_googleperspective_googleperspective_analyzeComment_name,
        description_i18n: i18n_key:tool_googleperspective_googleperspective_analyzeComment_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 811,
        tooltip_i18n: i18n_key:tool_googleperspective_googleperspective_analyzeComment_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googleperspective_googleperspective_analyzeComment_success,
        error_message_i18n: i18n_key:tool_googleperspective_googleperspective_analyzeComment_error,
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
    resource_id: resource:googleperspective_googleperspective,
    is_active: true;

CREATE tool:googlesheets_googlesheets_get SET
    identity = {
        name: "get",
        slug: "googlesheets_googlesheets_get",
        display_name_i18n: i18n_key:tool_googlesheets_googlesheets_get_name,
        description_i18n: i18n_key:tool_googlesheets_googlesheets_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 812,
        tooltip_i18n: i18n_key:tool_googlesheets_googlesheets_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googlesheets_googlesheets_get_success,
        error_message_i18n: i18n_key:tool_googlesheets_googlesheets_get_error,
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
    resource_id: resource:googlesheets_googlesheets,
    is_active: true;

CREATE tool:googlesheets_googlesheets_getMany SET
    identity = {
        name: "getMany",
        slug: "googlesheets_googlesheets_getMany",
        display_name_i18n: i18n_key:tool_googlesheets_googlesheets_getMany_name,
        description_i18n: i18n_key:tool_googlesheets_googlesheets_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 813,
        tooltip_i18n: i18n_key:tool_googlesheets_googlesheets_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googlesheets_googlesheets_getMany_success,
        error_message_i18n: i18n_key:tool_googlesheets_googlesheets_getMany_error,
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
    resource_id: resource:googlesheets_googlesheets,
    is_active: true;

CREATE tool:googlesheetsv1_googlesheetsv1_get SET
    identity = {
        name: "get",
        slug: "googlesheetsv1_googlesheetsv1_get",
        display_name_i18n: i18n_key:tool_googlesheetsv1_googlesheetsv1_get_name,
        description_i18n: i18n_key:tool_googlesheetsv1_googlesheetsv1_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 814,
        tooltip_i18n: i18n_key:tool_googlesheetsv1_googlesheetsv1_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googlesheetsv1_googlesheetsv1_get_success,
        error_message_i18n: i18n_key:tool_googlesheetsv1_googlesheetsv1_get_error,
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
    resource_id: resource:googlesheetsv1_googlesheetsv1,
    is_active: true;

CREATE tool:googlesheetsv1_googlesheetsv1_getMany SET
    identity = {
        name: "getMany",
        slug: "googlesheetsv1_googlesheetsv1_getMany",
        display_name_i18n: i18n_key:tool_googlesheetsv1_googlesheetsv1_getMany_name,
        description_i18n: i18n_key:tool_googlesheetsv1_googlesheetsv1_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 815,
        tooltip_i18n: i18n_key:tool_googlesheetsv1_googlesheetsv1_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googlesheetsv1_googlesheetsv1_getMany_success,
        error_message_i18n: i18n_key:tool_googlesheetsv1_googlesheetsv1_getMany_error,
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
    resource_id: resource:googlesheetsv1_googlesheetsv1,
    is_active: true;

CREATE tool:googlesheetsv2_googlesheetsv2_get SET
    identity = {
        name: "get",
        slug: "googlesheetsv2_googlesheetsv2_get",
        display_name_i18n: i18n_key:tool_googlesheetsv2_googlesheetsv2_get_name,
        description_i18n: i18n_key:tool_googlesheetsv2_googlesheetsv2_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 816,
        tooltip_i18n: i18n_key:tool_googlesheetsv2_googlesheetsv2_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googlesheetsv2_googlesheetsv2_get_success,
        error_message_i18n: i18n_key:tool_googlesheetsv2_googlesheetsv2_get_error,
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
    resource_id: resource:googlesheetsv2_googlesheetsv2,
    is_active: true;

CREATE tool:googlesheetsv2_googlesheetsv2_getMany SET
    identity = {
        name: "getMany",
        slug: "googlesheetsv2_googlesheetsv2_getMany",
        display_name_i18n: i18n_key:tool_googlesheetsv2_googlesheetsv2_getMany_name,
        description_i18n: i18n_key:tool_googlesheetsv2_googlesheetsv2_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 817,
        tooltip_i18n: i18n_key:tool_googlesheetsv2_googlesheetsv2_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googlesheetsv2_googlesheetsv2_getMany_success,
        error_message_i18n: i18n_key:tool_googlesheetsv2_googlesheetsv2_getMany_error,
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
    resource_id: resource:googlesheetsv2_googlesheetsv2,
    is_active: true;

CREATE tool:googleslides_page_create SET
    identity = {
        name: "create",
        slug: "googleslides_page_create",
        display_name_i18n: i18n_key:tool_googleslides_page_create_name,
        description_i18n: i18n_key:tool_googleslides_page_create_desc,
        operation_type: "create",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#4CAF50",
        display_order: 818,
        tooltip_i18n: i18n_key:tool_googleslides_page_create_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googleslides_page_create_success,
        error_message_i18n: i18n_key:tool_googleslides_page_create_error,
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
    resource_id: resource:googleslides_page,
    is_active: true;

CREATE tool:googleslides_page_get SET
    identity = {
        name: "get",
        slug: "googleslides_page_get",
        display_name_i18n: i18n_key:tool_googleslides_page_get_name,
        description_i18n: i18n_key:tool_googleslides_page_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 819,
        tooltip_i18n: i18n_key:tool_googleslides_page_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googleslides_page_get_success,
        error_message_i18n: i18n_key:tool_googleslides_page_get_error,
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
    resource_id: resource:googleslides_page,
    is_active: true;

CREATE tool:googleslides_page_getSlides SET
    identity = {
        name: "getSlides",
        slug: "googleslides_page_getSlides",
        display_name_i18n: i18n_key:tool_googleslides_page_getSlides_name,
        description_i18n: i18n_key:tool_googleslides_page_getSlides_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 820,
        tooltip_i18n: i18n_key:tool_googleslides_page_getSlides_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googleslides_page_getSlides_success,
        error_message_i18n: i18n_key:tool_googleslides_page_getSlides_error,
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
    resource_id: resource:googleslides_page,
    is_active: true;

CREATE tool:googleslides_page_replaceText SET
    identity = {
        name: "replaceText",
        slug: "googleslides_page_replaceText",
        display_name_i18n: i18n_key:tool_googleslides_page_replaceText_name,
        description_i18n: i18n_key:tool_googleslides_page_replaceText_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 821,
        tooltip_i18n: i18n_key:tool_googleslides_page_replaceText_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googleslides_page_replaceText_success,
        error_message_i18n: i18n_key:tool_googleslides_page_replaceText_error,
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
    resource_id: resource:googleslides_page,
    is_active: true;

CREATE tool:googleslides_presentation_create SET
    identity = {
        name: "create",
        slug: "googleslides_presentation_create",
        display_name_i18n: i18n_key:tool_googleslides_presentation_create_name,
        description_i18n: i18n_key:tool_googleslides_presentation_create_desc,
        operation_type: "create",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#4CAF50",
        display_order: 822,
        tooltip_i18n: i18n_key:tool_googleslides_presentation_create_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googleslides_presentation_create_success,
        error_message_i18n: i18n_key:tool_googleslides_presentation_create_error,
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
    resource_id: resource:googleslides_presentation,
    is_active: true;

CREATE tool:googleslides_presentation_get SET
    identity = {
        name: "get",
        slug: "googleslides_presentation_get",
        display_name_i18n: i18n_key:tool_googleslides_presentation_get_name,
        description_i18n: i18n_key:tool_googleslides_presentation_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 823,
        tooltip_i18n: i18n_key:tool_googleslides_presentation_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googleslides_presentation_get_success,
        error_message_i18n: i18n_key:tool_googleslides_presentation_get_error,
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
    resource_id: resource:googleslides_presentation,
    is_active: true;

CREATE tool:googleslides_presentation_getSlides SET
    identity = {
        name: "getSlides",
        slug: "googleslides_presentation_getSlides",
        display_name_i18n: i18n_key:tool_googleslides_presentation_getSlides_name,
        description_i18n: i18n_key:tool_googleslides_presentation_getSlides_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 824,
        tooltip_i18n: i18n_key:tool_googleslides_presentation_getSlides_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googleslides_presentation_getSlides_success,
        error_message_i18n: i18n_key:tool_googleslides_presentation_getSlides_error,
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
    resource_id: resource:googleslides_presentation,
    is_active: true;

CREATE tool:googleslides_presentation_replaceText SET
    identity = {
        name: "replaceText",
        slug: "googleslides_presentation_replaceText",
        display_name_i18n: i18n_key:tool_googleslides_presentation_replaceText_name,
        description_i18n: i18n_key:tool_googleslides_presentation_replaceText_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 825,
        tooltip_i18n: i18n_key:tool_googleslides_presentation_replaceText_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googleslides_presentation_replaceText_success,
        error_message_i18n: i18n_key:tool_googleslides_presentation_replaceText_error,
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
    resource_id: resource:googleslides_presentation,
    is_active: true;

CREATE tool:googletasks_task_get SET
    identity = {
        name: "get",
        slug: "googletasks_task_get",
        display_name_i18n: i18n_key:tool_googletasks_task_get_name,
        description_i18n: i18n_key:tool_googletasks_task_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 826,
        tooltip_i18n: i18n_key:tool_googletasks_task_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googletasks_task_get_success,
        error_message_i18n: i18n_key:tool_googletasks_task_get_error,
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
    resource_id: resource:googletasks_task,
    is_active: true;

CREATE tool:googletasks_task_getMany SET
    identity = {
        name: "getMany",
        slug: "googletasks_task_getMany",
        display_name_i18n: i18n_key:tool_googletasks_task_getMany_name,
        description_i18n: i18n_key:tool_googletasks_task_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 827,
        tooltip_i18n: i18n_key:tool_googletasks_task_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googletasks_task_getMany_success,
        error_message_i18n: i18n_key:tool_googletasks_task_getMany_error,
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
    resource_id: resource:googletasks_task,
    is_active: true;

CREATE tool:googletranslate_language_translate SET
    identity = {
        name: "translate",
        slug: "googletranslate_language_translate",
        display_name_i18n: i18n_key:tool_googletranslate_language_translate_name,
        description_i18n: i18n_key:tool_googletranslate_language_translate_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 828,
        tooltip_i18n: i18n_key:tool_googletranslate_language_translate_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googletranslate_language_translate_success,
        error_message_i18n: i18n_key:tool_googletranslate_language_translate_error,
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
    resource_id: resource:googletranslate_language,
    is_active: true;

CREATE tool:youtube_channel_get SET
    identity = {
        name: "get",
        slug: "youtube_channel_get",
        display_name_i18n: i18n_key:tool_youtube_channel_get_name,
        description_i18n: i18n_key:tool_youtube_channel_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 829,
        tooltip_i18n: i18n_key:tool_youtube_channel_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_youtube_channel_get_success,
        error_message_i18n: i18n_key:tool_youtube_channel_get_error,
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
    resource_id: resource:youtube_channel,
    is_active: true;

CREATE tool:youtube_channel_getMany SET
    identity = {
        name: "getMany",
        slug: "youtube_channel_getMany",
        display_name_i18n: i18n_key:tool_youtube_channel_getMany_name,
        description_i18n: i18n_key:tool_youtube_channel_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 830,
        tooltip_i18n: i18n_key:tool_youtube_channel_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_youtube_channel_getMany_success,
        error_message_i18n: i18n_key:tool_youtube_channel_getMany_error,
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
    resource_id: resource:youtube_channel,
    is_active: true;

CREATE tool:youtube_playlist_get SET
    identity = {
        name: "get",
        slug: "youtube_playlist_get",
        display_name_i18n: i18n_key:tool_youtube_playlist_get_name,
        description_i18n: i18n_key:tool_youtube_playlist_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 831,
        tooltip_i18n: i18n_key:tool_youtube_playlist_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_youtube_playlist_get_success,
        error_message_i18n: i18n_key:tool_youtube_playlist_get_error,
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
    resource_id: resource:youtube_playlist,
    is_active: true;

CREATE tool:youtube_playlist_getMany SET
    identity = {
        name: "getMany",
        slug: "youtube_playlist_getMany",
        display_name_i18n: i18n_key:tool_youtube_playlist_getMany_name,
        description_i18n: i18n_key:tool_youtube_playlist_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 832,
        tooltip_i18n: i18n_key:tool_youtube_playlist_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_youtube_playlist_getMany_success,
        error_message_i18n: i18n_key:tool_youtube_playlist_getMany_error,
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
    resource_id: resource:youtube_playlist,
    is_active: true;

CREATE tool:youtube_playlistItem_get SET
    identity = {
        name: "get",
        slug: "youtube_playlistItem_get",
        display_name_i18n: i18n_key:tool_youtube_playlistItem_get_name,
        description_i18n: i18n_key:tool_youtube_playlistItem_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 833,
        tooltip_i18n: i18n_key:tool_youtube_playlistItem_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_youtube_playlistItem_get_success,
        error_message_i18n: i18n_key:tool_youtube_playlistItem_get_error,
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
    resource_id: resource:youtube_playlistItem,
    is_active: true;

CREATE tool:youtube_playlistItem_getMany SET
    identity = {
        name: "getMany",
        slug: "youtube_playlistItem_getMany",
        display_name_i18n: i18n_key:tool_youtube_playlistItem_getMany_name,
        description_i18n: i18n_key:tool_youtube_playlistItem_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 834,
        tooltip_i18n: i18n_key:tool_youtube_playlistItem_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_youtube_playlistItem_getMany_success,
        error_message_i18n: i18n_key:tool_youtube_playlistItem_getMany_error,
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
    resource_id: resource:youtube_playlistItem,
    is_active: true;

CREATE tool:youtube_video_get SET
    identity = {
        name: "get",
        slug: "youtube_video_get",
        display_name_i18n: i18n_key:tool_youtube_video_get_name,
        description_i18n: i18n_key:tool_youtube_video_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 835,
        tooltip_i18n: i18n_key:tool_youtube_video_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_youtube_video_get_success,
        error_message_i18n: i18n_key:tool_youtube_video_get_error,
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
    resource_id: resource:youtube_video,
    is_active: true;

CREATE tool:youtube_video_getMany SET
    identity = {
        name: "getMany",
        slug: "youtube_video_getMany",
        display_name_i18n: i18n_key:tool_youtube_video_getMany_name,
        description_i18n: i18n_key:tool_youtube_video_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 836,
        tooltip_i18n: i18n_key:tool_youtube_video_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_youtube_video_getMany_success,
        error_message_i18n: i18n_key:tool_youtube_video_getMany_error,
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
    resource_id: resource:youtube_video,
    is_active: true;

CREATE tool:youtube_videoCategory_get SET
    identity = {
        name: "get",
        slug: "youtube_videoCategory_get",
        display_name_i18n: i18n_key:tool_youtube_videoCategory_get_name,
        description_i18n: i18n_key:tool_youtube_videoCategory_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 837,
        tooltip_i18n: i18n_key:tool_youtube_videoCategory_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_youtube_videoCategory_get_success,
        error_message_i18n: i18n_key:tool_youtube_videoCategory_get_error,
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
    resource_id: resource:youtube_videoCategory,
    is_active: true;

CREATE tool:youtube_videoCategory_getMany SET
    identity = {
        name: "getMany",
        slug: "youtube_videoCategory_getMany",
        display_name_i18n: i18n_key:tool_youtube_videoCategory_getMany_name,
        description_i18n: i18n_key:tool_youtube_videoCategory_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 838,
        tooltip_i18n: i18n_key:tool_youtube_videoCategory_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_youtube_videoCategory_getMany_success,
        error_message_i18n: i18n_key:tool_youtube_videoCategory_getMany_error,
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
    resource_id: resource:youtube_videoCategory,
    is_active: true;

CREATE tool:youtube_playlistitem_get SET
    identity = {
        name: "get",
        slug: "youtube_playlistitem_get",
        display_name_i18n: i18n_key:tool_youtube_playlistitem_get_name,
        description_i18n: i18n_key:tool_youtube_playlistitem_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 839,
        tooltip_i18n: i18n_key:tool_youtube_playlistitem_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_youtube_playlistitem_get_success,
        error_message_i18n: i18n_key:tool_youtube_playlistitem_get_error,
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
    resource_id: resource:youtube_playlistitem,
    is_active: true;

CREATE tool:youtube_playlistitem_getMany SET
    identity = {
        name: "getMany",
        slug: "youtube_playlistitem_getMany",
        display_name_i18n: i18n_key:tool_youtube_playlistitem_getMany_name,
        description_i18n: i18n_key:tool_youtube_playlistitem_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 840,
        tooltip_i18n: i18n_key:tool_youtube_playlistitem_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_youtube_playlistitem_getMany_success,
        error_message_i18n: i18n_key:tool_youtube_playlistitem_getMany_error,
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
    resource_id: resource:youtube_playlistitem,
    is_active: true;

CREATE tool:youtube_videocategory_get SET
    identity = {
        name: "get",
        slug: "youtube_videocategory_get",
        display_name_i18n: i18n_key:tool_youtube_videocategory_get_name,
        description_i18n: i18n_key:tool_youtube_videocategory_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 841,
        tooltip_i18n: i18n_key:tool_youtube_videocategory_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_youtube_videocategory_get_success,
        error_message_i18n: i18n_key:tool_youtube_videocategory_get_error,
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
    resource_id: resource:youtube_videocategory,
    is_active: true;

CREATE tool:youtube_videocategory_getMany SET
    identity = {
        name: "getMany",
        slug: "youtube_videocategory_getMany",
        display_name_i18n: i18n_key:tool_youtube_videocategory_getMany_name,
        description_i18n: i18n_key:tool_youtube_videocategory_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 842,
        tooltip_i18n: i18n_key:tool_youtube_videocategory_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_youtube_videocategory_getMany_success,
        error_message_i18n: i18n_key:tool_youtube_videocategory_getMany_error,
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
    resource_id: resource:youtube_videocategory,
    is_active: true;

CREATE tool:gotify_message_create SET
    identity = {
        name: "create",
        slug: "gotify_message_create",
        display_name_i18n: i18n_key:tool_gotify_message_create_name,
        description_i18n: i18n_key:tool_gotify_message_create_desc,
        operation_type: "create",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#4CAF50",
        display_order: 843,
        tooltip_i18n: i18n_key:tool_gotify_message_create_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_gotify_message_create_success,
        error_message_i18n: i18n_key:tool_gotify_message_create_error,
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
    resource_id: resource:gotify_message,
    is_active: true;

CREATE tool:gotify_message_delete SET
    identity = {
        name: "delete",
        slug: "gotify_message_delete",
        display_name_i18n: i18n_key:tool_gotify_message_delete_name,
        description_i18n: i18n_key:tool_gotify_message_delete_desc,
        operation_type: "delete",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#F44336",
        display_order: 844,
        tooltip_i18n: i18n_key:tool_gotify_message_delete_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_gotify_message_delete_success,
        error_message_i18n: i18n_key:tool_gotify_message_delete_error,
        confirmation_required: true,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: true
    },
    config = {
        request: {
            method: "DELETE",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [204],
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
            requires_confirmation: true
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
    resource_id: resource:gotify_message,
    is_active: true;

CREATE tool:gotify_message_getAll SET
    identity = {
        name: "getAll",
        slug: "gotify_message_getAll",
        display_name_i18n: i18n_key:tool_gotify_message_getAll_name,
        description_i18n: i18n_key:tool_gotify_message_getAll_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 845,
        tooltip_i18n: i18n_key:tool_gotify_message_getAll_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_gotify_message_getAll_success,
        error_message_i18n: i18n_key:tool_gotify_message_getAll_error,
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
    resource_id: resource:gotify_message,
    is_active: true;

CREATE tool:gotowebinar_attendee_get SET
    identity = {
        name: "get",
        slug: "gotowebinar_attendee_get",
        display_name_i18n: i18n_key:tool_gotowebinar_attendee_get_name,
        description_i18n: i18n_key:tool_gotowebinar_attendee_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 846,
        tooltip_i18n: i18n_key:tool_gotowebinar_attendee_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_gotowebinar_attendee_get_success,
        error_message_i18n: i18n_key:tool_gotowebinar_attendee_get_error,
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
    resource_id: resource:gotowebinar_attendee,
    is_active: true;

CREATE tool:gotowebinar_attendee_getMany SET
    identity = {
        name: "getMany",
        slug: "gotowebinar_attendee_getMany",
        display_name_i18n: i18n_key:tool_gotowebinar_attendee_getMany_name,
        description_i18n: i18n_key:tool_gotowebinar_attendee_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 847,
        tooltip_i18n: i18n_key:tool_gotowebinar_attendee_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_gotowebinar_attendee_getMany_success,
        error_message_i18n: i18n_key:tool_gotowebinar_attendee_getMany_error,
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
    resource_id: resource:gotowebinar_attendee,
    is_active: true;

CREATE tool:gotowebinar_coorganizer_get SET
    identity = {
        name: "get",
        slug: "gotowebinar_coorganizer_get",
        display_name_i18n: i18n_key:tool_gotowebinar_coorganizer_get_name,
        description_i18n: i18n_key:tool_gotowebinar_coorganizer_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 848,
        tooltip_i18n: i18n_key:tool_gotowebinar_coorganizer_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_gotowebinar_coorganizer_get_success,
        error_message_i18n: i18n_key:tool_gotowebinar_coorganizer_get_error,
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
    resource_id: resource:gotowebinar_coorganizer,
    is_active: true;

CREATE tool:gotowebinar_coorganizer_getMany SET
    identity = {
        name: "getMany",
        slug: "gotowebinar_coorganizer_getMany",
        display_name_i18n: i18n_key:tool_gotowebinar_coorganizer_getMany_name,
        description_i18n: i18n_key:tool_gotowebinar_coorganizer_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 849,
        tooltip_i18n: i18n_key:tool_gotowebinar_coorganizer_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_gotowebinar_coorganizer_getMany_success,
        error_message_i18n: i18n_key:tool_gotowebinar_coorganizer_getMany_error,
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
    resource_id: resource:gotowebinar_coorganizer,
    is_active: true;

CREATE tool:gotowebinar_panelist_get SET
    identity = {
        name: "get",
        slug: "gotowebinar_panelist_get",
        display_name_i18n: i18n_key:tool_gotowebinar_panelist_get_name,
        description_i18n: i18n_key:tool_gotowebinar_panelist_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 850,
        tooltip_i18n: i18n_key:tool_gotowebinar_panelist_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_gotowebinar_panelist_get_success,
        error_message_i18n: i18n_key:tool_gotowebinar_panelist_get_error,
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
    resource_id: resource:gotowebinar_panelist,
    is_active: true;

CREATE tool:gotowebinar_panelist_getMany SET
    identity = {
        name: "getMany",
        slug: "gotowebinar_panelist_getMany",
        display_name_i18n: i18n_key:tool_gotowebinar_panelist_getMany_name,
        description_i18n: i18n_key:tool_gotowebinar_panelist_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 851,
        tooltip_i18n: i18n_key:tool_gotowebinar_panelist_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_gotowebinar_panelist_getMany_success,
        error_message_i18n: i18n_key:tool_gotowebinar_panelist_getMany_error,
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
    resource_id: resource:gotowebinar_panelist,
    is_active: true;

CREATE tool:gotowebinar_registrant_get SET
    identity = {
        name: "get",
        slug: "gotowebinar_registrant_get",
        display_name_i18n: i18n_key:tool_gotowebinar_registrant_get_name,
        description_i18n: i18n_key:tool_gotowebinar_registrant_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 852,
        tooltip_i18n: i18n_key:tool_gotowebinar_registrant_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_gotowebinar_registrant_get_success,
        error_message_i18n: i18n_key:tool_gotowebinar_registrant_get_error,
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
    resource_id: resource:gotowebinar_registrant,
    is_active: true;

CREATE tool:gotowebinar_registrant_getMany SET
    identity = {
        name: "getMany",
        slug: "gotowebinar_registrant_getMany",
        display_name_i18n: i18n_key:tool_gotowebinar_registrant_getMany_name,
        description_i18n: i18n_key:tool_gotowebinar_registrant_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 853,
        tooltip_i18n: i18n_key:tool_gotowebinar_registrant_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_gotowebinar_registrant_getMany_success,
        error_message_i18n: i18n_key:tool_gotowebinar_registrant_getMany_error,
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
    resource_id: resource:gotowebinar_registrant,
    is_active: true;

CREATE tool:gotowebinar_session_get SET
    identity = {
        name: "get",
        slug: "gotowebinar_session_get",
        display_name_i18n: i18n_key:tool_gotowebinar_session_get_name,
        description_i18n: i18n_key:tool_gotowebinar_session_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 854,
        tooltip_i18n: i18n_key:tool_gotowebinar_session_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_gotowebinar_session_get_success,
        error_message_i18n: i18n_key:tool_gotowebinar_session_get_error,
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
    resource_id: resource:gotowebinar_session,
    is_active: true;

CREATE tool:gotowebinar_session_getMany SET
    identity = {
        name: "getMany",
        slug: "gotowebinar_session_getMany",
        display_name_i18n: i18n_key:tool_gotowebinar_session_getMany_name,
        description_i18n: i18n_key:tool_gotowebinar_session_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 855,
        tooltip_i18n: i18n_key:tool_gotowebinar_session_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_gotowebinar_session_getMany_success,
        error_message_i18n: i18n_key:tool_gotowebinar_session_getMany_error,
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
    resource_id: resource:gotowebinar_session,
    is_active: true;

CREATE tool:gotowebinar_webinar_get SET
    identity = {
        name: "get",
        slug: "gotowebinar_webinar_get",
        display_name_i18n: i18n_key:tool_gotowebinar_webinar_get_name,
        description_i18n: i18n_key:tool_gotowebinar_webinar_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 856,
        tooltip_i18n: i18n_key:tool_gotowebinar_webinar_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_gotowebinar_webinar_get_success,
        error_message_i18n: i18n_key:tool_gotowebinar_webinar_get_error,
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
    resource_id: resource:gotowebinar_webinar,
    is_active: true;

CREATE tool:gotowebinar_webinar_getMany SET
    identity = {
        name: "getMany",
        slug: "gotowebinar_webinar_getMany",
        display_name_i18n: i18n_key:tool_gotowebinar_webinar_getMany_name,
        description_i18n: i18n_key:tool_gotowebinar_webinar_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 857,
        tooltip_i18n: i18n_key:tool_gotowebinar_webinar_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_gotowebinar_webinar_getMany_success,
        error_message_i18n: i18n_key:tool_gotowebinar_webinar_getMany_error,
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
    resource_id: resource:gotowebinar_webinar,
    is_active: true;

CREATE tool:grafana_dashboard_get SET
    identity = {
        name: "get",
        slug: "grafana_dashboard_get",
        display_name_i18n: i18n_key:tool_grafana_dashboard_get_name,
        description_i18n: i18n_key:tool_grafana_dashboard_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 858,
        tooltip_i18n: i18n_key:tool_grafana_dashboard_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_grafana_dashboard_get_success,
        error_message_i18n: i18n_key:tool_grafana_dashboard_get_error,
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
    resource_id: resource:grafana_dashboard,
    is_active: true;

CREATE tool:grafana_dashboard_getMany SET
    identity = {
        name: "getMany",
        slug: "grafana_dashboard_getMany",
        display_name_i18n: i18n_key:tool_grafana_dashboard_getMany_name,
        description_i18n: i18n_key:tool_grafana_dashboard_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 859,
        tooltip_i18n: i18n_key:tool_grafana_dashboard_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_grafana_dashboard_getMany_success,
        error_message_i18n: i18n_key:tool_grafana_dashboard_getMany_error,
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
    resource_id: resource:grafana_dashboard,
    is_active: true;

CREATE tool:grafana_team_get SET
    identity = {
        name: "get",
        slug: "grafana_team_get",
        display_name_i18n: i18n_key:tool_grafana_team_get_name,
        description_i18n: i18n_key:tool_grafana_team_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 860,
        tooltip_i18n: i18n_key:tool_grafana_team_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_grafana_team_get_success,
        error_message_i18n: i18n_key:tool_grafana_team_get_error,
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
    resource_id: resource:grafana_team,
    is_active: true;

CREATE tool:grafana_team_getMany SET
    identity = {
        name: "getMany",
        slug: "grafana_team_getMany",
        display_name_i18n: i18n_key:tool_grafana_team_getMany_name,
        description_i18n: i18n_key:tool_grafana_team_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 861,
        tooltip_i18n: i18n_key:tool_grafana_team_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_grafana_team_getMany_success,
        error_message_i18n: i18n_key:tool_grafana_team_getMany_error,
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
    resource_id: resource:grafana_team,
    is_active: true;

CREATE tool:grafana_teamMember_get SET
    identity = {
        name: "get",
        slug: "grafana_teamMember_get",
        display_name_i18n: i18n_key:tool_grafana_teamMember_get_name,
        description_i18n: i18n_key:tool_grafana_teamMember_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 862,
        tooltip_i18n: i18n_key:tool_grafana_teamMember_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_grafana_teamMember_get_success,
        error_message_i18n: i18n_key:tool_grafana_teamMember_get_error,
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
    resource_id: resource:grafana_teamMember,
    is_active: true;

CREATE tool:grafana_teamMember_getMany SET
    identity = {
        name: "getMany",
        slug: "grafana_teamMember_getMany",
        display_name_i18n: i18n_key:tool_grafana_teamMember_getMany_name,
        description_i18n: i18n_key:tool_grafana_teamMember_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 863,
        tooltip_i18n: i18n_key:tool_grafana_teamMember_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_grafana_teamMember_getMany_success,
        error_message_i18n: i18n_key:tool_grafana_teamMember_getMany_error,
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
    resource_id: resource:grafana_teamMember,
    is_active: true;

CREATE tool:grafana_user_get SET
    identity = {
        name: "get",
        slug: "grafana_user_get",
        display_name_i18n: i18n_key:tool_grafana_user_get_name,
        description_i18n: i18n_key:tool_grafana_user_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 864,
        tooltip_i18n: i18n_key:tool_grafana_user_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_grafana_user_get_success,
        error_message_i18n: i18n_key:tool_grafana_user_get_error,
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
    resource_id: resource:grafana_user,
    is_active: true;

CREATE tool:grafana_user_getMany SET
    identity = {
        name: "getMany",
        slug: "grafana_user_getMany",
        display_name_i18n: i18n_key:tool_grafana_user_getMany_name,
        description_i18n: i18n_key:tool_grafana_user_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 865,
        tooltip_i18n: i18n_key:tool_grafana_user_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_grafana_user_getMany_success,
        error_message_i18n: i18n_key:tool_grafana_user_getMany_error,
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
    resource_id: resource:grafana_user,
    is_active: true;

CREATE tool:graphql_graphql_get SET
    identity = {
        name: "get",
        slug: "graphql_graphql_get",
        display_name_i18n: i18n_key:tool_graphql_graphql_get_name,
        description_i18n: i18n_key:tool_graphql_graphql_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 866,
        tooltip_i18n: i18n_key:tool_graphql_graphql_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_graphql_graphql_get_success,
        error_message_i18n: i18n_key:tool_graphql_graphql_get_error,
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
    resource_id: resource:graphql_graphql,
    is_active: true;

CREATE tool:graphql_graphql_getMany SET
    identity = {
        name: "getMany",
        slug: "graphql_graphql_getMany",
        display_name_i18n: i18n_key:tool_graphql_graphql_getMany_name,
        description_i18n: i18n_key:tool_graphql_graphql_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 867,
        tooltip_i18n: i18n_key:tool_graphql_graphql_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_graphql_graphql_getMany_success,
        error_message_i18n: i18n_key:tool_graphql_graphql_getMany_error,
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
    resource_id: resource:graphql_graphql,
    is_active: true;

CREATE tool:grist_operation_get SET
    identity = {
        name: "get",
        slug: "grist_operation_get",
        display_name_i18n: i18n_key:tool_grist_operation_get_name,
        description_i18n: i18n_key:tool_grist_operation_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 868,
        tooltip_i18n: i18n_key:tool_grist_operation_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_grist_operation_get_success,
        error_message_i18n: i18n_key:tool_grist_operation_get_error,
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
    resource_id: resource:grist_operation,
    is_active: true;

CREATE tool:grist_operation_getMany SET
    identity = {
        name: "getMany",
        slug: "grist_operation_getMany",
        display_name_i18n: i18n_key:tool_grist_operation_getMany_name,
        description_i18n: i18n_key:tool_grist_operation_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 869,
        tooltip_i18n: i18n_key:tool_grist_operation_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_grist_operation_getMany_success,
        error_message_i18n: i18n_key:tool_grist_operation_getMany_error,
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
    resource_id: resource:grist_operation,
    is_active: true;

CREATE tool:hackernews_all_getAll SET
    identity = {
        name: "getAll",
        slug: "hackernews_all_getAll",
        display_name_i18n: i18n_key:tool_hackernews_all_getAll_name,
        description_i18n: i18n_key:tool_hackernews_all_getAll_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 870,
        tooltip_i18n: i18n_key:tool_hackernews_all_getAll_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_hackernews_all_getAll_success,
        error_message_i18n: i18n_key:tool_hackernews_all_getAll_error,
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
    resource_id: resource:hackernews_all,
    is_active: true;

CREATE tool:hackernews_article_getAll SET
    identity = {
        name: "getAll",
        slug: "hackernews_article_getAll",
        display_name_i18n: i18n_key:tool_hackernews_article_getAll_name,
        description_i18n: i18n_key:tool_hackernews_article_getAll_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 871,
        tooltip_i18n: i18n_key:tool_hackernews_article_getAll_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_hackernews_article_getAll_success,
        error_message_i18n: i18n_key:tool_hackernews_article_getAll_error,
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
    resource_id: resource:hackernews_article,
    is_active: true;

CREATE tool:hackernews_user_getAll SET
    identity = {
        name: "getAll",
        slug: "hackernews_user_getAll",
        display_name_i18n: i18n_key:tool_hackernews_user_getAll_name,
        description_i18n: i18n_key:tool_hackernews_user_getAll_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 872,
        tooltip_i18n: i18n_key:tool_hackernews_user_getAll_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_hackernews_user_getAll_success,
        error_message_i18n: i18n_key:tool_hackernews_user_getAll_error,
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
    resource_id: resource:hackernews_user,
    is_active: true;

CREATE tool:halopsa_client_get SET
    identity = {
        name: "get",
        slug: "halopsa_client_get",
        display_name_i18n: i18n_key:tool_halopsa_client_get_name,
        description_i18n: i18n_key:tool_halopsa_client_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 873,
        tooltip_i18n: i18n_key:tool_halopsa_client_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_halopsa_client_get_success,
        error_message_i18n: i18n_key:tool_halopsa_client_get_error,
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
    resource_id: resource:halopsa_client,
    is_active: true;

CREATE tool:halopsa_client_getMany SET
    identity = {
        name: "getMany",
        slug: "halopsa_client_getMany",
        display_name_i18n: i18n_key:tool_halopsa_client_getMany_name,
        description_i18n: i18n_key:tool_halopsa_client_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 874,
        tooltip_i18n: i18n_key:tool_halopsa_client_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_halopsa_client_getMany_success,
        error_message_i18n: i18n_key:tool_halopsa_client_getMany_error,
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
    resource_id: resource:halopsa_client,
    is_active: true;

CREATE tool:halopsa_site_get SET
    identity = {
        name: "get",
        slug: "halopsa_site_get",
        display_name_i18n: i18n_key:tool_halopsa_site_get_name,
        description_i18n: i18n_key:tool_halopsa_site_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 875,
        tooltip_i18n: i18n_key:tool_halopsa_site_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_halopsa_site_get_success,
        error_message_i18n: i18n_key:tool_halopsa_site_get_error,
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
    resource_id: resource:halopsa_site,
    is_active: true;

CREATE tool:halopsa_site_getMany SET
    identity = {
        name: "getMany",
        slug: "halopsa_site_getMany",
        display_name_i18n: i18n_key:tool_halopsa_site_getMany_name,
        description_i18n: i18n_key:tool_halopsa_site_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 876,
        tooltip_i18n: i18n_key:tool_halopsa_site_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_halopsa_site_getMany_success,
        error_message_i18n: i18n_key:tool_halopsa_site_getMany_error,
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
    resource_id: resource:halopsa_site,
    is_active: true;

CREATE tool:halopsa_ticket_get SET
    identity = {
        name: "get",
        slug: "halopsa_ticket_get",
        display_name_i18n: i18n_key:tool_halopsa_ticket_get_name,
        description_i18n: i18n_key:tool_halopsa_ticket_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 877,
        tooltip_i18n: i18n_key:tool_halopsa_ticket_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_halopsa_ticket_get_success,
        error_message_i18n: i18n_key:tool_halopsa_ticket_get_error,
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
    resource_id: resource:halopsa_ticket,
    is_active: true;

CREATE tool:halopsa_ticket_getMany SET
    identity = {
        name: "getMany",
        slug: "halopsa_ticket_getMany",
        display_name_i18n: i18n_key:tool_halopsa_ticket_getMany_name,
        description_i18n: i18n_key:tool_halopsa_ticket_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 878,
        tooltip_i18n: i18n_key:tool_halopsa_ticket_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_halopsa_ticket_getMany_success,
        error_message_i18n: i18n_key:tool_halopsa_ticket_getMany_error,
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
    resource_id: resource:halopsa_ticket,
    is_active: true;

CREATE tool:halopsa_user_get SET
    identity = {
        name: "get",
        slug: "halopsa_user_get",
        display_name_i18n: i18n_key:tool_halopsa_user_get_name,
        description_i18n: i18n_key:tool_halopsa_user_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 879,
        tooltip_i18n: i18n_key:tool_halopsa_user_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_halopsa_user_get_success,
        error_message_i18n: i18n_key:tool_halopsa_user_get_error,
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
    resource_id: resource:halopsa_user,
    is_active: true;

CREATE tool:halopsa_user_getMany SET
    identity = {
        name: "getMany",
        slug: "halopsa_user_getMany",
        display_name_i18n: i18n_key:tool_halopsa_user_getMany_name,
        description_i18n: i18n_key:tool_halopsa_user_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 880,
        tooltip_i18n: i18n_key:tool_halopsa_user_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_halopsa_user_getMany_success,
        error_message_i18n: i18n_key:tool_halopsa_user_getMany_error,
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
    resource_id: resource:halopsa_user,
    is_active: true;

CREATE tool:harvest_client_get SET
    identity = {
        name: "get",
        slug: "harvest_client_get",
        display_name_i18n: i18n_key:tool_harvest_client_get_name,
        description_i18n: i18n_key:tool_harvest_client_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 881,
        tooltip_i18n: i18n_key:tool_harvest_client_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_harvest_client_get_success,
        error_message_i18n: i18n_key:tool_harvest_client_get_error,
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
    resource_id: resource:harvest_client,
    is_active: true;

CREATE tool:harvest_client_getMany SET
    identity = {
        name: "getMany",
        slug: "harvest_client_getMany",
        display_name_i18n: i18n_key:tool_harvest_client_getMany_name,
        description_i18n: i18n_key:tool_harvest_client_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 882,
        tooltip_i18n: i18n_key:tool_harvest_client_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_harvest_client_getMany_success,
        error_message_i18n: i18n_key:tool_harvest_client_getMany_error,
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
    resource_id: resource:harvest_client,
    is_active: true;

CREATE tool:harvest_company_get SET
    identity = {
        name: "get",
        slug: "harvest_company_get",
        display_name_i18n: i18n_key:tool_harvest_company_get_name,
        description_i18n: i18n_key:tool_harvest_company_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 883,
        tooltip_i18n: i18n_key:tool_harvest_company_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_harvest_company_get_success,
        error_message_i18n: i18n_key:tool_harvest_company_get_error,
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
    resource_id: resource:harvest_company,
    is_active: true;

CREATE tool:harvest_company_getMany SET
    identity = {
        name: "getMany",
        slug: "harvest_company_getMany",
        display_name_i18n: i18n_key:tool_harvest_company_getMany_name,
        description_i18n: i18n_key:tool_harvest_company_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 884,
        tooltip_i18n: i18n_key:tool_harvest_company_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_harvest_company_getMany_success,
        error_message_i18n: i18n_key:tool_harvest_company_getMany_error,
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
    resource_id: resource:harvest_company,
    is_active: true;

CREATE tool:harvest_contact_get SET
    identity = {
        name: "get",
        slug: "harvest_contact_get",
        display_name_i18n: i18n_key:tool_harvest_contact_get_name,
        description_i18n: i18n_key:tool_harvest_contact_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 885,
        tooltip_i18n: i18n_key:tool_harvest_contact_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_harvest_contact_get_success,
        error_message_i18n: i18n_key:tool_harvest_contact_get_error,
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
    resource_id: resource:harvest_contact,
    is_active: true;

CREATE tool:harvest_contact_getMany SET
    identity = {
        name: "getMany",
        slug: "harvest_contact_getMany",
        display_name_i18n: i18n_key:tool_harvest_contact_getMany_name,
        description_i18n: i18n_key:tool_harvest_contact_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 886,
        tooltip_i18n: i18n_key:tool_harvest_contact_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_harvest_contact_getMany_success,
        error_message_i18n: i18n_key:tool_harvest_contact_getMany_error,
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
    resource_id: resource:harvest_contact,
    is_active: true;

CREATE tool:harvest_estimate_get SET
    identity = {
        name: "get",
        slug: "harvest_estimate_get",
        display_name_i18n: i18n_key:tool_harvest_estimate_get_name,
        description_i18n: i18n_key:tool_harvest_estimate_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 887,
        tooltip_i18n: i18n_key:tool_harvest_estimate_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_harvest_estimate_get_success,
        error_message_i18n: i18n_key:tool_harvest_estimate_get_error,
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
    resource_id: resource:harvest_estimate,
    is_active: true;

CREATE tool:harvest_estimate_getMany SET
    identity = {
        name: "getMany",
        slug: "harvest_estimate_getMany",
        display_name_i18n: i18n_key:tool_harvest_estimate_getMany_name,
        description_i18n: i18n_key:tool_harvest_estimate_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 888,
        tooltip_i18n: i18n_key:tool_harvest_estimate_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_harvest_estimate_getMany_success,
        error_message_i18n: i18n_key:tool_harvest_estimate_getMany_error,
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
    resource_id: resource:harvest_estimate,
    is_active: true;

CREATE tool:harvest_expense_get SET
    identity = {
        name: "get",
        slug: "harvest_expense_get",
        display_name_i18n: i18n_key:tool_harvest_expense_get_name,
        description_i18n: i18n_key:tool_harvest_expense_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 889,
        tooltip_i18n: i18n_key:tool_harvest_expense_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_harvest_expense_get_success,
        error_message_i18n: i18n_key:tool_harvest_expense_get_error,
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
    resource_id: resource:harvest_expense,
    is_active: true;

CREATE tool:harvest_expense_getMany SET
    identity = {
        name: "getMany",
        slug: "harvest_expense_getMany",
        display_name_i18n: i18n_key:tool_harvest_expense_getMany_name,
        description_i18n: i18n_key:tool_harvest_expense_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 890,
        tooltip_i18n: i18n_key:tool_harvest_expense_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_harvest_expense_getMany_success,
        error_message_i18n: i18n_key:tool_harvest_expense_getMany_error,
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
    resource_id: resource:harvest_expense,
    is_active: true;

CREATE tool:harvest_invoice_get SET
    identity = {
        name: "get",
        slug: "harvest_invoice_get",
        display_name_i18n: i18n_key:tool_harvest_invoice_get_name,
        description_i18n: i18n_key:tool_harvest_invoice_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 891,
        tooltip_i18n: i18n_key:tool_harvest_invoice_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_harvest_invoice_get_success,
        error_message_i18n: i18n_key:tool_harvest_invoice_get_error,
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
    resource_id: resource:harvest_invoice,
    is_active: true;

CREATE tool:harvest_invoice_getMany SET
    identity = {
        name: "getMany",
        slug: "harvest_invoice_getMany",
        display_name_i18n: i18n_key:tool_harvest_invoice_getMany_name,
        description_i18n: i18n_key:tool_harvest_invoice_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 892,
        tooltip_i18n: i18n_key:tool_harvest_invoice_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_harvest_invoice_getMany_success,
        error_message_i18n: i18n_key:tool_harvest_invoice_getMany_error,
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
    resource_id: resource:harvest_invoice,
    is_active: true;

CREATE tool:harvest_project_get SET
    identity = {
        name: "get",
        slug: "harvest_project_get",
        display_name_i18n: i18n_key:tool_harvest_project_get_name,
        description_i18n: i18n_key:tool_harvest_project_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 893,
        tooltip_i18n: i18n_key:tool_harvest_project_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_harvest_project_get_success,
        error_message_i18n: i18n_key:tool_harvest_project_get_error,
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
    resource_id: resource:harvest_project,
    is_active: true;

CREATE tool:harvest_project_getMany SET
    identity = {
        name: "getMany",
        slug: "harvest_project_getMany",
        display_name_i18n: i18n_key:tool_harvest_project_getMany_name,
        description_i18n: i18n_key:tool_harvest_project_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 894,
        tooltip_i18n: i18n_key:tool_harvest_project_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_harvest_project_getMany_success,
        error_message_i18n: i18n_key:tool_harvest_project_getMany_error,
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
    resource_id: resource:harvest_project,
    is_active: true;

CREATE tool:harvest_task_get SET
    identity = {
        name: "get",
        slug: "harvest_task_get",
        display_name_i18n: i18n_key:tool_harvest_task_get_name,
        description_i18n: i18n_key:tool_harvest_task_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 895,
        tooltip_i18n: i18n_key:tool_harvest_task_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_harvest_task_get_success,
        error_message_i18n: i18n_key:tool_harvest_task_get_error,
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
    resource_id: resource:harvest_task,
    is_active: true;

CREATE tool:harvest_task_getMany SET
    identity = {
        name: "getMany",
        slug: "harvest_task_getMany",
        display_name_i18n: i18n_key:tool_harvest_task_getMany_name,
        description_i18n: i18n_key:tool_harvest_task_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 896,
        tooltip_i18n: i18n_key:tool_harvest_task_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_harvest_task_getMany_success,
        error_message_i18n: i18n_key:tool_harvest_task_getMany_error,
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
    resource_id: resource:harvest_task,
    is_active: true;

CREATE tool:harvest_timeEntry_get SET
    identity = {
        name: "get",
        slug: "harvest_timeEntry_get",
        display_name_i18n: i18n_key:tool_harvest_timeEntry_get_name,
        description_i18n: i18n_key:tool_harvest_timeEntry_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 897,
        tooltip_i18n: i18n_key:tool_harvest_timeEntry_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_harvest_timeEntry_get_success,
        error_message_i18n: i18n_key:tool_harvest_timeEntry_get_error,
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
    resource_id: resource:harvest_timeEntry,
    is_active: true;

CREATE tool:harvest_timeEntry_getMany SET
    identity = {
        name: "getMany",
        slug: "harvest_timeEntry_getMany",
        display_name_i18n: i18n_key:tool_harvest_timeEntry_getMany_name,
        description_i18n: i18n_key:tool_harvest_timeEntry_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 898,
        tooltip_i18n: i18n_key:tool_harvest_timeEntry_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_harvest_timeEntry_getMany_success,
        error_message_i18n: i18n_key:tool_harvest_timeEntry_getMany_error,
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
    resource_id: resource:harvest_timeEntry,
    is_active: true;

CREATE tool:harvest_user_get SET
    identity = {
        name: "get",
        slug: "harvest_user_get",
        display_name_i18n: i18n_key:tool_harvest_user_get_name,
        description_i18n: i18n_key:tool_harvest_user_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 899,
        tooltip_i18n: i18n_key:tool_harvest_user_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_harvest_user_get_success,
        error_message_i18n: i18n_key:tool_harvest_user_get_error,
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
    resource_id: resource:harvest_user,
    is_active: true;

CREATE tool:harvest_user_getMany SET
    identity = {
        name: "getMany",
        slug: "harvest_user_getMany",
        display_name_i18n: i18n_key:tool_harvest_user_getMany_name,
        description_i18n: i18n_key:tool_harvest_user_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 900,
        tooltip_i18n: i18n_key:tool_harvest_user_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_harvest_user_getMany_success,
        error_message_i18n: i18n_key:tool_harvest_user_getMany_error,
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
    resource_id: resource:harvest_user,
    is_active: true;

