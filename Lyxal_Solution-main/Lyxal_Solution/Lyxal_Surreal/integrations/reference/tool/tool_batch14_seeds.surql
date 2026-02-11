-- Batch 14: 100 tools Lyxal

CREATE tool:microsoftoutlookv1_folder_get SET
    identity = {
        name: "get",
        slug: "microsoftoutlookv1_folder_get",
        display_name_i18n: i18n_key:tool_microsoftoutlookv1_folder_get_name,
        description_i18n: i18n_key:tool_microsoftoutlookv1_folder_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1301,
        tooltip_i18n: i18n_key:tool_microsoftoutlookv1_folder_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_microsoftoutlookv1_folder_get_success,
        error_message_i18n: i18n_key:tool_microsoftoutlookv1_folder_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:microsoftoutlookv1_folder,
    is_active: true;

CREATE tool:microsoftoutlookv1_folder_getMany SET
    identity = {
        name: "getMany",
        slug: "microsoftoutlookv1_folder_getMany",
        display_name_i18n: i18n_key:tool_microsoftoutlookv1_folder_getMany_name,
        description_i18n: i18n_key:tool_microsoftoutlookv1_folder_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 1302,
        tooltip_i18n: i18n_key:tool_microsoftoutlookv1_folder_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_microsoftoutlookv1_folder_getMany_success,
        error_message_i18n: i18n_key:tool_microsoftoutlookv1_folder_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:microsoftoutlookv1_folder,
    is_active: true;

CREATE tool:microsoftoutlookv1_folderMessage_get SET
    identity = {
        name: "get",
        slug: "microsoftoutlookv1_folderMessage_get",
        display_name_i18n: i18n_key:tool_microsoftoutlookv1_folderMessage_get_name,
        description_i18n: i18n_key:tool_microsoftoutlookv1_folderMessage_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1303,
        tooltip_i18n: i18n_key:tool_microsoftoutlookv1_folderMessage_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_microsoftoutlookv1_folderMessage_get_success,
        error_message_i18n: i18n_key:tool_microsoftoutlookv1_folderMessage_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:microsoftoutlookv1_folderMessage,
    is_active: true;

CREATE tool:microsoftoutlookv1_folderMessage_getMany SET
    identity = {
        name: "getMany",
        slug: "microsoftoutlookv1_folderMessage_getMany",
        display_name_i18n: i18n_key:tool_microsoftoutlookv1_folderMessage_getMany_name,
        description_i18n: i18n_key:tool_microsoftoutlookv1_folderMessage_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 1304,
        tooltip_i18n: i18n_key:tool_microsoftoutlookv1_folderMessage_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_microsoftoutlookv1_folderMessage_getMany_success,
        error_message_i18n: i18n_key:tool_microsoftoutlookv1_folderMessage_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:microsoftoutlookv1_folderMessage,
    is_active: true;

CREATE tool:microsoftoutlookv1_message_get SET
    identity = {
        name: "get",
        slug: "microsoftoutlookv1_message_get",
        display_name_i18n: i18n_key:tool_microsoftoutlookv1_message_get_name,
        description_i18n: i18n_key:tool_microsoftoutlookv1_message_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1305,
        tooltip_i18n: i18n_key:tool_microsoftoutlookv1_message_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_microsoftoutlookv1_message_get_success,
        error_message_i18n: i18n_key:tool_microsoftoutlookv1_message_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:microsoftoutlookv1_message,
    is_active: true;

CREATE tool:microsoftoutlookv1_message_getMany SET
    identity = {
        name: "getMany",
        slug: "microsoftoutlookv1_message_getMany",
        display_name_i18n: i18n_key:tool_microsoftoutlookv1_message_getMany_name,
        description_i18n: i18n_key:tool_microsoftoutlookv1_message_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 1306,
        tooltip_i18n: i18n_key:tool_microsoftoutlookv1_message_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_microsoftoutlookv1_message_getMany_success,
        error_message_i18n: i18n_key:tool_microsoftoutlookv1_message_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:microsoftoutlookv1_message,
    is_active: true;

CREATE tool:microsoftoutlookv1_messageAttachment_get SET
    identity = {
        name: "get",
        slug: "microsoftoutlookv1_messageAttachment_get",
        display_name_i18n: i18n_key:tool_microsoftoutlookv1_messageAttachment_get_name,
        description_i18n: i18n_key:tool_microsoftoutlookv1_messageAttachment_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1307,
        tooltip_i18n: i18n_key:tool_microsoftoutlookv1_messageAttachment_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_microsoftoutlookv1_messageAttachment_get_success,
        error_message_i18n: i18n_key:tool_microsoftoutlookv1_messageAttachment_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:microsoftoutlookv1_messageAttachment,
    is_active: true;

CREATE tool:microsoftoutlookv1_messageAttachment_getMany SET
    identity = {
        name: "getMany",
        slug: "microsoftoutlookv1_messageAttachment_getMany",
        display_name_i18n: i18n_key:tool_microsoftoutlookv1_messageAttachment_getMany_name,
        description_i18n: i18n_key:tool_microsoftoutlookv1_messageAttachment_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 1308,
        tooltip_i18n: i18n_key:tool_microsoftoutlookv1_messageAttachment_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_microsoftoutlookv1_messageAttachment_getMany_success,
        error_message_i18n: i18n_key:tool_microsoftoutlookv1_messageAttachment_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:microsoftoutlookv1_messageAttachment,
    is_active: true;

CREATE tool:microsoftoutlookv1_draftmessageshared_get SET
    identity = {
        name: "get",
        slug: "microsoftoutlookv1_draftmessageshared_get",
        display_name_i18n: i18n_key:tool_microsoftoutlookv1_draftmessageshared_get_name,
        description_i18n: i18n_key:tool_microsoftoutlookv1_draftmessageshared_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1309,
        tooltip_i18n: i18n_key:tool_microsoftoutlookv1_draftmessageshared_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_microsoftoutlookv1_draftmessageshared_get_success,
        error_message_i18n: i18n_key:tool_microsoftoutlookv1_draftmessageshared_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:microsoftoutlookv1_draftmessageshared,
    is_active: true;

CREATE tool:microsoftoutlookv1_draftmessageshared_getMany SET
    identity = {
        name: "getMany",
        slug: "microsoftoutlookv1_draftmessageshared_getMany",
        display_name_i18n: i18n_key:tool_microsoftoutlookv1_draftmessageshared_getMany_name,
        description_i18n: i18n_key:tool_microsoftoutlookv1_draftmessageshared_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 1310,
        tooltip_i18n: i18n_key:tool_microsoftoutlookv1_draftmessageshared_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_microsoftoutlookv1_draftmessageshared_getMany_success,
        error_message_i18n: i18n_key:tool_microsoftoutlookv1_draftmessageshared_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:microsoftoutlookv1_draftmessageshared,
    is_active: true;

CREATE tool:microsoftoutlookv1_messageattachment_get SET
    identity = {
        name: "get",
        slug: "microsoftoutlookv1_messageattachment_get",
        display_name_i18n: i18n_key:tool_microsoftoutlookv1_messageattachment_get_name,
        description_i18n: i18n_key:tool_microsoftoutlookv1_messageattachment_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1311,
        tooltip_i18n: i18n_key:tool_microsoftoutlookv1_messageattachment_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_microsoftoutlookv1_messageattachment_get_success,
        error_message_i18n: i18n_key:tool_microsoftoutlookv1_messageattachment_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:microsoftoutlookv1_messageattachment,
    is_active: true;

CREATE tool:microsoftoutlookv1_messageattachment_getMany SET
    identity = {
        name: "getMany",
        slug: "microsoftoutlookv1_messageattachment_getMany",
        display_name_i18n: i18n_key:tool_microsoftoutlookv1_messageattachment_getMany_name,
        description_i18n: i18n_key:tool_microsoftoutlookv1_messageattachment_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 1312,
        tooltip_i18n: i18n_key:tool_microsoftoutlookv1_messageattachment_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_microsoftoutlookv1_messageattachment_getMany_success,
        error_message_i18n: i18n_key:tool_microsoftoutlookv1_messageattachment_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:microsoftoutlookv1_messageattachment,
    is_active: true;

CREATE tool:microsoftoutlookv2_microsoftoutlookv2_get SET
    identity = {
        name: "get",
        slug: "microsoftoutlookv2_microsoftoutlookv2_get",
        display_name_i18n: i18n_key:tool_microsoftoutlookv2_microsoftoutlookv2_get_name,
        description_i18n: i18n_key:tool_microsoftoutlookv2_microsoftoutlookv2_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1313,
        tooltip_i18n: i18n_key:tool_microsoftoutlookv2_microsoftoutlookv2_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_microsoftoutlookv2_microsoftoutlookv2_get_success,
        error_message_i18n: i18n_key:tool_microsoftoutlookv2_microsoftoutlookv2_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:microsoftoutlookv2_microsoftoutlookv2,
    is_active: true;

CREATE tool:microsoftoutlookv2_microsoftoutlookv2_getMany SET
    identity = {
        name: "getMany",
        slug: "microsoftoutlookv2_microsoftoutlookv2_getMany",
        display_name_i18n: i18n_key:tool_microsoftoutlookv2_microsoftoutlookv2_getMany_name,
        description_i18n: i18n_key:tool_microsoftoutlookv2_microsoftoutlookv2_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 1314,
        tooltip_i18n: i18n_key:tool_microsoftoutlookv2_microsoftoutlookv2_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_microsoftoutlookv2_microsoftoutlookv2_getMany_success,
        error_message_i18n: i18n_key:tool_microsoftoutlookv2_microsoftoutlookv2_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:microsoftoutlookv2_microsoftoutlookv2,
    is_active: true;

CREATE tool:microsoftsharepoint_file_get SET
    identity = {
        name: "get",
        slug: "microsoftsharepoint_file_get",
        display_name_i18n: i18n_key:tool_microsoftsharepoint_file_get_name,
        description_i18n: i18n_key:tool_microsoftsharepoint_file_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1315,
        tooltip_i18n: i18n_key:tool_microsoftsharepoint_file_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_microsoftsharepoint_file_get_success,
        error_message_i18n: i18n_key:tool_microsoftsharepoint_file_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:microsoftsharepoint_file,
    is_active: true;

CREATE tool:microsoftsharepoint_file_getMany SET
    identity = {
        name: "getMany",
        slug: "microsoftsharepoint_file_getMany",
        display_name_i18n: i18n_key:tool_microsoftsharepoint_file_getMany_name,
        description_i18n: i18n_key:tool_microsoftsharepoint_file_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 1316,
        tooltip_i18n: i18n_key:tool_microsoftsharepoint_file_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_microsoftsharepoint_file_getMany_success,
        error_message_i18n: i18n_key:tool_microsoftsharepoint_file_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:microsoftsharepoint_file,
    is_active: true;

CREATE tool:microsoftsharepoint_item_get SET
    identity = {
        name: "get",
        slug: "microsoftsharepoint_item_get",
        display_name_i18n: i18n_key:tool_microsoftsharepoint_item_get_name,
        description_i18n: i18n_key:tool_microsoftsharepoint_item_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1317,
        tooltip_i18n: i18n_key:tool_microsoftsharepoint_item_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_microsoftsharepoint_item_get_success,
        error_message_i18n: i18n_key:tool_microsoftsharepoint_item_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:microsoftsharepoint_item,
    is_active: true;

CREATE tool:microsoftsharepoint_item_getMany SET
    identity = {
        name: "getMany",
        slug: "microsoftsharepoint_item_getMany",
        display_name_i18n: i18n_key:tool_microsoftsharepoint_item_getMany_name,
        description_i18n: i18n_key:tool_microsoftsharepoint_item_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 1318,
        tooltip_i18n: i18n_key:tool_microsoftsharepoint_item_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_microsoftsharepoint_item_getMany_success,
        error_message_i18n: i18n_key:tool_microsoftsharepoint_item_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:microsoftsharepoint_item,
    is_active: true;

CREATE tool:microsoftsharepoint_list_get SET
    identity = {
        name: "get",
        slug: "microsoftsharepoint_list_get",
        display_name_i18n: i18n_key:tool_microsoftsharepoint_list_get_name,
        description_i18n: i18n_key:tool_microsoftsharepoint_list_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1319,
        tooltip_i18n: i18n_key:tool_microsoftsharepoint_list_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_microsoftsharepoint_list_get_success,
        error_message_i18n: i18n_key:tool_microsoftsharepoint_list_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:microsoftsharepoint_list,
    is_active: true;

CREATE tool:microsoftsharepoint_list_getMany SET
    identity = {
        name: "getMany",
        slug: "microsoftsharepoint_list_getMany",
        display_name_i18n: i18n_key:tool_microsoftsharepoint_list_getMany_name,
        description_i18n: i18n_key:tool_microsoftsharepoint_list_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 1320,
        tooltip_i18n: i18n_key:tool_microsoftsharepoint_list_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_microsoftsharepoint_list_getMany_success,
        error_message_i18n: i18n_key:tool_microsoftsharepoint_list_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:microsoftsharepoint_list,
    is_active: true;

CREATE tool:microsoftsql_microsoftsql_executeQuery SET
    identity = {
        name: "executeQuery",
        slug: "microsoftsql_microsoftsql_executeQuery",
        display_name_i18n: i18n_key:tool_microsoftsql_microsoftsql_executeQuery_name,
        description_i18n: i18n_key:tool_microsoftsql_microsoftsql_executeQuery_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 1321,
        tooltip_i18n: i18n_key:tool_microsoftsql_microsoftsql_executeQuery_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_microsoftsql_microsoftsql_executeQuery_success,
        error_message_i18n: i18n_key:tool_microsoftsql_microsoftsql_executeQuery_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:microsoftsql_microsoftsql,
    is_active: true;

CREATE tool:microsoftsql_microsoftsql_insert SET
    identity = {
        name: "insert",
        slug: "microsoftsql_microsoftsql_insert",
        display_name_i18n: i18n_key:tool_microsoftsql_microsoftsql_insert_name,
        description_i18n: i18n_key:tool_microsoftsql_microsoftsql_insert_desc,
        operation_type: "create",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#4CAF50",
        display_order: 1322,
        tooltip_i18n: i18n_key:tool_microsoftsql_microsoftsql_insert_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_microsoftsql_microsoftsql_insert_success,
        error_message_i18n: i18n_key:tool_microsoftsql_microsoftsql_insert_error,
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
    resource_id: resource:microsoftsql_microsoftsql,
    is_active: true;

CREATE tool:microsoftsql_microsoftsql_update SET
    identity = {
        name: "update",
        slug: "microsoftsql_microsoftsql_update",
        display_name_i18n: i18n_key:tool_microsoftsql_microsoftsql_update_name,
        description_i18n: i18n_key:tool_microsoftsql_microsoftsql_update_desc,
        operation_type: "update",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#FF9800",
        display_order: 1323,
        tooltip_i18n: i18n_key:tool_microsoftsql_microsoftsql_update_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_microsoftsql_microsoftsql_update_success,
        error_message_i18n: i18n_key:tool_microsoftsql_microsoftsql_update_error,
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
    resource_id: resource:microsoftsql_microsoftsql,
    is_active: true;

CREATE tool:microsoftsql_microsoftsql_delete SET
    identity = {
        name: "delete",
        slug: "microsoftsql_microsoftsql_delete",
        display_name_i18n: i18n_key:tool_microsoftsql_microsoftsql_delete_name,
        description_i18n: i18n_key:tool_microsoftsql_microsoftsql_delete_desc,
        operation_type: "delete",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#F44336",
        display_order: 1324,
        tooltip_i18n: i18n_key:tool_microsoftsql_microsoftsql_delete_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_microsoftsql_microsoftsql_delete_success,
        error_message_i18n: i18n_key:tool_microsoftsql_microsoftsql_delete_error,
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
    resource_id: resource:microsoftsql_microsoftsql,
    is_active: true;

CREATE tool:azurestorage_blob_get SET
    identity = {
        name: "get",
        slug: "azurestorage_blob_get",
        display_name_i18n: i18n_key:tool_azurestorage_blob_get_name,
        description_i18n: i18n_key:tool_azurestorage_blob_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1325,
        tooltip_i18n: i18n_key:tool_azurestorage_blob_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_azurestorage_blob_get_success,
        error_message_i18n: i18n_key:tool_azurestorage_blob_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:azurestorage_blob,
    is_active: true;

CREATE tool:azurestorage_blob_getMany SET
    identity = {
        name: "getMany",
        slug: "azurestorage_blob_getMany",
        display_name_i18n: i18n_key:tool_azurestorage_blob_getMany_name,
        description_i18n: i18n_key:tool_azurestorage_blob_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 1326,
        tooltip_i18n: i18n_key:tool_azurestorage_blob_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_azurestorage_blob_getMany_success,
        error_message_i18n: i18n_key:tool_azurestorage_blob_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:azurestorage_blob,
    is_active: true;

CREATE tool:azurestorage_container_get SET
    identity = {
        name: "get",
        slug: "azurestorage_container_get",
        display_name_i18n: i18n_key:tool_azurestorage_container_get_name,
        description_i18n: i18n_key:tool_azurestorage_container_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1327,
        tooltip_i18n: i18n_key:tool_azurestorage_container_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_azurestorage_container_get_success,
        error_message_i18n: i18n_key:tool_azurestorage_container_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:azurestorage_container,
    is_active: true;

CREATE tool:azurestorage_container_getMany SET
    identity = {
        name: "getMany",
        slug: "azurestorage_container_getMany",
        display_name_i18n: i18n_key:tool_azurestorage_container_getMany_name,
        description_i18n: i18n_key:tool_azurestorage_container_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 1328,
        tooltip_i18n: i18n_key:tool_azurestorage_container_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_azurestorage_container_getMany_success,
        error_message_i18n: i18n_key:tool_azurestorage_container_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:azurestorage_container,
    is_active: true;

CREATE tool:microsoftteams_microsoftteams_get SET
    identity = {
        name: "get",
        slug: "microsoftteams_microsoftteams_get",
        display_name_i18n: i18n_key:tool_microsoftteams_microsoftteams_get_name,
        description_i18n: i18n_key:tool_microsoftteams_microsoftteams_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1329,
        tooltip_i18n: i18n_key:tool_microsoftteams_microsoftteams_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_microsoftteams_microsoftteams_get_success,
        error_message_i18n: i18n_key:tool_microsoftteams_microsoftteams_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:microsoftteams_microsoftteams,
    is_active: true;

CREATE tool:microsoftteams_microsoftteams_getMany SET
    identity = {
        name: "getMany",
        slug: "microsoftteams_microsoftteams_getMany",
        display_name_i18n: i18n_key:tool_microsoftteams_microsoftteams_getMany_name,
        description_i18n: i18n_key:tool_microsoftteams_microsoftteams_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 1330,
        tooltip_i18n: i18n_key:tool_microsoftteams_microsoftteams_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_microsoftteams_microsoftteams_getMany_success,
        error_message_i18n: i18n_key:tool_microsoftteams_microsoftteams_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:microsoftteams_microsoftteams,
    is_active: true;

CREATE tool:microsoftteamsv1_channel_get SET
    identity = {
        name: "get",
        slug: "microsoftteamsv1_channel_get",
        display_name_i18n: i18n_key:tool_microsoftteamsv1_channel_get_name,
        description_i18n: i18n_key:tool_microsoftteamsv1_channel_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1331,
        tooltip_i18n: i18n_key:tool_microsoftteamsv1_channel_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_microsoftteamsv1_channel_get_success,
        error_message_i18n: i18n_key:tool_microsoftteamsv1_channel_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:microsoftteamsv1_channel,
    is_active: true;

CREATE tool:microsoftteamsv1_channel_getMany SET
    identity = {
        name: "getMany",
        slug: "microsoftteamsv1_channel_getMany",
        display_name_i18n: i18n_key:tool_microsoftteamsv1_channel_getMany_name,
        description_i18n: i18n_key:tool_microsoftteamsv1_channel_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 1332,
        tooltip_i18n: i18n_key:tool_microsoftteamsv1_channel_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_microsoftteamsv1_channel_getMany_success,
        error_message_i18n: i18n_key:tool_microsoftteamsv1_channel_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:microsoftteamsv1_channel,
    is_active: true;

CREATE tool:microsoftteamsv1_channelMessage_get SET
    identity = {
        name: "get",
        slug: "microsoftteamsv1_channelMessage_get",
        display_name_i18n: i18n_key:tool_microsoftteamsv1_channelMessage_get_name,
        description_i18n: i18n_key:tool_microsoftteamsv1_channelMessage_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1333,
        tooltip_i18n: i18n_key:tool_microsoftteamsv1_channelMessage_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_microsoftteamsv1_channelMessage_get_success,
        error_message_i18n: i18n_key:tool_microsoftteamsv1_channelMessage_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:microsoftteamsv1_channelMessage,
    is_active: true;

CREATE tool:microsoftteamsv1_channelMessage_getMany SET
    identity = {
        name: "getMany",
        slug: "microsoftteamsv1_channelMessage_getMany",
        display_name_i18n: i18n_key:tool_microsoftteamsv1_channelMessage_getMany_name,
        description_i18n: i18n_key:tool_microsoftteamsv1_channelMessage_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 1334,
        tooltip_i18n: i18n_key:tool_microsoftteamsv1_channelMessage_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_microsoftteamsv1_channelMessage_getMany_success,
        error_message_i18n: i18n_key:tool_microsoftteamsv1_channelMessage_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:microsoftteamsv1_channelMessage,
    is_active: true;

CREATE tool:microsoftteamsv1_chatMessage_get SET
    identity = {
        name: "get",
        slug: "microsoftteamsv1_chatMessage_get",
        display_name_i18n: i18n_key:tool_microsoftteamsv1_chatMessage_get_name,
        description_i18n: i18n_key:tool_microsoftteamsv1_chatMessage_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1335,
        tooltip_i18n: i18n_key:tool_microsoftteamsv1_chatMessage_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_microsoftteamsv1_chatMessage_get_success,
        error_message_i18n: i18n_key:tool_microsoftteamsv1_chatMessage_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:microsoftteamsv1_chatMessage,
    is_active: true;

CREATE tool:microsoftteamsv1_chatMessage_getMany SET
    identity = {
        name: "getMany",
        slug: "microsoftteamsv1_chatMessage_getMany",
        display_name_i18n: i18n_key:tool_microsoftteamsv1_chatMessage_getMany_name,
        description_i18n: i18n_key:tool_microsoftteamsv1_chatMessage_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 1336,
        tooltip_i18n: i18n_key:tool_microsoftteamsv1_chatMessage_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_microsoftteamsv1_chatMessage_getMany_success,
        error_message_i18n: i18n_key:tool_microsoftteamsv1_chatMessage_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:microsoftteamsv1_chatMessage,
    is_active: true;

CREATE tool:microsoftteamsv1_task_get SET
    identity = {
        name: "get",
        slug: "microsoftteamsv1_task_get",
        display_name_i18n: i18n_key:tool_microsoftteamsv1_task_get_name,
        description_i18n: i18n_key:tool_microsoftteamsv1_task_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1337,
        tooltip_i18n: i18n_key:tool_microsoftteamsv1_task_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_microsoftteamsv1_task_get_success,
        error_message_i18n: i18n_key:tool_microsoftteamsv1_task_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:microsoftteamsv1_task,
    is_active: true;

CREATE tool:microsoftteamsv1_task_getMany SET
    identity = {
        name: "getMany",
        slug: "microsoftteamsv1_task_getMany",
        display_name_i18n: i18n_key:tool_microsoftteamsv1_task_getMany_name,
        description_i18n: i18n_key:tool_microsoftteamsv1_task_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 1338,
        tooltip_i18n: i18n_key:tool_microsoftteamsv1_task_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_microsoftteamsv1_task_getMany_success,
        error_message_i18n: i18n_key:tool_microsoftteamsv1_task_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:microsoftteamsv1_task,
    is_active: true;

CREATE tool:microsoftteamsv1_channelmessage_get SET
    identity = {
        name: "get",
        slug: "microsoftteamsv1_channelmessage_get",
        display_name_i18n: i18n_key:tool_microsoftteamsv1_channelmessage_get_name,
        description_i18n: i18n_key:tool_microsoftteamsv1_channelmessage_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1339,
        tooltip_i18n: i18n_key:tool_microsoftteamsv1_channelmessage_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_microsoftteamsv1_channelmessage_get_success,
        error_message_i18n: i18n_key:tool_microsoftteamsv1_channelmessage_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:microsoftteamsv1_channelmessage,
    is_active: true;

CREATE tool:microsoftteamsv1_channelmessage_getMany SET
    identity = {
        name: "getMany",
        slug: "microsoftteamsv1_channelmessage_getMany",
        display_name_i18n: i18n_key:tool_microsoftteamsv1_channelmessage_getMany_name,
        description_i18n: i18n_key:tool_microsoftteamsv1_channelmessage_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 1340,
        tooltip_i18n: i18n_key:tool_microsoftteamsv1_channelmessage_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_microsoftteamsv1_channelmessage_getMany_success,
        error_message_i18n: i18n_key:tool_microsoftteamsv1_channelmessage_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:microsoftteamsv1_channelmessage,
    is_active: true;

CREATE tool:microsoftteamsv1_chatmessage_get SET
    identity = {
        name: "get",
        slug: "microsoftteamsv1_chatmessage_get",
        display_name_i18n: i18n_key:tool_microsoftteamsv1_chatmessage_get_name,
        description_i18n: i18n_key:tool_microsoftteamsv1_chatmessage_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1341,
        tooltip_i18n: i18n_key:tool_microsoftteamsv1_chatmessage_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_microsoftteamsv1_chatmessage_get_success,
        error_message_i18n: i18n_key:tool_microsoftteamsv1_chatmessage_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:microsoftteamsv1_chatmessage,
    is_active: true;

CREATE tool:microsoftteamsv1_chatmessage_getMany SET
    identity = {
        name: "getMany",
        slug: "microsoftteamsv1_chatmessage_getMany",
        display_name_i18n: i18n_key:tool_microsoftteamsv1_chatmessage_getMany_name,
        description_i18n: i18n_key:tool_microsoftteamsv1_chatmessage_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 1342,
        tooltip_i18n: i18n_key:tool_microsoftteamsv1_chatmessage_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_microsoftteamsv1_chatmessage_getMany_success,
        error_message_i18n: i18n_key:tool_microsoftteamsv1_chatmessage_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:microsoftteamsv1_chatmessage,
    is_active: true;

CREATE tool:microsoftteamsv2_microsoftteamsv2_get SET
    identity = {
        name: "get",
        slug: "microsoftteamsv2_microsoftteamsv2_get",
        display_name_i18n: i18n_key:tool_microsoftteamsv2_microsoftteamsv2_get_name,
        description_i18n: i18n_key:tool_microsoftteamsv2_microsoftteamsv2_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1343,
        tooltip_i18n: i18n_key:tool_microsoftteamsv2_microsoftteamsv2_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_microsoftteamsv2_microsoftteamsv2_get_success,
        error_message_i18n: i18n_key:tool_microsoftteamsv2_microsoftteamsv2_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:microsoftteamsv2_microsoftteamsv2,
    is_active: true;

CREATE tool:microsoftteamsv2_microsoftteamsv2_getMany SET
    identity = {
        name: "getMany",
        slug: "microsoftteamsv2_microsoftteamsv2_getMany",
        display_name_i18n: i18n_key:tool_microsoftteamsv2_microsoftteamsv2_getMany_name,
        description_i18n: i18n_key:tool_microsoftteamsv2_microsoftteamsv2_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 1344,
        tooltip_i18n: i18n_key:tool_microsoftteamsv2_microsoftteamsv2_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_microsoftteamsv2_microsoftteamsv2_getMany_success,
        error_message_i18n: i18n_key:tool_microsoftteamsv2_microsoftteamsv2_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:microsoftteamsv2_microsoftteamsv2,
    is_active: true;

CREATE tool:microsofttodo_linkedResource_get SET
    identity = {
        name: "get",
        slug: "microsofttodo_linkedResource_get",
        display_name_i18n: i18n_key:tool_microsofttodo_linkedResource_get_name,
        description_i18n: i18n_key:tool_microsofttodo_linkedResource_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1345,
        tooltip_i18n: i18n_key:tool_microsofttodo_linkedResource_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_microsofttodo_linkedResource_get_success,
        error_message_i18n: i18n_key:tool_microsofttodo_linkedResource_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:microsofttodo_linkedResource,
    is_active: true;

CREATE tool:microsofttodo_linkedResource_getMany SET
    identity = {
        name: "getMany",
        slug: "microsofttodo_linkedResource_getMany",
        display_name_i18n: i18n_key:tool_microsofttodo_linkedResource_getMany_name,
        description_i18n: i18n_key:tool_microsofttodo_linkedResource_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 1346,
        tooltip_i18n: i18n_key:tool_microsofttodo_linkedResource_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_microsofttodo_linkedResource_getMany_success,
        error_message_i18n: i18n_key:tool_microsofttodo_linkedResource_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:microsofttodo_linkedResource,
    is_active: true;

CREATE tool:microsofttodo_list_get SET
    identity = {
        name: "get",
        slug: "microsofttodo_list_get",
        display_name_i18n: i18n_key:tool_microsofttodo_list_get_name,
        description_i18n: i18n_key:tool_microsofttodo_list_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1347,
        tooltip_i18n: i18n_key:tool_microsofttodo_list_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_microsofttodo_list_get_success,
        error_message_i18n: i18n_key:tool_microsofttodo_list_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:microsofttodo_list,
    is_active: true;

CREATE tool:microsofttodo_list_getMany SET
    identity = {
        name: "getMany",
        slug: "microsofttodo_list_getMany",
        display_name_i18n: i18n_key:tool_microsofttodo_list_getMany_name,
        description_i18n: i18n_key:tool_microsofttodo_list_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 1348,
        tooltip_i18n: i18n_key:tool_microsofttodo_list_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_microsofttodo_list_getMany_success,
        error_message_i18n: i18n_key:tool_microsofttodo_list_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:microsofttodo_list,
    is_active: true;

CREATE tool:microsofttodo_task_get SET
    identity = {
        name: "get",
        slug: "microsofttodo_task_get",
        display_name_i18n: i18n_key:tool_microsofttodo_task_get_name,
        description_i18n: i18n_key:tool_microsofttodo_task_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1349,
        tooltip_i18n: i18n_key:tool_microsofttodo_task_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_microsofttodo_task_get_success,
        error_message_i18n: i18n_key:tool_microsofttodo_task_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:microsofttodo_task,
    is_active: true;

CREATE tool:microsofttodo_task_getMany SET
    identity = {
        name: "getMany",
        slug: "microsofttodo_task_getMany",
        display_name_i18n: i18n_key:tool_microsofttodo_task_getMany_name,
        description_i18n: i18n_key:tool_microsofttodo_task_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 1350,
        tooltip_i18n: i18n_key:tool_microsofttodo_task_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_microsofttodo_task_getMany_success,
        error_message_i18n: i18n_key:tool_microsofttodo_task_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:microsofttodo_task,
    is_active: true;

CREATE tool:microsofttodo_linkedresource_get SET
    identity = {
        name: "get",
        slug: "microsofttodo_linkedresource_get",
        display_name_i18n: i18n_key:tool_microsofttodo_linkedresource_get_name,
        description_i18n: i18n_key:tool_microsofttodo_linkedresource_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1351,
        tooltip_i18n: i18n_key:tool_microsofttodo_linkedresource_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_microsofttodo_linkedresource_get_success,
        error_message_i18n: i18n_key:tool_microsofttodo_linkedresource_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:microsofttodo_linkedresource,
    is_active: true;

CREATE tool:microsofttodo_linkedresource_getMany SET
    identity = {
        name: "getMany",
        slug: "microsofttodo_linkedresource_getMany",
        display_name_i18n: i18n_key:tool_microsofttodo_linkedresource_getMany_name,
        description_i18n: i18n_key:tool_microsofttodo_linkedresource_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 1352,
        tooltip_i18n: i18n_key:tool_microsofttodo_linkedresource_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_microsofttodo_linkedresource_getMany_success,
        error_message_i18n: i18n_key:tool_microsofttodo_linkedresource_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:microsofttodo_linkedresource,
    is_active: true;

CREATE tool:mindee_invoice_predict SET
    identity = {
        name: "predict",
        slug: "mindee_invoice_predict",
        display_name_i18n: i18n_key:tool_mindee_invoice_predict_name,
        description_i18n: i18n_key:tool_mindee_invoice_predict_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 1353,
        tooltip_i18n: i18n_key:tool_mindee_invoice_predict_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_mindee_invoice_predict_success,
        error_message_i18n: i18n_key:tool_mindee_invoice_predict_error,
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
    resource_id: resource:mindee_invoice,
    is_active: true;

CREATE tool:mindee_receipt_predict SET
    identity = {
        name: "predict",
        slug: "mindee_receipt_predict",
        display_name_i18n: i18n_key:tool_mindee_receipt_predict_name,
        description_i18n: i18n_key:tool_mindee_receipt_predict_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 1354,
        tooltip_i18n: i18n_key:tool_mindee_receipt_predict_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_mindee_receipt_predict_success,
        error_message_i18n: i18n_key:tool_mindee_receipt_predict_error,
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
    resource_id: resource:mindee_receipt,
    is_active: true;

CREATE tool:misp_attribute_get SET
    identity = {
        name: "get",
        slug: "misp_attribute_get",
        display_name_i18n: i18n_key:tool_misp_attribute_get_name,
        description_i18n: i18n_key:tool_misp_attribute_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1355,
        tooltip_i18n: i18n_key:tool_misp_attribute_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_misp_attribute_get_success,
        error_message_i18n: i18n_key:tool_misp_attribute_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:misp_attribute,
    is_active: true;

CREATE tool:misp_attribute_getMany SET
    identity = {
        name: "getMany",
        slug: "misp_attribute_getMany",
        display_name_i18n: i18n_key:tool_misp_attribute_getMany_name,
        description_i18n: i18n_key:tool_misp_attribute_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 1356,
        tooltip_i18n: i18n_key:tool_misp_attribute_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_misp_attribute_getMany_success,
        error_message_i18n: i18n_key:tool_misp_attribute_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:misp_attribute,
    is_active: true;

CREATE tool:misp_event_get SET
    identity = {
        name: "get",
        slug: "misp_event_get",
        display_name_i18n: i18n_key:tool_misp_event_get_name,
        description_i18n: i18n_key:tool_misp_event_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1357,
        tooltip_i18n: i18n_key:tool_misp_event_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_misp_event_get_success,
        error_message_i18n: i18n_key:tool_misp_event_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:misp_event,
    is_active: true;

CREATE tool:misp_event_getMany SET
    identity = {
        name: "getMany",
        slug: "misp_event_getMany",
        display_name_i18n: i18n_key:tool_misp_event_getMany_name,
        description_i18n: i18n_key:tool_misp_event_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 1358,
        tooltip_i18n: i18n_key:tool_misp_event_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_misp_event_getMany_success,
        error_message_i18n: i18n_key:tool_misp_event_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:misp_event,
    is_active: true;

CREATE tool:misp_eventTag_get SET
    identity = {
        name: "get",
        slug: "misp_eventTag_get",
        display_name_i18n: i18n_key:tool_misp_eventTag_get_name,
        description_i18n: i18n_key:tool_misp_eventTag_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1359,
        tooltip_i18n: i18n_key:tool_misp_eventTag_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_misp_eventTag_get_success,
        error_message_i18n: i18n_key:tool_misp_eventTag_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:misp_eventTag,
    is_active: true;

CREATE tool:misp_eventTag_getMany SET
    identity = {
        name: "getMany",
        slug: "misp_eventTag_getMany",
        display_name_i18n: i18n_key:tool_misp_eventTag_getMany_name,
        description_i18n: i18n_key:tool_misp_eventTag_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 1360,
        tooltip_i18n: i18n_key:tool_misp_eventTag_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_misp_eventTag_getMany_success,
        error_message_i18n: i18n_key:tool_misp_eventTag_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:misp_eventTag,
    is_active: true;

CREATE tool:misp_feed_get SET
    identity = {
        name: "get",
        slug: "misp_feed_get",
        display_name_i18n: i18n_key:tool_misp_feed_get_name,
        description_i18n: i18n_key:tool_misp_feed_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1361,
        tooltip_i18n: i18n_key:tool_misp_feed_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_misp_feed_get_success,
        error_message_i18n: i18n_key:tool_misp_feed_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:misp_feed,
    is_active: true;

CREATE tool:misp_feed_getMany SET
    identity = {
        name: "getMany",
        slug: "misp_feed_getMany",
        display_name_i18n: i18n_key:tool_misp_feed_getMany_name,
        description_i18n: i18n_key:tool_misp_feed_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 1362,
        tooltip_i18n: i18n_key:tool_misp_feed_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_misp_feed_getMany_success,
        error_message_i18n: i18n_key:tool_misp_feed_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:misp_feed,
    is_active: true;

CREATE tool:misp_galaxy_get SET
    identity = {
        name: "get",
        slug: "misp_galaxy_get",
        display_name_i18n: i18n_key:tool_misp_galaxy_get_name,
        description_i18n: i18n_key:tool_misp_galaxy_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1363,
        tooltip_i18n: i18n_key:tool_misp_galaxy_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_misp_galaxy_get_success,
        error_message_i18n: i18n_key:tool_misp_galaxy_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:misp_galaxy,
    is_active: true;

CREATE tool:misp_galaxy_getMany SET
    identity = {
        name: "getMany",
        slug: "misp_galaxy_getMany",
        display_name_i18n: i18n_key:tool_misp_galaxy_getMany_name,
        description_i18n: i18n_key:tool_misp_galaxy_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 1364,
        tooltip_i18n: i18n_key:tool_misp_galaxy_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_misp_galaxy_getMany_success,
        error_message_i18n: i18n_key:tool_misp_galaxy_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:misp_galaxy,
    is_active: true;

CREATE tool:misp_noticelist_get SET
    identity = {
        name: "get",
        slug: "misp_noticelist_get",
        display_name_i18n: i18n_key:tool_misp_noticelist_get_name,
        description_i18n: i18n_key:tool_misp_noticelist_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1365,
        tooltip_i18n: i18n_key:tool_misp_noticelist_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_misp_noticelist_get_success,
        error_message_i18n: i18n_key:tool_misp_noticelist_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:misp_noticelist,
    is_active: true;

CREATE tool:misp_noticelist_getMany SET
    identity = {
        name: "getMany",
        slug: "misp_noticelist_getMany",
        display_name_i18n: i18n_key:tool_misp_noticelist_getMany_name,
        description_i18n: i18n_key:tool_misp_noticelist_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 1366,
        tooltip_i18n: i18n_key:tool_misp_noticelist_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_misp_noticelist_getMany_success,
        error_message_i18n: i18n_key:tool_misp_noticelist_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:misp_noticelist,
    is_active: true;

CREATE tool:misp_object_get SET
    identity = {
        name: "get",
        slug: "misp_object_get",
        display_name_i18n: i18n_key:tool_misp_object_get_name,
        description_i18n: i18n_key:tool_misp_object_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1367,
        tooltip_i18n: i18n_key:tool_misp_object_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_misp_object_get_success,
        error_message_i18n: i18n_key:tool_misp_object_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:misp_object,
    is_active: true;

CREATE tool:misp_object_getMany SET
    identity = {
        name: "getMany",
        slug: "misp_object_getMany",
        display_name_i18n: i18n_key:tool_misp_object_getMany_name,
        description_i18n: i18n_key:tool_misp_object_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 1368,
        tooltip_i18n: i18n_key:tool_misp_object_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_misp_object_getMany_success,
        error_message_i18n: i18n_key:tool_misp_object_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:misp_object,
    is_active: true;

CREATE tool:misp_organisation_get SET
    identity = {
        name: "get",
        slug: "misp_organisation_get",
        display_name_i18n: i18n_key:tool_misp_organisation_get_name,
        description_i18n: i18n_key:tool_misp_organisation_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1369,
        tooltip_i18n: i18n_key:tool_misp_organisation_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_misp_organisation_get_success,
        error_message_i18n: i18n_key:tool_misp_organisation_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:misp_organisation,
    is_active: true;

CREATE tool:misp_organisation_getMany SET
    identity = {
        name: "getMany",
        slug: "misp_organisation_getMany",
        display_name_i18n: i18n_key:tool_misp_organisation_getMany_name,
        description_i18n: i18n_key:tool_misp_organisation_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 1370,
        tooltip_i18n: i18n_key:tool_misp_organisation_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_misp_organisation_getMany_success,
        error_message_i18n: i18n_key:tool_misp_organisation_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:misp_organisation,
    is_active: true;

CREATE tool:misp_tag_get SET
    identity = {
        name: "get",
        slug: "misp_tag_get",
        display_name_i18n: i18n_key:tool_misp_tag_get_name,
        description_i18n: i18n_key:tool_misp_tag_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1371,
        tooltip_i18n: i18n_key:tool_misp_tag_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_misp_tag_get_success,
        error_message_i18n: i18n_key:tool_misp_tag_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:misp_tag,
    is_active: true;

CREATE tool:misp_tag_getMany SET
    identity = {
        name: "getMany",
        slug: "misp_tag_getMany",
        display_name_i18n: i18n_key:tool_misp_tag_getMany_name,
        description_i18n: i18n_key:tool_misp_tag_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 1372,
        tooltip_i18n: i18n_key:tool_misp_tag_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_misp_tag_getMany_success,
        error_message_i18n: i18n_key:tool_misp_tag_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:misp_tag,
    is_active: true;

CREATE tool:misp_user_get SET
    identity = {
        name: "get",
        slug: "misp_user_get",
        display_name_i18n: i18n_key:tool_misp_user_get_name,
        description_i18n: i18n_key:tool_misp_user_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1373,
        tooltip_i18n: i18n_key:tool_misp_user_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_misp_user_get_success,
        error_message_i18n: i18n_key:tool_misp_user_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:misp_user,
    is_active: true;

CREATE tool:misp_user_getMany SET
    identity = {
        name: "getMany",
        slug: "misp_user_getMany",
        display_name_i18n: i18n_key:tool_misp_user_getMany_name,
        description_i18n: i18n_key:tool_misp_user_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 1374,
        tooltip_i18n: i18n_key:tool_misp_user_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_misp_user_getMany_success,
        error_message_i18n: i18n_key:tool_misp_user_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:misp_user,
    is_active: true;

CREATE tool:misp_warninglist_get SET
    identity = {
        name: "get",
        slug: "misp_warninglist_get",
        display_name_i18n: i18n_key:tool_misp_warninglist_get_name,
        description_i18n: i18n_key:tool_misp_warninglist_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1375,
        tooltip_i18n: i18n_key:tool_misp_warninglist_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_misp_warninglist_get_success,
        error_message_i18n: i18n_key:tool_misp_warninglist_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:misp_warninglist,
    is_active: true;

CREATE tool:misp_warninglist_getMany SET
    identity = {
        name: "getMany",
        slug: "misp_warninglist_getMany",
        display_name_i18n: i18n_key:tool_misp_warninglist_getMany_name,
        description_i18n: i18n_key:tool_misp_warninglist_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 1376,
        tooltip_i18n: i18n_key:tool_misp_warninglist_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_misp_warninglist_getMany_success,
        error_message_i18n: i18n_key:tool_misp_warninglist_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:misp_warninglist,
    is_active: true;

CREATE tool:mistralai_document_get SET
    identity = {
        name: "get",
        slug: "mistralai_document_get",
        display_name_i18n: i18n_key:tool_mistralai_document_get_name,
        description_i18n: i18n_key:tool_mistralai_document_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1377,
        tooltip_i18n: i18n_key:tool_mistralai_document_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_mistralai_document_get_success,
        error_message_i18n: i18n_key:tool_mistralai_document_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:mistralai_document,
    is_active: true;

CREATE tool:mistralai_document_getMany SET
    identity = {
        name: "getMany",
        slug: "mistralai_document_getMany",
        display_name_i18n: i18n_key:tool_mistralai_document_getMany_name,
        description_i18n: i18n_key:tool_mistralai_document_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 1378,
        tooltip_i18n: i18n_key:tool_mistralai_document_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_mistralai_document_getMany_success,
        error_message_i18n: i18n_key:tool_mistralai_document_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:mistralai_document,
    is_active: true;

CREATE tool:mocean_sms_send SET
    identity = {
        name: "send",
        slug: "mocean_sms_send",
        display_name_i18n: i18n_key:tool_mocean_sms_send_name,
        description_i18n: i18n_key:tool_mocean_sms_send_desc,
        operation_type: "upload",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#8BC34A",
        display_order: 1379,
        tooltip_i18n: i18n_key:tool_mocean_sms_send_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_mocean_sms_send_success,
        error_message_i18n: i18n_key:tool_mocean_sms_send_error,
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
    resource_id: resource:mocean_sms,
    is_active: true;

CREATE tool:mocean_voice_send SET
    identity = {
        name: "send",
        slug: "mocean_voice_send",
        display_name_i18n: i18n_key:tool_mocean_voice_send_name,
        description_i18n: i18n_key:tool_mocean_voice_send_desc,
        operation_type: "upload",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#8BC34A",
        display_order: 1380,
        tooltip_i18n: i18n_key:tool_mocean_voice_send_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_mocean_voice_send_success,
        error_message_i18n: i18n_key:tool_mocean_voice_send_error,
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
    resource_id: resource:mocean_voice,
    is_active: true;

CREATE tool:mondaycom_board_get SET
    identity = {
        name: "get",
        slug: "mondaycom_board_get",
        display_name_i18n: i18n_key:tool_mondaycom_board_get_name,
        description_i18n: i18n_key:tool_mondaycom_board_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1381,
        tooltip_i18n: i18n_key:tool_mondaycom_board_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_mondaycom_board_get_success,
        error_message_i18n: i18n_key:tool_mondaycom_board_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:mondaycom_board,
    is_active: true;

CREATE tool:mondaycom_board_getMany SET
    identity = {
        name: "getMany",
        slug: "mondaycom_board_getMany",
        display_name_i18n: i18n_key:tool_mondaycom_board_getMany_name,
        description_i18n: i18n_key:tool_mondaycom_board_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 1382,
        tooltip_i18n: i18n_key:tool_mondaycom_board_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_mondaycom_board_getMany_success,
        error_message_i18n: i18n_key:tool_mondaycom_board_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:mondaycom_board,
    is_active: true;

CREATE tool:mondaycom_boardColumn_get SET
    identity = {
        name: "get",
        slug: "mondaycom_boardColumn_get",
        display_name_i18n: i18n_key:tool_mondaycom_boardColumn_get_name,
        description_i18n: i18n_key:tool_mondaycom_boardColumn_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1383,
        tooltip_i18n: i18n_key:tool_mondaycom_boardColumn_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_mondaycom_boardColumn_get_success,
        error_message_i18n: i18n_key:tool_mondaycom_boardColumn_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:mondaycom_boardColumn,
    is_active: true;

CREATE tool:mondaycom_boardColumn_getMany SET
    identity = {
        name: "getMany",
        slug: "mondaycom_boardColumn_getMany",
        display_name_i18n: i18n_key:tool_mondaycom_boardColumn_getMany_name,
        description_i18n: i18n_key:tool_mondaycom_boardColumn_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 1384,
        tooltip_i18n: i18n_key:tool_mondaycom_boardColumn_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_mondaycom_boardColumn_getMany_success,
        error_message_i18n: i18n_key:tool_mondaycom_boardColumn_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:mondaycom_boardColumn,
    is_active: true;

CREATE tool:mondaycom_boardGroup_get SET
    identity = {
        name: "get",
        slug: "mondaycom_boardGroup_get",
        display_name_i18n: i18n_key:tool_mondaycom_boardGroup_get_name,
        description_i18n: i18n_key:tool_mondaycom_boardGroup_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1385,
        tooltip_i18n: i18n_key:tool_mondaycom_boardGroup_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_mondaycom_boardGroup_get_success,
        error_message_i18n: i18n_key:tool_mondaycom_boardGroup_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:mondaycom_boardGroup,
    is_active: true;

CREATE tool:mondaycom_boardGroup_getMany SET
    identity = {
        name: "getMany",
        slug: "mondaycom_boardGroup_getMany",
        display_name_i18n: i18n_key:tool_mondaycom_boardGroup_getMany_name,
        description_i18n: i18n_key:tool_mondaycom_boardGroup_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 1386,
        tooltip_i18n: i18n_key:tool_mondaycom_boardGroup_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_mondaycom_boardGroup_getMany_success,
        error_message_i18n: i18n_key:tool_mondaycom_boardGroup_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:mondaycom_boardGroup,
    is_active: true;

CREATE tool:mondaycom_boardItem_get SET
    identity = {
        name: "get",
        slug: "mondaycom_boardItem_get",
        display_name_i18n: i18n_key:tool_mondaycom_boardItem_get_name,
        description_i18n: i18n_key:tool_mondaycom_boardItem_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1387,
        tooltip_i18n: i18n_key:tool_mondaycom_boardItem_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_mondaycom_boardItem_get_success,
        error_message_i18n: i18n_key:tool_mondaycom_boardItem_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:mondaycom_boardItem,
    is_active: true;

CREATE tool:mondaycom_boardItem_getMany SET
    identity = {
        name: "getMany",
        slug: "mondaycom_boardItem_getMany",
        display_name_i18n: i18n_key:tool_mondaycom_boardItem_getMany_name,
        description_i18n: i18n_key:tool_mondaycom_boardItem_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 1388,
        tooltip_i18n: i18n_key:tool_mondaycom_boardItem_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_mondaycom_boardItem_getMany_success,
        error_message_i18n: i18n_key:tool_mondaycom_boardItem_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:mondaycom_boardItem,
    is_active: true;

CREATE tool:mondaycom_boardcolumn_get SET
    identity = {
        name: "get",
        slug: "mondaycom_boardcolumn_get",
        display_name_i18n: i18n_key:tool_mondaycom_boardcolumn_get_name,
        description_i18n: i18n_key:tool_mondaycom_boardcolumn_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1389,
        tooltip_i18n: i18n_key:tool_mondaycom_boardcolumn_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_mondaycom_boardcolumn_get_success,
        error_message_i18n: i18n_key:tool_mondaycom_boardcolumn_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:mondaycom_boardcolumn,
    is_active: true;

CREATE tool:mondaycom_boardcolumn_getMany SET
    identity = {
        name: "getMany",
        slug: "mondaycom_boardcolumn_getMany",
        display_name_i18n: i18n_key:tool_mondaycom_boardcolumn_getMany_name,
        description_i18n: i18n_key:tool_mondaycom_boardcolumn_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 1390,
        tooltip_i18n: i18n_key:tool_mondaycom_boardcolumn_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_mondaycom_boardcolumn_getMany_success,
        error_message_i18n: i18n_key:tool_mondaycom_boardcolumn_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:mondaycom_boardcolumn,
    is_active: true;

CREATE tool:mondaycom_boardgroup_get SET
    identity = {
        name: "get",
        slug: "mondaycom_boardgroup_get",
        display_name_i18n: i18n_key:tool_mondaycom_boardgroup_get_name,
        description_i18n: i18n_key:tool_mondaycom_boardgroup_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1391,
        tooltip_i18n: i18n_key:tool_mondaycom_boardgroup_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_mondaycom_boardgroup_get_success,
        error_message_i18n: i18n_key:tool_mondaycom_boardgroup_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:mondaycom_boardgroup,
    is_active: true;

CREATE tool:mondaycom_boardgroup_getMany SET
    identity = {
        name: "getMany",
        slug: "mondaycom_boardgroup_getMany",
        display_name_i18n: i18n_key:tool_mondaycom_boardgroup_getMany_name,
        description_i18n: i18n_key:tool_mondaycom_boardgroup_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 1392,
        tooltip_i18n: i18n_key:tool_mondaycom_boardgroup_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_mondaycom_boardgroup_getMany_success,
        error_message_i18n: i18n_key:tool_mondaycom_boardgroup_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:mondaycom_boardgroup,
    is_active: true;

CREATE tool:mondaycom_boarditem_get SET
    identity = {
        name: "get",
        slug: "mondaycom_boarditem_get",
        display_name_i18n: i18n_key:tool_mondaycom_boarditem_get_name,
        description_i18n: i18n_key:tool_mondaycom_boarditem_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1393,
        tooltip_i18n: i18n_key:tool_mondaycom_boarditem_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_mondaycom_boarditem_get_success,
        error_message_i18n: i18n_key:tool_mondaycom_boarditem_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:mondaycom_boarditem,
    is_active: true;

CREATE tool:mondaycom_boarditem_getMany SET
    identity = {
        name: "getMany",
        slug: "mondaycom_boarditem_getMany",
        display_name_i18n: i18n_key:tool_mondaycom_boarditem_getMany_name,
        description_i18n: i18n_key:tool_mondaycom_boarditem_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 1394,
        tooltip_i18n: i18n_key:tool_mondaycom_boarditem_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_mondaycom_boarditem_getMany_success,
        error_message_i18n: i18n_key:tool_mondaycom_boarditem_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:mondaycom_boarditem,
    is_active: true;

CREATE tool:mongodb_mongodb_get SET
    identity = {
        name: "get",
        slug: "mongodb_mongodb_get",
        display_name_i18n: i18n_key:tool_mongodb_mongodb_get_name,
        description_i18n: i18n_key:tool_mongodb_mongodb_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1395,
        tooltip_i18n: i18n_key:tool_mongodb_mongodb_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_mongodb_mongodb_get_success,
        error_message_i18n: i18n_key:tool_mongodb_mongodb_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:mongodb_mongodb,
    is_active: true;

CREATE tool:mongodb_mongodb_getMany SET
    identity = {
        name: "getMany",
        slug: "mongodb_mongodb_getMany",
        display_name_i18n: i18n_key:tool_mongodb_mongodb_getMany_name,
        description_i18n: i18n_key:tool_mongodb_mongodb_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 1396,
        tooltip_i18n: i18n_key:tool_mongodb_mongodb_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_mongodb_mongodb_getMany_success,
        error_message_i18n: i18n_key:tool_mongodb_mongodb_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:mongodb_mongodb,
    is_active: true;

CREATE tool:monicacrm_activity_get SET
    identity = {
        name: "get",
        slug: "monicacrm_activity_get",
        display_name_i18n: i18n_key:tool_monicacrm_activity_get_name,
        description_i18n: i18n_key:tool_monicacrm_activity_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1397,
        tooltip_i18n: i18n_key:tool_monicacrm_activity_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_monicacrm_activity_get_success,
        error_message_i18n: i18n_key:tool_monicacrm_activity_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:monicacrm_activity,
    is_active: true;

CREATE tool:monicacrm_activity_getMany SET
    identity = {
        name: "getMany",
        slug: "monicacrm_activity_getMany",
        display_name_i18n: i18n_key:tool_monicacrm_activity_getMany_name,
        description_i18n: i18n_key:tool_monicacrm_activity_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 1398,
        tooltip_i18n: i18n_key:tool_monicacrm_activity_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_monicacrm_activity_getMany_success,
        error_message_i18n: i18n_key:tool_monicacrm_activity_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:monicacrm_activity,
    is_active: true;

CREATE tool:monicacrm_call_get SET
    identity = {
        name: "get",
        slug: "monicacrm_call_get",
        display_name_i18n: i18n_key:tool_monicacrm_call_get_name,
        description_i18n: i18n_key:tool_monicacrm_call_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1399,
        tooltip_i18n: i18n_key:tool_monicacrm_call_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_monicacrm_call_get_success,
        error_message_i18n: i18n_key:tool_monicacrm_call_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:monicacrm_call,
    is_active: true;

CREATE tool:monicacrm_call_getMany SET
    identity = {
        name: "getMany",
        slug: "monicacrm_call_getMany",
        display_name_i18n: i18n_key:tool_monicacrm_call_getMany_name,
        description_i18n: i18n_key:tool_monicacrm_call_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 1400,
        tooltip_i18n: i18n_key:tool_monicacrm_call_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_monicacrm_call_getMany_success,
        error_message_i18n: i18n_key:tool_monicacrm_call_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:monicacrm_call,
    is_active: true;

