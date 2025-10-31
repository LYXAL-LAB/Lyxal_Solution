-- Batch 8: 100 tools Lyxal

CREATE tool:gong_call_getMany SET
    identity = {
        name: "getMany",
        slug: "gong_call_getMany",
        display_name_i18n: i18n_key:tool_gong_call_getMany_name,
        description_i18n: i18n_key:tool_gong_call_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 701,
        tooltip_i18n: i18n_key:tool_gong_call_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_gong_call_getMany_success,
        error_message_i18n: i18n_key:tool_gong_call_getMany_error,
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
    resource_id: resource:gong_call,
    is_active: true;

CREATE tool:gong_user_get SET
    identity = {
        name: "get",
        slug: "gong_user_get",
        display_name_i18n: i18n_key:tool_gong_user_get_name,
        description_i18n: i18n_key:tool_gong_user_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 702,
        tooltip_i18n: i18n_key:tool_gong_user_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_gong_user_get_success,
        error_message_i18n: i18n_key:tool_gong_user_get_error,
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
    resource_id: resource:gong_user,
    is_active: true;

CREATE tool:gong_user_getMany SET
    identity = {
        name: "getMany",
        slug: "gong_user_getMany",
        display_name_i18n: i18n_key:tool_gong_user_getMany_name,
        description_i18n: i18n_key:tool_gong_user_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 703,
        tooltip_i18n: i18n_key:tool_gong_user_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_gong_user_getMany_success,
        error_message_i18n: i18n_key:tool_gong_user_getMany_error,
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
    resource_id: resource:gong_user,
    is_active: true;

CREATE tool:googleads_campaign_get SET
    identity = {
        name: "get",
        slug: "googleads_campaign_get",
        display_name_i18n: i18n_key:tool_googleads_campaign_get_name,
        description_i18n: i18n_key:tool_googleads_campaign_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 704,
        tooltip_i18n: i18n_key:tool_googleads_campaign_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googleads_campaign_get_success,
        error_message_i18n: i18n_key:tool_googleads_campaign_get_error,
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
    resource_id: resource:googleads_campaign,
    is_active: true;

CREATE tool:googleads_campaign_getMany SET
    identity = {
        name: "getMany",
        slug: "googleads_campaign_getMany",
        display_name_i18n: i18n_key:tool_googleads_campaign_getMany_name,
        description_i18n: i18n_key:tool_googleads_campaign_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 705,
        tooltip_i18n: i18n_key:tool_googleads_campaign_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googleads_campaign_getMany_success,
        error_message_i18n: i18n_key:tool_googleads_campaign_getMany_error,
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
    resource_id: resource:googleads_campaign,
    is_active: true;

CREATE tool:googleanalytics_googleanalytics_get SET
    identity = {
        name: "get",
        slug: "googleanalytics_googleanalytics_get",
        display_name_i18n: i18n_key:tool_googleanalytics_googleanalytics_get_name,
        description_i18n: i18n_key:tool_googleanalytics_googleanalytics_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 706,
        tooltip_i18n: i18n_key:tool_googleanalytics_googleanalytics_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googleanalytics_googleanalytics_get_success,
        error_message_i18n: i18n_key:tool_googleanalytics_googleanalytics_get_error,
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
    resource_id: resource:googleanalytics_googleanalytics,
    is_active: true;

CREATE tool:googleanalytics_googleanalytics_getMany SET
    identity = {
        name: "getMany",
        slug: "googleanalytics_googleanalytics_getMany",
        display_name_i18n: i18n_key:tool_googleanalytics_googleanalytics_getMany_name,
        description_i18n: i18n_key:tool_googleanalytics_googleanalytics_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 707,
        tooltip_i18n: i18n_key:tool_googleanalytics_googleanalytics_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googleanalytics_googleanalytics_getMany_success,
        error_message_i18n: i18n_key:tool_googleanalytics_googleanalytics_getMany_error,
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
    resource_id: resource:googleanalytics_googleanalytics,
    is_active: true;

CREATE tool:googleanalyticsv1_report_get SET
    identity = {
        name: "get",
        slug: "googleanalyticsv1_report_get",
        display_name_i18n: i18n_key:tool_googleanalyticsv1_report_get_name,
        description_i18n: i18n_key:tool_googleanalyticsv1_report_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 708,
        tooltip_i18n: i18n_key:tool_googleanalyticsv1_report_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googleanalyticsv1_report_get_success,
        error_message_i18n: i18n_key:tool_googleanalyticsv1_report_get_error,
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
    resource_id: resource:googleanalyticsv1_report,
    is_active: true;

CREATE tool:googleanalyticsv1_report_getMany SET
    identity = {
        name: "getMany",
        slug: "googleanalyticsv1_report_getMany",
        display_name_i18n: i18n_key:tool_googleanalyticsv1_report_getMany_name,
        description_i18n: i18n_key:tool_googleanalyticsv1_report_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 709,
        tooltip_i18n: i18n_key:tool_googleanalyticsv1_report_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googleanalyticsv1_report_getMany_success,
        error_message_i18n: i18n_key:tool_googleanalyticsv1_report_getMany_error,
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
    resource_id: resource:googleanalyticsv1_report,
    is_active: true;

CREATE tool:googleanalyticsv1_userActivity_get SET
    identity = {
        name: "get",
        slug: "googleanalyticsv1_userActivity_get",
        display_name_i18n: i18n_key:tool_googleanalyticsv1_userActivity_get_name,
        description_i18n: i18n_key:tool_googleanalyticsv1_userActivity_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 710,
        tooltip_i18n: i18n_key:tool_googleanalyticsv1_userActivity_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googleanalyticsv1_userActivity_get_success,
        error_message_i18n: i18n_key:tool_googleanalyticsv1_userActivity_get_error,
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
    resource_id: resource:googleanalyticsv1_userActivity,
    is_active: true;

CREATE tool:googleanalyticsv1_userActivity_getMany SET
    identity = {
        name: "getMany",
        slug: "googleanalyticsv1_userActivity_getMany",
        display_name_i18n: i18n_key:tool_googleanalyticsv1_userActivity_getMany_name,
        description_i18n: i18n_key:tool_googleanalyticsv1_userActivity_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 711,
        tooltip_i18n: i18n_key:tool_googleanalyticsv1_userActivity_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googleanalyticsv1_userActivity_getMany_success,
        error_message_i18n: i18n_key:tool_googleanalyticsv1_userActivity_getMany_error,
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
    resource_id: resource:googleanalyticsv1_userActivity,
    is_active: true;

CREATE tool:googleanalyticsv1_useractivity_get SET
    identity = {
        name: "get",
        slug: "googleanalyticsv1_useractivity_get",
        display_name_i18n: i18n_key:tool_googleanalyticsv1_useractivity_get_name,
        description_i18n: i18n_key:tool_googleanalyticsv1_useractivity_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 712,
        tooltip_i18n: i18n_key:tool_googleanalyticsv1_useractivity_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googleanalyticsv1_useractivity_get_success,
        error_message_i18n: i18n_key:tool_googleanalyticsv1_useractivity_get_error,
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
    resource_id: resource:googleanalyticsv1_useractivity,
    is_active: true;

CREATE tool:googleanalyticsv1_useractivity_getMany SET
    identity = {
        name: "getMany",
        slug: "googleanalyticsv1_useractivity_getMany",
        display_name_i18n: i18n_key:tool_googleanalyticsv1_useractivity_getMany_name,
        description_i18n: i18n_key:tool_googleanalyticsv1_useractivity_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 713,
        tooltip_i18n: i18n_key:tool_googleanalyticsv1_useractivity_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googleanalyticsv1_useractivity_getMany_success,
        error_message_i18n: i18n_key:tool_googleanalyticsv1_useractivity_getMany_error,
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
    resource_id: resource:googleanalyticsv1_useractivity,
    is_active: true;

CREATE tool:googleanalyticsv2_googleanalyticsv2_get SET
    identity = {
        name: "get",
        slug: "googleanalyticsv2_googleanalyticsv2_get",
        display_name_i18n: i18n_key:tool_googleanalyticsv2_googleanalyticsv2_get_name,
        description_i18n: i18n_key:tool_googleanalyticsv2_googleanalyticsv2_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 714,
        tooltip_i18n: i18n_key:tool_googleanalyticsv2_googleanalyticsv2_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googleanalyticsv2_googleanalyticsv2_get_success,
        error_message_i18n: i18n_key:tool_googleanalyticsv2_googleanalyticsv2_get_error,
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
    resource_id: resource:googleanalyticsv2_googleanalyticsv2,
    is_active: true;

CREATE tool:googleanalyticsv2_googleanalyticsv2_getMany SET
    identity = {
        name: "getMany",
        slug: "googleanalyticsv2_googleanalyticsv2_getMany",
        display_name_i18n: i18n_key:tool_googleanalyticsv2_googleanalyticsv2_getMany_name,
        description_i18n: i18n_key:tool_googleanalyticsv2_googleanalyticsv2_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 715,
        tooltip_i18n: i18n_key:tool_googleanalyticsv2_googleanalyticsv2_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googleanalyticsv2_googleanalyticsv2_getMany_success,
        error_message_i18n: i18n_key:tool_googleanalyticsv2_googleanalyticsv2_getMany_error,
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
    resource_id: resource:googleanalyticsv2_googleanalyticsv2,
    is_active: true;

CREATE tool:googlebigquery_googlebigquery_get SET
    identity = {
        name: "get",
        slug: "googlebigquery_googlebigquery_get",
        display_name_i18n: i18n_key:tool_googlebigquery_googlebigquery_get_name,
        description_i18n: i18n_key:tool_googlebigquery_googlebigquery_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 716,
        tooltip_i18n: i18n_key:tool_googlebigquery_googlebigquery_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googlebigquery_googlebigquery_get_success,
        error_message_i18n: i18n_key:tool_googlebigquery_googlebigquery_get_error,
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
    resource_id: resource:googlebigquery_googlebigquery,
    is_active: true;

CREATE tool:googlebigquery_googlebigquery_getMany SET
    identity = {
        name: "getMany",
        slug: "googlebigquery_googlebigquery_getMany",
        display_name_i18n: i18n_key:tool_googlebigquery_googlebigquery_getMany_name,
        description_i18n: i18n_key:tool_googlebigquery_googlebigquery_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 717,
        tooltip_i18n: i18n_key:tool_googlebigquery_googlebigquery_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googlebigquery_googlebigquery_getMany_success,
        error_message_i18n: i18n_key:tool_googlebigquery_googlebigquery_getMany_error,
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
    resource_id: resource:googlebigquery_googlebigquery,
    is_active: true;

CREATE tool:googlebigqueryv1_record_get SET
    identity = {
        name: "get",
        slug: "googlebigqueryv1_record_get",
        display_name_i18n: i18n_key:tool_googlebigqueryv1_record_get_name,
        description_i18n: i18n_key:tool_googlebigqueryv1_record_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 718,
        tooltip_i18n: i18n_key:tool_googlebigqueryv1_record_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googlebigqueryv1_record_get_success,
        error_message_i18n: i18n_key:tool_googlebigqueryv1_record_get_error,
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
    resource_id: resource:googlebigqueryv1_record,
    is_active: true;

CREATE tool:googlebigqueryv1_record_getMany SET
    identity = {
        name: "getMany",
        slug: "googlebigqueryv1_record_getMany",
        display_name_i18n: i18n_key:tool_googlebigqueryv1_record_getMany_name,
        description_i18n: i18n_key:tool_googlebigqueryv1_record_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 719,
        tooltip_i18n: i18n_key:tool_googlebigqueryv1_record_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googlebigqueryv1_record_getMany_success,
        error_message_i18n: i18n_key:tool_googlebigqueryv1_record_getMany_error,
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
    resource_id: resource:googlebigqueryv1_record,
    is_active: true;

CREATE tool:googlebigqueryv2_googlebigqueryv2_get SET
    identity = {
        name: "get",
        slug: "googlebigqueryv2_googlebigqueryv2_get",
        display_name_i18n: i18n_key:tool_googlebigqueryv2_googlebigqueryv2_get_name,
        description_i18n: i18n_key:tool_googlebigqueryv2_googlebigqueryv2_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 720,
        tooltip_i18n: i18n_key:tool_googlebigqueryv2_googlebigqueryv2_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googlebigqueryv2_googlebigqueryv2_get_success,
        error_message_i18n: i18n_key:tool_googlebigqueryv2_googlebigqueryv2_get_error,
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
    resource_id: resource:googlebigqueryv2_googlebigqueryv2,
    is_active: true;

CREATE tool:googlebigqueryv2_googlebigqueryv2_getMany SET
    identity = {
        name: "getMany",
        slug: "googlebigqueryv2_googlebigqueryv2_getMany",
        display_name_i18n: i18n_key:tool_googlebigqueryv2_googlebigqueryv2_getMany_name,
        description_i18n: i18n_key:tool_googlebigqueryv2_googlebigqueryv2_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 721,
        tooltip_i18n: i18n_key:tool_googlebigqueryv2_googlebigqueryv2_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googlebigqueryv2_googlebigqueryv2_getMany_success,
        error_message_i18n: i18n_key:tool_googlebigqueryv2_googlebigqueryv2_getMany_error,
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
    resource_id: resource:googlebigqueryv2_googlebigqueryv2,
    is_active: true;

CREATE tool:googlebooks_bookshelf_get SET
    identity = {
        name: "get",
        slug: "googlebooks_bookshelf_get",
        display_name_i18n: i18n_key:tool_googlebooks_bookshelf_get_name,
        description_i18n: i18n_key:tool_googlebooks_bookshelf_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 722,
        tooltip_i18n: i18n_key:tool_googlebooks_bookshelf_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googlebooks_bookshelf_get_success,
        error_message_i18n: i18n_key:tool_googlebooks_bookshelf_get_error,
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
    resource_id: resource:googlebooks_bookshelf,
    is_active: true;

CREATE tool:googlebooks_bookshelf_getAll SET
    identity = {
        name: "getAll",
        slug: "googlebooks_bookshelf_getAll",
        display_name_i18n: i18n_key:tool_googlebooks_bookshelf_getAll_name,
        description_i18n: i18n_key:tool_googlebooks_bookshelf_getAll_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 723,
        tooltip_i18n: i18n_key:tool_googlebooks_bookshelf_getAll_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googlebooks_bookshelf_getAll_success,
        error_message_i18n: i18n_key:tool_googlebooks_bookshelf_getAll_error,
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
    resource_id: resource:googlebooks_bookshelf,
    is_active: true;

CREATE tool:googlebooks_bookshelfVolume_get SET
    identity = {
        name: "get",
        slug: "googlebooks_bookshelfVolume_get",
        display_name_i18n: i18n_key:tool_googlebooks_bookshelfVolume_get_name,
        description_i18n: i18n_key:tool_googlebooks_bookshelfVolume_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 724,
        tooltip_i18n: i18n_key:tool_googlebooks_bookshelfVolume_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googlebooks_bookshelfVolume_get_success,
        error_message_i18n: i18n_key:tool_googlebooks_bookshelfVolume_get_error,
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
    resource_id: resource:googlebooks_bookshelfVolume,
    is_active: true;

CREATE tool:googlebooks_bookshelfVolume_getAll SET
    identity = {
        name: "getAll",
        slug: "googlebooks_bookshelfVolume_getAll",
        display_name_i18n: i18n_key:tool_googlebooks_bookshelfVolume_getAll_name,
        description_i18n: i18n_key:tool_googlebooks_bookshelfVolume_getAll_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 725,
        tooltip_i18n: i18n_key:tool_googlebooks_bookshelfVolume_getAll_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googlebooks_bookshelfVolume_getAll_success,
        error_message_i18n: i18n_key:tool_googlebooks_bookshelfVolume_getAll_error,
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
    resource_id: resource:googlebooks_bookshelfVolume,
    is_active: true;

CREATE tool:googlebooks_volume_get SET
    identity = {
        name: "get",
        slug: "googlebooks_volume_get",
        display_name_i18n: i18n_key:tool_googlebooks_volume_get_name,
        description_i18n: i18n_key:tool_googlebooks_volume_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 726,
        tooltip_i18n: i18n_key:tool_googlebooks_volume_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googlebooks_volume_get_success,
        error_message_i18n: i18n_key:tool_googlebooks_volume_get_error,
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
    resource_id: resource:googlebooks_volume,
    is_active: true;

CREATE tool:googlebooks_volume_getAll SET
    identity = {
        name: "getAll",
        slug: "googlebooks_volume_getAll",
        display_name_i18n: i18n_key:tool_googlebooks_volume_getAll_name,
        description_i18n: i18n_key:tool_googlebooks_volume_getAll_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 727,
        tooltip_i18n: i18n_key:tool_googlebooks_volume_getAll_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googlebooks_volume_getAll_success,
        error_message_i18n: i18n_key:tool_googlebooks_volume_getAll_error,
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
    resource_id: resource:googlebooks_volume,
    is_active: true;

CREATE tool:googlebusinessprofile_post_get SET
    identity = {
        name: "get",
        slug: "googlebusinessprofile_post_get",
        display_name_i18n: i18n_key:tool_googlebusinessprofile_post_get_name,
        description_i18n: i18n_key:tool_googlebusinessprofile_post_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 728,
        tooltip_i18n: i18n_key:tool_googlebusinessprofile_post_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googlebusinessprofile_post_get_success,
        error_message_i18n: i18n_key:tool_googlebusinessprofile_post_get_error,
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
    resource_id: resource:googlebusinessprofile_post,
    is_active: true;

CREATE tool:googlebusinessprofile_post_getMany SET
    identity = {
        name: "getMany",
        slug: "googlebusinessprofile_post_getMany",
        display_name_i18n: i18n_key:tool_googlebusinessprofile_post_getMany_name,
        description_i18n: i18n_key:tool_googlebusinessprofile_post_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 729,
        tooltip_i18n: i18n_key:tool_googlebusinessprofile_post_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googlebusinessprofile_post_getMany_success,
        error_message_i18n: i18n_key:tool_googlebusinessprofile_post_getMany_error,
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
    resource_id: resource:googlebusinessprofile_post,
    is_active: true;

CREATE tool:googlebusinessprofile_review_get SET
    identity = {
        name: "get",
        slug: "googlebusinessprofile_review_get",
        display_name_i18n: i18n_key:tool_googlebusinessprofile_review_get_name,
        description_i18n: i18n_key:tool_googlebusinessprofile_review_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 730,
        tooltip_i18n: i18n_key:tool_googlebusinessprofile_review_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googlebusinessprofile_review_get_success,
        error_message_i18n: i18n_key:tool_googlebusinessprofile_review_get_error,
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
    resource_id: resource:googlebusinessprofile_review,
    is_active: true;

CREATE tool:googlebusinessprofile_review_getMany SET
    identity = {
        name: "getMany",
        slug: "googlebusinessprofile_review_getMany",
        display_name_i18n: i18n_key:tool_googlebusinessprofile_review_getMany_name,
        description_i18n: i18n_key:tool_googlebusinessprofile_review_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 731,
        tooltip_i18n: i18n_key:tool_googlebusinessprofile_review_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googlebusinessprofile_review_getMany_success,
        error_message_i18n: i18n_key:tool_googlebusinessprofile_review_getMany_error,
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
    resource_id: resource:googlebusinessprofile_review,
    is_active: true;

CREATE tool:googlecalendar_calendar_get SET
    identity = {
        name: "get",
        slug: "googlecalendar_calendar_get",
        display_name_i18n: i18n_key:tool_googlecalendar_calendar_get_name,
        description_i18n: i18n_key:tool_googlecalendar_calendar_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 732,
        tooltip_i18n: i18n_key:tool_googlecalendar_calendar_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googlecalendar_calendar_get_success,
        error_message_i18n: i18n_key:tool_googlecalendar_calendar_get_error,
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
    resource_id: resource:googlecalendar_calendar,
    is_active: true;

CREATE tool:googlecalendar_calendar_getMany SET
    identity = {
        name: "getMany",
        slug: "googlecalendar_calendar_getMany",
        display_name_i18n: i18n_key:tool_googlecalendar_calendar_getMany_name,
        description_i18n: i18n_key:tool_googlecalendar_calendar_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 733,
        tooltip_i18n: i18n_key:tool_googlecalendar_calendar_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googlecalendar_calendar_getMany_success,
        error_message_i18n: i18n_key:tool_googlecalendar_calendar_getMany_error,
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
    resource_id: resource:googlecalendar_calendar,
    is_active: true;

CREATE tool:googlecalendar_event_get SET
    identity = {
        name: "get",
        slug: "googlecalendar_event_get",
        display_name_i18n: i18n_key:tool_googlecalendar_event_get_name,
        description_i18n: i18n_key:tool_googlecalendar_event_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 734,
        tooltip_i18n: i18n_key:tool_googlecalendar_event_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googlecalendar_event_get_success,
        error_message_i18n: i18n_key:tool_googlecalendar_event_get_error,
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
    resource_id: resource:googlecalendar_event,
    is_active: true;

CREATE tool:googlecalendar_event_getMany SET
    identity = {
        name: "getMany",
        slug: "googlecalendar_event_getMany",
        display_name_i18n: i18n_key:tool_googlecalendar_event_getMany_name,
        description_i18n: i18n_key:tool_googlecalendar_event_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 735,
        tooltip_i18n: i18n_key:tool_googlecalendar_event_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googlecalendar_event_getMany_success,
        error_message_i18n: i18n_key:tool_googlecalendar_event_getMany_error,
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
    resource_id: resource:googlecalendar_event,
    is_active: true;

CREATE tool:googlechat_member_get SET
    identity = {
        name: "get",
        slug: "googlechat_member_get",
        display_name_i18n: i18n_key:tool_googlechat_member_get_name,
        description_i18n: i18n_key:tool_googlechat_member_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 736,
        tooltip_i18n: i18n_key:tool_googlechat_member_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googlechat_member_get_success,
        error_message_i18n: i18n_key:tool_googlechat_member_get_error,
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
    resource_id: resource:googlechat_member,
    is_active: true;

CREATE tool:googlechat_member_getMany SET
    identity = {
        name: "getMany",
        slug: "googlechat_member_getMany",
        display_name_i18n: i18n_key:tool_googlechat_member_getMany_name,
        description_i18n: i18n_key:tool_googlechat_member_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 737,
        tooltip_i18n: i18n_key:tool_googlechat_member_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googlechat_member_getMany_success,
        error_message_i18n: i18n_key:tool_googlechat_member_getMany_error,
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
    resource_id: resource:googlechat_member,
    is_active: true;

CREATE tool:googlechat_message_get SET
    identity = {
        name: "get",
        slug: "googlechat_message_get",
        display_name_i18n: i18n_key:tool_googlechat_message_get_name,
        description_i18n: i18n_key:tool_googlechat_message_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 738,
        tooltip_i18n: i18n_key:tool_googlechat_message_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googlechat_message_get_success,
        error_message_i18n: i18n_key:tool_googlechat_message_get_error,
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
    resource_id: resource:googlechat_message,
    is_active: true;

CREATE tool:googlechat_message_getMany SET
    identity = {
        name: "getMany",
        slug: "googlechat_message_getMany",
        display_name_i18n: i18n_key:tool_googlechat_message_getMany_name,
        description_i18n: i18n_key:tool_googlechat_message_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 739,
        tooltip_i18n: i18n_key:tool_googlechat_message_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googlechat_message_getMany_success,
        error_message_i18n: i18n_key:tool_googlechat_message_getMany_error,
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
    resource_id: resource:googlechat_message,
    is_active: true;

CREATE tool:googlechat_space_get SET
    identity = {
        name: "get",
        slug: "googlechat_space_get",
        display_name_i18n: i18n_key:tool_googlechat_space_get_name,
        description_i18n: i18n_key:tool_googlechat_space_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 740,
        tooltip_i18n: i18n_key:tool_googlechat_space_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googlechat_space_get_success,
        error_message_i18n: i18n_key:tool_googlechat_space_get_error,
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
    resource_id: resource:googlechat_space,
    is_active: true;

CREATE tool:googlechat_space_getMany SET
    identity = {
        name: "getMany",
        slug: "googlechat_space_getMany",
        display_name_i18n: i18n_key:tool_googlechat_space_getMany_name,
        description_i18n: i18n_key:tool_googlechat_space_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 741,
        tooltip_i18n: i18n_key:tool_googlechat_space_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googlechat_space_getMany_success,
        error_message_i18n: i18n_key:tool_googlechat_space_getMany_error,
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
    resource_id: resource:googlechat_space,
    is_active: true;

CREATE tool:googlecloudnaturallanguage_document_analyzeSentiment SET
    identity = {
        name: "analyzeSentiment",
        slug: "googlecloudnaturallanguage_document_analyzeSentiment",
        display_name_i18n: i18n_key:tool_googlecloudnaturallanguage_document_analyzeSentiment_name,
        description_i18n: i18n_key:tool_googlecloudnaturallanguage_document_analyzeSentiment_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 742,
        tooltip_i18n: i18n_key:tool_googlecloudnaturallanguage_document_analyzeSentiment_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googlecloudnaturallanguage_document_analyzeSentiment_success,
        error_message_i18n: i18n_key:tool_googlecloudnaturallanguage_document_analyzeSentiment_error,
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
    resource_id: resource:googlecloudnaturallanguage_document,
    is_active: true;

CREATE tool:googlecloudstorage_bucket_get SET
    identity = {
        name: "get",
        slug: "googlecloudstorage_bucket_get",
        display_name_i18n: i18n_key:tool_googlecloudstorage_bucket_get_name,
        description_i18n: i18n_key:tool_googlecloudstorage_bucket_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 743,
        tooltip_i18n: i18n_key:tool_googlecloudstorage_bucket_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googlecloudstorage_bucket_get_success,
        error_message_i18n: i18n_key:tool_googlecloudstorage_bucket_get_error,
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
    resource_id: resource:googlecloudstorage_bucket,
    is_active: true;

CREATE tool:googlecloudstorage_bucket_getMany SET
    identity = {
        name: "getMany",
        slug: "googlecloudstorage_bucket_getMany",
        display_name_i18n: i18n_key:tool_googlecloudstorage_bucket_getMany_name,
        description_i18n: i18n_key:tool_googlecloudstorage_bucket_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 744,
        tooltip_i18n: i18n_key:tool_googlecloudstorage_bucket_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googlecloudstorage_bucket_getMany_success,
        error_message_i18n: i18n_key:tool_googlecloudstorage_bucket_getMany_error,
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
    resource_id: resource:googlecloudstorage_bucket,
    is_active: true;

CREATE tool:googlecloudstorage_object_get SET
    identity = {
        name: "get",
        slug: "googlecloudstorage_object_get",
        display_name_i18n: i18n_key:tool_googlecloudstorage_object_get_name,
        description_i18n: i18n_key:tool_googlecloudstorage_object_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 745,
        tooltip_i18n: i18n_key:tool_googlecloudstorage_object_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googlecloudstorage_object_get_success,
        error_message_i18n: i18n_key:tool_googlecloudstorage_object_get_error,
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
    resource_id: resource:googlecloudstorage_object,
    is_active: true;

CREATE tool:googlecloudstorage_object_getMany SET
    identity = {
        name: "getMany",
        slug: "googlecloudstorage_object_getMany",
        display_name_i18n: i18n_key:tool_googlecloudstorage_object_getMany_name,
        description_i18n: i18n_key:tool_googlecloudstorage_object_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 746,
        tooltip_i18n: i18n_key:tool_googlecloudstorage_object_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googlecloudstorage_object_getMany_success,
        error_message_i18n: i18n_key:tool_googlecloudstorage_object_getMany_error,
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
    resource_id: resource:googlecloudstorage_object,
    is_active: true;

CREATE tool:googlecontacts_contact_get SET
    identity = {
        name: "get",
        slug: "googlecontacts_contact_get",
        display_name_i18n: i18n_key:tool_googlecontacts_contact_get_name,
        description_i18n: i18n_key:tool_googlecontacts_contact_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 747,
        tooltip_i18n: i18n_key:tool_googlecontacts_contact_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googlecontacts_contact_get_success,
        error_message_i18n: i18n_key:tool_googlecontacts_contact_get_error,
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
    resource_id: resource:googlecontacts_contact,
    is_active: true;

CREATE tool:googlecontacts_contact_getMany SET
    identity = {
        name: "getMany",
        slug: "googlecontacts_contact_getMany",
        display_name_i18n: i18n_key:tool_googlecontacts_contact_getMany_name,
        description_i18n: i18n_key:tool_googlecontacts_contact_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 748,
        tooltip_i18n: i18n_key:tool_googlecontacts_contact_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googlecontacts_contact_getMany_success,
        error_message_i18n: i18n_key:tool_googlecontacts_contact_getMany_error,
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
    resource_id: resource:googlecontacts_contact,
    is_active: true;

CREATE tool:googledocs_document_get SET
    identity = {
        name: "get",
        slug: "googledocs_document_get",
        display_name_i18n: i18n_key:tool_googledocs_document_get_name,
        description_i18n: i18n_key:tool_googledocs_document_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 749,
        tooltip_i18n: i18n_key:tool_googledocs_document_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googledocs_document_get_success,
        error_message_i18n: i18n_key:tool_googledocs_document_get_error,
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
    resource_id: resource:googledocs_document,
    is_active: true;

CREATE tool:googledocs_document_getMany SET
    identity = {
        name: "getMany",
        slug: "googledocs_document_getMany",
        display_name_i18n: i18n_key:tool_googledocs_document_getMany_name,
        description_i18n: i18n_key:tool_googledocs_document_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 750,
        tooltip_i18n: i18n_key:tool_googledocs_document_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googledocs_document_getMany_success,
        error_message_i18n: i18n_key:tool_googledocs_document_getMany_error,
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
    resource_id: resource:googledocs_document,
    is_active: true;

CREATE tool:googledrive_googledrive_get SET
    identity = {
        name: "get",
        slug: "googledrive_googledrive_get",
        display_name_i18n: i18n_key:tool_googledrive_googledrive_get_name,
        description_i18n: i18n_key:tool_googledrive_googledrive_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 751,
        tooltip_i18n: i18n_key:tool_googledrive_googledrive_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googledrive_googledrive_get_success,
        error_message_i18n: i18n_key:tool_googledrive_googledrive_get_error,
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
    resource_id: resource:googledrive_googledrive,
    is_active: true;

CREATE tool:googledrive_googledrive_getMany SET
    identity = {
        name: "getMany",
        slug: "googledrive_googledrive_getMany",
        display_name_i18n: i18n_key:tool_googledrive_googledrive_getMany_name,
        description_i18n: i18n_key:tool_googledrive_googledrive_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 752,
        tooltip_i18n: i18n_key:tool_googledrive_googledrive_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googledrive_googledrive_getMany_success,
        error_message_i18n: i18n_key:tool_googledrive_googledrive_getMany_error,
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
    resource_id: resource:googledrive_googledrive,
    is_active: true;

CREATE tool:googledrivev1_drive_copy SET
    identity = {
        name: "copy",
        slug: "googledrivev1_drive_copy",
        display_name_i18n: i18n_key:tool_googledrivev1_drive_copy_name,
        description_i18n: i18n_key:tool_googledrivev1_drive_copy_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 753,
        tooltip_i18n: i18n_key:tool_googledrivev1_drive_copy_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googledrivev1_drive_copy_success,
        error_message_i18n: i18n_key:tool_googledrivev1_drive_copy_error,
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
    resource_id: resource:googledrivev1_drive,
    is_active: true;

CREATE tool:googledrivev1_drive_delete SET
    identity = {
        name: "delete",
        slug: "googledrivev1_drive_delete",
        display_name_i18n: i18n_key:tool_googledrivev1_drive_delete_name,
        description_i18n: i18n_key:tool_googledrivev1_drive_delete_desc,
        operation_type: "delete",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#F44336",
        display_order: 754,
        tooltip_i18n: i18n_key:tool_googledrivev1_drive_delete_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googledrivev1_drive_delete_success,
        error_message_i18n: i18n_key:tool_googledrivev1_drive_delete_error,
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
    resource_id: resource:googledrivev1_drive,
    is_active: true;

CREATE tool:googledrivev1_drive_download SET
    identity = {
        name: "download",
        slug: "googledrivev1_drive_download",
        display_name_i18n: i18n_key:tool_googledrivev1_drive_download_name,
        description_i18n: i18n_key:tool_googledrivev1_drive_download_desc,
        operation_type: "download",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#03A9F4",
        display_order: 755,
        tooltip_i18n: i18n_key:tool_googledrivev1_drive_download_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googledrivev1_drive_download_success,
        error_message_i18n: i18n_key:tool_googledrivev1_drive_download_error,
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
    resource_id: resource:googledrivev1_drive,
    is_active: true;

CREATE tool:googledrivev1_drive_list SET
    identity = {
        name: "list",
        slug: "googledrivev1_drive_list",
        display_name_i18n: i18n_key:tool_googledrivev1_drive_list_name,
        description_i18n: i18n_key:tool_googledrivev1_drive_list_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 756,
        tooltip_i18n: i18n_key:tool_googledrivev1_drive_list_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googledrivev1_drive_list_success,
        error_message_i18n: i18n_key:tool_googledrivev1_drive_list_error,
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
    resource_id: resource:googledrivev1_drive,
    is_active: true;

CREATE tool:googledrivev1_drive_share SET
    identity = {
        name: "share",
        slug: "googledrivev1_drive_share",
        display_name_i18n: i18n_key:tool_googledrivev1_drive_share_name,
        description_i18n: i18n_key:tool_googledrivev1_drive_share_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 757,
        tooltip_i18n: i18n_key:tool_googledrivev1_drive_share_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googledrivev1_drive_share_success,
        error_message_i18n: i18n_key:tool_googledrivev1_drive_share_error,
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
    resource_id: resource:googledrivev1_drive,
    is_active: true;

CREATE tool:googledrivev1_drive_update SET
    identity = {
        name: "update",
        slug: "googledrivev1_drive_update",
        display_name_i18n: i18n_key:tool_googledrivev1_drive_update_name,
        description_i18n: i18n_key:tool_googledrivev1_drive_update_desc,
        operation_type: "update",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#FF9800",
        display_order: 758,
        tooltip_i18n: i18n_key:tool_googledrivev1_drive_update_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googledrivev1_drive_update_success,
        error_message_i18n: i18n_key:tool_googledrivev1_drive_update_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "PUT",
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
    resource_id: resource:googledrivev1_drive,
    is_active: true;

CREATE tool:googledrivev1_drive_upload SET
    identity = {
        name: "upload",
        slug: "googledrivev1_drive_upload",
        display_name_i18n: i18n_key:tool_googledrivev1_drive_upload_name,
        description_i18n: i18n_key:tool_googledrivev1_drive_upload_desc,
        operation_type: "upload",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#8BC34A",
        display_order: 759,
        tooltip_i18n: i18n_key:tool_googledrivev1_drive_upload_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googledrivev1_drive_upload_success,
        error_message_i18n: i18n_key:tool_googledrivev1_drive_upload_error,
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
    resource_id: resource:googledrivev1_drive,
    is_active: true;

CREATE tool:googledrivev1_file_copy SET
    identity = {
        name: "copy",
        slug: "googledrivev1_file_copy",
        display_name_i18n: i18n_key:tool_googledrivev1_file_copy_name,
        description_i18n: i18n_key:tool_googledrivev1_file_copy_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 760,
        tooltip_i18n: i18n_key:tool_googledrivev1_file_copy_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googledrivev1_file_copy_success,
        error_message_i18n: i18n_key:tool_googledrivev1_file_copy_error,
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
    resource_id: resource:googledrivev1_file,
    is_active: true;

CREATE tool:googledrivev1_file_delete SET
    identity = {
        name: "delete",
        slug: "googledrivev1_file_delete",
        display_name_i18n: i18n_key:tool_googledrivev1_file_delete_name,
        description_i18n: i18n_key:tool_googledrivev1_file_delete_desc,
        operation_type: "delete",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#F44336",
        display_order: 761,
        tooltip_i18n: i18n_key:tool_googledrivev1_file_delete_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googledrivev1_file_delete_success,
        error_message_i18n: i18n_key:tool_googledrivev1_file_delete_error,
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
    resource_id: resource:googledrivev1_file,
    is_active: true;

CREATE tool:googledrivev1_file_download SET
    identity = {
        name: "download",
        slug: "googledrivev1_file_download",
        display_name_i18n: i18n_key:tool_googledrivev1_file_download_name,
        description_i18n: i18n_key:tool_googledrivev1_file_download_desc,
        operation_type: "download",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#03A9F4",
        display_order: 762,
        tooltip_i18n: i18n_key:tool_googledrivev1_file_download_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googledrivev1_file_download_success,
        error_message_i18n: i18n_key:tool_googledrivev1_file_download_error,
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
    resource_id: resource:googledrivev1_file,
    is_active: true;

CREATE tool:googledrivev1_file_list SET
    identity = {
        name: "list",
        slug: "googledrivev1_file_list",
        display_name_i18n: i18n_key:tool_googledrivev1_file_list_name,
        description_i18n: i18n_key:tool_googledrivev1_file_list_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 763,
        tooltip_i18n: i18n_key:tool_googledrivev1_file_list_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googledrivev1_file_list_success,
        error_message_i18n: i18n_key:tool_googledrivev1_file_list_error,
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
    resource_id: resource:googledrivev1_file,
    is_active: true;

CREATE tool:googledrivev1_file_share SET
    identity = {
        name: "share",
        slug: "googledrivev1_file_share",
        display_name_i18n: i18n_key:tool_googledrivev1_file_share_name,
        description_i18n: i18n_key:tool_googledrivev1_file_share_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 764,
        tooltip_i18n: i18n_key:tool_googledrivev1_file_share_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googledrivev1_file_share_success,
        error_message_i18n: i18n_key:tool_googledrivev1_file_share_error,
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
    resource_id: resource:googledrivev1_file,
    is_active: true;

CREATE tool:googledrivev1_file_update SET
    identity = {
        name: "update",
        slug: "googledrivev1_file_update",
        display_name_i18n: i18n_key:tool_googledrivev1_file_update_name,
        description_i18n: i18n_key:tool_googledrivev1_file_update_desc,
        operation_type: "update",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#FF9800",
        display_order: 765,
        tooltip_i18n: i18n_key:tool_googledrivev1_file_update_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googledrivev1_file_update_success,
        error_message_i18n: i18n_key:tool_googledrivev1_file_update_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "PUT",
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
    resource_id: resource:googledrivev1_file,
    is_active: true;

CREATE tool:googledrivev1_file_upload SET
    identity = {
        name: "upload",
        slug: "googledrivev1_file_upload",
        display_name_i18n: i18n_key:tool_googledrivev1_file_upload_name,
        description_i18n: i18n_key:tool_googledrivev1_file_upload_desc,
        operation_type: "upload",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#8BC34A",
        display_order: 766,
        tooltip_i18n: i18n_key:tool_googledrivev1_file_upload_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googledrivev1_file_upload_success,
        error_message_i18n: i18n_key:tool_googledrivev1_file_upload_error,
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
    resource_id: resource:googledrivev1_file,
    is_active: true;

CREATE tool:googledrivev1_folder_copy SET
    identity = {
        name: "copy",
        slug: "googledrivev1_folder_copy",
        display_name_i18n: i18n_key:tool_googledrivev1_folder_copy_name,
        description_i18n: i18n_key:tool_googledrivev1_folder_copy_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 767,
        tooltip_i18n: i18n_key:tool_googledrivev1_folder_copy_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googledrivev1_folder_copy_success,
        error_message_i18n: i18n_key:tool_googledrivev1_folder_copy_error,
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
    resource_id: resource:googledrivev1_folder,
    is_active: true;

CREATE tool:googledrivev1_folder_delete SET
    identity = {
        name: "delete",
        slug: "googledrivev1_folder_delete",
        display_name_i18n: i18n_key:tool_googledrivev1_folder_delete_name,
        description_i18n: i18n_key:tool_googledrivev1_folder_delete_desc,
        operation_type: "delete",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#F44336",
        display_order: 768,
        tooltip_i18n: i18n_key:tool_googledrivev1_folder_delete_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googledrivev1_folder_delete_success,
        error_message_i18n: i18n_key:tool_googledrivev1_folder_delete_error,
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
    resource_id: resource:googledrivev1_folder,
    is_active: true;

CREATE tool:googledrivev1_folder_download SET
    identity = {
        name: "download",
        slug: "googledrivev1_folder_download",
        display_name_i18n: i18n_key:tool_googledrivev1_folder_download_name,
        description_i18n: i18n_key:tool_googledrivev1_folder_download_desc,
        operation_type: "download",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#03A9F4",
        display_order: 769,
        tooltip_i18n: i18n_key:tool_googledrivev1_folder_download_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googledrivev1_folder_download_success,
        error_message_i18n: i18n_key:tool_googledrivev1_folder_download_error,
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
    resource_id: resource:googledrivev1_folder,
    is_active: true;

CREATE tool:googledrivev1_folder_list SET
    identity = {
        name: "list",
        slug: "googledrivev1_folder_list",
        display_name_i18n: i18n_key:tool_googledrivev1_folder_list_name,
        description_i18n: i18n_key:tool_googledrivev1_folder_list_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 770,
        tooltip_i18n: i18n_key:tool_googledrivev1_folder_list_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googledrivev1_folder_list_success,
        error_message_i18n: i18n_key:tool_googledrivev1_folder_list_error,
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
    resource_id: resource:googledrivev1_folder,
    is_active: true;

CREATE tool:googledrivev1_folder_share SET
    identity = {
        name: "share",
        slug: "googledrivev1_folder_share",
        display_name_i18n: i18n_key:tool_googledrivev1_folder_share_name,
        description_i18n: i18n_key:tool_googledrivev1_folder_share_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 771,
        tooltip_i18n: i18n_key:tool_googledrivev1_folder_share_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googledrivev1_folder_share_success,
        error_message_i18n: i18n_key:tool_googledrivev1_folder_share_error,
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
    resource_id: resource:googledrivev1_folder,
    is_active: true;

CREATE tool:googledrivev1_folder_update SET
    identity = {
        name: "update",
        slug: "googledrivev1_folder_update",
        display_name_i18n: i18n_key:tool_googledrivev1_folder_update_name,
        description_i18n: i18n_key:tool_googledrivev1_folder_update_desc,
        operation_type: "update",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#FF9800",
        display_order: 772,
        tooltip_i18n: i18n_key:tool_googledrivev1_folder_update_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googledrivev1_folder_update_success,
        error_message_i18n: i18n_key:tool_googledrivev1_folder_update_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "PUT",
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
    resource_id: resource:googledrivev1_folder,
    is_active: true;

CREATE tool:googledrivev1_folder_upload SET
    identity = {
        name: "upload",
        slug: "googledrivev1_folder_upload",
        display_name_i18n: i18n_key:tool_googledrivev1_folder_upload_name,
        description_i18n: i18n_key:tool_googledrivev1_folder_upload_desc,
        operation_type: "upload",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#8BC34A",
        display_order: 773,
        tooltip_i18n: i18n_key:tool_googledrivev1_folder_upload_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googledrivev1_folder_upload_success,
        error_message_i18n: i18n_key:tool_googledrivev1_folder_upload_error,
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
    resource_id: resource:googledrivev1_folder,
    is_active: true;

CREATE tool:googledrivev2_googledrivev2_get SET
    identity = {
        name: "get",
        slug: "googledrivev2_googledrivev2_get",
        display_name_i18n: i18n_key:tool_googledrivev2_googledrivev2_get_name,
        description_i18n: i18n_key:tool_googledrivev2_googledrivev2_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 774,
        tooltip_i18n: i18n_key:tool_googledrivev2_googledrivev2_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googledrivev2_googledrivev2_get_success,
        error_message_i18n: i18n_key:tool_googledrivev2_googledrivev2_get_error,
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
    resource_id: resource:googledrivev2_googledrivev2,
    is_active: true;

CREATE tool:googledrivev2_googledrivev2_getMany SET
    identity = {
        name: "getMany",
        slug: "googledrivev2_googledrivev2_getMany",
        display_name_i18n: i18n_key:tool_googledrivev2_googledrivev2_getMany_name,
        description_i18n: i18n_key:tool_googledrivev2_googledrivev2_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 775,
        tooltip_i18n: i18n_key:tool_googledrivev2_googledrivev2_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googledrivev2_googledrivev2_getMany_success,
        error_message_i18n: i18n_key:tool_googledrivev2_googledrivev2_getMany_error,
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
    resource_id: resource:googledrivev2_googledrivev2,
    is_active: true;

CREATE tool:googlefirebasecloudfirestore_document_get SET
    identity = {
        name: "get",
        slug: "googlefirebasecloudfirestore_document_get",
        display_name_i18n: i18n_key:tool_googlefirebasecloudfirestore_document_get_name,
        description_i18n: i18n_key:tool_googlefirebasecloudfirestore_document_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 776,
        tooltip_i18n: i18n_key:tool_googlefirebasecloudfirestore_document_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googlefirebasecloudfirestore_document_get_success,
        error_message_i18n: i18n_key:tool_googlefirebasecloudfirestore_document_get_error,
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
    resource_id: resource:googlefirebasecloudfirestore_document,
    is_active: true;

CREATE tool:googlefirebasecloudfirestore_document_getMany SET
    identity = {
        name: "getMany",
        slug: "googlefirebasecloudfirestore_document_getMany",
        display_name_i18n: i18n_key:tool_googlefirebasecloudfirestore_document_getMany_name,
        description_i18n: i18n_key:tool_googlefirebasecloudfirestore_document_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 777,
        tooltip_i18n: i18n_key:tool_googlefirebasecloudfirestore_document_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googlefirebasecloudfirestore_document_getMany_success,
        error_message_i18n: i18n_key:tool_googlefirebasecloudfirestore_document_getMany_error,
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
    resource_id: resource:googlefirebasecloudfirestore_document,
    is_active: true;

CREATE tool:googlefirebasecloudfirestore_collection_get SET
    identity = {
        name: "get",
        slug: "googlefirebasecloudfirestore_collection_get",
        display_name_i18n: i18n_key:tool_googlefirebasecloudfirestore_collection_get_name,
        description_i18n: i18n_key:tool_googlefirebasecloudfirestore_collection_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 778,
        tooltip_i18n: i18n_key:tool_googlefirebasecloudfirestore_collection_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googlefirebasecloudfirestore_collection_get_success,
        error_message_i18n: i18n_key:tool_googlefirebasecloudfirestore_collection_get_error,
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
    resource_id: resource:googlefirebasecloudfirestore_collection,
    is_active: true;

CREATE tool:googlefirebasecloudfirestore_collection_getMany SET
    identity = {
        name: "getMany",
        slug: "googlefirebasecloudfirestore_collection_getMany",
        display_name_i18n: i18n_key:tool_googlefirebasecloudfirestore_collection_getMany_name,
        description_i18n: i18n_key:tool_googlefirebasecloudfirestore_collection_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 779,
        tooltip_i18n: i18n_key:tool_googlefirebasecloudfirestore_collection_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googlefirebasecloudfirestore_collection_getMany_success,
        error_message_i18n: i18n_key:tool_googlefirebasecloudfirestore_collection_getMany_error,
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
    resource_id: resource:googlefirebasecloudfirestore_collection,
    is_active: true;

CREATE tool:googlefirebaserealtimedatabase_googlefirebaserealtimedatabase_create SET
    identity = {
        name: "create",
        slug: "googlefirebaserealtimedatabase_googlefirebaserealtimedatabase_create",
        display_name_i18n: i18n_key:tool_googlefirebaserealtimedatabase_googlefirebaserealtimedatabase_create_name,
        description_i18n: i18n_key:tool_googlefirebaserealtimedatabase_googlefirebaserealtimedatabase_create_desc,
        operation_type: "create",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#4CAF50",
        display_order: 780,
        tooltip_i18n: i18n_key:tool_googlefirebaserealtimedatabase_googlefirebaserealtimedatabase_create_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googlefirebaserealtimedatabase_googlefirebaserealtimedatabase_create_success,
        error_message_i18n: i18n_key:tool_googlefirebaserealtimedatabase_googlefirebaserealtimedatabase_create_error,
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
    resource_id: resource:googlefirebaserealtimedatabase_googlefirebaserealtimedatabase,
    is_active: true;

CREATE tool:googlefirebaserealtimedatabase_googlefirebaserealtimedatabase_delete SET
    identity = {
        name: "delete",
        slug: "googlefirebaserealtimedatabase_googlefirebaserealtimedatabase_delete",
        display_name_i18n: i18n_key:tool_googlefirebaserealtimedatabase_googlefirebaserealtimedatabase_delete_name,
        description_i18n: i18n_key:tool_googlefirebaserealtimedatabase_googlefirebaserealtimedatabase_delete_desc,
        operation_type: "delete",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#F44336",
        display_order: 781,
        tooltip_i18n: i18n_key:tool_googlefirebaserealtimedatabase_googlefirebaserealtimedatabase_delete_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googlefirebaserealtimedatabase_googlefirebaserealtimedatabase_delete_success,
        error_message_i18n: i18n_key:tool_googlefirebaserealtimedatabase_googlefirebaserealtimedatabase_delete_error,
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
    resource_id: resource:googlefirebaserealtimedatabase_googlefirebaserealtimedatabase,
    is_active: true;

CREATE tool:googlefirebaserealtimedatabase_googlefirebaserealtimedatabase_get SET
    identity = {
        name: "get",
        slug: "googlefirebaserealtimedatabase_googlefirebaserealtimedatabase_get",
        display_name_i18n: i18n_key:tool_googlefirebaserealtimedatabase_googlefirebaserealtimedatabase_get_name,
        description_i18n: i18n_key:tool_googlefirebaserealtimedatabase_googlefirebaserealtimedatabase_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 782,
        tooltip_i18n: i18n_key:tool_googlefirebaserealtimedatabase_googlefirebaserealtimedatabase_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googlefirebaserealtimedatabase_googlefirebaserealtimedatabase_get_success,
        error_message_i18n: i18n_key:tool_googlefirebaserealtimedatabase_googlefirebaserealtimedatabase_get_error,
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
    resource_id: resource:googlefirebaserealtimedatabase_googlefirebaserealtimedatabase,
    is_active: true;

CREATE tool:googlefirebaserealtimedatabase_googlefirebaserealtimedatabase_push SET
    identity = {
        name: "push",
        slug: "googlefirebaserealtimedatabase_googlefirebaserealtimedatabase_push",
        display_name_i18n: i18n_key:tool_googlefirebaserealtimedatabase_googlefirebaserealtimedatabase_push_name,
        description_i18n: i18n_key:tool_googlefirebaserealtimedatabase_googlefirebaserealtimedatabase_push_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 783,
        tooltip_i18n: i18n_key:tool_googlefirebaserealtimedatabase_googlefirebaserealtimedatabase_push_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googlefirebaserealtimedatabase_googlefirebaserealtimedatabase_push_success,
        error_message_i18n: i18n_key:tool_googlefirebaserealtimedatabase_googlefirebaserealtimedatabase_push_error,
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
    resource_id: resource:googlefirebaserealtimedatabase_googlefirebaserealtimedatabase,
    is_active: true;

CREATE tool:googlefirebaserealtimedatabase_googlefirebaserealtimedatabase_update SET
    identity = {
        name: "update",
        slug: "googlefirebaserealtimedatabase_googlefirebaserealtimedatabase_update",
        display_name_i18n: i18n_key:tool_googlefirebaserealtimedatabase_googlefirebaserealtimedatabase_update_name,
        description_i18n: i18n_key:tool_googlefirebaserealtimedatabase_googlefirebaserealtimedatabase_update_desc,
        operation_type: "update",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#FF9800",
        display_order: 784,
        tooltip_i18n: i18n_key:tool_googlefirebaserealtimedatabase_googlefirebaserealtimedatabase_update_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_googlefirebaserealtimedatabase_googlefirebaserealtimedatabase_update_success,
        error_message_i18n: i18n_key:tool_googlefirebaserealtimedatabase_googlefirebaserealtimedatabase_update_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "PUT",
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
    resource_id: resource:googlefirebaserealtimedatabase_googlefirebaserealtimedatabase,
    is_active: true;

CREATE tool:gmail_gmail_get SET
    identity = {
        name: "get",
        slug: "gmail_gmail_get",
        display_name_i18n: i18n_key:tool_gmail_gmail_get_name,
        description_i18n: i18n_key:tool_gmail_gmail_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 785,
        tooltip_i18n: i18n_key:tool_gmail_gmail_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_gmail_gmail_get_success,
        error_message_i18n: i18n_key:tool_gmail_gmail_get_error,
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
    resource_id: resource:gmail_gmail,
    is_active: true;

CREATE tool:gmail_gmail_getMany SET
    identity = {
        name: "getMany",
        slug: "gmail_gmail_getMany",
        display_name_i18n: i18n_key:tool_gmail_gmail_getMany_name,
        description_i18n: i18n_key:tool_gmail_gmail_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 786,
        tooltip_i18n: i18n_key:tool_gmail_gmail_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_gmail_gmail_getMany_success,
        error_message_i18n: i18n_key:tool_gmail_gmail_getMany_error,
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
    resource_id: resource:gmail_gmail,
    is_active: true;

CREATE tool:gmailv1_draft_get SET
    identity = {
        name: "get",
        slug: "gmailv1_draft_get",
        display_name_i18n: i18n_key:tool_gmailv1_draft_get_name,
        description_i18n: i18n_key:tool_gmailv1_draft_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 787,
        tooltip_i18n: i18n_key:tool_gmailv1_draft_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_gmailv1_draft_get_success,
        error_message_i18n: i18n_key:tool_gmailv1_draft_get_error,
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
    resource_id: resource:gmailv1_draft,
    is_active: true;

CREATE tool:gmailv1_draft_getMany SET
    identity = {
        name: "getMany",
        slug: "gmailv1_draft_getMany",
        display_name_i18n: i18n_key:tool_gmailv1_draft_getMany_name,
        description_i18n: i18n_key:tool_gmailv1_draft_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 788,
        tooltip_i18n: i18n_key:tool_gmailv1_draft_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_gmailv1_draft_getMany_success,
        error_message_i18n: i18n_key:tool_gmailv1_draft_getMany_error,
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
    resource_id: resource:gmailv1_draft,
    is_active: true;

CREATE tool:gmailv1_label_get SET
    identity = {
        name: "get",
        slug: "gmailv1_label_get",
        display_name_i18n: i18n_key:tool_gmailv1_label_get_name,
        description_i18n: i18n_key:tool_gmailv1_label_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 789,
        tooltip_i18n: i18n_key:tool_gmailv1_label_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_gmailv1_label_get_success,
        error_message_i18n: i18n_key:tool_gmailv1_label_get_error,
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
    resource_id: resource:gmailv1_label,
    is_active: true;

CREATE tool:gmailv1_label_getMany SET
    identity = {
        name: "getMany",
        slug: "gmailv1_label_getMany",
        display_name_i18n: i18n_key:tool_gmailv1_label_getMany_name,
        description_i18n: i18n_key:tool_gmailv1_label_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 790,
        tooltip_i18n: i18n_key:tool_gmailv1_label_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_gmailv1_label_getMany_success,
        error_message_i18n: i18n_key:tool_gmailv1_label_getMany_error,
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
    resource_id: resource:gmailv1_label,
    is_active: true;

CREATE tool:gmailv1_message_get SET
    identity = {
        name: "get",
        slug: "gmailv1_message_get",
        display_name_i18n: i18n_key:tool_gmailv1_message_get_name,
        description_i18n: i18n_key:tool_gmailv1_message_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 791,
        tooltip_i18n: i18n_key:tool_gmailv1_message_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_gmailv1_message_get_success,
        error_message_i18n: i18n_key:tool_gmailv1_message_get_error,
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
    resource_id: resource:gmailv1_message,
    is_active: true;

CREATE tool:gmailv1_message_getMany SET
    identity = {
        name: "getMany",
        slug: "gmailv1_message_getMany",
        display_name_i18n: i18n_key:tool_gmailv1_message_getMany_name,
        description_i18n: i18n_key:tool_gmailv1_message_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 792,
        tooltip_i18n: i18n_key:tool_gmailv1_message_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_gmailv1_message_getMany_success,
        error_message_i18n: i18n_key:tool_gmailv1_message_getMany_error,
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
    resource_id: resource:gmailv1_message,
    is_active: true;

CREATE tool:gmailv1_messageLabel_get SET
    identity = {
        name: "get",
        slug: "gmailv1_messageLabel_get",
        display_name_i18n: i18n_key:tool_gmailv1_messageLabel_get_name,
        description_i18n: i18n_key:tool_gmailv1_messageLabel_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 793,
        tooltip_i18n: i18n_key:tool_gmailv1_messageLabel_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_gmailv1_messageLabel_get_success,
        error_message_i18n: i18n_key:tool_gmailv1_messageLabel_get_error,
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
    resource_id: resource:gmailv1_messageLabel,
    is_active: true;

CREATE tool:gmailv1_messageLabel_getMany SET
    identity = {
        name: "getMany",
        slug: "gmailv1_messageLabel_getMany",
        display_name_i18n: i18n_key:tool_gmailv1_messageLabel_getMany_name,
        description_i18n: i18n_key:tool_gmailv1_messageLabel_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 794,
        tooltip_i18n: i18n_key:tool_gmailv1_messageLabel_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_gmailv1_messageLabel_getMany_success,
        error_message_i18n: i18n_key:tool_gmailv1_messageLabel_getMany_error,
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
    resource_id: resource:gmailv1_messageLabel,
    is_active: true;

CREATE tool:gmailv1_messagelabel_get SET
    identity = {
        name: "get",
        slug: "gmailv1_messagelabel_get",
        display_name_i18n: i18n_key:tool_gmailv1_messagelabel_get_name,
        description_i18n: i18n_key:tool_gmailv1_messagelabel_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 795,
        tooltip_i18n: i18n_key:tool_gmailv1_messagelabel_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_gmailv1_messagelabel_get_success,
        error_message_i18n: i18n_key:tool_gmailv1_messagelabel_get_error,
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
    resource_id: resource:gmailv1_messagelabel,
    is_active: true;

CREATE tool:gmailv1_messagelabel_getMany SET
    identity = {
        name: "getMany",
        slug: "gmailv1_messagelabel_getMany",
        display_name_i18n: i18n_key:tool_gmailv1_messagelabel_getMany_name,
        description_i18n: i18n_key:tool_gmailv1_messagelabel_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 796,
        tooltip_i18n: i18n_key:tool_gmailv1_messagelabel_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_gmailv1_messagelabel_getMany_success,
        error_message_i18n: i18n_key:tool_gmailv1_messagelabel_getMany_error,
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
    resource_id: resource:gmailv1_messagelabel,
    is_active: true;

CREATE tool:gmailv2_message_get SET
    identity = {
        name: "get",
        slug: "gmailv2_message_get",
        display_name_i18n: i18n_key:tool_gmailv2_message_get_name,
        description_i18n: i18n_key:tool_gmailv2_message_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 797,
        tooltip_i18n: i18n_key:tool_gmailv2_message_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_gmailv2_message_get_success,
        error_message_i18n: i18n_key:tool_gmailv2_message_get_error,
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
    resource_id: resource:gmailv2_message,
    is_active: true;

CREATE tool:gmailv2_message_getMany SET
    identity = {
        name: "getMany",
        slug: "gmailv2_message_getMany",
        display_name_i18n: i18n_key:tool_gmailv2_message_getMany_name,
        description_i18n: i18n_key:tool_gmailv2_message_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 798,
        tooltip_i18n: i18n_key:tool_gmailv2_message_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_gmailv2_message_getMany_success,
        error_message_i18n: i18n_key:tool_gmailv2_message_getMany_error,
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
    resource_id: resource:gmailv2_message,
    is_active: true;

CREATE tool:gmailv2_label_get SET
    identity = {
        name: "get",
        slug: "gmailv2_label_get",
        display_name_i18n: i18n_key:tool_gmailv2_label_get_name,
        description_i18n: i18n_key:tool_gmailv2_label_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 799,
        tooltip_i18n: i18n_key:tool_gmailv2_label_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_gmailv2_label_get_success,
        error_message_i18n: i18n_key:tool_gmailv2_label_get_error,
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
    resource_id: resource:gmailv2_label,
    is_active: true;

CREATE tool:gmailv2_label_getMany SET
    identity = {
        name: "getMany",
        slug: "gmailv2_label_getMany",
        display_name_i18n: i18n_key:tool_gmailv2_label_getMany_name,
        description_i18n: i18n_key:tool_gmailv2_label_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 800,
        tooltip_i18n: i18n_key:tool_gmailv2_label_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_gmailv2_label_getMany_success,
        error_message_i18n: i18n_key:tool_gmailv2_label_getMany_error,
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
    resource_id: resource:gmailv2_label,
    is_active: true;

