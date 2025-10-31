-- Batch 15: 100 tools Lyxal

CREATE tool:monicacrm_contact_get SET
    identity = {
        name: "get",
        slug: "monicacrm_contact_get",
        display_name_i18n: i18n_key:tool_monicacrm_contact_get_name,
        description_i18n: i18n_key:tool_monicacrm_contact_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1401,
        tooltip_i18n: i18n_key:tool_monicacrm_contact_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_monicacrm_contact_get_success,
        error_message_i18n: i18n_key:tool_monicacrm_contact_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:monicacrm_contact,
    is_active: true;

CREATE tool:monicacrm_contact_getMany SET
    identity = {
        name: "getMany",
        slug: "monicacrm_contact_getMany",
        display_name_i18n: i18n_key:tool_monicacrm_contact_getMany_name,
        description_i18n: i18n_key:tool_monicacrm_contact_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 1402,
        tooltip_i18n: i18n_key:tool_monicacrm_contact_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_monicacrm_contact_getMany_success,
        error_message_i18n: i18n_key:tool_monicacrm_contact_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:monicacrm_contact,
    is_active: true;

CREATE tool:monicacrm_contactField_get SET
    identity = {
        name: "get",
        slug: "monicacrm_contactField_get",
        display_name_i18n: i18n_key:tool_monicacrm_contactField_get_name,
        description_i18n: i18n_key:tool_monicacrm_contactField_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1403,
        tooltip_i18n: i18n_key:tool_monicacrm_contactField_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_monicacrm_contactField_get_success,
        error_message_i18n: i18n_key:tool_monicacrm_contactField_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:monicacrm_contactField,
    is_active: true;

CREATE tool:monicacrm_contactField_getMany SET
    identity = {
        name: "getMany",
        slug: "monicacrm_contactField_getMany",
        display_name_i18n: i18n_key:tool_monicacrm_contactField_getMany_name,
        description_i18n: i18n_key:tool_monicacrm_contactField_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 1404,
        tooltip_i18n: i18n_key:tool_monicacrm_contactField_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_monicacrm_contactField_getMany_success,
        error_message_i18n: i18n_key:tool_monicacrm_contactField_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:monicacrm_contactField,
    is_active: true;

CREATE tool:monicacrm_contactTag_get SET
    identity = {
        name: "get",
        slug: "monicacrm_contactTag_get",
        display_name_i18n: i18n_key:tool_monicacrm_contactTag_get_name,
        description_i18n: i18n_key:tool_monicacrm_contactTag_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1405,
        tooltip_i18n: i18n_key:tool_monicacrm_contactTag_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_monicacrm_contactTag_get_success,
        error_message_i18n: i18n_key:tool_monicacrm_contactTag_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:monicacrm_contactTag,
    is_active: true;

CREATE tool:monicacrm_contactTag_getMany SET
    identity = {
        name: "getMany",
        slug: "monicacrm_contactTag_getMany",
        display_name_i18n: i18n_key:tool_monicacrm_contactTag_getMany_name,
        description_i18n: i18n_key:tool_monicacrm_contactTag_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 1406,
        tooltip_i18n: i18n_key:tool_monicacrm_contactTag_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_monicacrm_contactTag_getMany_success,
        error_message_i18n: i18n_key:tool_monicacrm_contactTag_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:monicacrm_contactTag,
    is_active: true;

CREATE tool:monicacrm_conversation_get SET
    identity = {
        name: "get",
        slug: "monicacrm_conversation_get",
        display_name_i18n: i18n_key:tool_monicacrm_conversation_get_name,
        description_i18n: i18n_key:tool_monicacrm_conversation_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1407,
        tooltip_i18n: i18n_key:tool_monicacrm_conversation_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_monicacrm_conversation_get_success,
        error_message_i18n: i18n_key:tool_monicacrm_conversation_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:monicacrm_conversation,
    is_active: true;

CREATE tool:monicacrm_conversation_getMany SET
    identity = {
        name: "getMany",
        slug: "monicacrm_conversation_getMany",
        display_name_i18n: i18n_key:tool_monicacrm_conversation_getMany_name,
        description_i18n: i18n_key:tool_monicacrm_conversation_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 1408,
        tooltip_i18n: i18n_key:tool_monicacrm_conversation_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_monicacrm_conversation_getMany_success,
        error_message_i18n: i18n_key:tool_monicacrm_conversation_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:monicacrm_conversation,
    is_active: true;

CREATE tool:monicacrm_conversationMessage_get SET
    identity = {
        name: "get",
        slug: "monicacrm_conversationMessage_get",
        display_name_i18n: i18n_key:tool_monicacrm_conversationMessage_get_name,
        description_i18n: i18n_key:tool_monicacrm_conversationMessage_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1409,
        tooltip_i18n: i18n_key:tool_monicacrm_conversationMessage_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_monicacrm_conversationMessage_get_success,
        error_message_i18n: i18n_key:tool_monicacrm_conversationMessage_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:monicacrm_conversationMessage,
    is_active: true;

CREATE tool:monicacrm_conversationMessage_getMany SET
    identity = {
        name: "getMany",
        slug: "monicacrm_conversationMessage_getMany",
        display_name_i18n: i18n_key:tool_monicacrm_conversationMessage_getMany_name,
        description_i18n: i18n_key:tool_monicacrm_conversationMessage_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 1410,
        tooltip_i18n: i18n_key:tool_monicacrm_conversationMessage_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_monicacrm_conversationMessage_getMany_success,
        error_message_i18n: i18n_key:tool_monicacrm_conversationMessage_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:monicacrm_conversationMessage,
    is_active: true;

CREATE tool:monicacrm_journalEntry_get SET
    identity = {
        name: "get",
        slug: "monicacrm_journalEntry_get",
        display_name_i18n: i18n_key:tool_monicacrm_journalEntry_get_name,
        description_i18n: i18n_key:tool_monicacrm_journalEntry_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1411,
        tooltip_i18n: i18n_key:tool_monicacrm_journalEntry_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_monicacrm_journalEntry_get_success,
        error_message_i18n: i18n_key:tool_monicacrm_journalEntry_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:monicacrm_journalEntry,
    is_active: true;

CREATE tool:monicacrm_journalEntry_getMany SET
    identity = {
        name: "getMany",
        slug: "monicacrm_journalEntry_getMany",
        display_name_i18n: i18n_key:tool_monicacrm_journalEntry_getMany_name,
        description_i18n: i18n_key:tool_monicacrm_journalEntry_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 1412,
        tooltip_i18n: i18n_key:tool_monicacrm_journalEntry_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_monicacrm_journalEntry_getMany_success,
        error_message_i18n: i18n_key:tool_monicacrm_journalEntry_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:monicacrm_journalEntry,
    is_active: true;

CREATE tool:monicacrm_note_get SET
    identity = {
        name: "get",
        slug: "monicacrm_note_get",
        display_name_i18n: i18n_key:tool_monicacrm_note_get_name,
        description_i18n: i18n_key:tool_monicacrm_note_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1413,
        tooltip_i18n: i18n_key:tool_monicacrm_note_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_monicacrm_note_get_success,
        error_message_i18n: i18n_key:tool_monicacrm_note_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:monicacrm_note,
    is_active: true;

CREATE tool:monicacrm_note_getMany SET
    identity = {
        name: "getMany",
        slug: "monicacrm_note_getMany",
        display_name_i18n: i18n_key:tool_monicacrm_note_getMany_name,
        description_i18n: i18n_key:tool_monicacrm_note_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 1414,
        tooltip_i18n: i18n_key:tool_monicacrm_note_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_monicacrm_note_getMany_success,
        error_message_i18n: i18n_key:tool_monicacrm_note_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:monicacrm_note,
    is_active: true;

CREATE tool:monicacrm_reminder_get SET
    identity = {
        name: "get",
        slug: "monicacrm_reminder_get",
        display_name_i18n: i18n_key:tool_monicacrm_reminder_get_name,
        description_i18n: i18n_key:tool_monicacrm_reminder_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1415,
        tooltip_i18n: i18n_key:tool_monicacrm_reminder_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_monicacrm_reminder_get_success,
        error_message_i18n: i18n_key:tool_monicacrm_reminder_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:monicacrm_reminder,
    is_active: true;

CREATE tool:monicacrm_reminder_getMany SET
    identity = {
        name: "getMany",
        slug: "monicacrm_reminder_getMany",
        display_name_i18n: i18n_key:tool_monicacrm_reminder_getMany_name,
        description_i18n: i18n_key:tool_monicacrm_reminder_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 1416,
        tooltip_i18n: i18n_key:tool_monicacrm_reminder_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_monicacrm_reminder_getMany_success,
        error_message_i18n: i18n_key:tool_monicacrm_reminder_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:monicacrm_reminder,
    is_active: true;

CREATE tool:monicacrm_tag_get SET
    identity = {
        name: "get",
        slug: "monicacrm_tag_get",
        display_name_i18n: i18n_key:tool_monicacrm_tag_get_name,
        description_i18n: i18n_key:tool_monicacrm_tag_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1417,
        tooltip_i18n: i18n_key:tool_monicacrm_tag_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_monicacrm_tag_get_success,
        error_message_i18n: i18n_key:tool_monicacrm_tag_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:monicacrm_tag,
    is_active: true;

CREATE tool:monicacrm_tag_getMany SET
    identity = {
        name: "getMany",
        slug: "monicacrm_tag_getMany",
        display_name_i18n: i18n_key:tool_monicacrm_tag_getMany_name,
        description_i18n: i18n_key:tool_monicacrm_tag_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 1418,
        tooltip_i18n: i18n_key:tool_monicacrm_tag_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_monicacrm_tag_getMany_success,
        error_message_i18n: i18n_key:tool_monicacrm_tag_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:monicacrm_tag,
    is_active: true;

CREATE tool:monicacrm_task_get SET
    identity = {
        name: "get",
        slug: "monicacrm_task_get",
        display_name_i18n: i18n_key:tool_monicacrm_task_get_name,
        description_i18n: i18n_key:tool_monicacrm_task_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1419,
        tooltip_i18n: i18n_key:tool_monicacrm_task_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_monicacrm_task_get_success,
        error_message_i18n: i18n_key:tool_monicacrm_task_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:monicacrm_task,
    is_active: true;

CREATE tool:monicacrm_task_getMany SET
    identity = {
        name: "getMany",
        slug: "monicacrm_task_getMany",
        display_name_i18n: i18n_key:tool_monicacrm_task_getMany_name,
        description_i18n: i18n_key:tool_monicacrm_task_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 1420,
        tooltip_i18n: i18n_key:tool_monicacrm_task_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_monicacrm_task_getMany_success,
        error_message_i18n: i18n_key:tool_monicacrm_task_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:monicacrm_task,
    is_active: true;

CREATE tool:movebinarydata_movebinarydata_get SET
    identity = {
        name: "get",
        slug: "movebinarydata_movebinarydata_get",
        display_name_i18n: i18n_key:tool_movebinarydata_movebinarydata_get_name,
        description_i18n: i18n_key:tool_movebinarydata_movebinarydata_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1421,
        tooltip_i18n: i18n_key:tool_movebinarydata_movebinarydata_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_movebinarydata_movebinarydata_get_success,
        error_message_i18n: i18n_key:tool_movebinarydata_movebinarydata_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:movebinarydata_movebinarydata,
    is_active: true;

CREATE tool:movebinarydata_movebinarydata_getMany SET
    identity = {
        name: "getMany",
        slug: "movebinarydata_movebinarydata_getMany",
        display_name_i18n: i18n_key:tool_movebinarydata_movebinarydata_getMany_name,
        description_i18n: i18n_key:tool_movebinarydata_movebinarydata_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 1422,
        tooltip_i18n: i18n_key:tool_movebinarydata_movebinarydata_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_movebinarydata_movebinarydata_getMany_success,
        error_message_i18n: i18n_key:tool_movebinarydata_movebinarydata_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:movebinarydata_movebinarydata,
    is_active: true;

CREATE tool:mqtt_mqtt_get SET
    identity = {
        name: "get",
        slug: "mqtt_mqtt_get",
        display_name_i18n: i18n_key:tool_mqtt_mqtt_get_name,
        description_i18n: i18n_key:tool_mqtt_mqtt_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1423,
        tooltip_i18n: i18n_key:tool_mqtt_mqtt_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_mqtt_mqtt_get_success,
        error_message_i18n: i18n_key:tool_mqtt_mqtt_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:mqtt_mqtt,
    is_active: true;

CREATE tool:mqtt_mqtt_getMany SET
    identity = {
        name: "getMany",
        slug: "mqtt_mqtt_getMany",
        display_name_i18n: i18n_key:tool_mqtt_mqtt_getMany_name,
        description_i18n: i18n_key:tool_mqtt_mqtt_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 1424,
        tooltip_i18n: i18n_key:tool_mqtt_mqtt_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_mqtt_mqtt_getMany_success,
        error_message_i18n: i18n_key:tool_mqtt_mqtt_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:mqtt_mqtt,
    is_active: true;

CREATE tool:msg91_sms_send SET
    identity = {
        name: "send",
        slug: "msg91_sms_send",
        display_name_i18n: i18n_key:tool_msg91_sms_send_name,
        description_i18n: i18n_key:tool_msg91_sms_send_desc,
        operation_type: "upload",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#8BC34A",
        display_order: 1425,
        tooltip_i18n: i18n_key:tool_msg91_sms_send_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_msg91_sms_send_success,
        error_message_i18n: i18n_key:tool_msg91_sms_send_error,
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
    resource_id: resource:msg91_sms,
    is_active: true;

CREATE tool:mysql_mysql_get SET
    identity = {
        name: "get",
        slug: "mysql_mysql_get",
        display_name_i18n: i18n_key:tool_mysql_mysql_get_name,
        description_i18n: i18n_key:tool_mysql_mysql_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1426,
        tooltip_i18n: i18n_key:tool_mysql_mysql_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_mysql_mysql_get_success,
        error_message_i18n: i18n_key:tool_mysql_mysql_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:mysql_mysql,
    is_active: true;

CREATE tool:mysql_mysql_getMany SET
    identity = {
        name: "getMany",
        slug: "mysql_mysql_getMany",
        display_name_i18n: i18n_key:tool_mysql_mysql_getMany_name,
        description_i18n: i18n_key:tool_mysql_mysql_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 1427,
        tooltip_i18n: i18n_key:tool_mysql_mysql_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_mysql_mysql_getMany_success,
        error_message_i18n: i18n_key:tool_mysql_mysql_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:mysql_mysql,
    is_active: true;

CREATE tool:mysqlv1_mysqlv1_executeQuery SET
    identity = {
        name: "executeQuery",
        slug: "mysqlv1_mysqlv1_executeQuery",
        display_name_i18n: i18n_key:tool_mysqlv1_mysqlv1_executeQuery_name,
        description_i18n: i18n_key:tool_mysqlv1_mysqlv1_executeQuery_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 1428,
        tooltip_i18n: i18n_key:tool_mysqlv1_mysqlv1_executeQuery_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_mysqlv1_mysqlv1_executeQuery_success,
        error_message_i18n: i18n_key:tool_mysqlv1_mysqlv1_executeQuery_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:mysqlv1_mysqlv1,
    is_active: true;

CREATE tool:mysqlv1_mysqlv1_insert SET
    identity = {
        name: "insert",
        slug: "mysqlv1_mysqlv1_insert",
        display_name_i18n: i18n_key:tool_mysqlv1_mysqlv1_insert_name,
        description_i18n: i18n_key:tool_mysqlv1_mysqlv1_insert_desc,
        operation_type: "create",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#4CAF50",
        display_order: 1429,
        tooltip_i18n: i18n_key:tool_mysqlv1_mysqlv1_insert_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_mysqlv1_mysqlv1_insert_success,
        error_message_i18n: i18n_key:tool_mysqlv1_mysqlv1_insert_error,
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
    resource_id: resource:mysqlv1_mysqlv1,
    is_active: true;

CREATE tool:mysqlv1_mysqlv1_update SET
    identity = {
        name: "update",
        slug: "mysqlv1_mysqlv1_update",
        display_name_i18n: i18n_key:tool_mysqlv1_mysqlv1_update_name,
        description_i18n: i18n_key:tool_mysqlv1_mysqlv1_update_desc,
        operation_type: "update",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#FF9800",
        display_order: 1430,
        tooltip_i18n: i18n_key:tool_mysqlv1_mysqlv1_update_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_mysqlv1_mysqlv1_update_success,
        error_message_i18n: i18n_key:tool_mysqlv1_mysqlv1_update_error,
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
    resource_id: resource:mysqlv1_mysqlv1,
    is_active: true;

CREATE tool:mysqlv2_mysqlv2_get SET
    identity = {
        name: "get",
        slug: "mysqlv2_mysqlv2_get",
        display_name_i18n: i18n_key:tool_mysqlv2_mysqlv2_get_name,
        description_i18n: i18n_key:tool_mysqlv2_mysqlv2_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1431,
        tooltip_i18n: i18n_key:tool_mysqlv2_mysqlv2_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_mysqlv2_mysqlv2_get_success,
        error_message_i18n: i18n_key:tool_mysqlv2_mysqlv2_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:mysqlv2_mysqlv2,
    is_active: true;

CREATE tool:mysqlv2_mysqlv2_getMany SET
    identity = {
        name: "getMany",
        slug: "mysqlv2_mysqlv2_getMany",
        display_name_i18n: i18n_key:tool_mysqlv2_mysqlv2_getMany_name,
        description_i18n: i18n_key:tool_mysqlv2_mysqlv2_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 1432,
        tooltip_i18n: i18n_key:tool_mysqlv2_mysqlv2_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_mysqlv2_mysqlv2_getMany_success,
        error_message_i18n: i18n_key:tool_mysqlv2_mysqlv2_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:mysqlv2_mysqlv2,
    is_active: true;

CREATE tool:n8n_audit_get SET
    identity = {
        name: "get",
        slug: "n8n_audit_get",
        display_name_i18n: i18n_key:tool_n8n_audit_get_name,
        description_i18n: i18n_key:tool_n8n_audit_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1433,
        tooltip_i18n: i18n_key:tool_n8n_audit_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_n8n_audit_get_success,
        error_message_i18n: i18n_key:tool_n8n_audit_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:n8n_audit,
    is_active: true;

CREATE tool:n8n_audit_getMany SET
    identity = {
        name: "getMany",
        slug: "n8n_audit_getMany",
        display_name_i18n: i18n_key:tool_n8n_audit_getMany_name,
        description_i18n: i18n_key:tool_n8n_audit_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 1434,
        tooltip_i18n: i18n_key:tool_n8n_audit_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_n8n_audit_getMany_success,
        error_message_i18n: i18n_key:tool_n8n_audit_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:n8n_audit,
    is_active: true;

CREATE tool:n8n_credential_get SET
    identity = {
        name: "get",
        slug: "n8n_credential_get",
        display_name_i18n: i18n_key:tool_n8n_credential_get_name,
        description_i18n: i18n_key:tool_n8n_credential_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1435,
        tooltip_i18n: i18n_key:tool_n8n_credential_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_n8n_credential_get_success,
        error_message_i18n: i18n_key:tool_n8n_credential_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:n8n_credential,
    is_active: true;

CREATE tool:n8n_credential_getMany SET
    identity = {
        name: "getMany",
        slug: "n8n_credential_getMany",
        display_name_i18n: i18n_key:tool_n8n_credential_getMany_name,
        description_i18n: i18n_key:tool_n8n_credential_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 1436,
        tooltip_i18n: i18n_key:tool_n8n_credential_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_n8n_credential_getMany_success,
        error_message_i18n: i18n_key:tool_n8n_credential_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:n8n_credential,
    is_active: true;

CREATE tool:n8n_execution_get SET
    identity = {
        name: "get",
        slug: "n8n_execution_get",
        display_name_i18n: i18n_key:tool_n8n_execution_get_name,
        description_i18n: i18n_key:tool_n8n_execution_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1437,
        tooltip_i18n: i18n_key:tool_n8n_execution_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_n8n_execution_get_success,
        error_message_i18n: i18n_key:tool_n8n_execution_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:n8n_execution,
    is_active: true;

CREATE tool:n8n_execution_getMany SET
    identity = {
        name: "getMany",
        slug: "n8n_execution_getMany",
        display_name_i18n: i18n_key:tool_n8n_execution_getMany_name,
        description_i18n: i18n_key:tool_n8n_execution_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 1438,
        tooltip_i18n: i18n_key:tool_n8n_execution_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_n8n_execution_getMany_success,
        error_message_i18n: i18n_key:tool_n8n_execution_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:n8n_execution,
    is_active: true;

CREATE tool:n8n_workflow_get SET
    identity = {
        name: "get",
        slug: "n8n_workflow_get",
        display_name_i18n: i18n_key:tool_n8n_workflow_get_name,
        description_i18n: i18n_key:tool_n8n_workflow_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1439,
        tooltip_i18n: i18n_key:tool_n8n_workflow_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_n8n_workflow_get_success,
        error_message_i18n: i18n_key:tool_n8n_workflow_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:n8n_workflow,
    is_active: true;

CREATE tool:n8n_workflow_getMany SET
    identity = {
        name: "getMany",
        slug: "n8n_workflow_getMany",
        display_name_i18n: i18n_key:tool_n8n_workflow_getMany_name,
        description_i18n: i18n_key:tool_n8n_workflow_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 1440,
        tooltip_i18n: i18n_key:tool_n8n_workflow_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_n8n_workflow_getMany_success,
        error_message_i18n: i18n_key:tool_n8n_workflow_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:n8n_workflow,
    is_active: true;

CREATE tool:n8ntrainingcustomerdatastore_n8ntrainingcustomerdatastore_getOnePerson SET
    identity = {
        name: "getOnePerson",
        slug: "n8ntrainingcustomerdatastore_n8ntrainingcustomerdatastore_getOnePerson",
        display_name_i18n: i18n_key:tool_n8ntrainingcustomerdatastore_n8ntrainingcustomerdatastore_getOnePerson_name,
        description_i18n: i18n_key:tool_n8ntrainingcustomerdatastore_n8ntrainingcustomerdatastore_getOnePerson_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1441,
        tooltip_i18n: i18n_key:tool_n8ntrainingcustomerdatastore_n8ntrainingcustomerdatastore_getOnePerson_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_n8ntrainingcustomerdatastore_n8ntrainingcustomerdatastore_getOnePerson_success,
        error_message_i18n: i18n_key:tool_n8ntrainingcustomerdatastore_n8ntrainingcustomerdatastore_getOnePerson_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:n8ntrainingcustomerdatastore_n8ntrainingcustomerdatastore,
    is_active: true;

CREATE tool:n8ntrainingcustomerdatastore_n8ntrainingcustomerdatastore_getAllPeople SET
    identity = {
        name: "getAllPeople",
        slug: "n8ntrainingcustomerdatastore_n8ntrainingcustomerdatastore_getAllPeople",
        display_name_i18n: i18n_key:tool_n8ntrainingcustomerdatastore_n8ntrainingcustomerdatastore_getAllPeople_name,
        description_i18n: i18n_key:tool_n8ntrainingcustomerdatastore_n8ntrainingcustomerdatastore_getAllPeople_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1442,
        tooltip_i18n: i18n_key:tool_n8ntrainingcustomerdatastore_n8ntrainingcustomerdatastore_getAllPeople_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_n8ntrainingcustomerdatastore_n8ntrainingcustomerdatastore_getAllPeople_success,
        error_message_i18n: i18n_key:tool_n8ntrainingcustomerdatastore_n8ntrainingcustomerdatastore_getAllPeople_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:n8ntrainingcustomerdatastore_n8ntrainingcustomerdatastore,
    is_active: true;

CREATE tool:n8ntrainingcustomermessenger_n8ntrainingcustomermessenger_get SET
    identity = {
        name: "get",
        slug: "n8ntrainingcustomermessenger_n8ntrainingcustomermessenger_get",
        display_name_i18n: i18n_key:tool_n8ntrainingcustomermessenger_n8ntrainingcustomermessenger_get_name,
        description_i18n: i18n_key:tool_n8ntrainingcustomermessenger_n8ntrainingcustomermessenger_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1443,
        tooltip_i18n: i18n_key:tool_n8ntrainingcustomermessenger_n8ntrainingcustomermessenger_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_n8ntrainingcustomermessenger_n8ntrainingcustomermessenger_get_success,
        error_message_i18n: i18n_key:tool_n8ntrainingcustomermessenger_n8ntrainingcustomermessenger_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:n8ntrainingcustomermessenger_n8ntrainingcustomermessenger,
    is_active: true;

CREATE tool:n8ntrainingcustomermessenger_n8ntrainingcustomermessenger_getMany SET
    identity = {
        name: "getMany",
        slug: "n8ntrainingcustomermessenger_n8ntrainingcustomermessenger_getMany",
        display_name_i18n: i18n_key:tool_n8ntrainingcustomermessenger_n8ntrainingcustomermessenger_getMany_name,
        description_i18n: i18n_key:tool_n8ntrainingcustomermessenger_n8ntrainingcustomermessenger_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 1444,
        tooltip_i18n: i18n_key:tool_n8ntrainingcustomermessenger_n8ntrainingcustomermessenger_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_n8ntrainingcustomermessenger_n8ntrainingcustomermessenger_getMany_success,
        error_message_i18n: i18n_key:tool_n8ntrainingcustomermessenger_n8ntrainingcustomermessenger_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:n8ntrainingcustomermessenger_n8ntrainingcustomermessenger,
    is_active: true;

CREATE tool:nasa_asteroidNeoBrowse_get SET
    identity = {
        name: "get",
        slug: "nasa_asteroidNeoBrowse_get",
        display_name_i18n: i18n_key:tool_nasa_asteroidNeoBrowse_get_name,
        description_i18n: i18n_key:tool_nasa_asteroidNeoBrowse_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1445,
        tooltip_i18n: i18n_key:tool_nasa_asteroidNeoBrowse_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_nasa_asteroidNeoBrowse_get_success,
        error_message_i18n: i18n_key:tool_nasa_asteroidNeoBrowse_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:nasa_asteroidNeoBrowse,
    is_active: true;

CREATE tool:nasa_asteroidNeoFeed_get SET
    identity = {
        name: "get",
        slug: "nasa_asteroidNeoFeed_get",
        display_name_i18n: i18n_key:tool_nasa_asteroidNeoFeed_get_name,
        description_i18n: i18n_key:tool_nasa_asteroidNeoFeed_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1446,
        tooltip_i18n: i18n_key:tool_nasa_asteroidNeoFeed_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_nasa_asteroidNeoFeed_get_success,
        error_message_i18n: i18n_key:tool_nasa_asteroidNeoFeed_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:nasa_asteroidNeoFeed,
    is_active: true;

CREATE tool:nasa_asteroidNeoLookup_get SET
    identity = {
        name: "get",
        slug: "nasa_asteroidNeoLookup_get",
        display_name_i18n: i18n_key:tool_nasa_asteroidNeoLookup_get_name,
        description_i18n: i18n_key:tool_nasa_asteroidNeoLookup_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1447,
        tooltip_i18n: i18n_key:tool_nasa_asteroidNeoLookup_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_nasa_asteroidNeoLookup_get_success,
        error_message_i18n: i18n_key:tool_nasa_asteroidNeoLookup_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:nasa_asteroidNeoLookup,
    is_active: true;

CREATE tool:nasa_astronomyPictureOfTheDay_get SET
    identity = {
        name: "get",
        slug: "nasa_astronomyPictureOfTheDay_get",
        display_name_i18n: i18n_key:tool_nasa_astronomyPictureOfTheDay_get_name,
        description_i18n: i18n_key:tool_nasa_astronomyPictureOfTheDay_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1448,
        tooltip_i18n: i18n_key:tool_nasa_astronomyPictureOfTheDay_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_nasa_astronomyPictureOfTheDay_get_success,
        error_message_i18n: i18n_key:tool_nasa_astronomyPictureOfTheDay_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:nasa_astronomyPictureOfTheDay,
    is_active: true;

CREATE tool:nasa_donkiCoronalMassEjection_get SET
    identity = {
        name: "get",
        slug: "nasa_donkiCoronalMassEjection_get",
        display_name_i18n: i18n_key:tool_nasa_donkiCoronalMassEjection_get_name,
        description_i18n: i18n_key:tool_nasa_donkiCoronalMassEjection_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1449,
        tooltip_i18n: i18n_key:tool_nasa_donkiCoronalMassEjection_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_nasa_donkiCoronalMassEjection_get_success,
        error_message_i18n: i18n_key:tool_nasa_donkiCoronalMassEjection_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:nasa_donkiCoronalMassEjection,
    is_active: true;

CREATE tool:nasa_donkiHighSpeedStream_get SET
    identity = {
        name: "get",
        slug: "nasa_donkiHighSpeedStream_get",
        display_name_i18n: i18n_key:tool_nasa_donkiHighSpeedStream_get_name,
        description_i18n: i18n_key:tool_nasa_donkiHighSpeedStream_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1450,
        tooltip_i18n: i18n_key:tool_nasa_donkiHighSpeedStream_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_nasa_donkiHighSpeedStream_get_success,
        error_message_i18n: i18n_key:tool_nasa_donkiHighSpeedStream_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:nasa_donkiHighSpeedStream,
    is_active: true;

CREATE tool:nasa_donkiInterplanetaryShock_get SET
    identity = {
        name: "get",
        slug: "nasa_donkiInterplanetaryShock_get",
        display_name_i18n: i18n_key:tool_nasa_donkiInterplanetaryShock_get_name,
        description_i18n: i18n_key:tool_nasa_donkiInterplanetaryShock_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1451,
        tooltip_i18n: i18n_key:tool_nasa_donkiInterplanetaryShock_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_nasa_donkiInterplanetaryShock_get_success,
        error_message_i18n: i18n_key:tool_nasa_donkiInterplanetaryShock_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:nasa_donkiInterplanetaryShock,
    is_active: true;

CREATE tool:nasa_donkiMagnetopauseCrossing_get SET
    identity = {
        name: "get",
        slug: "nasa_donkiMagnetopauseCrossing_get",
        display_name_i18n: i18n_key:tool_nasa_donkiMagnetopauseCrossing_get_name,
        description_i18n: i18n_key:tool_nasa_donkiMagnetopauseCrossing_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1452,
        tooltip_i18n: i18n_key:tool_nasa_donkiMagnetopauseCrossing_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_nasa_donkiMagnetopauseCrossing_get_success,
        error_message_i18n: i18n_key:tool_nasa_donkiMagnetopauseCrossing_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:nasa_donkiMagnetopauseCrossing,
    is_active: true;

CREATE tool:nasa_donkiNotifications_get SET
    identity = {
        name: "get",
        slug: "nasa_donkiNotifications_get",
        display_name_i18n: i18n_key:tool_nasa_donkiNotifications_get_name,
        description_i18n: i18n_key:tool_nasa_donkiNotifications_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1453,
        tooltip_i18n: i18n_key:tool_nasa_donkiNotifications_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_nasa_donkiNotifications_get_success,
        error_message_i18n: i18n_key:tool_nasa_donkiNotifications_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:nasa_donkiNotifications,
    is_active: true;

CREATE tool:nasa_donkiRadiationBeltEnhancement_get SET
    identity = {
        name: "get",
        slug: "nasa_donkiRadiationBeltEnhancement_get",
        display_name_i18n: i18n_key:tool_nasa_donkiRadiationBeltEnhancement_get_name,
        description_i18n: i18n_key:tool_nasa_donkiRadiationBeltEnhancement_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1454,
        tooltip_i18n: i18n_key:tool_nasa_donkiRadiationBeltEnhancement_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_nasa_donkiRadiationBeltEnhancement_get_success,
        error_message_i18n: i18n_key:tool_nasa_donkiRadiationBeltEnhancement_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:nasa_donkiRadiationBeltEnhancement,
    is_active: true;

CREATE tool:nasa_donkiSolarEnergeticParticle_get SET
    identity = {
        name: "get",
        slug: "nasa_donkiSolarEnergeticParticle_get",
        display_name_i18n: i18n_key:tool_nasa_donkiSolarEnergeticParticle_get_name,
        description_i18n: i18n_key:tool_nasa_donkiSolarEnergeticParticle_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1455,
        tooltip_i18n: i18n_key:tool_nasa_donkiSolarEnergeticParticle_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_nasa_donkiSolarEnergeticParticle_get_success,
        error_message_i18n: i18n_key:tool_nasa_donkiSolarEnergeticParticle_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:nasa_donkiSolarEnergeticParticle,
    is_active: true;

CREATE tool:nasa_donkiSolarFlare_get SET
    identity = {
        name: "get",
        slug: "nasa_donkiSolarFlare_get",
        display_name_i18n: i18n_key:tool_nasa_donkiSolarFlare_get_name,
        description_i18n: i18n_key:tool_nasa_donkiSolarFlare_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1456,
        tooltip_i18n: i18n_key:tool_nasa_donkiSolarFlare_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_nasa_donkiSolarFlare_get_success,
        error_message_i18n: i18n_key:tool_nasa_donkiSolarFlare_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:nasa_donkiSolarFlare,
    is_active: true;

CREATE tool:nasa_donkiWsaEnlilSimulation_get SET
    identity = {
        name: "get",
        slug: "nasa_donkiWsaEnlilSimulation_get",
        display_name_i18n: i18n_key:tool_nasa_donkiWsaEnlilSimulation_get_name,
        description_i18n: i18n_key:tool_nasa_donkiWsaEnlilSimulation_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1457,
        tooltip_i18n: i18n_key:tool_nasa_donkiWsaEnlilSimulation_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_nasa_donkiWsaEnlilSimulation_get_success,
        error_message_i18n: i18n_key:tool_nasa_donkiWsaEnlilSimulation_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:nasa_donkiWsaEnlilSimulation,
    is_active: true;

CREATE tool:nasa_earthAssets_get SET
    identity = {
        name: "get",
        slug: "nasa_earthAssets_get",
        display_name_i18n: i18n_key:tool_nasa_earthAssets_get_name,
        description_i18n: i18n_key:tool_nasa_earthAssets_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1458,
        tooltip_i18n: i18n_key:tool_nasa_earthAssets_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_nasa_earthAssets_get_success,
        error_message_i18n: i18n_key:tool_nasa_earthAssets_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:nasa_earthAssets,
    is_active: true;

CREATE tool:nasa_earthImagery_get SET
    identity = {
        name: "get",
        slug: "nasa_earthImagery_get",
        display_name_i18n: i18n_key:tool_nasa_earthImagery_get_name,
        description_i18n: i18n_key:tool_nasa_earthImagery_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1459,
        tooltip_i18n: i18n_key:tool_nasa_earthImagery_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_nasa_earthImagery_get_success,
        error_message_i18n: i18n_key:tool_nasa_earthImagery_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:nasa_earthImagery,
    is_active: true;

CREATE tool:netlify_deploy_get SET
    identity = {
        name: "get",
        slug: "netlify_deploy_get",
        display_name_i18n: i18n_key:tool_netlify_deploy_get_name,
        description_i18n: i18n_key:tool_netlify_deploy_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1460,
        tooltip_i18n: i18n_key:tool_netlify_deploy_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_netlify_deploy_get_success,
        error_message_i18n: i18n_key:tool_netlify_deploy_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:netlify_deploy,
    is_active: true;

CREATE tool:netlify_deploy_getMany SET
    identity = {
        name: "getMany",
        slug: "netlify_deploy_getMany",
        display_name_i18n: i18n_key:tool_netlify_deploy_getMany_name,
        description_i18n: i18n_key:tool_netlify_deploy_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 1461,
        tooltip_i18n: i18n_key:tool_netlify_deploy_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_netlify_deploy_getMany_success,
        error_message_i18n: i18n_key:tool_netlify_deploy_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:netlify_deploy,
    is_active: true;

CREATE tool:netlify_site_get SET
    identity = {
        name: "get",
        slug: "netlify_site_get",
        display_name_i18n: i18n_key:tool_netlify_site_get_name,
        description_i18n: i18n_key:tool_netlify_site_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1462,
        tooltip_i18n: i18n_key:tool_netlify_site_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_netlify_site_get_success,
        error_message_i18n: i18n_key:tool_netlify_site_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:netlify_site,
    is_active: true;

CREATE tool:netlify_site_getMany SET
    identity = {
        name: "getMany",
        slug: "netlify_site_getMany",
        display_name_i18n: i18n_key:tool_netlify_site_getMany_name,
        description_i18n: i18n_key:tool_netlify_site_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 1463,
        tooltip_i18n: i18n_key:tool_netlify_site_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_netlify_site_getMany_success,
        error_message_i18n: i18n_key:tool_netlify_site_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:netlify_site,
    is_active: true;

CREATE tool:netscaleradc_certificate_get SET
    identity = {
        name: "get",
        slug: "netscaleradc_certificate_get",
        display_name_i18n: i18n_key:tool_netscaleradc_certificate_get_name,
        description_i18n: i18n_key:tool_netscaleradc_certificate_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1464,
        tooltip_i18n: i18n_key:tool_netscaleradc_certificate_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_netscaleradc_certificate_get_success,
        error_message_i18n: i18n_key:tool_netscaleradc_certificate_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:netscaleradc_certificate,
    is_active: true;

CREATE tool:netscaleradc_certificate_getMany SET
    identity = {
        name: "getMany",
        slug: "netscaleradc_certificate_getMany",
        display_name_i18n: i18n_key:tool_netscaleradc_certificate_getMany_name,
        description_i18n: i18n_key:tool_netscaleradc_certificate_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 1465,
        tooltip_i18n: i18n_key:tool_netscaleradc_certificate_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_netscaleradc_certificate_getMany_success,
        error_message_i18n: i18n_key:tool_netscaleradc_certificate_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:netscaleradc_certificate,
    is_active: true;

CREATE tool:netscaleradc_file_get SET
    identity = {
        name: "get",
        slug: "netscaleradc_file_get",
        display_name_i18n: i18n_key:tool_netscaleradc_file_get_name,
        description_i18n: i18n_key:tool_netscaleradc_file_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1466,
        tooltip_i18n: i18n_key:tool_netscaleradc_file_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_netscaleradc_file_get_success,
        error_message_i18n: i18n_key:tool_netscaleradc_file_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:netscaleradc_file,
    is_active: true;

CREATE tool:netscaleradc_file_getMany SET
    identity = {
        name: "getMany",
        slug: "netscaleradc_file_getMany",
        display_name_i18n: i18n_key:tool_netscaleradc_file_getMany_name,
        description_i18n: i18n_key:tool_netscaleradc_file_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 1467,
        tooltip_i18n: i18n_key:tool_netscaleradc_file_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_netscaleradc_file_getMany_success,
        error_message_i18n: i18n_key:tool_netscaleradc_file_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:netscaleradc_file,
    is_active: true;

CREATE tool:nextcloud_file_copy SET
    identity = {
        name: "copy",
        slug: "nextcloud_file_copy",
        display_name_i18n: i18n_key:tool_nextcloud_file_copy_name,
        description_i18n: i18n_key:tool_nextcloud_file_copy_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 1468,
        tooltip_i18n: i18n_key:tool_nextcloud_file_copy_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_nextcloud_file_copy_success,
        error_message_i18n: i18n_key:tool_nextcloud_file_copy_error,
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
    resource_id: resource:nextcloud_file,
    is_active: true;

CREATE tool:nextcloud_file_delete SET
    identity = {
        name: "delete",
        slug: "nextcloud_file_delete",
        display_name_i18n: i18n_key:tool_nextcloud_file_delete_name,
        description_i18n: i18n_key:tool_nextcloud_file_delete_desc,
        operation_type: "delete",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#F44336",
        display_order: 1469,
        tooltip_i18n: i18n_key:tool_nextcloud_file_delete_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_nextcloud_file_delete_success,
        error_message_i18n: i18n_key:tool_nextcloud_file_delete_error,
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
    resource_id: resource:nextcloud_file,
    is_active: true;

CREATE tool:nextcloud_file_download SET
    identity = {
        name: "download",
        slug: "nextcloud_file_download",
        display_name_i18n: i18n_key:tool_nextcloud_file_download_name,
        description_i18n: i18n_key:tool_nextcloud_file_download_desc,
        operation_type: "download",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#03A9F4",
        display_order: 1470,
        tooltip_i18n: i18n_key:tool_nextcloud_file_download_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_nextcloud_file_download_success,
        error_message_i18n: i18n_key:tool_nextcloud_file_download_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:nextcloud_file,
    is_active: true;

CREATE tool:nextcloud_file_move SET
    identity = {
        name: "move",
        slug: "nextcloud_file_move",
        display_name_i18n: i18n_key:tool_nextcloud_file_move_name,
        description_i18n: i18n_key:tool_nextcloud_file_move_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 1471,
        tooltip_i18n: i18n_key:tool_nextcloud_file_move_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_nextcloud_file_move_success,
        error_message_i18n: i18n_key:tool_nextcloud_file_move_error,
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
    resource_id: resource:nextcloud_file,
    is_active: true;

CREATE tool:nextcloud_file_share SET
    identity = {
        name: "share",
        slug: "nextcloud_file_share",
        display_name_i18n: i18n_key:tool_nextcloud_file_share_name,
        description_i18n: i18n_key:tool_nextcloud_file_share_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 1472,
        tooltip_i18n: i18n_key:tool_nextcloud_file_share_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_nextcloud_file_share_success,
        error_message_i18n: i18n_key:tool_nextcloud_file_share_error,
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
    resource_id: resource:nextcloud_file,
    is_active: true;

CREATE tool:nextcloud_file_upload SET
    identity = {
        name: "upload",
        slug: "nextcloud_file_upload",
        display_name_i18n: i18n_key:tool_nextcloud_file_upload_name,
        description_i18n: i18n_key:tool_nextcloud_file_upload_desc,
        operation_type: "upload",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#8BC34A",
        display_order: 1473,
        tooltip_i18n: i18n_key:tool_nextcloud_file_upload_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_nextcloud_file_upload_success,
        error_message_i18n: i18n_key:tool_nextcloud_file_upload_error,
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
    resource_id: resource:nextcloud_file,
    is_active: true;

CREATE tool:nextcloud_folder_copy SET
    identity = {
        name: "copy",
        slug: "nextcloud_folder_copy",
        display_name_i18n: i18n_key:tool_nextcloud_folder_copy_name,
        description_i18n: i18n_key:tool_nextcloud_folder_copy_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 1474,
        tooltip_i18n: i18n_key:tool_nextcloud_folder_copy_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_nextcloud_folder_copy_success,
        error_message_i18n: i18n_key:tool_nextcloud_folder_copy_error,
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
    resource_id: resource:nextcloud_folder,
    is_active: true;

CREATE tool:nextcloud_folder_delete SET
    identity = {
        name: "delete",
        slug: "nextcloud_folder_delete",
        display_name_i18n: i18n_key:tool_nextcloud_folder_delete_name,
        description_i18n: i18n_key:tool_nextcloud_folder_delete_desc,
        operation_type: "delete",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#F44336",
        display_order: 1475,
        tooltip_i18n: i18n_key:tool_nextcloud_folder_delete_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_nextcloud_folder_delete_success,
        error_message_i18n: i18n_key:tool_nextcloud_folder_delete_error,
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
    resource_id: resource:nextcloud_folder,
    is_active: true;

CREATE tool:nextcloud_folder_download SET
    identity = {
        name: "download",
        slug: "nextcloud_folder_download",
        display_name_i18n: i18n_key:tool_nextcloud_folder_download_name,
        description_i18n: i18n_key:tool_nextcloud_folder_download_desc,
        operation_type: "download",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#03A9F4",
        display_order: 1476,
        tooltip_i18n: i18n_key:tool_nextcloud_folder_download_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_nextcloud_folder_download_success,
        error_message_i18n: i18n_key:tool_nextcloud_folder_download_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:nextcloud_folder,
    is_active: true;

CREATE tool:nextcloud_folder_move SET
    identity = {
        name: "move",
        slug: "nextcloud_folder_move",
        display_name_i18n: i18n_key:tool_nextcloud_folder_move_name,
        description_i18n: i18n_key:tool_nextcloud_folder_move_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 1477,
        tooltip_i18n: i18n_key:tool_nextcloud_folder_move_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_nextcloud_folder_move_success,
        error_message_i18n: i18n_key:tool_nextcloud_folder_move_error,
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
    resource_id: resource:nextcloud_folder,
    is_active: true;

CREATE tool:nextcloud_folder_share SET
    identity = {
        name: "share",
        slug: "nextcloud_folder_share",
        display_name_i18n: i18n_key:tool_nextcloud_folder_share_name,
        description_i18n: i18n_key:tool_nextcloud_folder_share_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 1478,
        tooltip_i18n: i18n_key:tool_nextcloud_folder_share_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_nextcloud_folder_share_success,
        error_message_i18n: i18n_key:tool_nextcloud_folder_share_error,
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
    resource_id: resource:nextcloud_folder,
    is_active: true;

CREATE tool:nextcloud_folder_upload SET
    identity = {
        name: "upload",
        slug: "nextcloud_folder_upload",
        display_name_i18n: i18n_key:tool_nextcloud_folder_upload_name,
        description_i18n: i18n_key:tool_nextcloud_folder_upload_desc,
        operation_type: "upload",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#8BC34A",
        display_order: 1479,
        tooltip_i18n: i18n_key:tool_nextcloud_folder_upload_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_nextcloud_folder_upload_success,
        error_message_i18n: i18n_key:tool_nextcloud_folder_upload_error,
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
    resource_id: resource:nextcloud_folder,
    is_active: true;

CREATE tool:nextcloud_user_copy SET
    identity = {
        name: "copy",
        slug: "nextcloud_user_copy",
        display_name_i18n: i18n_key:tool_nextcloud_user_copy_name,
        description_i18n: i18n_key:tool_nextcloud_user_copy_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 1480,
        tooltip_i18n: i18n_key:tool_nextcloud_user_copy_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_nextcloud_user_copy_success,
        error_message_i18n: i18n_key:tool_nextcloud_user_copy_error,
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
    resource_id: resource:nextcloud_user,
    is_active: true;

CREATE tool:nextcloud_user_delete SET
    identity = {
        name: "delete",
        slug: "nextcloud_user_delete",
        display_name_i18n: i18n_key:tool_nextcloud_user_delete_name,
        description_i18n: i18n_key:tool_nextcloud_user_delete_desc,
        operation_type: "delete",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#F44336",
        display_order: 1481,
        tooltip_i18n: i18n_key:tool_nextcloud_user_delete_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_nextcloud_user_delete_success,
        error_message_i18n: i18n_key:tool_nextcloud_user_delete_error,
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
    resource_id: resource:nextcloud_user,
    is_active: true;

CREATE tool:nextcloud_user_download SET
    identity = {
        name: "download",
        slug: "nextcloud_user_download",
        display_name_i18n: i18n_key:tool_nextcloud_user_download_name,
        description_i18n: i18n_key:tool_nextcloud_user_download_desc,
        operation_type: "download",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#03A9F4",
        display_order: 1482,
        tooltip_i18n: i18n_key:tool_nextcloud_user_download_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_nextcloud_user_download_success,
        error_message_i18n: i18n_key:tool_nextcloud_user_download_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:nextcloud_user,
    is_active: true;

CREATE tool:nextcloud_user_move SET
    identity = {
        name: "move",
        slug: "nextcloud_user_move",
        display_name_i18n: i18n_key:tool_nextcloud_user_move_name,
        description_i18n: i18n_key:tool_nextcloud_user_move_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 1483,
        tooltip_i18n: i18n_key:tool_nextcloud_user_move_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_nextcloud_user_move_success,
        error_message_i18n: i18n_key:tool_nextcloud_user_move_error,
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
    resource_id: resource:nextcloud_user,
    is_active: true;

CREATE tool:nextcloud_user_share SET
    identity = {
        name: "share",
        slug: "nextcloud_user_share",
        display_name_i18n: i18n_key:tool_nextcloud_user_share_name,
        description_i18n: i18n_key:tool_nextcloud_user_share_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 1484,
        tooltip_i18n: i18n_key:tool_nextcloud_user_share_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_nextcloud_user_share_success,
        error_message_i18n: i18n_key:tool_nextcloud_user_share_error,
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
    resource_id: resource:nextcloud_user,
    is_active: true;

CREATE tool:nextcloud_user_upload SET
    identity = {
        name: "upload",
        slug: "nextcloud_user_upload",
        display_name_i18n: i18n_key:tool_nextcloud_user_upload_name,
        description_i18n: i18n_key:tool_nextcloud_user_upload_desc,
        operation_type: "upload",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#8BC34A",
        display_order: 1485,
        tooltip_i18n: i18n_key:tool_nextcloud_user_upload_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_nextcloud_user_upload_success,
        error_message_i18n: i18n_key:tool_nextcloud_user_upload_error,
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
    resource_id: resource:nextcloud_user,
    is_active: true;

CREATE tool:nocodb_row_create SET
    identity = {
        name: "create",
        slug: "nocodb_row_create",
        display_name_i18n: i18n_key:tool_nocodb_row_create_name,
        description_i18n: i18n_key:tool_nocodb_row_create_desc,
        operation_type: "create",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#4CAF50",
        display_order: 1486,
        tooltip_i18n: i18n_key:tool_nocodb_row_create_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_nocodb_row_create_success,
        error_message_i18n: i18n_key:tool_nocodb_row_create_error,
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
    resource_id: resource:nocodb_row,
    is_active: true;

CREATE tool:nocodb_row_delete SET
    identity = {
        name: "delete",
        slug: "nocodb_row_delete",
        display_name_i18n: i18n_key:tool_nocodb_row_delete_name,
        description_i18n: i18n_key:tool_nocodb_row_delete_desc,
        operation_type: "delete",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#F44336",
        display_order: 1487,
        tooltip_i18n: i18n_key:tool_nocodb_row_delete_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_nocodb_row_delete_success,
        error_message_i18n: i18n_key:tool_nocodb_row_delete_error,
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
    resource_id: resource:nocodb_row,
    is_active: true;

CREATE tool:nocodb_row_get SET
    identity = {
        name: "get",
        slug: "nocodb_row_get",
        display_name_i18n: i18n_key:tool_nocodb_row_get_name,
        description_i18n: i18n_key:tool_nocodb_row_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1488,
        tooltip_i18n: i18n_key:tool_nocodb_row_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_nocodb_row_get_success,
        error_message_i18n: i18n_key:tool_nocodb_row_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:nocodb_row,
    is_active: true;

CREATE tool:nocodb_row_getAll SET
    identity = {
        name: "getAll",
        slug: "nocodb_row_getAll",
        display_name_i18n: i18n_key:tool_nocodb_row_getAll_name,
        description_i18n: i18n_key:tool_nocodb_row_getAll_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1489,
        tooltip_i18n: i18n_key:tool_nocodb_row_getAll_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_nocodb_row_getAll_success,
        error_message_i18n: i18n_key:tool_nocodb_row_getAll_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:nocodb_row,
    is_active: true;

CREATE tool:nocodb_row_update SET
    identity = {
        name: "update",
        slug: "nocodb_row_update",
        display_name_i18n: i18n_key:tool_nocodb_row_update_name,
        description_i18n: i18n_key:tool_nocodb_row_update_desc,
        operation_type: "update",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#FF9800",
        display_order: 1490,
        tooltip_i18n: i18n_key:tool_nocodb_row_update_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_nocodb_row_update_success,
        error_message_i18n: i18n_key:tool_nocodb_row_update_error,
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
    resource_id: resource:nocodb_row,
    is_active: true;

CREATE tool:nocodb_operation_create SET
    identity = {
        name: "create",
        slug: "nocodb_operation_create",
        display_name_i18n: i18n_key:tool_nocodb_operation_create_name,
        description_i18n: i18n_key:tool_nocodb_operation_create_desc,
        operation_type: "create",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#4CAF50",
        display_order: 1491,
        tooltip_i18n: i18n_key:tool_nocodb_operation_create_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_nocodb_operation_create_success,
        error_message_i18n: i18n_key:tool_nocodb_operation_create_error,
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
    resource_id: resource:nocodb_operation,
    is_active: true;

CREATE tool:nocodb_operation_delete SET
    identity = {
        name: "delete",
        slug: "nocodb_operation_delete",
        display_name_i18n: i18n_key:tool_nocodb_operation_delete_name,
        description_i18n: i18n_key:tool_nocodb_operation_delete_desc,
        operation_type: "delete",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#F44336",
        display_order: 1492,
        tooltip_i18n: i18n_key:tool_nocodb_operation_delete_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_nocodb_operation_delete_success,
        error_message_i18n: i18n_key:tool_nocodb_operation_delete_error,
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
    resource_id: resource:nocodb_operation,
    is_active: true;

CREATE tool:nocodb_operation_get SET
    identity = {
        name: "get",
        slug: "nocodb_operation_get",
        display_name_i18n: i18n_key:tool_nocodb_operation_get_name,
        description_i18n: i18n_key:tool_nocodb_operation_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1493,
        tooltip_i18n: i18n_key:tool_nocodb_operation_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_nocodb_operation_get_success,
        error_message_i18n: i18n_key:tool_nocodb_operation_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:nocodb_operation,
    is_active: true;

CREATE tool:nocodb_operation_getAll SET
    identity = {
        name: "getAll",
        slug: "nocodb_operation_getAll",
        display_name_i18n: i18n_key:tool_nocodb_operation_getAll_name,
        description_i18n: i18n_key:tool_nocodb_operation_getAll_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1494,
        tooltip_i18n: i18n_key:tool_nocodb_operation_getAll_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_nocodb_operation_getAll_success,
        error_message_i18n: i18n_key:tool_nocodb_operation_getAll_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:nocodb_operation,
    is_active: true;

CREATE tool:nocodb_operation_update SET
    identity = {
        name: "update",
        slug: "nocodb_operation_update",
        display_name_i18n: i18n_key:tool_nocodb_operation_update_name,
        description_i18n: i18n_key:tool_nocodb_operation_update_desc,
        operation_type: "update",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#FF9800",
        display_order: 1495,
        tooltip_i18n: i18n_key:tool_nocodb_operation_update_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_nocodb_operation_update_success,
        error_message_i18n: i18n_key:tool_nocodb_operation_update_error,
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
    resource_id: resource:nocodb_operation,
    is_active: true;

CREATE tool:noop_noop_get SET
    identity = {
        name: "get",
        slug: "noop_noop_get",
        display_name_i18n: i18n_key:tool_noop_noop_get_name,
        description_i18n: i18n_key:tool_noop_noop_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1496,
        tooltip_i18n: i18n_key:tool_noop_noop_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_noop_noop_get_success,
        error_message_i18n: i18n_key:tool_noop_noop_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:noop_noop,
    is_active: true;

CREATE tool:noop_noop_getMany SET
    identity = {
        name: "getMany",
        slug: "noop_noop_getMany",
        display_name_i18n: i18n_key:tool_noop_noop_getMany_name,
        description_i18n: i18n_key:tool_noop_noop_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 1497,
        tooltip_i18n: i18n_key:tool_noop_noop_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_noop_noop_getMany_success,
        error_message_i18n: i18n_key:tool_noop_noop_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:noop_noop,
    is_active: true;

CREATE tool:notion_notion_get SET
    identity = {
        name: "get",
        slug: "notion_notion_get",
        display_name_i18n: i18n_key:tool_notion_notion_get_name,
        description_i18n: i18n_key:tool_notion_notion_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1498,
        tooltip_i18n: i18n_key:tool_notion_notion_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_notion_notion_get_success,
        error_message_i18n: i18n_key:tool_notion_notion_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:notion_notion,
    is_active: true;

CREATE tool:notion_notion_getMany SET
    identity = {
        name: "getMany",
        slug: "notion_notion_getMany",
        display_name_i18n: i18n_key:tool_notion_notion_getMany_name,
        description_i18n: i18n_key:tool_notion_notion_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 1499,
        tooltip_i18n: i18n_key:tool_notion_notion_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_notion_notion_getMany_success,
        error_message_i18n: i18n_key:tool_notion_notion_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:notion_notion,
    is_active: true;

CREATE tool:notionv1_version_get SET
    identity = {
        name: "get",
        slug: "notionv1_version_get",
        display_name_i18n: i18n_key:tool_notionv1_version_get_name,
        description_i18n: i18n_key:tool_notionv1_version_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 1500,
        tooltip_i18n: i18n_key:tool_notionv1_version_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_notionv1_version_get_success,
        error_message_i18n: i18n_key:tool_notionv1_version_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:notionv1_version,
    is_active: true;

