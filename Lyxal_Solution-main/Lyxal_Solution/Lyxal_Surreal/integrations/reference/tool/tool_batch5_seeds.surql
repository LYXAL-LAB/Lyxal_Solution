-- Batch 5: 100 tools Lyxal

CREATE tool:customerio_campaign_get SET
    identity = {
        name: "get",
        slug: "customerio_campaign_get",
        display_name_i18n: i18n_key:tool_customerio_campaign_get_name,
        description_i18n: i18n_key:tool_customerio_campaign_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 401,
        tooltip_i18n: i18n_key:tool_customerio_campaign_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_customerio_campaign_get_success,
        error_message_i18n: i18n_key:tool_customerio_campaign_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:customerio_campaign,
    is_active: true;

CREATE tool:customerio_campaign_getMany SET
    identity = {
        name: "getMany",
        slug: "customerio_campaign_getMany",
        display_name_i18n: i18n_key:tool_customerio_campaign_getMany_name,
        description_i18n: i18n_key:tool_customerio_campaign_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 402,
        tooltip_i18n: i18n_key:tool_customerio_campaign_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_customerio_campaign_getMany_success,
        error_message_i18n: i18n_key:tool_customerio_campaign_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:customerio_campaign,
    is_active: true;

CREATE tool:customerio_segment_get SET
    identity = {
        name: "get",
        slug: "customerio_segment_get",
        display_name_i18n: i18n_key:tool_customerio_segment_get_name,
        description_i18n: i18n_key:tool_customerio_segment_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 403,
        tooltip_i18n: i18n_key:tool_customerio_segment_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_customerio_segment_get_success,
        error_message_i18n: i18n_key:tool_customerio_segment_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:customerio_segment,
    is_active: true;

CREATE tool:customerio_segment_getMany SET
    identity = {
        name: "getMany",
        slug: "customerio_segment_getMany",
        display_name_i18n: i18n_key:tool_customerio_segment_getMany_name,
        description_i18n: i18n_key:tool_customerio_segment_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 404,
        tooltip_i18n: i18n_key:tool_customerio_segment_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_customerio_segment_getMany_success,
        error_message_i18n: i18n_key:tool_customerio_segment_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:customerio_segment,
    is_active: true;

CREATE tool:datatable_row_get SET
    identity = {
        name: "get",
        slug: "datatable_row_get",
        display_name_i18n: i18n_key:tool_datatable_row_get_name,
        description_i18n: i18n_key:tool_datatable_row_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 405,
        tooltip_i18n: i18n_key:tool_datatable_row_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_datatable_row_get_success,
        error_message_i18n: i18n_key:tool_datatable_row_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:datatable_row,
    is_active: true;

CREATE tool:datatable_row_getMany SET
    identity = {
        name: "getMany",
        slug: "datatable_row_getMany",
        display_name_i18n: i18n_key:tool_datatable_row_getMany_name,
        description_i18n: i18n_key:tool_datatable_row_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 406,
        tooltip_i18n: i18n_key:tool_datatable_row_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_datatable_row_getMany_success,
        error_message_i18n: i18n_key:tool_datatable_row_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:datatable_row,
    is_active: true;

CREATE tool:datetime_datetime_get SET
    identity = {
        name: "get",
        slug: "datetime_datetime_get",
        display_name_i18n: i18n_key:tool_datetime_datetime_get_name,
        description_i18n: i18n_key:tool_datetime_datetime_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 407,
        tooltip_i18n: i18n_key:tool_datetime_datetime_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_datetime_datetime_get_success,
        error_message_i18n: i18n_key:tool_datetime_datetime_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:datetime_datetime,
    is_active: true;

CREATE tool:datetime_datetime_getMany SET
    identity = {
        name: "getMany",
        slug: "datetime_datetime_getMany",
        display_name_i18n: i18n_key:tool_datetime_datetime_getMany_name,
        description_i18n: i18n_key:tool_datetime_datetime_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 408,
        tooltip_i18n: i18n_key:tool_datetime_datetime_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_datetime_datetime_getMany_success,
        error_message_i18n: i18n_key:tool_datetime_datetime_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:datetime_datetime,
    is_active: true;

CREATE tool:datetimev1_datetimev1_get SET
    identity = {
        name: "get",
        slug: "datetimev1_datetimev1_get",
        display_name_i18n: i18n_key:tool_datetimev1_datetimev1_get_name,
        description_i18n: i18n_key:tool_datetimev1_datetimev1_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 409,
        tooltip_i18n: i18n_key:tool_datetimev1_datetimev1_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_datetimev1_datetimev1_get_success,
        error_message_i18n: i18n_key:tool_datetimev1_datetimev1_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:datetimev1_datetimev1,
    is_active: true;

CREATE tool:datetimev1_datetimev1_getMany SET
    identity = {
        name: "getMany",
        slug: "datetimev1_datetimev1_getMany",
        display_name_i18n: i18n_key:tool_datetimev1_datetimev1_getMany_name,
        description_i18n: i18n_key:tool_datetimev1_datetimev1_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 410,
        tooltip_i18n: i18n_key:tool_datetimev1_datetimev1_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_datetimev1_datetimev1_getMany_success,
        error_message_i18n: i18n_key:tool_datetimev1_datetimev1_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:datetimev1_datetimev1,
    is_active: true;

CREATE tool:datetimev2_addtodate_addToDate SET
    identity = {
        name: "addToDate",
        slug: "datetimev2_addtodate_addToDate",
        display_name_i18n: i18n_key:tool_datetimev2_addtodate_addToDate_name,
        description_i18n: i18n_key:tool_datetimev2_addtodate_addToDate_desc,
        operation_type: "create",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#4CAF50",
        display_order: 411,
        tooltip_i18n: i18n_key:tool_datetimev2_addtodate_addToDate_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_datetimev2_addtodate_addToDate_success,
        error_message_i18n: i18n_key:tool_datetimev2_addtodate_addToDate_error,
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
    resource_id: resource:datetimev2_addtodate,
    is_active: true;

CREATE tool:datetimev2_addtodate_extractDate SET
    identity = {
        name: "extractDate",
        slug: "datetimev2_addtodate_extractDate",
        display_name_i18n: i18n_key:tool_datetimev2_addtodate_extractDate_name,
        description_i18n: i18n_key:tool_datetimev2_addtodate_extractDate_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 412,
        tooltip_i18n: i18n_key:tool_datetimev2_addtodate_extractDate_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_datetimev2_addtodate_extractDate_success,
        error_message_i18n: i18n_key:tool_datetimev2_addtodate_extractDate_error,
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
    resource_id: resource:datetimev2_addtodate,
    is_active: true;

CREATE tool:datetimev2_addtodate_formatDate SET
    identity = {
        name: "formatDate",
        slug: "datetimev2_addtodate_formatDate",
        display_name_i18n: i18n_key:tool_datetimev2_addtodate_formatDate_name,
        description_i18n: i18n_key:tool_datetimev2_addtodate_formatDate_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 413,
        tooltip_i18n: i18n_key:tool_datetimev2_addtodate_formatDate_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_datetimev2_addtodate_formatDate_success,
        error_message_i18n: i18n_key:tool_datetimev2_addtodate_formatDate_error,
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
    resource_id: resource:datetimev2_addtodate,
    is_active: true;

CREATE tool:datetimev2_addtodate_getCurrentDate SET
    identity = {
        name: "getCurrentDate",
        slug: "datetimev2_addtodate_getCurrentDate",
        display_name_i18n: i18n_key:tool_datetimev2_addtodate_getCurrentDate_name,
        description_i18n: i18n_key:tool_datetimev2_addtodate_getCurrentDate_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 414,
        tooltip_i18n: i18n_key:tool_datetimev2_addtodate_getCurrentDate_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_datetimev2_addtodate_getCurrentDate_success,
        error_message_i18n: i18n_key:tool_datetimev2_addtodate_getCurrentDate_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:datetimev2_addtodate,
    is_active: true;

CREATE tool:datetimev2_addtodate_getTimeBetweenDates SET
    identity = {
        name: "getTimeBetweenDates",
        slug: "datetimev2_addtodate_getTimeBetweenDates",
        display_name_i18n: i18n_key:tool_datetimev2_addtodate_getTimeBetweenDates_name,
        description_i18n: i18n_key:tool_datetimev2_addtodate_getTimeBetweenDates_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 415,
        tooltip_i18n: i18n_key:tool_datetimev2_addtodate_getTimeBetweenDates_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_datetimev2_addtodate_getTimeBetweenDates_success,
        error_message_i18n: i18n_key:tool_datetimev2_addtodate_getTimeBetweenDates_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:datetimev2_addtodate,
    is_active: true;

CREATE tool:datetimev2_addtodate_roundDate SET
    identity = {
        name: "roundDate",
        slug: "datetimev2_addtodate_roundDate",
        display_name_i18n: i18n_key:tool_datetimev2_addtodate_roundDate_name,
        description_i18n: i18n_key:tool_datetimev2_addtodate_roundDate_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 416,
        tooltip_i18n: i18n_key:tool_datetimev2_addtodate_roundDate_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_datetimev2_addtodate_roundDate_success,
        error_message_i18n: i18n_key:tool_datetimev2_addtodate_roundDate_error,
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
    resource_id: resource:datetimev2_addtodate,
    is_active: true;

CREATE tool:datetimev2_addtodate_subtractFromDate SET
    identity = {
        name: "subtractFromDate",
        slug: "datetimev2_addtodate_subtractFromDate",
        display_name_i18n: i18n_key:tool_datetimev2_addtodate_subtractFromDate_name,
        description_i18n: i18n_key:tool_datetimev2_addtodate_subtractFromDate_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 417,
        tooltip_i18n: i18n_key:tool_datetimev2_addtodate_subtractFromDate_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_datetimev2_addtodate_subtractFromDate_success,
        error_message_i18n: i18n_key:tool_datetimev2_addtodate_subtractFromDate_error,
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
    resource_id: resource:datetimev2_addtodate,
    is_active: true;

CREATE tool:datetimev2_currentdate_addToDate SET
    identity = {
        name: "addToDate",
        slug: "datetimev2_currentdate_addToDate",
        display_name_i18n: i18n_key:tool_datetimev2_currentdate_addToDate_name,
        description_i18n: i18n_key:tool_datetimev2_currentdate_addToDate_desc,
        operation_type: "create",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#4CAF50",
        display_order: 418,
        tooltip_i18n: i18n_key:tool_datetimev2_currentdate_addToDate_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_datetimev2_currentdate_addToDate_success,
        error_message_i18n: i18n_key:tool_datetimev2_currentdate_addToDate_error,
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
    resource_id: resource:datetimev2_currentdate,
    is_active: true;

CREATE tool:datetimev2_currentdate_extractDate SET
    identity = {
        name: "extractDate",
        slug: "datetimev2_currentdate_extractDate",
        display_name_i18n: i18n_key:tool_datetimev2_currentdate_extractDate_name,
        description_i18n: i18n_key:tool_datetimev2_currentdate_extractDate_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 419,
        tooltip_i18n: i18n_key:tool_datetimev2_currentdate_extractDate_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_datetimev2_currentdate_extractDate_success,
        error_message_i18n: i18n_key:tool_datetimev2_currentdate_extractDate_error,
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
    resource_id: resource:datetimev2_currentdate,
    is_active: true;

CREATE tool:datetimev2_currentdate_formatDate SET
    identity = {
        name: "formatDate",
        slug: "datetimev2_currentdate_formatDate",
        display_name_i18n: i18n_key:tool_datetimev2_currentdate_formatDate_name,
        description_i18n: i18n_key:tool_datetimev2_currentdate_formatDate_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 420,
        tooltip_i18n: i18n_key:tool_datetimev2_currentdate_formatDate_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_datetimev2_currentdate_formatDate_success,
        error_message_i18n: i18n_key:tool_datetimev2_currentdate_formatDate_error,
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
    resource_id: resource:datetimev2_currentdate,
    is_active: true;

CREATE tool:datetimev2_currentdate_getCurrentDate SET
    identity = {
        name: "getCurrentDate",
        slug: "datetimev2_currentdate_getCurrentDate",
        display_name_i18n: i18n_key:tool_datetimev2_currentdate_getCurrentDate_name,
        description_i18n: i18n_key:tool_datetimev2_currentdate_getCurrentDate_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 421,
        tooltip_i18n: i18n_key:tool_datetimev2_currentdate_getCurrentDate_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_datetimev2_currentdate_getCurrentDate_success,
        error_message_i18n: i18n_key:tool_datetimev2_currentdate_getCurrentDate_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:datetimev2_currentdate,
    is_active: true;

CREATE tool:datetimev2_currentdate_getTimeBetweenDates SET
    identity = {
        name: "getTimeBetweenDates",
        slug: "datetimev2_currentdate_getTimeBetweenDates",
        display_name_i18n: i18n_key:tool_datetimev2_currentdate_getTimeBetweenDates_name,
        description_i18n: i18n_key:tool_datetimev2_currentdate_getTimeBetweenDates_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 422,
        tooltip_i18n: i18n_key:tool_datetimev2_currentdate_getTimeBetweenDates_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_datetimev2_currentdate_getTimeBetweenDates_success,
        error_message_i18n: i18n_key:tool_datetimev2_currentdate_getTimeBetweenDates_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:datetimev2_currentdate,
    is_active: true;

CREATE tool:datetimev2_currentdate_roundDate SET
    identity = {
        name: "roundDate",
        slug: "datetimev2_currentdate_roundDate",
        display_name_i18n: i18n_key:tool_datetimev2_currentdate_roundDate_name,
        description_i18n: i18n_key:tool_datetimev2_currentdate_roundDate_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 423,
        tooltip_i18n: i18n_key:tool_datetimev2_currentdate_roundDate_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_datetimev2_currentdate_roundDate_success,
        error_message_i18n: i18n_key:tool_datetimev2_currentdate_roundDate_error,
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
    resource_id: resource:datetimev2_currentdate,
    is_active: true;

CREATE tool:datetimev2_currentdate_subtractFromDate SET
    identity = {
        name: "subtractFromDate",
        slug: "datetimev2_currentdate_subtractFromDate",
        display_name_i18n: i18n_key:tool_datetimev2_currentdate_subtractFromDate_name,
        description_i18n: i18n_key:tool_datetimev2_currentdate_subtractFromDate_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 424,
        tooltip_i18n: i18n_key:tool_datetimev2_currentdate_subtractFromDate_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_datetimev2_currentdate_subtractFromDate_success,
        error_message_i18n: i18n_key:tool_datetimev2_currentdate_subtractFromDate_error,
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
    resource_id: resource:datetimev2_currentdate,
    is_active: true;

CREATE tool:datetimev2_extractdate_addToDate SET
    identity = {
        name: "addToDate",
        slug: "datetimev2_extractdate_addToDate",
        display_name_i18n: i18n_key:tool_datetimev2_extractdate_addToDate_name,
        description_i18n: i18n_key:tool_datetimev2_extractdate_addToDate_desc,
        operation_type: "create",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#4CAF50",
        display_order: 425,
        tooltip_i18n: i18n_key:tool_datetimev2_extractdate_addToDate_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_datetimev2_extractdate_addToDate_success,
        error_message_i18n: i18n_key:tool_datetimev2_extractdate_addToDate_error,
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
    resource_id: resource:datetimev2_extractdate,
    is_active: true;

CREATE tool:datetimev2_extractdate_extractDate SET
    identity = {
        name: "extractDate",
        slug: "datetimev2_extractdate_extractDate",
        display_name_i18n: i18n_key:tool_datetimev2_extractdate_extractDate_name,
        description_i18n: i18n_key:tool_datetimev2_extractdate_extractDate_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 426,
        tooltip_i18n: i18n_key:tool_datetimev2_extractdate_extractDate_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_datetimev2_extractdate_extractDate_success,
        error_message_i18n: i18n_key:tool_datetimev2_extractdate_extractDate_error,
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
    resource_id: resource:datetimev2_extractdate,
    is_active: true;

CREATE tool:datetimev2_extractdate_formatDate SET
    identity = {
        name: "formatDate",
        slug: "datetimev2_extractdate_formatDate",
        display_name_i18n: i18n_key:tool_datetimev2_extractdate_formatDate_name,
        description_i18n: i18n_key:tool_datetimev2_extractdate_formatDate_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 427,
        tooltip_i18n: i18n_key:tool_datetimev2_extractdate_formatDate_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_datetimev2_extractdate_formatDate_success,
        error_message_i18n: i18n_key:tool_datetimev2_extractdate_formatDate_error,
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
    resource_id: resource:datetimev2_extractdate,
    is_active: true;

CREATE tool:datetimev2_extractdate_getCurrentDate SET
    identity = {
        name: "getCurrentDate",
        slug: "datetimev2_extractdate_getCurrentDate",
        display_name_i18n: i18n_key:tool_datetimev2_extractdate_getCurrentDate_name,
        description_i18n: i18n_key:tool_datetimev2_extractdate_getCurrentDate_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 428,
        tooltip_i18n: i18n_key:tool_datetimev2_extractdate_getCurrentDate_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_datetimev2_extractdate_getCurrentDate_success,
        error_message_i18n: i18n_key:tool_datetimev2_extractdate_getCurrentDate_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:datetimev2_extractdate,
    is_active: true;

CREATE tool:datetimev2_extractdate_getTimeBetweenDates SET
    identity = {
        name: "getTimeBetweenDates",
        slug: "datetimev2_extractdate_getTimeBetweenDates",
        display_name_i18n: i18n_key:tool_datetimev2_extractdate_getTimeBetweenDates_name,
        description_i18n: i18n_key:tool_datetimev2_extractdate_getTimeBetweenDates_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 429,
        tooltip_i18n: i18n_key:tool_datetimev2_extractdate_getTimeBetweenDates_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_datetimev2_extractdate_getTimeBetweenDates_success,
        error_message_i18n: i18n_key:tool_datetimev2_extractdate_getTimeBetweenDates_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:datetimev2_extractdate,
    is_active: true;

CREATE tool:datetimev2_extractdate_roundDate SET
    identity = {
        name: "roundDate",
        slug: "datetimev2_extractdate_roundDate",
        display_name_i18n: i18n_key:tool_datetimev2_extractdate_roundDate_name,
        description_i18n: i18n_key:tool_datetimev2_extractdate_roundDate_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 430,
        tooltip_i18n: i18n_key:tool_datetimev2_extractdate_roundDate_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_datetimev2_extractdate_roundDate_success,
        error_message_i18n: i18n_key:tool_datetimev2_extractdate_roundDate_error,
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
    resource_id: resource:datetimev2_extractdate,
    is_active: true;

CREATE tool:datetimev2_extractdate_subtractFromDate SET
    identity = {
        name: "subtractFromDate",
        slug: "datetimev2_extractdate_subtractFromDate",
        display_name_i18n: i18n_key:tool_datetimev2_extractdate_subtractFromDate_name,
        description_i18n: i18n_key:tool_datetimev2_extractdate_subtractFromDate_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 431,
        tooltip_i18n: i18n_key:tool_datetimev2_extractdate_subtractFromDate_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_datetimev2_extractdate_subtractFromDate_success,
        error_message_i18n: i18n_key:tool_datetimev2_extractdate_subtractFromDate_error,
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
    resource_id: resource:datetimev2_extractdate,
    is_active: true;

CREATE tool:datetimev2_formatdate_addToDate SET
    identity = {
        name: "addToDate",
        slug: "datetimev2_formatdate_addToDate",
        display_name_i18n: i18n_key:tool_datetimev2_formatdate_addToDate_name,
        description_i18n: i18n_key:tool_datetimev2_formatdate_addToDate_desc,
        operation_type: "create",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#4CAF50",
        display_order: 432,
        tooltip_i18n: i18n_key:tool_datetimev2_formatdate_addToDate_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_datetimev2_formatdate_addToDate_success,
        error_message_i18n: i18n_key:tool_datetimev2_formatdate_addToDate_error,
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
    resource_id: resource:datetimev2_formatdate,
    is_active: true;

CREATE tool:datetimev2_formatdate_extractDate SET
    identity = {
        name: "extractDate",
        slug: "datetimev2_formatdate_extractDate",
        display_name_i18n: i18n_key:tool_datetimev2_formatdate_extractDate_name,
        description_i18n: i18n_key:tool_datetimev2_formatdate_extractDate_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 433,
        tooltip_i18n: i18n_key:tool_datetimev2_formatdate_extractDate_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_datetimev2_formatdate_extractDate_success,
        error_message_i18n: i18n_key:tool_datetimev2_formatdate_extractDate_error,
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
    resource_id: resource:datetimev2_formatdate,
    is_active: true;

CREATE tool:datetimev2_formatdate_formatDate SET
    identity = {
        name: "formatDate",
        slug: "datetimev2_formatdate_formatDate",
        display_name_i18n: i18n_key:tool_datetimev2_formatdate_formatDate_name,
        description_i18n: i18n_key:tool_datetimev2_formatdate_formatDate_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 434,
        tooltip_i18n: i18n_key:tool_datetimev2_formatdate_formatDate_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_datetimev2_formatdate_formatDate_success,
        error_message_i18n: i18n_key:tool_datetimev2_formatdate_formatDate_error,
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
    resource_id: resource:datetimev2_formatdate,
    is_active: true;

CREATE tool:datetimev2_formatdate_getCurrentDate SET
    identity = {
        name: "getCurrentDate",
        slug: "datetimev2_formatdate_getCurrentDate",
        display_name_i18n: i18n_key:tool_datetimev2_formatdate_getCurrentDate_name,
        description_i18n: i18n_key:tool_datetimev2_formatdate_getCurrentDate_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 435,
        tooltip_i18n: i18n_key:tool_datetimev2_formatdate_getCurrentDate_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_datetimev2_formatdate_getCurrentDate_success,
        error_message_i18n: i18n_key:tool_datetimev2_formatdate_getCurrentDate_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:datetimev2_formatdate,
    is_active: true;

CREATE tool:datetimev2_formatdate_getTimeBetweenDates SET
    identity = {
        name: "getTimeBetweenDates",
        slug: "datetimev2_formatdate_getTimeBetweenDates",
        display_name_i18n: i18n_key:tool_datetimev2_formatdate_getTimeBetweenDates_name,
        description_i18n: i18n_key:tool_datetimev2_formatdate_getTimeBetweenDates_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 436,
        tooltip_i18n: i18n_key:tool_datetimev2_formatdate_getTimeBetweenDates_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_datetimev2_formatdate_getTimeBetweenDates_success,
        error_message_i18n: i18n_key:tool_datetimev2_formatdate_getTimeBetweenDates_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:datetimev2_formatdate,
    is_active: true;

CREATE tool:datetimev2_formatdate_roundDate SET
    identity = {
        name: "roundDate",
        slug: "datetimev2_formatdate_roundDate",
        display_name_i18n: i18n_key:tool_datetimev2_formatdate_roundDate_name,
        description_i18n: i18n_key:tool_datetimev2_formatdate_roundDate_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 437,
        tooltip_i18n: i18n_key:tool_datetimev2_formatdate_roundDate_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_datetimev2_formatdate_roundDate_success,
        error_message_i18n: i18n_key:tool_datetimev2_formatdate_roundDate_error,
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
    resource_id: resource:datetimev2_formatdate,
    is_active: true;

CREATE tool:datetimev2_formatdate_subtractFromDate SET
    identity = {
        name: "subtractFromDate",
        slug: "datetimev2_formatdate_subtractFromDate",
        display_name_i18n: i18n_key:tool_datetimev2_formatdate_subtractFromDate_name,
        description_i18n: i18n_key:tool_datetimev2_formatdate_subtractFromDate_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 438,
        tooltip_i18n: i18n_key:tool_datetimev2_formatdate_subtractFromDate_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_datetimev2_formatdate_subtractFromDate_success,
        error_message_i18n: i18n_key:tool_datetimev2_formatdate_subtractFromDate_error,
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
    resource_id: resource:datetimev2_formatdate,
    is_active: true;

CREATE tool:datetimev2_rounddate_addToDate SET
    identity = {
        name: "addToDate",
        slug: "datetimev2_rounddate_addToDate",
        display_name_i18n: i18n_key:tool_datetimev2_rounddate_addToDate_name,
        description_i18n: i18n_key:tool_datetimev2_rounddate_addToDate_desc,
        operation_type: "create",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#4CAF50",
        display_order: 439,
        tooltip_i18n: i18n_key:tool_datetimev2_rounddate_addToDate_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_datetimev2_rounddate_addToDate_success,
        error_message_i18n: i18n_key:tool_datetimev2_rounddate_addToDate_error,
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
    resource_id: resource:datetimev2_rounddate,
    is_active: true;

CREATE tool:datetimev2_rounddate_extractDate SET
    identity = {
        name: "extractDate",
        slug: "datetimev2_rounddate_extractDate",
        display_name_i18n: i18n_key:tool_datetimev2_rounddate_extractDate_name,
        description_i18n: i18n_key:tool_datetimev2_rounddate_extractDate_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 440,
        tooltip_i18n: i18n_key:tool_datetimev2_rounddate_extractDate_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_datetimev2_rounddate_extractDate_success,
        error_message_i18n: i18n_key:tool_datetimev2_rounddate_extractDate_error,
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
    resource_id: resource:datetimev2_rounddate,
    is_active: true;

CREATE tool:datetimev2_rounddate_formatDate SET
    identity = {
        name: "formatDate",
        slug: "datetimev2_rounddate_formatDate",
        display_name_i18n: i18n_key:tool_datetimev2_rounddate_formatDate_name,
        description_i18n: i18n_key:tool_datetimev2_rounddate_formatDate_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 441,
        tooltip_i18n: i18n_key:tool_datetimev2_rounddate_formatDate_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_datetimev2_rounddate_formatDate_success,
        error_message_i18n: i18n_key:tool_datetimev2_rounddate_formatDate_error,
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
    resource_id: resource:datetimev2_rounddate,
    is_active: true;

CREATE tool:datetimev2_rounddate_getCurrentDate SET
    identity = {
        name: "getCurrentDate",
        slug: "datetimev2_rounddate_getCurrentDate",
        display_name_i18n: i18n_key:tool_datetimev2_rounddate_getCurrentDate_name,
        description_i18n: i18n_key:tool_datetimev2_rounddate_getCurrentDate_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 442,
        tooltip_i18n: i18n_key:tool_datetimev2_rounddate_getCurrentDate_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_datetimev2_rounddate_getCurrentDate_success,
        error_message_i18n: i18n_key:tool_datetimev2_rounddate_getCurrentDate_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:datetimev2_rounddate,
    is_active: true;

CREATE tool:datetimev2_rounddate_getTimeBetweenDates SET
    identity = {
        name: "getTimeBetweenDates",
        slug: "datetimev2_rounddate_getTimeBetweenDates",
        display_name_i18n: i18n_key:tool_datetimev2_rounddate_getTimeBetweenDates_name,
        description_i18n: i18n_key:tool_datetimev2_rounddate_getTimeBetweenDates_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 443,
        tooltip_i18n: i18n_key:tool_datetimev2_rounddate_getTimeBetweenDates_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_datetimev2_rounddate_getTimeBetweenDates_success,
        error_message_i18n: i18n_key:tool_datetimev2_rounddate_getTimeBetweenDates_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:datetimev2_rounddate,
    is_active: true;

CREATE tool:datetimev2_rounddate_roundDate SET
    identity = {
        name: "roundDate",
        slug: "datetimev2_rounddate_roundDate",
        display_name_i18n: i18n_key:tool_datetimev2_rounddate_roundDate_name,
        description_i18n: i18n_key:tool_datetimev2_rounddate_roundDate_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 444,
        tooltip_i18n: i18n_key:tool_datetimev2_rounddate_roundDate_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_datetimev2_rounddate_roundDate_success,
        error_message_i18n: i18n_key:tool_datetimev2_rounddate_roundDate_error,
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
    resource_id: resource:datetimev2_rounddate,
    is_active: true;

CREATE tool:datetimev2_rounddate_subtractFromDate SET
    identity = {
        name: "subtractFromDate",
        slug: "datetimev2_rounddate_subtractFromDate",
        display_name_i18n: i18n_key:tool_datetimev2_rounddate_subtractFromDate_name,
        description_i18n: i18n_key:tool_datetimev2_rounddate_subtractFromDate_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 445,
        tooltip_i18n: i18n_key:tool_datetimev2_rounddate_subtractFromDate_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_datetimev2_rounddate_subtractFromDate_success,
        error_message_i18n: i18n_key:tool_datetimev2_rounddate_subtractFromDate_error,
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
    resource_id: resource:datetimev2_rounddate,
    is_active: true;

CREATE tool:datetimev2_subtractfromdate_addToDate SET
    identity = {
        name: "addToDate",
        slug: "datetimev2_subtractfromdate_addToDate",
        display_name_i18n: i18n_key:tool_datetimev2_subtractfromdate_addToDate_name,
        description_i18n: i18n_key:tool_datetimev2_subtractfromdate_addToDate_desc,
        operation_type: "create",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#4CAF50",
        display_order: 446,
        tooltip_i18n: i18n_key:tool_datetimev2_subtractfromdate_addToDate_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_datetimev2_subtractfromdate_addToDate_success,
        error_message_i18n: i18n_key:tool_datetimev2_subtractfromdate_addToDate_error,
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
    resource_id: resource:datetimev2_subtractfromdate,
    is_active: true;

CREATE tool:datetimev2_subtractfromdate_extractDate SET
    identity = {
        name: "extractDate",
        slug: "datetimev2_subtractfromdate_extractDate",
        display_name_i18n: i18n_key:tool_datetimev2_subtractfromdate_extractDate_name,
        description_i18n: i18n_key:tool_datetimev2_subtractfromdate_extractDate_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 447,
        tooltip_i18n: i18n_key:tool_datetimev2_subtractfromdate_extractDate_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_datetimev2_subtractfromdate_extractDate_success,
        error_message_i18n: i18n_key:tool_datetimev2_subtractfromdate_extractDate_error,
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
    resource_id: resource:datetimev2_subtractfromdate,
    is_active: true;

CREATE tool:datetimev2_subtractfromdate_formatDate SET
    identity = {
        name: "formatDate",
        slug: "datetimev2_subtractfromdate_formatDate",
        display_name_i18n: i18n_key:tool_datetimev2_subtractfromdate_formatDate_name,
        description_i18n: i18n_key:tool_datetimev2_subtractfromdate_formatDate_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 448,
        tooltip_i18n: i18n_key:tool_datetimev2_subtractfromdate_formatDate_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_datetimev2_subtractfromdate_formatDate_success,
        error_message_i18n: i18n_key:tool_datetimev2_subtractfromdate_formatDate_error,
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
    resource_id: resource:datetimev2_subtractfromdate,
    is_active: true;

CREATE tool:datetimev2_subtractfromdate_getCurrentDate SET
    identity = {
        name: "getCurrentDate",
        slug: "datetimev2_subtractfromdate_getCurrentDate",
        display_name_i18n: i18n_key:tool_datetimev2_subtractfromdate_getCurrentDate_name,
        description_i18n: i18n_key:tool_datetimev2_subtractfromdate_getCurrentDate_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 449,
        tooltip_i18n: i18n_key:tool_datetimev2_subtractfromdate_getCurrentDate_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_datetimev2_subtractfromdate_getCurrentDate_success,
        error_message_i18n: i18n_key:tool_datetimev2_subtractfromdate_getCurrentDate_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:datetimev2_subtractfromdate,
    is_active: true;

CREATE tool:datetimev2_subtractfromdate_getTimeBetweenDates SET
    identity = {
        name: "getTimeBetweenDates",
        slug: "datetimev2_subtractfromdate_getTimeBetweenDates",
        display_name_i18n: i18n_key:tool_datetimev2_subtractfromdate_getTimeBetweenDates_name,
        description_i18n: i18n_key:tool_datetimev2_subtractfromdate_getTimeBetweenDates_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 450,
        tooltip_i18n: i18n_key:tool_datetimev2_subtractfromdate_getTimeBetweenDates_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_datetimev2_subtractfromdate_getTimeBetweenDates_success,
        error_message_i18n: i18n_key:tool_datetimev2_subtractfromdate_getTimeBetweenDates_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:datetimev2_subtractfromdate,
    is_active: true;

CREATE tool:datetimev2_subtractfromdate_roundDate SET
    identity = {
        name: "roundDate",
        slug: "datetimev2_subtractfromdate_roundDate",
        display_name_i18n: i18n_key:tool_datetimev2_subtractfromdate_roundDate_name,
        description_i18n: i18n_key:tool_datetimev2_subtractfromdate_roundDate_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 451,
        tooltip_i18n: i18n_key:tool_datetimev2_subtractfromdate_roundDate_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_datetimev2_subtractfromdate_roundDate_success,
        error_message_i18n: i18n_key:tool_datetimev2_subtractfromdate_roundDate_error,
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
    resource_id: resource:datetimev2_subtractfromdate,
    is_active: true;

CREATE tool:datetimev2_subtractfromdate_subtractFromDate SET
    identity = {
        name: "subtractFromDate",
        slug: "datetimev2_subtractfromdate_subtractFromDate",
        display_name_i18n: i18n_key:tool_datetimev2_subtractfromdate_subtractFromDate_name,
        description_i18n: i18n_key:tool_datetimev2_subtractfromdate_subtractFromDate_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 452,
        tooltip_i18n: i18n_key:tool_datetimev2_subtractfromdate_subtractFromDate_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_datetimev2_subtractfromdate_subtractFromDate_success,
        error_message_i18n: i18n_key:tool_datetimev2_subtractfromdate_subtractFromDate_error,
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
    resource_id: resource:datetimev2_subtractfromdate,
    is_active: true;

CREATE tool:debughelper_debughelper_get SET
    identity = {
        name: "get",
        slug: "debughelper_debughelper_get",
        display_name_i18n: i18n_key:tool_debughelper_debughelper_get_name,
        description_i18n: i18n_key:tool_debughelper_debughelper_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 453,
        tooltip_i18n: i18n_key:tool_debughelper_debughelper_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_debughelper_debughelper_get_success,
        error_message_i18n: i18n_key:tool_debughelper_debughelper_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:debughelper_debughelper,
    is_active: true;

CREATE tool:debughelper_debughelper_getMany SET
    identity = {
        name: "getMany",
        slug: "debughelper_debughelper_getMany",
        display_name_i18n: i18n_key:tool_debughelper_debughelper_getMany_name,
        description_i18n: i18n_key:tool_debughelper_debughelper_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 454,
        tooltip_i18n: i18n_key:tool_debughelper_debughelper_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_debughelper_debughelper_getMany_success,
        error_message_i18n: i18n_key:tool_debughelper_debughelper_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:debughelper_debughelper,
    is_active: true;

CREATE tool:deepl_language_translate SET
    identity = {
        name: "translate",
        slug: "deepl_language_translate",
        display_name_i18n: i18n_key:tool_deepl_language_translate_name,
        description_i18n: i18n_key:tool_deepl_language_translate_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 455,
        tooltip_i18n: i18n_key:tool_deepl_language_translate_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_deepl_language_translate_success,
        error_message_i18n: i18n_key:tool_deepl_language_translate_error,
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
    resource_id: resource:deepl_language,
    is_active: true;

CREATE tool:deepl_text_translate SET
    identity = {
        name: "translate",
        slug: "deepl_text_translate",
        display_name_i18n: i18n_key:tool_deepl_text_translate_name,
        description_i18n: i18n_key:tool_deepl_text_translate_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 456,
        tooltip_i18n: i18n_key:tool_deepl_text_translate_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_deepl_text_translate_success,
        error_message_i18n: i18n_key:tool_deepl_text_translate_error,
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
    resource_id: resource:deepl_text,
    is_active: true;

CREATE tool:demio_event_get SET
    identity = {
        name: "get",
        slug: "demio_event_get",
        display_name_i18n: i18n_key:tool_demio_event_get_name,
        description_i18n: i18n_key:tool_demio_event_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 457,
        tooltip_i18n: i18n_key:tool_demio_event_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_demio_event_get_success,
        error_message_i18n: i18n_key:tool_demio_event_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:demio_event,
    is_active: true;

CREATE tool:demio_event_getMany SET
    identity = {
        name: "getMany",
        slug: "demio_event_getMany",
        display_name_i18n: i18n_key:tool_demio_event_getMany_name,
        description_i18n: i18n_key:tool_demio_event_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 458,
        tooltip_i18n: i18n_key:tool_demio_event_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_demio_event_getMany_success,
        error_message_i18n: i18n_key:tool_demio_event_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:demio_event,
    is_active: true;

CREATE tool:demio_report_get SET
    identity = {
        name: "get",
        slug: "demio_report_get",
        display_name_i18n: i18n_key:tool_demio_report_get_name,
        description_i18n: i18n_key:tool_demio_report_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 459,
        tooltip_i18n: i18n_key:tool_demio_report_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_demio_report_get_success,
        error_message_i18n: i18n_key:tool_demio_report_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:demio_report,
    is_active: true;

CREATE tool:demio_report_getMany SET
    identity = {
        name: "getMany",
        slug: "demio_report_getMany",
        display_name_i18n: i18n_key:tool_demio_report_getMany_name,
        description_i18n: i18n_key:tool_demio_report_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 460,
        tooltip_i18n: i18n_key:tool_demio_report_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_demio_report_getMany_success,
        error_message_i18n: i18n_key:tool_demio_report_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:demio_report,
    is_active: true;

CREATE tool:dhl_shipment_get SET
    identity = {
        name: "get",
        slug: "dhl_shipment_get",
        display_name_i18n: i18n_key:tool_dhl_shipment_get_name,
        description_i18n: i18n_key:tool_dhl_shipment_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 461,
        tooltip_i18n: i18n_key:tool_dhl_shipment_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_dhl_shipment_get_success,
        error_message_i18n: i18n_key:tool_dhl_shipment_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:dhl_shipment,
    is_active: true;

CREATE tool:discord_discord_get SET
    identity = {
        name: "get",
        slug: "discord_discord_get",
        display_name_i18n: i18n_key:tool_discord_discord_get_name,
        description_i18n: i18n_key:tool_discord_discord_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 462,
        tooltip_i18n: i18n_key:tool_discord_discord_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_discord_discord_get_success,
        error_message_i18n: i18n_key:tool_discord_discord_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:discord_discord,
    is_active: true;

CREATE tool:discord_discord_getMany SET
    identity = {
        name: "getMany",
        slug: "discord_discord_getMany",
        display_name_i18n: i18n_key:tool_discord_discord_getMany_name,
        description_i18n: i18n_key:tool_discord_discord_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 463,
        tooltip_i18n: i18n_key:tool_discord_discord_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_discord_discord_getMany_success,
        error_message_i18n: i18n_key:tool_discord_discord_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:discord_discord,
    is_active: true;

CREATE tool:discordv1_discordv1_get SET
    identity = {
        name: "get",
        slug: "discordv1_discordv1_get",
        display_name_i18n: i18n_key:tool_discordv1_discordv1_get_name,
        description_i18n: i18n_key:tool_discordv1_discordv1_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 464,
        tooltip_i18n: i18n_key:tool_discordv1_discordv1_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_discordv1_discordv1_get_success,
        error_message_i18n: i18n_key:tool_discordv1_discordv1_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:discordv1_discordv1,
    is_active: true;

CREATE tool:discordv1_discordv1_getMany SET
    identity = {
        name: "getMany",
        slug: "discordv1_discordv1_getMany",
        display_name_i18n: i18n_key:tool_discordv1_discordv1_getMany_name,
        description_i18n: i18n_key:tool_discordv1_discordv1_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 465,
        tooltip_i18n: i18n_key:tool_discordv1_discordv1_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_discordv1_discordv1_getMany_success,
        error_message_i18n: i18n_key:tool_discordv1_discordv1_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:discordv1_discordv1,
    is_active: true;

CREATE tool:discordv2_discordv2_get SET
    identity = {
        name: "get",
        slug: "discordv2_discordv2_get",
        display_name_i18n: i18n_key:tool_discordv2_discordv2_get_name,
        description_i18n: i18n_key:tool_discordv2_discordv2_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 466,
        tooltip_i18n: i18n_key:tool_discordv2_discordv2_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_discordv2_discordv2_get_success,
        error_message_i18n: i18n_key:tool_discordv2_discordv2_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:discordv2_discordv2,
    is_active: true;

CREATE tool:discordv2_discordv2_getMany SET
    identity = {
        name: "getMany",
        slug: "discordv2_discordv2_getMany",
        display_name_i18n: i18n_key:tool_discordv2_discordv2_getMany_name,
        description_i18n: i18n_key:tool_discordv2_discordv2_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 467,
        tooltip_i18n: i18n_key:tool_discordv2_discordv2_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_discordv2_discordv2_getMany_success,
        error_message_i18n: i18n_key:tool_discordv2_discordv2_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:discordv2_discordv2,
    is_active: true;

CREATE tool:discourse_category_get SET
    identity = {
        name: "get",
        slug: "discourse_category_get",
        display_name_i18n: i18n_key:tool_discourse_category_get_name,
        description_i18n: i18n_key:tool_discourse_category_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 468,
        tooltip_i18n: i18n_key:tool_discourse_category_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_discourse_category_get_success,
        error_message_i18n: i18n_key:tool_discourse_category_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:discourse_category,
    is_active: true;

CREATE tool:discourse_category_getMany SET
    identity = {
        name: "getMany",
        slug: "discourse_category_getMany",
        display_name_i18n: i18n_key:tool_discourse_category_getMany_name,
        description_i18n: i18n_key:tool_discourse_category_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 469,
        tooltip_i18n: i18n_key:tool_discourse_category_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_discourse_category_getMany_success,
        error_message_i18n: i18n_key:tool_discourse_category_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:discourse_category,
    is_active: true;

CREATE tool:discourse_group_get SET
    identity = {
        name: "get",
        slug: "discourse_group_get",
        display_name_i18n: i18n_key:tool_discourse_group_get_name,
        description_i18n: i18n_key:tool_discourse_group_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 470,
        tooltip_i18n: i18n_key:tool_discourse_group_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_discourse_group_get_success,
        error_message_i18n: i18n_key:tool_discourse_group_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:discourse_group,
    is_active: true;

CREATE tool:discourse_group_getMany SET
    identity = {
        name: "getMany",
        slug: "discourse_group_getMany",
        display_name_i18n: i18n_key:tool_discourse_group_getMany_name,
        description_i18n: i18n_key:tool_discourse_group_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 471,
        tooltip_i18n: i18n_key:tool_discourse_group_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_discourse_group_getMany_success,
        error_message_i18n: i18n_key:tool_discourse_group_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:discourse_group,
    is_active: true;

CREATE tool:discourse_post_get SET
    identity = {
        name: "get",
        slug: "discourse_post_get",
        display_name_i18n: i18n_key:tool_discourse_post_get_name,
        description_i18n: i18n_key:tool_discourse_post_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 472,
        tooltip_i18n: i18n_key:tool_discourse_post_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_discourse_post_get_success,
        error_message_i18n: i18n_key:tool_discourse_post_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:discourse_post,
    is_active: true;

CREATE tool:discourse_post_getMany SET
    identity = {
        name: "getMany",
        slug: "discourse_post_getMany",
        display_name_i18n: i18n_key:tool_discourse_post_getMany_name,
        description_i18n: i18n_key:tool_discourse_post_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 473,
        tooltip_i18n: i18n_key:tool_discourse_post_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_discourse_post_getMany_success,
        error_message_i18n: i18n_key:tool_discourse_post_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:discourse_post,
    is_active: true;

CREATE tool:discourse_user_get SET
    identity = {
        name: "get",
        slug: "discourse_user_get",
        display_name_i18n: i18n_key:tool_discourse_user_get_name,
        description_i18n: i18n_key:tool_discourse_user_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 474,
        tooltip_i18n: i18n_key:tool_discourse_user_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_discourse_user_get_success,
        error_message_i18n: i18n_key:tool_discourse_user_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:discourse_user,
    is_active: true;

CREATE tool:discourse_user_getMany SET
    identity = {
        name: "getMany",
        slug: "discourse_user_getMany",
        display_name_i18n: i18n_key:tool_discourse_user_getMany_name,
        description_i18n: i18n_key:tool_discourse_user_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 475,
        tooltip_i18n: i18n_key:tool_discourse_user_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_discourse_user_getMany_success,
        error_message_i18n: i18n_key:tool_discourse_user_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:discourse_user,
    is_active: true;

CREATE tool:discourse_userGroup_get SET
    identity = {
        name: "get",
        slug: "discourse_userGroup_get",
        display_name_i18n: i18n_key:tool_discourse_userGroup_get_name,
        description_i18n: i18n_key:tool_discourse_userGroup_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 476,
        tooltip_i18n: i18n_key:tool_discourse_userGroup_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_discourse_userGroup_get_success,
        error_message_i18n: i18n_key:tool_discourse_userGroup_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:discourse_userGroup,
    is_active: true;

CREATE tool:discourse_userGroup_getMany SET
    identity = {
        name: "getMany",
        slug: "discourse_userGroup_getMany",
        display_name_i18n: i18n_key:tool_discourse_userGroup_getMany_name,
        description_i18n: i18n_key:tool_discourse_userGroup_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 477,
        tooltip_i18n: i18n_key:tool_discourse_userGroup_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_discourse_userGroup_getMany_success,
        error_message_i18n: i18n_key:tool_discourse_userGroup_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:discourse_userGroup,
    is_active: true;

CREATE tool:discourse_usergroup_get SET
    identity = {
        name: "get",
        slug: "discourse_usergroup_get",
        display_name_i18n: i18n_key:tool_discourse_usergroup_get_name,
        description_i18n: i18n_key:tool_discourse_usergroup_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 478,
        tooltip_i18n: i18n_key:tool_discourse_usergroup_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_discourse_usergroup_get_success,
        error_message_i18n: i18n_key:tool_discourse_usergroup_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:discourse_usergroup,
    is_active: true;

CREATE tool:discourse_usergroup_getMany SET
    identity = {
        name: "getMany",
        slug: "discourse_usergroup_getMany",
        display_name_i18n: i18n_key:tool_discourse_usergroup_getMany_name,
        description_i18n: i18n_key:tool_discourse_usergroup_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 479,
        tooltip_i18n: i18n_key:tool_discourse_usergroup_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_discourse_usergroup_getMany_success,
        error_message_i18n: i18n_key:tool_discourse_usergroup_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:discourse_usergroup,
    is_active: true;

CREATE tool:disqus_forum_get SET
    identity = {
        name: "get",
        slug: "disqus_forum_get",
        display_name_i18n: i18n_key:tool_disqus_forum_get_name,
        description_i18n: i18n_key:tool_disqus_forum_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 480,
        tooltip_i18n: i18n_key:tool_disqus_forum_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_disqus_forum_get_success,
        error_message_i18n: i18n_key:tool_disqus_forum_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:disqus_forum,
    is_active: true;

CREATE tool:disqus_forum_getCategories SET
    identity = {
        name: "getCategories",
        slug: "disqus_forum_getCategories",
        display_name_i18n: i18n_key:tool_disqus_forum_getCategories_name,
        description_i18n: i18n_key:tool_disqus_forum_getCategories_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 481,
        tooltip_i18n: i18n_key:tool_disqus_forum_getCategories_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_disqus_forum_getCategories_success,
        error_message_i18n: i18n_key:tool_disqus_forum_getCategories_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:disqus_forum,
    is_active: true;

CREATE tool:disqus_forum_getThreads SET
    identity = {
        name: "getThreads",
        slug: "disqus_forum_getThreads",
        display_name_i18n: i18n_key:tool_disqus_forum_getThreads_name,
        description_i18n: i18n_key:tool_disqus_forum_getThreads_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 482,
        tooltip_i18n: i18n_key:tool_disqus_forum_getThreads_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_disqus_forum_getThreads_success,
        error_message_i18n: i18n_key:tool_disqus_forum_getThreads_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:disqus_forum,
    is_active: true;

CREATE tool:disqus_forum_getPosts SET
    identity = {
        name: "getPosts",
        slug: "disqus_forum_getPosts",
        display_name_i18n: i18n_key:tool_disqus_forum_getPosts_name,
        description_i18n: i18n_key:tool_disqus_forum_getPosts_desc,
        operation_type: "create",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#4CAF50",
        display_order: 483,
        tooltip_i18n: i18n_key:tool_disqus_forum_getPosts_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_disqus_forum_getPosts_success,
        error_message_i18n: i18n_key:tool_disqus_forum_getPosts_error,
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
    resource_id: resource:disqus_forum,
    is_active: true;

CREATE tool:drift_contact_get SET
    identity = {
        name: "get",
        slug: "drift_contact_get",
        display_name_i18n: i18n_key:tool_drift_contact_get_name,
        description_i18n: i18n_key:tool_drift_contact_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 484,
        tooltip_i18n: i18n_key:tool_drift_contact_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_drift_contact_get_success,
        error_message_i18n: i18n_key:tool_drift_contact_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:drift_contact,
    is_active: true;

CREATE tool:drift_contact_getMany SET
    identity = {
        name: "getMany",
        slug: "drift_contact_getMany",
        display_name_i18n: i18n_key:tool_drift_contact_getMany_name,
        description_i18n: i18n_key:tool_drift_contact_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 485,
        tooltip_i18n: i18n_key:tool_drift_contact_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_drift_contact_getMany_success,
        error_message_i18n: i18n_key:tool_drift_contact_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:drift_contact,
    is_active: true;

CREATE tool:dropbox_file_copy SET
    identity = {
        name: "copy",
        slug: "dropbox_file_copy",
        display_name_i18n: i18n_key:tool_dropbox_file_copy_name,
        description_i18n: i18n_key:tool_dropbox_file_copy_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 486,
        tooltip_i18n: i18n_key:tool_dropbox_file_copy_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_dropbox_file_copy_success,
        error_message_i18n: i18n_key:tool_dropbox_file_copy_error,
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
    resource_id: resource:dropbox_file,
    is_active: true;

CREATE tool:dropbox_file_delete SET
    identity = {
        name: "delete",
        slug: "dropbox_file_delete",
        display_name_i18n: i18n_key:tool_dropbox_file_delete_name,
        description_i18n: i18n_key:tool_dropbox_file_delete_desc,
        operation_type: "delete",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#F44336",
        display_order: 487,
        tooltip_i18n: i18n_key:tool_dropbox_file_delete_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_dropbox_file_delete_success,
        error_message_i18n: i18n_key:tool_dropbox_file_delete_error,
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
    resource_id: resource:dropbox_file,
    is_active: true;

CREATE tool:dropbox_file_download SET
    identity = {
        name: "download",
        slug: "dropbox_file_download",
        display_name_i18n: i18n_key:tool_dropbox_file_download_name,
        description_i18n: i18n_key:tool_dropbox_file_download_desc,
        operation_type: "download",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#03A9F4",
        display_order: 488,
        tooltip_i18n: i18n_key:tool_dropbox_file_download_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_dropbox_file_download_success,
        error_message_i18n: i18n_key:tool_dropbox_file_download_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:dropbox_file,
    is_active: true;

CREATE tool:dropbox_file_move SET
    identity = {
        name: "move",
        slug: "dropbox_file_move",
        display_name_i18n: i18n_key:tool_dropbox_file_move_name,
        description_i18n: i18n_key:tool_dropbox_file_move_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 489,
        tooltip_i18n: i18n_key:tool_dropbox_file_move_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_dropbox_file_move_success,
        error_message_i18n: i18n_key:tool_dropbox_file_move_error,
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
    resource_id: resource:dropbox_file,
    is_active: true;

CREATE tool:dropbox_file_upload SET
    identity = {
        name: "upload",
        slug: "dropbox_file_upload",
        display_name_i18n: i18n_key:tool_dropbox_file_upload_name,
        description_i18n: i18n_key:tool_dropbox_file_upload_desc,
        operation_type: "upload",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#8BC34A",
        display_order: 490,
        tooltip_i18n: i18n_key:tool_dropbox_file_upload_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_dropbox_file_upload_success,
        error_message_i18n: i18n_key:tool_dropbox_file_upload_error,
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
    resource_id: resource:dropbox_file,
    is_active: true;

CREATE tool:dropbox_folder_copy SET
    identity = {
        name: "copy",
        slug: "dropbox_folder_copy",
        display_name_i18n: i18n_key:tool_dropbox_folder_copy_name,
        description_i18n: i18n_key:tool_dropbox_folder_copy_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 491,
        tooltip_i18n: i18n_key:tool_dropbox_folder_copy_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_dropbox_folder_copy_success,
        error_message_i18n: i18n_key:tool_dropbox_folder_copy_error,
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
    resource_id: resource:dropbox_folder,
    is_active: true;

CREATE tool:dropbox_folder_delete SET
    identity = {
        name: "delete",
        slug: "dropbox_folder_delete",
        display_name_i18n: i18n_key:tool_dropbox_folder_delete_name,
        description_i18n: i18n_key:tool_dropbox_folder_delete_desc,
        operation_type: "delete",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#F44336",
        display_order: 492,
        tooltip_i18n: i18n_key:tool_dropbox_folder_delete_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_dropbox_folder_delete_success,
        error_message_i18n: i18n_key:tool_dropbox_folder_delete_error,
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
    resource_id: resource:dropbox_folder,
    is_active: true;

CREATE tool:dropbox_folder_download SET
    identity = {
        name: "download",
        slug: "dropbox_folder_download",
        display_name_i18n: i18n_key:tool_dropbox_folder_download_name,
        description_i18n: i18n_key:tool_dropbox_folder_download_desc,
        operation_type: "download",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#03A9F4",
        display_order: 493,
        tooltip_i18n: i18n_key:tool_dropbox_folder_download_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_dropbox_folder_download_success,
        error_message_i18n: i18n_key:tool_dropbox_folder_download_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:dropbox_folder,
    is_active: true;

CREATE tool:dropbox_folder_move SET
    identity = {
        name: "move",
        slug: "dropbox_folder_move",
        display_name_i18n: i18n_key:tool_dropbox_folder_move_name,
        description_i18n: i18n_key:tool_dropbox_folder_move_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 494,
        tooltip_i18n: i18n_key:tool_dropbox_folder_move_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_dropbox_folder_move_success,
        error_message_i18n: i18n_key:tool_dropbox_folder_move_error,
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
    resource_id: resource:dropbox_folder,
    is_active: true;

CREATE tool:dropbox_folder_upload SET
    identity = {
        name: "upload",
        slug: "dropbox_folder_upload",
        display_name_i18n: i18n_key:tool_dropbox_folder_upload_name,
        description_i18n: i18n_key:tool_dropbox_folder_upload_desc,
        operation_type: "upload",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#8BC34A",
        display_order: 495,
        tooltip_i18n: i18n_key:tool_dropbox_folder_upload_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_dropbox_folder_upload_success,
        error_message_i18n: i18n_key:tool_dropbox_folder_upload_error,
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
    resource_id: resource:dropbox_folder,
    is_active: true;

CREATE tool:dropbox_search_copy SET
    identity = {
        name: "copy",
        slug: "dropbox_search_copy",
        display_name_i18n: i18n_key:tool_dropbox_search_copy_name,
        description_i18n: i18n_key:tool_dropbox_search_copy_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 496,
        tooltip_i18n: i18n_key:tool_dropbox_search_copy_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_dropbox_search_copy_success,
        error_message_i18n: i18n_key:tool_dropbox_search_copy_error,
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
    resource_id: resource:dropbox_search,
    is_active: true;

CREATE tool:dropbox_search_delete SET
    identity = {
        name: "delete",
        slug: "dropbox_search_delete",
        display_name_i18n: i18n_key:tool_dropbox_search_delete_name,
        description_i18n: i18n_key:tool_dropbox_search_delete_desc,
        operation_type: "delete",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#F44336",
        display_order: 497,
        tooltip_i18n: i18n_key:tool_dropbox_search_delete_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_dropbox_search_delete_success,
        error_message_i18n: i18n_key:tool_dropbox_search_delete_error,
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
    resource_id: resource:dropbox_search,
    is_active: true;

CREATE tool:dropbox_search_download SET
    identity = {
        name: "download",
        slug: "dropbox_search_download",
        display_name_i18n: i18n_key:tool_dropbox_search_download_name,
        description_i18n: i18n_key:tool_dropbox_search_download_desc,
        operation_type: "download",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#03A9F4",
        display_order: 498,
        tooltip_i18n: i18n_key:tool_dropbox_search_download_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_dropbox_search_download_success,
        error_message_i18n: i18n_key:tool_dropbox_search_download_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:dropbox_search,
    is_active: true;

CREATE tool:dropbox_search_move SET
    identity = {
        name: "move",
        slug: "dropbox_search_move",
        display_name_i18n: i18n_key:tool_dropbox_search_move_name,
        description_i18n: i18n_key:tool_dropbox_search_move_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 499,
        tooltip_i18n: i18n_key:tool_dropbox_search_move_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_dropbox_search_move_success,
        error_message_i18n: i18n_key:tool_dropbox_search_move_error,
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
    resource_id: resource:dropbox_search,
    is_active: true;

CREATE tool:dropbox_search_upload SET
    identity = {
        name: "upload",
        slug: "dropbox_search_upload",
        display_name_i18n: i18n_key:tool_dropbox_search_upload_name,
        description_i18n: i18n_key:tool_dropbox_search_upload_desc,
        operation_type: "upload",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#8BC34A",
        display_order: 500,
        tooltip_i18n: i18n_key:tool_dropbox_search_upload_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_dropbox_search_upload_success,
        error_message_i18n: i18n_key:tool_dropbox_search_upload_error,
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
    resource_id: resource:dropbox_search,
    is_active: true;

