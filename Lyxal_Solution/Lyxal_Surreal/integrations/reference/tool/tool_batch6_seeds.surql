-- Batch 6: 100 tools Lyxal

CREATE tool:dropcontact_dropcontact_get SET
    identity = {
        name: "get",
        slug: "dropcontact_dropcontact_get",
        display_name_i18n: i18n_key:tool_dropcontact_dropcontact_get_name,
        description_i18n: i18n_key:tool_dropcontact_dropcontact_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 501,
        tooltip_i18n: i18n_key:tool_dropcontact_dropcontact_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_dropcontact_dropcontact_get_success,
        error_message_i18n: i18n_key:tool_dropcontact_dropcontact_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:dropcontact_dropcontact,
    is_active: true;

CREATE tool:dropcontact_dropcontact_getMany SET
    identity = {
        name: "getMany",
        slug: "dropcontact_dropcontact_getMany",
        display_name_i18n: i18n_key:tool_dropcontact_dropcontact_getMany_name,
        description_i18n: i18n_key:tool_dropcontact_dropcontact_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 502,
        tooltip_i18n: i18n_key:tool_dropcontact_dropcontact_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_dropcontact_dropcontact_getMany_success,
        error_message_i18n: i18n_key:tool_dropcontact_dropcontact_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:dropcontact_dropcontact,
    is_active: true;

CREATE tool:editimage_editimage_get SET
    identity = {
        name: "get",
        slug: "editimage_editimage_get",
        display_name_i18n: i18n_key:tool_editimage_editimage_get_name,
        description_i18n: i18n_key:tool_editimage_editimage_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 503,
        tooltip_i18n: i18n_key:tool_editimage_editimage_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_editimage_editimage_get_success,
        error_message_i18n: i18n_key:tool_editimage_editimage_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:editimage_editimage,
    is_active: true;

CREATE tool:editimage_editimage_getMany SET
    identity = {
        name: "getMany",
        slug: "editimage_editimage_getMany",
        display_name_i18n: i18n_key:tool_editimage_editimage_getMany_name,
        description_i18n: i18n_key:tool_editimage_editimage_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 504,
        tooltip_i18n: i18n_key:tool_editimage_editimage_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_editimage_editimage_getMany_success,
        error_message_i18n: i18n_key:tool_editimage_editimage_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:editimage_editimage,
    is_active: true;

CREATE tool:egoi_contact_create SET
    identity = {
        name: "create",
        slug: "egoi_contact_create",
        display_name_i18n: i18n_key:tool_egoi_contact_create_name,
        description_i18n: i18n_key:tool_egoi_contact_create_desc,
        operation_type: "create",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#4CAF50",
        display_order: 505,
        tooltip_i18n: i18n_key:tool_egoi_contact_create_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_egoi_contact_create_success,
        error_message_i18n: i18n_key:tool_egoi_contact_create_error,
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
    resource_id: resource:egoi_contact,
    is_active: true;

CREATE tool:egoi_contact_get SET
    identity = {
        name: "get",
        slug: "egoi_contact_get",
        display_name_i18n: i18n_key:tool_egoi_contact_get_name,
        description_i18n: i18n_key:tool_egoi_contact_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 506,
        tooltip_i18n: i18n_key:tool_egoi_contact_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_egoi_contact_get_success,
        error_message_i18n: i18n_key:tool_egoi_contact_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:egoi_contact,
    is_active: true;

CREATE tool:egoi_contact_getAll SET
    identity = {
        name: "getAll",
        slug: "egoi_contact_getAll",
        display_name_i18n: i18n_key:tool_egoi_contact_getAll_name,
        description_i18n: i18n_key:tool_egoi_contact_getAll_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 507,
        tooltip_i18n: i18n_key:tool_egoi_contact_getAll_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_egoi_contact_getAll_success,
        error_message_i18n: i18n_key:tool_egoi_contact_getAll_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:egoi_contact,
    is_active: true;

CREATE tool:egoi_contact_update SET
    identity = {
        name: "update",
        slug: "egoi_contact_update",
        display_name_i18n: i18n_key:tool_egoi_contact_update_name,
        description_i18n: i18n_key:tool_egoi_contact_update_desc,
        operation_type: "update",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#FF9800",
        display_order: 508,
        tooltip_i18n: i18n_key:tool_egoi_contact_update_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_egoi_contact_update_success,
        error_message_i18n: i18n_key:tool_egoi_contact_update_error,
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
    resource_id: resource:egoi_contact,
    is_active: true;

CREATE tool:elasticsearch_document_get SET
    identity = {
        name: "get",
        slug: "elasticsearch_document_get",
        display_name_i18n: i18n_key:tool_elasticsearch_document_get_name,
        description_i18n: i18n_key:tool_elasticsearch_document_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 509,
        tooltip_i18n: i18n_key:tool_elasticsearch_document_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_elasticsearch_document_get_success,
        error_message_i18n: i18n_key:tool_elasticsearch_document_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:elasticsearch_document,
    is_active: true;

CREATE tool:elasticsearch_document_getMany SET
    identity = {
        name: "getMany",
        slug: "elasticsearch_document_getMany",
        display_name_i18n: i18n_key:tool_elasticsearch_document_getMany_name,
        description_i18n: i18n_key:tool_elasticsearch_document_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 510,
        tooltip_i18n: i18n_key:tool_elasticsearch_document_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_elasticsearch_document_getMany_success,
        error_message_i18n: i18n_key:tool_elasticsearch_document_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:elasticsearch_document,
    is_active: true;

CREATE tool:elasticsearch_index_get SET
    identity = {
        name: "get",
        slug: "elasticsearch_index_get",
        display_name_i18n: i18n_key:tool_elasticsearch_index_get_name,
        description_i18n: i18n_key:tool_elasticsearch_index_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 511,
        tooltip_i18n: i18n_key:tool_elasticsearch_index_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_elasticsearch_index_get_success,
        error_message_i18n: i18n_key:tool_elasticsearch_index_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:elasticsearch_index,
    is_active: true;

CREATE tool:elasticsearch_index_getMany SET
    identity = {
        name: "getMany",
        slug: "elasticsearch_index_getMany",
        display_name_i18n: i18n_key:tool_elasticsearch_index_getMany_name,
        description_i18n: i18n_key:tool_elasticsearch_index_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 512,
        tooltip_i18n: i18n_key:tool_elasticsearch_index_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_elasticsearch_index_getMany_success,
        error_message_i18n: i18n_key:tool_elasticsearch_index_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:elasticsearch_index,
    is_active: true;

CREATE tool:elasticsecurity_case_get SET
    identity = {
        name: "get",
        slug: "elasticsecurity_case_get",
        display_name_i18n: i18n_key:tool_elasticsecurity_case_get_name,
        description_i18n: i18n_key:tool_elasticsecurity_case_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 513,
        tooltip_i18n: i18n_key:tool_elasticsecurity_case_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_elasticsecurity_case_get_success,
        error_message_i18n: i18n_key:tool_elasticsecurity_case_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:elasticsecurity_case,
    is_active: true;

CREATE tool:elasticsecurity_case_getMany SET
    identity = {
        name: "getMany",
        slug: "elasticsecurity_case_getMany",
        display_name_i18n: i18n_key:tool_elasticsecurity_case_getMany_name,
        description_i18n: i18n_key:tool_elasticsecurity_case_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 514,
        tooltip_i18n: i18n_key:tool_elasticsecurity_case_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_elasticsecurity_case_getMany_success,
        error_message_i18n: i18n_key:tool_elasticsecurity_case_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:elasticsecurity_case,
    is_active: true;

CREATE tool:elasticsecurity_caseComment_get SET
    identity = {
        name: "get",
        slug: "elasticsecurity_caseComment_get",
        display_name_i18n: i18n_key:tool_elasticsecurity_caseComment_get_name,
        description_i18n: i18n_key:tool_elasticsecurity_caseComment_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 515,
        tooltip_i18n: i18n_key:tool_elasticsecurity_caseComment_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_elasticsecurity_caseComment_get_success,
        error_message_i18n: i18n_key:tool_elasticsecurity_caseComment_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:elasticsecurity_caseComment,
    is_active: true;

CREATE tool:elasticsecurity_caseComment_getMany SET
    identity = {
        name: "getMany",
        slug: "elasticsecurity_caseComment_getMany",
        display_name_i18n: i18n_key:tool_elasticsecurity_caseComment_getMany_name,
        description_i18n: i18n_key:tool_elasticsecurity_caseComment_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 516,
        tooltip_i18n: i18n_key:tool_elasticsecurity_caseComment_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_elasticsecurity_caseComment_getMany_success,
        error_message_i18n: i18n_key:tool_elasticsecurity_caseComment_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:elasticsecurity_caseComment,
    is_active: true;

CREATE tool:elasticsecurity_caseTag_get SET
    identity = {
        name: "get",
        slug: "elasticsecurity_caseTag_get",
        display_name_i18n: i18n_key:tool_elasticsecurity_caseTag_get_name,
        description_i18n: i18n_key:tool_elasticsecurity_caseTag_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 517,
        tooltip_i18n: i18n_key:tool_elasticsecurity_caseTag_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_elasticsecurity_caseTag_get_success,
        error_message_i18n: i18n_key:tool_elasticsecurity_caseTag_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:elasticsecurity_caseTag,
    is_active: true;

CREATE tool:elasticsecurity_caseTag_getMany SET
    identity = {
        name: "getMany",
        slug: "elasticsecurity_caseTag_getMany",
        display_name_i18n: i18n_key:tool_elasticsecurity_caseTag_getMany_name,
        description_i18n: i18n_key:tool_elasticsecurity_caseTag_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 518,
        tooltip_i18n: i18n_key:tool_elasticsecurity_caseTag_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_elasticsecurity_caseTag_getMany_success,
        error_message_i18n: i18n_key:tool_elasticsecurity_caseTag_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:elasticsecurity_caseTag,
    is_active: true;

CREATE tool:elasticsecurity_connector_get SET
    identity = {
        name: "get",
        slug: "elasticsecurity_connector_get",
        display_name_i18n: i18n_key:tool_elasticsecurity_connector_get_name,
        description_i18n: i18n_key:tool_elasticsecurity_connector_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 519,
        tooltip_i18n: i18n_key:tool_elasticsecurity_connector_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_elasticsecurity_connector_get_success,
        error_message_i18n: i18n_key:tool_elasticsecurity_connector_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:elasticsecurity_connector,
    is_active: true;

CREATE tool:elasticsecurity_connector_getMany SET
    identity = {
        name: "getMany",
        slug: "elasticsecurity_connector_getMany",
        display_name_i18n: i18n_key:tool_elasticsecurity_connector_getMany_name,
        description_i18n: i18n_key:tool_elasticsecurity_connector_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 520,
        tooltip_i18n: i18n_key:tool_elasticsecurity_connector_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_elasticsecurity_connector_getMany_success,
        error_message_i18n: i18n_key:tool_elasticsecurity_connector_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:elasticsecurity_connector,
    is_active: true;

CREATE tool:emailreadimap_emailreadimap_get SET
    identity = {
        name: "get",
        slug: "emailreadimap_emailreadimap_get",
        display_name_i18n: i18n_key:tool_emailreadimap_emailreadimap_get_name,
        description_i18n: i18n_key:tool_emailreadimap_emailreadimap_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 521,
        tooltip_i18n: i18n_key:tool_emailreadimap_emailreadimap_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_emailreadimap_emailreadimap_get_success,
        error_message_i18n: i18n_key:tool_emailreadimap_emailreadimap_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:emailreadimap_emailreadimap,
    is_active: true;

CREATE tool:emailreadimap_emailreadimap_getMany SET
    identity = {
        name: "getMany",
        slug: "emailreadimap_emailreadimap_getMany",
        display_name_i18n: i18n_key:tool_emailreadimap_emailreadimap_getMany_name,
        description_i18n: i18n_key:tool_emailreadimap_emailreadimap_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 522,
        tooltip_i18n: i18n_key:tool_emailreadimap_emailreadimap_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_emailreadimap_emailreadimap_getMany_success,
        error_message_i18n: i18n_key:tool_emailreadimap_emailreadimap_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:emailreadimap_emailreadimap,
    is_active: true;

CREATE tool:emailreadimapv1_emailreadimapv1_get SET
    identity = {
        name: "get",
        slug: "emailreadimapv1_emailreadimapv1_get",
        display_name_i18n: i18n_key:tool_emailreadimapv1_emailreadimapv1_get_name,
        description_i18n: i18n_key:tool_emailreadimapv1_emailreadimapv1_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 523,
        tooltip_i18n: i18n_key:tool_emailreadimapv1_emailreadimapv1_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_emailreadimapv1_emailreadimapv1_get_success,
        error_message_i18n: i18n_key:tool_emailreadimapv1_emailreadimapv1_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:emailreadimapv1_emailreadimapv1,
    is_active: true;

CREATE tool:emailreadimapv1_emailreadimapv1_getMany SET
    identity = {
        name: "getMany",
        slug: "emailreadimapv1_emailreadimapv1_getMany",
        display_name_i18n: i18n_key:tool_emailreadimapv1_emailreadimapv1_getMany_name,
        description_i18n: i18n_key:tool_emailreadimapv1_emailreadimapv1_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 524,
        tooltip_i18n: i18n_key:tool_emailreadimapv1_emailreadimapv1_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_emailreadimapv1_emailreadimapv1_getMany_success,
        error_message_i18n: i18n_key:tool_emailreadimapv1_emailreadimapv1_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:emailreadimapv1_emailreadimapv1,
    is_active: true;

CREATE tool:emailreadimapv2_emailreadimapv2_get SET
    identity = {
        name: "get",
        slug: "emailreadimapv2_emailreadimapv2_get",
        display_name_i18n: i18n_key:tool_emailreadimapv2_emailreadimapv2_get_name,
        description_i18n: i18n_key:tool_emailreadimapv2_emailreadimapv2_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 525,
        tooltip_i18n: i18n_key:tool_emailreadimapv2_emailreadimapv2_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_emailreadimapv2_emailreadimapv2_get_success,
        error_message_i18n: i18n_key:tool_emailreadimapv2_emailreadimapv2_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:emailreadimapv2_emailreadimapv2,
    is_active: true;

CREATE tool:emailreadimapv2_emailreadimapv2_getMany SET
    identity = {
        name: "getMany",
        slug: "emailreadimapv2_emailreadimapv2_getMany",
        display_name_i18n: i18n_key:tool_emailreadimapv2_emailreadimapv2_getMany_name,
        description_i18n: i18n_key:tool_emailreadimapv2_emailreadimapv2_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 526,
        tooltip_i18n: i18n_key:tool_emailreadimapv2_emailreadimapv2_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_emailreadimapv2_emailreadimapv2_getMany_success,
        error_message_i18n: i18n_key:tool_emailreadimapv2_emailreadimapv2_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:emailreadimapv2_emailreadimapv2,
    is_active: true;

CREATE tool:emailsend_emailsend_get SET
    identity = {
        name: "get",
        slug: "emailsend_emailsend_get",
        display_name_i18n: i18n_key:tool_emailsend_emailsend_get_name,
        description_i18n: i18n_key:tool_emailsend_emailsend_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 527,
        tooltip_i18n: i18n_key:tool_emailsend_emailsend_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_emailsend_emailsend_get_success,
        error_message_i18n: i18n_key:tool_emailsend_emailsend_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:emailsend_emailsend,
    is_active: true;

CREATE tool:emailsend_emailsend_getMany SET
    identity = {
        name: "getMany",
        slug: "emailsend_emailsend_getMany",
        display_name_i18n: i18n_key:tool_emailsend_emailsend_getMany_name,
        description_i18n: i18n_key:tool_emailsend_emailsend_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 528,
        tooltip_i18n: i18n_key:tool_emailsend_emailsend_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_emailsend_emailsend_getMany_success,
        error_message_i18n: i18n_key:tool_emailsend_emailsend_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:emailsend_emailsend,
    is_active: true;

CREATE tool:emailsendv1_emailsendv1_get SET
    identity = {
        name: "get",
        slug: "emailsendv1_emailsendv1_get",
        display_name_i18n: i18n_key:tool_emailsendv1_emailsendv1_get_name,
        description_i18n: i18n_key:tool_emailsendv1_emailsendv1_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 529,
        tooltip_i18n: i18n_key:tool_emailsendv1_emailsendv1_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_emailsendv1_emailsendv1_get_success,
        error_message_i18n: i18n_key:tool_emailsendv1_emailsendv1_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:emailsendv1_emailsendv1,
    is_active: true;

CREATE tool:emailsendv1_emailsendv1_getMany SET
    identity = {
        name: "getMany",
        slug: "emailsendv1_emailsendv1_getMany",
        display_name_i18n: i18n_key:tool_emailsendv1_emailsendv1_getMany_name,
        description_i18n: i18n_key:tool_emailsendv1_emailsendv1_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 530,
        tooltip_i18n: i18n_key:tool_emailsendv1_emailsendv1_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_emailsendv1_emailsendv1_getMany_success,
        error_message_i18n: i18n_key:tool_emailsendv1_emailsendv1_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:emailsendv1_emailsendv1,
    is_active: true;

CREATE tool:emailsendv2_email_send SET
    identity = {
        name: "send",
        slug: "emailsendv2_email_send",
        display_name_i18n: i18n_key:tool_emailsendv2_email_send_name,
        description_i18n: i18n_key:tool_emailsendv2_email_send_desc,
        operation_type: "upload",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#8BC34A",
        display_order: 531,
        tooltip_i18n: i18n_key:tool_emailsendv2_email_send_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_emailsendv2_email_send_success,
        error_message_i18n: i18n_key:tool_emailsendv2_email_send_error,
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
    resource_id: resource:emailsendv2_email,
    is_active: true;

CREATE tool:emelia_campaign_get SET
    identity = {
        name: "get",
        slug: "emelia_campaign_get",
        display_name_i18n: i18n_key:tool_emelia_campaign_get_name,
        description_i18n: i18n_key:tool_emelia_campaign_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 532,
        tooltip_i18n: i18n_key:tool_emelia_campaign_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_emelia_campaign_get_success,
        error_message_i18n: i18n_key:tool_emelia_campaign_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:emelia_campaign,
    is_active: true;

CREATE tool:emelia_campaign_getMany SET
    identity = {
        name: "getMany",
        slug: "emelia_campaign_getMany",
        display_name_i18n: i18n_key:tool_emelia_campaign_getMany_name,
        description_i18n: i18n_key:tool_emelia_campaign_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 533,
        tooltip_i18n: i18n_key:tool_emelia_campaign_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_emelia_campaign_getMany_success,
        error_message_i18n: i18n_key:tool_emelia_campaign_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:emelia_campaign,
    is_active: true;

CREATE tool:emelia_contactList_get SET
    identity = {
        name: "get",
        slug: "emelia_contactList_get",
        display_name_i18n: i18n_key:tool_emelia_contactList_get_name,
        description_i18n: i18n_key:tool_emelia_contactList_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 534,
        tooltip_i18n: i18n_key:tool_emelia_contactList_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_emelia_contactList_get_success,
        error_message_i18n: i18n_key:tool_emelia_contactList_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:emelia_contactList,
    is_active: true;

CREATE tool:emelia_contactList_getMany SET
    identity = {
        name: "getMany",
        slug: "emelia_contactList_getMany",
        display_name_i18n: i18n_key:tool_emelia_contactList_getMany_name,
        description_i18n: i18n_key:tool_emelia_contactList_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 535,
        tooltip_i18n: i18n_key:tool_emelia_contactList_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_emelia_contactList_getMany_success,
        error_message_i18n: i18n_key:tool_emelia_contactList_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:emelia_contactList,
    is_active: true;

CREATE tool:emelia_contactlist_get SET
    identity = {
        name: "get",
        slug: "emelia_contactlist_get",
        display_name_i18n: i18n_key:tool_emelia_contactlist_get_name,
        description_i18n: i18n_key:tool_emelia_contactlist_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 536,
        tooltip_i18n: i18n_key:tool_emelia_contactlist_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_emelia_contactlist_get_success,
        error_message_i18n: i18n_key:tool_emelia_contactlist_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:emelia_contactlist,
    is_active: true;

CREATE tool:emelia_contactlist_getMany SET
    identity = {
        name: "getMany",
        slug: "emelia_contactlist_getMany",
        display_name_i18n: i18n_key:tool_emelia_contactlist_getMany_name,
        description_i18n: i18n_key:tool_emelia_contactlist_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 537,
        tooltip_i18n: i18n_key:tool_emelia_contactlist_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_emelia_contactlist_getMany_success,
        error_message_i18n: i18n_key:tool_emelia_contactlist_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:emelia_contactlist,
    is_active: true;

CREATE tool:erpnext_document_get SET
    identity = {
        name: "get",
        slug: "erpnext_document_get",
        display_name_i18n: i18n_key:tool_erpnext_document_get_name,
        description_i18n: i18n_key:tool_erpnext_document_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 538,
        tooltip_i18n: i18n_key:tool_erpnext_document_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_erpnext_document_get_success,
        error_message_i18n: i18n_key:tool_erpnext_document_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:erpnext_document,
    is_active: true;

CREATE tool:erpnext_document_getMany SET
    identity = {
        name: "getMany",
        slug: "erpnext_document_getMany",
        display_name_i18n: i18n_key:tool_erpnext_document_getMany_name,
        description_i18n: i18n_key:tool_erpnext_document_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 539,
        tooltip_i18n: i18n_key:tool_erpnext_document_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_erpnext_document_getMany_success,
        error_message_i18n: i18n_key:tool_erpnext_document_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:erpnext_document,
    is_active: true;

CREATE tool:description_description_get SET
    identity = {
        name: "get",
        slug: "description_description_get",
        display_name_i18n: i18n_key:tool_description_description_get_name,
        description_i18n: i18n_key:tool_description_description_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 540,
        tooltip_i18n: i18n_key:tool_description_description_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_description_description_get_success,
        error_message_i18n: i18n_key:tool_description_description_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:description_description,
    is_active: true;

CREATE tool:description_description_getMany SET
    identity = {
        name: "getMany",
        slug: "description_description_getMany",
        display_name_i18n: i18n_key:tool_description_description_getMany_name,
        description_i18n: i18n_key:tool_description_description_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 541,
        tooltip_i18n: i18n_key:tool_description_description_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_description_description_getMany_success,
        error_message_i18n: i18n_key:tool_description_description_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:description_description,
    is_active: true;

CREATE tool:executecommand_executecommand_get SET
    identity = {
        name: "get",
        slug: "executecommand_executecommand_get",
        display_name_i18n: i18n_key:tool_executecommand_executecommand_get_name,
        description_i18n: i18n_key:tool_executecommand_executecommand_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 542,
        tooltip_i18n: i18n_key:tool_executecommand_executecommand_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_executecommand_executecommand_get_success,
        error_message_i18n: i18n_key:tool_executecommand_executecommand_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:executecommand_executecommand,
    is_active: true;

CREATE tool:executecommand_executecommand_getMany SET
    identity = {
        name: "getMany",
        slug: "executecommand_executecommand_getMany",
        display_name_i18n: i18n_key:tool_executecommand_executecommand_getMany_name,
        description_i18n: i18n_key:tool_executecommand_executecommand_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 543,
        tooltip_i18n: i18n_key:tool_executecommand_executecommand_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_executecommand_executecommand_getMany_success,
        error_message_i18n: i18n_key:tool_executecommand_executecommand_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:executecommand_executecommand,
    is_active: true;

CREATE tool:executeworkflow_executeworkflow_call_workflow SET
    identity = {
        name: "call_workflow",
        slug: "executeworkflow_executeworkflow_call_workflow",
        display_name_i18n: i18n_key:tool_executeworkflow_executeworkflow_call_workflow_name,
        description_i18n: i18n_key:tool_executeworkflow_executeworkflow_call_workflow_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 544,
        tooltip_i18n: i18n_key:tool_executeworkflow_executeworkflow_call_workflow_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_executeworkflow_executeworkflow_call_workflow_success,
        error_message_i18n: i18n_key:tool_executeworkflow_executeworkflow_call_workflow_error,
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
    resource_id: resource:executeworkflow_executeworkflow,
    is_active: true;

CREATE tool:executiondata_executiondata_save SET
    identity = {
        name: "save",
        slug: "executiondata_executiondata_save",
        display_name_i18n: i18n_key:tool_executiondata_executiondata_save_name,
        description_i18n: i18n_key:tool_executiondata_executiondata_save_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 545,
        tooltip_i18n: i18n_key:tool_executiondata_executiondata_save_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_executiondata_executiondata_save_success,
        error_message_i18n: i18n_key:tool_executiondata_executiondata_save_error,
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
    resource_id: resource:executiondata_executiondata,
    is_active: true;

CREATE tool:facebookgraphapi_facebookgraphapi_get SET
    identity = {
        name: "get",
        slug: "facebookgraphapi_facebookgraphapi_get",
        display_name_i18n: i18n_key:tool_facebookgraphapi_facebookgraphapi_get_name,
        description_i18n: i18n_key:tool_facebookgraphapi_facebookgraphapi_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 546,
        tooltip_i18n: i18n_key:tool_facebookgraphapi_facebookgraphapi_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_facebookgraphapi_facebookgraphapi_get_success,
        error_message_i18n: i18n_key:tool_facebookgraphapi_facebookgraphapi_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:facebookgraphapi_facebookgraphapi,
    is_active: true;

CREATE tool:facebookgraphapi_facebookgraphapi_getMany SET
    identity = {
        name: "getMany",
        slug: "facebookgraphapi_facebookgraphapi_getMany",
        display_name_i18n: i18n_key:tool_facebookgraphapi_facebookgraphapi_getMany_name,
        description_i18n: i18n_key:tool_facebookgraphapi_facebookgraphapi_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 547,
        tooltip_i18n: i18n_key:tool_facebookgraphapi_facebookgraphapi_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_facebookgraphapi_facebookgraphapi_getMany_success,
        error_message_i18n: i18n_key:tool_facebookgraphapi_facebookgraphapi_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:facebookgraphapi_facebookgraphapi,
    is_active: true;

CREATE tool:filemaker_filemaker_get SET
    identity = {
        name: "get",
        slug: "filemaker_filemaker_get",
        display_name_i18n: i18n_key:tool_filemaker_filemaker_get_name,
        description_i18n: i18n_key:tool_filemaker_filemaker_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 548,
        tooltip_i18n: i18n_key:tool_filemaker_filemaker_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_filemaker_filemaker_get_success,
        error_message_i18n: i18n_key:tool_filemaker_filemaker_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:filemaker_filemaker,
    is_active: true;

CREATE tool:filemaker_filemaker_getMany SET
    identity = {
        name: "getMany",
        slug: "filemaker_filemaker_getMany",
        display_name_i18n: i18n_key:tool_filemaker_filemaker_getMany_name,
        description_i18n: i18n_key:tool_filemaker_filemaker_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 549,
        tooltip_i18n: i18n_key:tool_filemaker_filemaker_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_filemaker_filemaker_getMany_success,
        error_message_i18n: i18n_key:tool_filemaker_filemaker_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:filemaker_filemaker,
    is_active: true;

CREATE tool:converttofile_converttofile_csv SET
    identity = {
        name: "csv",
        slug: "converttofile_converttofile_csv",
        display_name_i18n: i18n_key:tool_converttofile_converttofile_csv_name,
        description_i18n: i18n_key:tool_converttofile_converttofile_csv_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 550,
        tooltip_i18n: i18n_key:tool_converttofile_converttofile_csv_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_converttofile_converttofile_csv_success,
        error_message_i18n: i18n_key:tool_converttofile_converttofile_csv_error,
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
    resource_id: resource:converttofile_converttofile,
    is_active: true;

CREATE tool:converttofile_converttofile_html SET
    identity = {
        name: "html",
        slug: "converttofile_converttofile_html",
        display_name_i18n: i18n_key:tool_converttofile_converttofile_html_name,
        description_i18n: i18n_key:tool_converttofile_converttofile_html_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 551,
        tooltip_i18n: i18n_key:tool_converttofile_converttofile_html_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_converttofile_converttofile_html_success,
        error_message_i18n: i18n_key:tool_converttofile_converttofile_html_error,
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
    resource_id: resource:converttofile_converttofile,
    is_active: true;

CREATE tool:converttofile_converttofile_iCal SET
    identity = {
        name: "iCal",
        slug: "converttofile_converttofile_iCal",
        display_name_i18n: i18n_key:tool_converttofile_converttofile_iCal_name,
        description_i18n: i18n_key:tool_converttofile_converttofile_iCal_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 552,
        tooltip_i18n: i18n_key:tool_converttofile_converttofile_iCal_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_converttofile_converttofile_iCal_success,
        error_message_i18n: i18n_key:tool_converttofile_converttofile_iCal_error,
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
    resource_id: resource:converttofile_converttofile,
    is_active: true;

CREATE tool:converttofile_converttofile_toJson SET
    identity = {
        name: "toJson",
        slug: "converttofile_converttofile_toJson",
        display_name_i18n: i18n_key:tool_converttofile_converttofile_toJson_name,
        description_i18n: i18n_key:tool_converttofile_converttofile_toJson_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 553,
        tooltip_i18n: i18n_key:tool_converttofile_converttofile_toJson_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_converttofile_converttofile_toJson_success,
        error_message_i18n: i18n_key:tool_converttofile_converttofile_toJson_error,
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
    resource_id: resource:converttofile_converttofile,
    is_active: true;

CREATE tool:converttofile_converttofile_ods SET
    identity = {
        name: "ods",
        slug: "converttofile_converttofile_ods",
        display_name_i18n: i18n_key:tool_converttofile_converttofile_ods_name,
        description_i18n: i18n_key:tool_converttofile_converttofile_ods_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 554,
        tooltip_i18n: i18n_key:tool_converttofile_converttofile_ods_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_converttofile_converttofile_ods_success,
        error_message_i18n: i18n_key:tool_converttofile_converttofile_ods_error,
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
    resource_id: resource:converttofile_converttofile,
    is_active: true;

CREATE tool:converttofile_converttofile_rtf SET
    identity = {
        name: "rtf",
        slug: "converttofile_converttofile_rtf",
        display_name_i18n: i18n_key:tool_converttofile_converttofile_rtf_name,
        description_i18n: i18n_key:tool_converttofile_converttofile_rtf_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 555,
        tooltip_i18n: i18n_key:tool_converttofile_converttofile_rtf_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_converttofile_converttofile_rtf_success,
        error_message_i18n: i18n_key:tool_converttofile_converttofile_rtf_error,
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
    resource_id: resource:converttofile_converttofile,
    is_active: true;

CREATE tool:converttofile_converttofile_toText SET
    identity = {
        name: "toText",
        slug: "converttofile_converttofile_toText",
        display_name_i18n: i18n_key:tool_converttofile_converttofile_toText_name,
        description_i18n: i18n_key:tool_converttofile_converttofile_toText_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 556,
        tooltip_i18n: i18n_key:tool_converttofile_converttofile_toText_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_converttofile_converttofile_toText_success,
        error_message_i18n: i18n_key:tool_converttofile_converttofile_toText_error,
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
    resource_id: resource:converttofile_converttofile,
    is_active: true;

CREATE tool:converttofile_converttofile_xls SET
    identity = {
        name: "xls",
        slug: "converttofile_converttofile_xls",
        display_name_i18n: i18n_key:tool_converttofile_converttofile_xls_name,
        description_i18n: i18n_key:tool_converttofile_converttofile_xls_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 557,
        tooltip_i18n: i18n_key:tool_converttofile_converttofile_xls_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_converttofile_converttofile_xls_success,
        error_message_i18n: i18n_key:tool_converttofile_converttofile_xls_error,
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
    resource_id: resource:converttofile_converttofile,
    is_active: true;

CREATE tool:converttofile_converttofile_xlsx SET
    identity = {
        name: "xlsx",
        slug: "converttofile_converttofile_xlsx",
        display_name_i18n: i18n_key:tool_converttofile_converttofile_xlsx_name,
        description_i18n: i18n_key:tool_converttofile_converttofile_xlsx_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 558,
        tooltip_i18n: i18n_key:tool_converttofile_converttofile_xlsx_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_converttofile_converttofile_xlsx_success,
        error_message_i18n: i18n_key:tool_converttofile_converttofile_xlsx_error,
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
    resource_id: resource:converttofile_converttofile,
    is_active: true;

CREATE tool:converttofile_converttofile_toBinary SET
    identity = {
        name: "toBinary",
        slug: "converttofile_converttofile_toBinary",
        display_name_i18n: i18n_key:tool_converttofile_converttofile_toBinary_name,
        description_i18n: i18n_key:tool_converttofile_converttofile_toBinary_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 559,
        tooltip_i18n: i18n_key:tool_converttofile_converttofile_toBinary_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_converttofile_converttofile_toBinary_success,
        error_message_i18n: i18n_key:tool_converttofile_converttofile_toBinary_error,
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
    resource_id: resource:converttofile_converttofile,
    is_active: true;

CREATE tool:extractfromfile_extractfromfile_csv SET
    identity = {
        name: "csv",
        slug: "extractfromfile_extractfromfile_csv",
        display_name_i18n: i18n_key:tool_extractfromfile_extractfromfile_csv_name,
        description_i18n: i18n_key:tool_extractfromfile_extractfromfile_csv_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 560,
        tooltip_i18n: i18n_key:tool_extractfromfile_extractfromfile_csv_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_extractfromfile_extractfromfile_csv_success,
        error_message_i18n: i18n_key:tool_extractfromfile_extractfromfile_csv_error,
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
    resource_id: resource:extractfromfile_extractfromfile,
    is_active: true;

CREATE tool:extractfromfile_extractfromfile_html SET
    identity = {
        name: "html",
        slug: "extractfromfile_extractfromfile_html",
        display_name_i18n: i18n_key:tool_extractfromfile_extractfromfile_html_name,
        description_i18n: i18n_key:tool_extractfromfile_extractfromfile_html_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 561,
        tooltip_i18n: i18n_key:tool_extractfromfile_extractfromfile_html_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_extractfromfile_extractfromfile_html_success,
        error_message_i18n: i18n_key:tool_extractfromfile_extractfromfile_html_error,
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
    resource_id: resource:extractfromfile_extractfromfile,
    is_active: true;

CREATE tool:extractfromfile_extractfromfile_fromIcs SET
    identity = {
        name: "fromIcs",
        slug: "extractfromfile_extractfromfile_fromIcs",
        display_name_i18n: i18n_key:tool_extractfromfile_extractfromfile_fromIcs_name,
        description_i18n: i18n_key:tool_extractfromfile_extractfromfile_fromIcs_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 562,
        tooltip_i18n: i18n_key:tool_extractfromfile_extractfromfile_fromIcs_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_extractfromfile_extractfromfile_fromIcs_success,
        error_message_i18n: i18n_key:tool_extractfromfile_extractfromfile_fromIcs_error,
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
    resource_id: resource:extractfromfile_extractfromfile,
    is_active: true;

CREATE tool:extractfromfile_extractfromfile_fromJson SET
    identity = {
        name: "fromJson",
        slug: "extractfromfile_extractfromfile_fromJson",
        display_name_i18n: i18n_key:tool_extractfromfile_extractfromfile_fromJson_name,
        description_i18n: i18n_key:tool_extractfromfile_extractfromfile_fromJson_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 563,
        tooltip_i18n: i18n_key:tool_extractfromfile_extractfromfile_fromJson_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_extractfromfile_extractfromfile_fromJson_success,
        error_message_i18n: i18n_key:tool_extractfromfile_extractfromfile_fromJson_error,
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
    resource_id: resource:extractfromfile_extractfromfile,
    is_active: true;

CREATE tool:extractfromfile_extractfromfile_ods SET
    identity = {
        name: "ods",
        slug: "extractfromfile_extractfromfile_ods",
        display_name_i18n: i18n_key:tool_extractfromfile_extractfromfile_ods_name,
        description_i18n: i18n_key:tool_extractfromfile_extractfromfile_ods_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 564,
        tooltip_i18n: i18n_key:tool_extractfromfile_extractfromfile_ods_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_extractfromfile_extractfromfile_ods_success,
        error_message_i18n: i18n_key:tool_extractfromfile_extractfromfile_ods_error,
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
    resource_id: resource:extractfromfile_extractfromfile,
    is_active: true;

CREATE tool:extractfromfile_extractfromfile_pdf SET
    identity = {
        name: "pdf",
        slug: "extractfromfile_extractfromfile_pdf",
        display_name_i18n: i18n_key:tool_extractfromfile_extractfromfile_pdf_name,
        description_i18n: i18n_key:tool_extractfromfile_extractfromfile_pdf_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 565,
        tooltip_i18n: i18n_key:tool_extractfromfile_extractfromfile_pdf_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_extractfromfile_extractfromfile_pdf_success,
        error_message_i18n: i18n_key:tool_extractfromfile_extractfromfile_pdf_error,
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
    resource_id: resource:extractfromfile_extractfromfile,
    is_active: true;

CREATE tool:extractfromfile_extractfromfile_rtf SET
    identity = {
        name: "rtf",
        slug: "extractfromfile_extractfromfile_rtf",
        display_name_i18n: i18n_key:tool_extractfromfile_extractfromfile_rtf_name,
        description_i18n: i18n_key:tool_extractfromfile_extractfromfile_rtf_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 566,
        tooltip_i18n: i18n_key:tool_extractfromfile_extractfromfile_rtf_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_extractfromfile_extractfromfile_rtf_success,
        error_message_i18n: i18n_key:tool_extractfromfile_extractfromfile_rtf_error,
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
    resource_id: resource:extractfromfile_extractfromfile,
    is_active: true;

CREATE tool:extractfromfile_extractfromfile_text SET
    identity = {
        name: "text",
        slug: "extractfromfile_extractfromfile_text",
        display_name_i18n: i18n_key:tool_extractfromfile_extractfromfile_text_name,
        description_i18n: i18n_key:tool_extractfromfile_extractfromfile_text_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 567,
        tooltip_i18n: i18n_key:tool_extractfromfile_extractfromfile_text_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_extractfromfile_extractfromfile_text_success,
        error_message_i18n: i18n_key:tool_extractfromfile_extractfromfile_text_error,
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
    resource_id: resource:extractfromfile_extractfromfile,
    is_active: true;

CREATE tool:extractfromfile_extractfromfile_xml SET
    identity = {
        name: "xml",
        slug: "extractfromfile_extractfromfile_xml",
        display_name_i18n: i18n_key:tool_extractfromfile_extractfromfile_xml_name,
        description_i18n: i18n_key:tool_extractfromfile_extractfromfile_xml_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 568,
        tooltip_i18n: i18n_key:tool_extractfromfile_extractfromfile_xml_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_extractfromfile_extractfromfile_xml_success,
        error_message_i18n: i18n_key:tool_extractfromfile_extractfromfile_xml_error,
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
    resource_id: resource:extractfromfile_extractfromfile,
    is_active: true;

CREATE tool:extractfromfile_extractfromfile_xls SET
    identity = {
        name: "xls",
        slug: "extractfromfile_extractfromfile_xls",
        display_name_i18n: i18n_key:tool_extractfromfile_extractfromfile_xls_name,
        description_i18n: i18n_key:tool_extractfromfile_extractfromfile_xls_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 569,
        tooltip_i18n: i18n_key:tool_extractfromfile_extractfromfile_xls_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_extractfromfile_extractfromfile_xls_success,
        error_message_i18n: i18n_key:tool_extractfromfile_extractfromfile_xls_error,
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
    resource_id: resource:extractfromfile_extractfromfile,
    is_active: true;

CREATE tool:extractfromfile_extractfromfile_xlsx SET
    identity = {
        name: "xlsx",
        slug: "extractfromfile_extractfromfile_xlsx",
        display_name_i18n: i18n_key:tool_extractfromfile_extractfromfile_xlsx_name,
        description_i18n: i18n_key:tool_extractfromfile_extractfromfile_xlsx_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 570,
        tooltip_i18n: i18n_key:tool_extractfromfile_extractfromfile_xlsx_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_extractfromfile_extractfromfile_xlsx_success,
        error_message_i18n: i18n_key:tool_extractfromfile_extractfromfile_xlsx_error,
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
    resource_id: resource:extractfromfile_extractfromfile,
    is_active: true;

CREATE tool:extractfromfile_extractfromfile_binaryToPropery SET
    identity = {
        name: "binaryToPropery",
        slug: "extractfromfile_extractfromfile_binaryToPropery",
        display_name_i18n: i18n_key:tool_extractfromfile_extractfromfile_binaryToPropery_name,
        description_i18n: i18n_key:tool_extractfromfile_extractfromfile_binaryToPropery_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 571,
        tooltip_i18n: i18n_key:tool_extractfromfile_extractfromfile_binaryToPropery_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_extractfromfile_extractfromfile_binaryToPropery_success,
        error_message_i18n: i18n_key:tool_extractfromfile_extractfromfile_binaryToPropery_error,
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
    resource_id: resource:extractfromfile_extractfromfile,
    is_active: true;

CREATE tool:readwritefile_readwritefile_read SET
    identity = {
        name: "read",
        slug: "readwritefile_readwritefile_read",
        display_name_i18n: i18n_key:tool_readwritefile_readwritefile_read_name,
        description_i18n: i18n_key:tool_readwritefile_readwritefile_read_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 572,
        tooltip_i18n: i18n_key:tool_readwritefile_readwritefile_read_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_readwritefile_readwritefile_read_success,
        error_message_i18n: i18n_key:tool_readwritefile_readwritefile_read_error,
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
    resource_id: resource:readwritefile_readwritefile,
    is_active: true;

CREATE tool:readwritefile_readwritefile_write SET
    identity = {
        name: "write",
        slug: "readwritefile_readwritefile_write",
        display_name_i18n: i18n_key:tool_readwritefile_readwritefile_write_name,
        description_i18n: i18n_key:tool_readwritefile_readwritefile_write_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 573,
        tooltip_i18n: i18n_key:tool_readwritefile_readwritefile_write_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_readwritefile_readwritefile_write_success,
        error_message_i18n: i18n_key:tool_readwritefile_readwritefile_write_error,
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
    resource_id: resource:readwritefile_readwritefile,
    is_active: true;

CREATE tool:filter_filter_get SET
    identity = {
        name: "get",
        slug: "filter_filter_get",
        display_name_i18n: i18n_key:tool_filter_filter_get_name,
        description_i18n: i18n_key:tool_filter_filter_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 574,
        tooltip_i18n: i18n_key:tool_filter_filter_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_filter_filter_get_success,
        error_message_i18n: i18n_key:tool_filter_filter_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:filter_filter,
    is_active: true;

CREATE tool:filter_filter_getMany SET
    identity = {
        name: "getMany",
        slug: "filter_filter_getMany",
        display_name_i18n: i18n_key:tool_filter_filter_getMany_name,
        description_i18n: i18n_key:tool_filter_filter_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 575,
        tooltip_i18n: i18n_key:tool_filter_filter_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_filter_filter_getMany_success,
        error_message_i18n: i18n_key:tool_filter_filter_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:filter_filter,
    is_active: true;

CREATE tool:filterv1_filterv1_equal SET
    identity = {
        name: "equal",
        slug: "filterv1_filterv1_equal",
        display_name_i18n: i18n_key:tool_filterv1_filterv1_equal_name,
        description_i18n: i18n_key:tool_filterv1_filterv1_equal_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 576,
        tooltip_i18n: i18n_key:tool_filterv1_filterv1_equal_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_filterv1_filterv1_equal_success,
        error_message_i18n: i18n_key:tool_filterv1_filterv1_equal_error,
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
    resource_id: resource:filterv1_filterv1,
    is_active: true;

CREATE tool:filterv1_filterv1_notEqual SET
    identity = {
        name: "notEqual",
        slug: "filterv1_filterv1_notEqual",
        display_name_i18n: i18n_key:tool_filterv1_filterv1_notEqual_name,
        description_i18n: i18n_key:tool_filterv1_filterv1_notEqual_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 577,
        tooltip_i18n: i18n_key:tool_filterv1_filterv1_notEqual_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_filterv1_filterv1_notEqual_success,
        error_message_i18n: i18n_key:tool_filterv1_filterv1_notEqual_error,
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
    resource_id: resource:filterv1_filterv1,
    is_active: true;

CREATE tool:filterv2_filterv2_get SET
    identity = {
        name: "get",
        slug: "filterv2_filterv2_get",
        display_name_i18n: i18n_key:tool_filterv2_filterv2_get_name,
        description_i18n: i18n_key:tool_filterv2_filterv2_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 578,
        tooltip_i18n: i18n_key:tool_filterv2_filterv2_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_filterv2_filterv2_get_success,
        error_message_i18n: i18n_key:tool_filterv2_filterv2_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:filterv2_filterv2,
    is_active: true;

CREATE tool:filterv2_filterv2_getMany SET
    identity = {
        name: "getMany",
        slug: "filterv2_filterv2_getMany",
        display_name_i18n: i18n_key:tool_filterv2_filterv2_getMany_name,
        description_i18n: i18n_key:tool_filterv2_filterv2_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 579,
        tooltip_i18n: i18n_key:tool_filterv2_filterv2_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_filterv2_filterv2_getMany_success,
        error_message_i18n: i18n_key:tool_filterv2_filterv2_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:filterv2_filterv2,
    is_active: true;

CREATE tool:flow_task_get SET
    identity = {
        name: "get",
        slug: "flow_task_get",
        display_name_i18n: i18n_key:tool_flow_task_get_name,
        description_i18n: i18n_key:tool_flow_task_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 580,
        tooltip_i18n: i18n_key:tool_flow_task_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_flow_task_get_success,
        error_message_i18n: i18n_key:tool_flow_task_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:flow_task,
    is_active: true;

CREATE tool:flow_task_getMany SET
    identity = {
        name: "getMany",
        slug: "flow_task_getMany",
        display_name_i18n: i18n_key:tool_flow_task_getMany_name,
        description_i18n: i18n_key:tool_flow_task_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 581,
        tooltip_i18n: i18n_key:tool_flow_task_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_flow_task_getMany_success,
        error_message_i18n: i18n_key:tool_flow_task_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:flow_task,
    is_active: true;

CREATE tool:form_form_get SET
    identity = {
        name: "get",
        slug: "form_form_get",
        display_name_i18n: i18n_key:tool_form_form_get_name,
        description_i18n: i18n_key:tool_form_form_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 582,
        tooltip_i18n: i18n_key:tool_form_form_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_form_form_get_success,
        error_message_i18n: i18n_key:tool_form_form_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:form_form,
    is_active: true;

CREATE tool:form_form_getMany SET
    identity = {
        name: "getMany",
        slug: "form_form_getMany",
        display_name_i18n: i18n_key:tool_form_form_getMany_name,
        description_i18n: i18n_key:tool_form_form_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 583,
        tooltip_i18n: i18n_key:tool_form_form_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_form_form_getMany_success,
        error_message_i18n: i18n_key:tool_form_form_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:form_form,
    is_active: true;

CREATE tool:freshdesk_contact_create SET
    identity = {
        name: "create",
        slug: "freshdesk_contact_create",
        display_name_i18n: i18n_key:tool_freshdesk_contact_create_name,
        description_i18n: i18n_key:tool_freshdesk_contact_create_desc,
        operation_type: "create",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#4CAF50",
        display_order: 584,
        tooltip_i18n: i18n_key:tool_freshdesk_contact_create_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_freshdesk_contact_create_success,
        error_message_i18n: i18n_key:tool_freshdesk_contact_create_error,
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
    resource_id: resource:freshdesk_contact,
    is_active: true;

CREATE tool:freshdesk_contact_delete SET
    identity = {
        name: "delete",
        slug: "freshdesk_contact_delete",
        display_name_i18n: i18n_key:tool_freshdesk_contact_delete_name,
        description_i18n: i18n_key:tool_freshdesk_contact_delete_desc,
        operation_type: "delete",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#F44336",
        display_order: 585,
        tooltip_i18n: i18n_key:tool_freshdesk_contact_delete_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_freshdesk_contact_delete_success,
        error_message_i18n: i18n_key:tool_freshdesk_contact_delete_error,
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
    resource_id: resource:freshdesk_contact,
    is_active: true;

CREATE tool:freshdesk_contact_get SET
    identity = {
        name: "get",
        slug: "freshdesk_contact_get",
        display_name_i18n: i18n_key:tool_freshdesk_contact_get_name,
        description_i18n: i18n_key:tool_freshdesk_contact_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 586,
        tooltip_i18n: i18n_key:tool_freshdesk_contact_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_freshdesk_contact_get_success,
        error_message_i18n: i18n_key:tool_freshdesk_contact_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:freshdesk_contact,
    is_active: true;

CREATE tool:freshdesk_contact_getAll SET
    identity = {
        name: "getAll",
        slug: "freshdesk_contact_getAll",
        display_name_i18n: i18n_key:tool_freshdesk_contact_getAll_name,
        description_i18n: i18n_key:tool_freshdesk_contact_getAll_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 587,
        tooltip_i18n: i18n_key:tool_freshdesk_contact_getAll_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_freshdesk_contact_getAll_success,
        error_message_i18n: i18n_key:tool_freshdesk_contact_getAll_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:freshdesk_contact,
    is_active: true;

CREATE tool:freshdesk_contact_update SET
    identity = {
        name: "update",
        slug: "freshdesk_contact_update",
        display_name_i18n: i18n_key:tool_freshdesk_contact_update_name,
        description_i18n: i18n_key:tool_freshdesk_contact_update_desc,
        operation_type: "update",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#FF9800",
        display_order: 588,
        tooltip_i18n: i18n_key:tool_freshdesk_contact_update_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_freshdesk_contact_update_success,
        error_message_i18n: i18n_key:tool_freshdesk_contact_update_error,
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
    resource_id: resource:freshdesk_contact,
    is_active: true;

CREATE tool:freshdesk_ticket_create SET
    identity = {
        name: "create",
        slug: "freshdesk_ticket_create",
        display_name_i18n: i18n_key:tool_freshdesk_ticket_create_name,
        description_i18n: i18n_key:tool_freshdesk_ticket_create_desc,
        operation_type: "create",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#4CAF50",
        display_order: 589,
        tooltip_i18n: i18n_key:tool_freshdesk_ticket_create_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_freshdesk_ticket_create_success,
        error_message_i18n: i18n_key:tool_freshdesk_ticket_create_error,
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
    resource_id: resource:freshdesk_ticket,
    is_active: true;

CREATE tool:freshdesk_ticket_delete SET
    identity = {
        name: "delete",
        slug: "freshdesk_ticket_delete",
        display_name_i18n: i18n_key:tool_freshdesk_ticket_delete_name,
        description_i18n: i18n_key:tool_freshdesk_ticket_delete_desc,
        operation_type: "delete",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#F44336",
        display_order: 590,
        tooltip_i18n: i18n_key:tool_freshdesk_ticket_delete_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_freshdesk_ticket_delete_success,
        error_message_i18n: i18n_key:tool_freshdesk_ticket_delete_error,
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
    resource_id: resource:freshdesk_ticket,
    is_active: true;

CREATE tool:freshdesk_ticket_get SET
    identity = {
        name: "get",
        slug: "freshdesk_ticket_get",
        display_name_i18n: i18n_key:tool_freshdesk_ticket_get_name,
        description_i18n: i18n_key:tool_freshdesk_ticket_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 591,
        tooltip_i18n: i18n_key:tool_freshdesk_ticket_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_freshdesk_ticket_get_success,
        error_message_i18n: i18n_key:tool_freshdesk_ticket_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:freshdesk_ticket,
    is_active: true;

CREATE tool:freshdesk_ticket_getAll SET
    identity = {
        name: "getAll",
        slug: "freshdesk_ticket_getAll",
        display_name_i18n: i18n_key:tool_freshdesk_ticket_getAll_name,
        description_i18n: i18n_key:tool_freshdesk_ticket_getAll_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 592,
        tooltip_i18n: i18n_key:tool_freshdesk_ticket_getAll_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_freshdesk_ticket_getAll_success,
        error_message_i18n: i18n_key:tool_freshdesk_ticket_getAll_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:freshdesk_ticket,
    is_active: true;

CREATE tool:freshdesk_ticket_update SET
    identity = {
        name: "update",
        slug: "freshdesk_ticket_update",
        display_name_i18n: i18n_key:tool_freshdesk_ticket_update_name,
        description_i18n: i18n_key:tool_freshdesk_ticket_update_desc,
        operation_type: "update",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#FF9800",
        display_order: 593,
        tooltip_i18n: i18n_key:tool_freshdesk_ticket_update_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_freshdesk_ticket_update_success,
        error_message_i18n: i18n_key:tool_freshdesk_ticket_update_error,
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
    resource_id: resource:freshdesk_ticket,
    is_active: true;

CREATE tool:freshservice_agent_get SET
    identity = {
        name: "get",
        slug: "freshservice_agent_get",
        display_name_i18n: i18n_key:tool_freshservice_agent_get_name,
        description_i18n: i18n_key:tool_freshservice_agent_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 594,
        tooltip_i18n: i18n_key:tool_freshservice_agent_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_freshservice_agent_get_success,
        error_message_i18n: i18n_key:tool_freshservice_agent_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:freshservice_agent,
    is_active: true;

CREATE tool:freshservice_agent_getMany SET
    identity = {
        name: "getMany",
        slug: "freshservice_agent_getMany",
        display_name_i18n: i18n_key:tool_freshservice_agent_getMany_name,
        description_i18n: i18n_key:tool_freshservice_agent_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 595,
        tooltip_i18n: i18n_key:tool_freshservice_agent_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_freshservice_agent_getMany_success,
        error_message_i18n: i18n_key:tool_freshservice_agent_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:freshservice_agent,
    is_active: true;

CREATE tool:freshservice_agentGroup_get SET
    identity = {
        name: "get",
        slug: "freshservice_agentGroup_get",
        display_name_i18n: i18n_key:tool_freshservice_agentGroup_get_name,
        description_i18n: i18n_key:tool_freshservice_agentGroup_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 596,
        tooltip_i18n: i18n_key:tool_freshservice_agentGroup_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_freshservice_agentGroup_get_success,
        error_message_i18n: i18n_key:tool_freshservice_agentGroup_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:freshservice_agentGroup,
    is_active: true;

CREATE tool:freshservice_agentGroup_getMany SET
    identity = {
        name: "getMany",
        slug: "freshservice_agentGroup_getMany",
        display_name_i18n: i18n_key:tool_freshservice_agentGroup_getMany_name,
        description_i18n: i18n_key:tool_freshservice_agentGroup_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 597,
        tooltip_i18n: i18n_key:tool_freshservice_agentGroup_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_freshservice_agentGroup_getMany_success,
        error_message_i18n: i18n_key:tool_freshservice_agentGroup_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:freshservice_agentGroup,
    is_active: true;

CREATE tool:freshservice_agentRole_get SET
    identity = {
        name: "get",
        slug: "freshservice_agentRole_get",
        display_name_i18n: i18n_key:tool_freshservice_agentRole_get_name,
        description_i18n: i18n_key:tool_freshservice_agentRole_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 598,
        tooltip_i18n: i18n_key:tool_freshservice_agentRole_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_freshservice_agentRole_get_success,
        error_message_i18n: i18n_key:tool_freshservice_agentRole_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:freshservice_agentRole,
    is_active: true;

CREATE tool:freshservice_agentRole_getMany SET
    identity = {
        name: "getMany",
        slug: "freshservice_agentRole_getMany",
        display_name_i18n: i18n_key:tool_freshservice_agentRole_getMany_name,
        description_i18n: i18n_key:tool_freshservice_agentRole_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 599,
        tooltip_i18n: i18n_key:tool_freshservice_agentRole_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_freshservice_agentRole_getMany_success,
        error_message_i18n: i18n_key:tool_freshservice_agentRole_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:freshservice_agentRole,
    is_active: true;

CREATE tool:freshservice_announcement_get SET
    identity = {
        name: "get",
        slug: "freshservice_announcement_get",
        display_name_i18n: i18n_key:tool_freshservice_announcement_get_name,
        description_i18n: i18n_key:tool_freshservice_announcement_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 600,
        tooltip_i18n: i18n_key:tool_freshservice_announcement_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_freshservice_announcement_get_success,
        error_message_i18n: i18n_key:tool_freshservice_announcement_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:freshservice_announcement,
    is_active: true;

