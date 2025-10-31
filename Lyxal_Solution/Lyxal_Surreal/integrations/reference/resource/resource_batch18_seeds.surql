-- Batch 18: 50 ressources Lyxal

CREATE resource:sentryio_team SET
    identity = {
        name: "team",
        slug: "sentryio_team",
        display_name_i18n: i18n_key:resource_sentryio_team_name,
        description_i18n: i18n_key:resource_sentryio_team_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 851,
        tooltip_i18n: i18n_key:resource_sentryio_team_tooltip,
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
    service_id: service:sentryio,
    is_active: true;

CREATE resource:servicenow_attachment SET
    identity = {
        name: "attachment",
        slug: "servicenow_attachment",
        display_name_i18n: i18n_key:resource_servicenow_attachment_name,
        description_i18n: i18n_key:resource_servicenow_attachment_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 852,
        tooltip_i18n: i18n_key:resource_servicenow_attachment_tooltip,
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
    service_id: service:servicenow,
    is_active: true;

CREATE resource:servicenow_businessService SET
    identity = {
        name: "businessService",
        slug: "servicenow_businessService",
        display_name_i18n: i18n_key:resource_servicenow_businessService_name,
        description_i18n: i18n_key:resource_servicenow_businessService_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 853,
        tooltip_i18n: i18n_key:resource_servicenow_businessService_tooltip,
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
    service_id: service:servicenow,
    is_active: true;

CREATE resource:servicenow_configurationItems SET
    identity = {
        name: "configurationItems",
        slug: "servicenow_configurationItems",
        display_name_i18n: i18n_key:resource_servicenow_configurationItems_name,
        description_i18n: i18n_key:resource_servicenow_configurationItems_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 854,
        tooltip_i18n: i18n_key:resource_servicenow_configurationItems_tooltip,
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
    service_id: service:servicenow,
    is_active: true;

CREATE resource:servicenow_department SET
    identity = {
        name: "department",
        slug: "servicenow_department",
        display_name_i18n: i18n_key:resource_servicenow_department_name,
        description_i18n: i18n_key:resource_servicenow_department_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 855,
        tooltip_i18n: i18n_key:resource_servicenow_department_tooltip,
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
    service_id: service:servicenow,
    is_active: true;

CREATE resource:servicenow_dictionary SET
    identity = {
        name: "dictionary",
        slug: "servicenow_dictionary",
        display_name_i18n: i18n_key:resource_servicenow_dictionary_name,
        description_i18n: i18n_key:resource_servicenow_dictionary_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 856,
        tooltip_i18n: i18n_key:resource_servicenow_dictionary_tooltip,
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
    service_id: service:servicenow,
    is_active: true;

CREATE resource:servicenow_incident SET
    identity = {
        name: "incident",
        slug: "servicenow_incident",
        display_name_i18n: i18n_key:resource_servicenow_incident_name,
        description_i18n: i18n_key:resource_servicenow_incident_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 857,
        tooltip_i18n: i18n_key:resource_servicenow_incident_tooltip,
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
    service_id: service:servicenow,
    is_active: true;

CREATE resource:servicenow_tableRecord SET
    identity = {
        name: "tableRecord",
        slug: "servicenow_tableRecord",
        display_name_i18n: i18n_key:resource_servicenow_tableRecord_name,
        description_i18n: i18n_key:resource_servicenow_tableRecord_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 858,
        tooltip_i18n: i18n_key:resource_servicenow_tableRecord_tooltip,
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
    service_id: service:servicenow,
    is_active: true;

CREATE resource:servicenow_user SET
    identity = {
        name: "user",
        slug: "servicenow_user",
        display_name_i18n: i18n_key:resource_servicenow_user_name,
        description_i18n: i18n_key:resource_servicenow_user_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 859,
        tooltip_i18n: i18n_key:resource_servicenow_user_tooltip,
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
    service_id: service:servicenow,
    is_active: true;

CREATE resource:servicenow_userGroup SET
    identity = {
        name: "userGroup",
        slug: "servicenow_userGroup",
        display_name_i18n: i18n_key:resource_servicenow_userGroup_name,
        description_i18n: i18n_key:resource_servicenow_userGroup_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 860,
        tooltip_i18n: i18n_key:resource_servicenow_userGroup_tooltip,
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
    service_id: service:servicenow,
    is_active: true;

CREATE resource:servicenow_userRole SET
    identity = {
        name: "userRole",
        slug: "servicenow_userRole",
        display_name_i18n: i18n_key:resource_servicenow_userRole_name,
        description_i18n: i18n_key:resource_servicenow_userRole_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 861,
        tooltip_i18n: i18n_key:resource_servicenow_userRole_tooltip,
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
    service_id: service:servicenow,
    is_active: true;

CREATE resource:servicenow_businessservice SET
    identity = {
        name: "businessservice",
        slug: "servicenow_businessservice",
        display_name_i18n: i18n_key:resource_servicenow_businessservice_name,
        description_i18n: i18n_key:resource_servicenow_businessservice_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 862,
        tooltip_i18n: i18n_key:resource_servicenow_businessservice_tooltip,
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
    service_id: service:servicenow,
    is_active: true;

CREATE resource:servicenow_configurationitems SET
    identity = {
        name: "configurationitems",
        slug: "servicenow_configurationitems",
        display_name_i18n: i18n_key:resource_servicenow_configurationitems_name,
        description_i18n: i18n_key:resource_servicenow_configurationitems_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 863,
        tooltip_i18n: i18n_key:resource_servicenow_configurationitems_tooltip,
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
    service_id: service:servicenow,
    is_active: true;

CREATE resource:servicenow_tablerecord SET
    identity = {
        name: "tablerecord",
        slug: "servicenow_tablerecord",
        display_name_i18n: i18n_key:resource_servicenow_tablerecord_name,
        description_i18n: i18n_key:resource_servicenow_tablerecord_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 864,
        tooltip_i18n: i18n_key:resource_servicenow_tablerecord_tooltip,
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
    service_id: service:servicenow,
    is_active: true;

CREATE resource:servicenow_usergroup SET
    identity = {
        name: "usergroup",
        slug: "servicenow_usergroup",
        display_name_i18n: i18n_key:resource_servicenow_usergroup_name,
        description_i18n: i18n_key:resource_servicenow_usergroup_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 865,
        tooltip_i18n: i18n_key:resource_servicenow_usergroup_tooltip,
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
    service_id: service:servicenow,
    is_active: true;

CREATE resource:servicenow_userrole SET
    identity = {
        name: "userrole",
        slug: "servicenow_userrole",
        display_name_i18n: i18n_key:resource_servicenow_userrole_name,
        description_i18n: i18n_key:resource_servicenow_userrole_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 866,
        tooltip_i18n: i18n_key:resource_servicenow_userrole_tooltip,
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
    service_id: service:servicenow,
    is_active: true;

CREATE resource:set_set SET
    identity = {
        name: "set",
        slug: "set_set",
        display_name_i18n: i18n_key:resource_set_set_name,
        description_i18n: i18n_key:resource_set_set_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 867,
        tooltip_i18n: i18n_key:resource_set_set_tooltip,
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
    service_id: service:set,
    is_active: true;

CREATE resource:setv1_setv1 SET
    identity = {
        name: "setv1",
        slug: "setv1_setv1",
        display_name_i18n: i18n_key:resource_setv1_setv1_name,
        description_i18n: i18n_key:resource_setv1_setv1_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 868,
        tooltip_i18n: i18n_key:resource_setv1_setv1_tooltip,
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
    service_id: service:setv1,
    is_active: true;

CREATE resource:setv2_setv2 SET
    identity = {
        name: "setv2",
        slug: "setv2_setv2",
        display_name_i18n: i18n_key:resource_setv2_setv2_name,
        description_i18n: i18n_key:resource_setv2_setv2_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 869,
        tooltip_i18n: i18n_key:resource_setv2_setv2_tooltip,
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
    service_id: service:setv2,
    is_active: true;

CREATE resource:shopify_order SET
    identity = {
        name: "order",
        slug: "shopify_order",
        display_name_i18n: i18n_key:resource_shopify_order_name,
        description_i18n: i18n_key:resource_shopify_order_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 870,
        tooltip_i18n: i18n_key:resource_shopify_order_tooltip,
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
    service_id: service:shopify,
    is_active: true;

CREATE resource:shopify_product SET
    identity = {
        name: "product",
        slug: "shopify_product",
        display_name_i18n: i18n_key:resource_shopify_product_name,
        description_i18n: i18n_key:resource_shopify_product_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 871,
        tooltip_i18n: i18n_key:resource_shopify_product_tooltip,
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
    service_id: service:shopify,
    is_active: true;

CREATE resource:signl4_alert SET
    identity = {
        name: "alert",
        slug: "signl4_alert",
        display_name_i18n: i18n_key:resource_signl4_alert_name,
        description_i18n: i18n_key:resource_signl4_alert_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 872,
        tooltip_i18n: i18n_key:resource_signl4_alert_tooltip,
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
    service_id: service:signl4,
    is_active: true;

CREATE resource:simulate_simulate SET
    identity = {
        name: "simulate",
        slug: "simulate_simulate",
        display_name_i18n: i18n_key:resource_simulate_simulate_name,
        description_i18n: i18n_key:resource_simulate_simulate_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 873,
        tooltip_i18n: i18n_key:resource_simulate_simulate_tooltip,
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
    service_id: service:simulate,
    is_active: true;

CREATE resource:slack_slack SET
    identity = {
        name: "slack",
        slug: "slack_slack",
        display_name_i18n: i18n_key:resource_slack_slack_name,
        description_i18n: i18n_key:resource_slack_slack_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 874,
        tooltip_i18n: i18n_key:resource_slack_slack_tooltip,
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
    service_id: service:slack,
    is_active: true;

CREATE resource:slackv1_channel SET
    identity = {
        name: "channel",
        slug: "slackv1_channel",
        display_name_i18n: i18n_key:resource_slackv1_channel_name,
        description_i18n: i18n_key:resource_slackv1_channel_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 875,
        tooltip_i18n: i18n_key:resource_slackv1_channel_tooltip,
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
    service_id: service:slackv1,
    is_active: true;

CREATE resource:slackv1_file SET
    identity = {
        name: "file",
        slug: "slackv1_file",
        display_name_i18n: i18n_key:resource_slackv1_file_name,
        description_i18n: i18n_key:resource_slackv1_file_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 876,
        tooltip_i18n: i18n_key:resource_slackv1_file_tooltip,
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
    service_id: service:slackv1,
    is_active: true;

CREATE resource:slackv1_message SET
    identity = {
        name: "message",
        slug: "slackv1_message",
        display_name_i18n: i18n_key:resource_slackv1_message_name,
        description_i18n: i18n_key:resource_slackv1_message_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 877,
        tooltip_i18n: i18n_key:resource_slackv1_message_tooltip,
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
    service_id: service:slackv1,
    is_active: true;

CREATE resource:slackv1_reaction SET
    identity = {
        name: "reaction",
        slug: "slackv1_reaction",
        display_name_i18n: i18n_key:resource_slackv1_reaction_name,
        description_i18n: i18n_key:resource_slackv1_reaction_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 878,
        tooltip_i18n: i18n_key:resource_slackv1_reaction_tooltip,
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
    service_id: service:slackv1,
    is_active: true;

CREATE resource:slackv1_star SET
    identity = {
        name: "star",
        slug: "slackv1_star",
        display_name_i18n: i18n_key:resource_slackv1_star_name,
        description_i18n: i18n_key:resource_slackv1_star_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 879,
        tooltip_i18n: i18n_key:resource_slackv1_star_tooltip,
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
    service_id: service:slackv1,
    is_active: true;

CREATE resource:slackv1_user SET
    identity = {
        name: "user",
        slug: "slackv1_user",
        display_name_i18n: i18n_key:resource_slackv1_user_name,
        description_i18n: i18n_key:resource_slackv1_user_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 880,
        tooltip_i18n: i18n_key:resource_slackv1_user_tooltip,
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
    service_id: service:slackv1,
    is_active: true;

CREATE resource:slackv1_userGroup SET
    identity = {
        name: "userGroup",
        slug: "slackv1_userGroup",
        display_name_i18n: i18n_key:resource_slackv1_userGroup_name,
        description_i18n: i18n_key:resource_slackv1_userGroup_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 881,
        tooltip_i18n: i18n_key:resource_slackv1_userGroup_tooltip,
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
    service_id: service:slackv1,
    is_active: true;

CREATE resource:slackv1_userProfile SET
    identity = {
        name: "userProfile",
        slug: "slackv1_userProfile",
        display_name_i18n: i18n_key:resource_slackv1_userProfile_name,
        description_i18n: i18n_key:resource_slackv1_userProfile_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 882,
        tooltip_i18n: i18n_key:resource_slackv1_userProfile_tooltip,
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
    service_id: service:slackv1,
    is_active: true;

CREATE resource:slackv1_usergroup SET
    identity = {
        name: "usergroup",
        slug: "slackv1_usergroup",
        display_name_i18n: i18n_key:resource_slackv1_usergroup_name,
        description_i18n: i18n_key:resource_slackv1_usergroup_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 883,
        tooltip_i18n: i18n_key:resource_slackv1_usergroup_tooltip,
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
    service_id: service:slackv1,
    is_active: true;

CREATE resource:slackv1_userprofile SET
    identity = {
        name: "userprofile",
        slug: "slackv1_userprofile",
        display_name_i18n: i18n_key:resource_slackv1_userprofile_name,
        description_i18n: i18n_key:resource_slackv1_userprofile_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 884,
        tooltip_i18n: i18n_key:resource_slackv1_userprofile_tooltip,
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
    service_id: service:slackv1,
    is_active: true;

CREATE resource:slackv2_channel SET
    identity = {
        name: "channel",
        slug: "slackv2_channel",
        display_name_i18n: i18n_key:resource_slackv2_channel_name,
        description_i18n: i18n_key:resource_slackv2_channel_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 885,
        tooltip_i18n: i18n_key:resource_slackv2_channel_tooltip,
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
    service_id: service:slackv2,
    is_active: true;

CREATE resource:slackv2_file SET
    identity = {
        name: "file",
        slug: "slackv2_file",
        display_name_i18n: i18n_key:resource_slackv2_file_name,
        description_i18n: i18n_key:resource_slackv2_file_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 886,
        tooltip_i18n: i18n_key:resource_slackv2_file_tooltip,
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
    service_id: service:slackv2,
    is_active: true;

CREATE resource:slackv2_message SET
    identity = {
        name: "message",
        slug: "slackv2_message",
        display_name_i18n: i18n_key:resource_slackv2_message_name,
        description_i18n: i18n_key:resource_slackv2_message_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 887,
        tooltip_i18n: i18n_key:resource_slackv2_message_tooltip,
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
    service_id: service:slackv2,
    is_active: true;

CREATE resource:slackv2_reaction SET
    identity = {
        name: "reaction",
        slug: "slackv2_reaction",
        display_name_i18n: i18n_key:resource_slackv2_reaction_name,
        description_i18n: i18n_key:resource_slackv2_reaction_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 888,
        tooltip_i18n: i18n_key:resource_slackv2_reaction_tooltip,
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
    service_id: service:slackv2,
    is_active: true;

CREATE resource:slackv2_star SET
    identity = {
        name: "star",
        slug: "slackv2_star",
        display_name_i18n: i18n_key:resource_slackv2_star_name,
        description_i18n: i18n_key:resource_slackv2_star_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 889,
        tooltip_i18n: i18n_key:resource_slackv2_star_tooltip,
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
    service_id: service:slackv2,
    is_active: true;

CREATE resource:slackv2_user SET
    identity = {
        name: "user",
        slug: "slackv2_user",
        display_name_i18n: i18n_key:resource_slackv2_user_name,
        description_i18n: i18n_key:resource_slackv2_user_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 890,
        tooltip_i18n: i18n_key:resource_slackv2_user_tooltip,
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
    service_id: service:slackv2,
    is_active: true;

CREATE resource:slackv2_userGroup SET
    identity = {
        name: "userGroup",
        slug: "slackv2_userGroup",
        display_name_i18n: i18n_key:resource_slackv2_userGroup_name,
        description_i18n: i18n_key:resource_slackv2_userGroup_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 891,
        tooltip_i18n: i18n_key:resource_slackv2_userGroup_tooltip,
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
    service_id: service:slackv2,
    is_active: true;

CREATE resource:slackv2_usergroup SET
    identity = {
        name: "usergroup",
        slug: "slackv2_usergroup",
        display_name_i18n: i18n_key:resource_slackv2_usergroup_name,
        description_i18n: i18n_key:resource_slackv2_usergroup_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 892,
        tooltip_i18n: i18n_key:resource_slackv2_usergroup_tooltip,
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
    service_id: service:slackv2,
    is_active: true;

CREATE resource:sms77_sms SET
    identity = {
        name: "sms",
        slug: "sms77_sms",
        display_name_i18n: i18n_key:resource_sms77_sms_name,
        description_i18n: i18n_key:resource_sms77_sms_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 893,
        tooltip_i18n: i18n_key:resource_sms77_sms_tooltip,
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
    service_id: service:sms77,
    is_active: true;

CREATE resource:sms77_voice SET
    identity = {
        name: "voice",
        slug: "sms77_voice",
        display_name_i18n: i18n_key:resource_sms77_voice_name,
        description_i18n: i18n_key:resource_sms77_voice_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 894,
        tooltip_i18n: i18n_key:resource_sms77_voice_tooltip,
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
    service_id: service:sms77,
    is_active: true;

CREATE resource:snowflake_snowflake SET
    identity = {
        name: "snowflake",
        slug: "snowflake_snowflake",
        display_name_i18n: i18n_key:resource_snowflake_snowflake_name,
        description_i18n: i18n_key:resource_snowflake_snowflake_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 895,
        tooltip_i18n: i18n_key:resource_snowflake_snowflake_tooltip,
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
    service_id: service:snowflake,
    is_active: true;

CREATE resource:splitinbatches_splitinbatches SET
    identity = {
        name: "splitinbatches",
        slug: "splitinbatches_splitinbatches",
        display_name_i18n: i18n_key:resource_splitinbatches_splitinbatches_name,
        description_i18n: i18n_key:resource_splitinbatches_splitinbatches_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 896,
        tooltip_i18n: i18n_key:resource_splitinbatches_splitinbatches_tooltip,
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
    service_id: service:splitinbatches,
    is_active: true;

CREATE resource:splitinbatchesv1_splitinbatchesv1 SET
    identity = {
        name: "splitinbatchesv1",
        slug: "splitinbatchesv1_splitinbatchesv1",
        display_name_i18n: i18n_key:resource_splitinbatchesv1_splitinbatchesv1_name,
        description_i18n: i18n_key:resource_splitinbatchesv1_splitinbatchesv1_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 897,
        tooltip_i18n: i18n_key:resource_splitinbatchesv1_splitinbatchesv1_tooltip,
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
    service_id: service:splitinbatchesv1,
    is_active: true;

CREATE resource:splitinbatchesv2_splitinbatchesv2 SET
    identity = {
        name: "splitinbatchesv2",
        slug: "splitinbatchesv2_splitinbatchesv2",
        display_name_i18n: i18n_key:resource_splitinbatchesv2_splitinbatchesv2_name,
        description_i18n: i18n_key:resource_splitinbatchesv2_splitinbatchesv2_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 898,
        tooltip_i18n: i18n_key:resource_splitinbatchesv2_splitinbatchesv2_tooltip,
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
    service_id: service:splitinbatchesv2,
    is_active: true;

CREATE resource:splitinbatchesv3_splitinbatchesv3 SET
    identity = {
        name: "splitinbatchesv3",
        slug: "splitinbatchesv3_splitinbatchesv3",
        display_name_i18n: i18n_key:resource_splitinbatchesv3_splitinbatchesv3_name,
        description_i18n: i18n_key:resource_splitinbatchesv3_splitinbatchesv3_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 899,
        tooltip_i18n: i18n_key:resource_splitinbatchesv3_splitinbatchesv3_tooltip,
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
    service_id: service:splitinbatchesv3,
    is_active: true;

CREATE resource:splunk_splunk SET
    identity = {
        name: "splunk",
        slug: "splunk_splunk",
        display_name_i18n: i18n_key:resource_splunk_splunk_name,
        description_i18n: i18n_key:resource_splunk_splunk_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 900,
        tooltip_i18n: i18n_key:resource_splunk_splunk_tooltip,
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
    service_id: service:splunk,
    is_active: true;

