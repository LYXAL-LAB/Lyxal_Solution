-- Batch 2: 50 ressources Lyxal

CREATE resource:asana_taskComment SET
    identity = {
        name: "taskComment",
        slug: "asana_taskComment",
        display_name_i18n: i18n_key:resource_asana_taskComment_name,
        description_i18n: i18n_key:resource_asana_taskComment_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 51,
        tooltip_i18n: i18n_key:resource_asana_taskComment_tooltip,
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
    service_id: service:asana,
    is_active: true;

CREATE resource:asana_taskProject SET
    identity = {
        name: "taskProject",
        slug: "asana_taskProject",
        display_name_i18n: i18n_key:resource_asana_taskProject_name,
        description_i18n: i18n_key:resource_asana_taskProject_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 52,
        tooltip_i18n: i18n_key:resource_asana_taskProject_tooltip,
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
    service_id: service:asana,
    is_active: true;

CREATE resource:asana_taskTag SET
    identity = {
        name: "taskTag",
        slug: "asana_taskTag",
        display_name_i18n: i18n_key:resource_asana_taskTag_name,
        description_i18n: i18n_key:resource_asana_taskTag_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 53,
        tooltip_i18n: i18n_key:resource_asana_taskTag_tooltip,
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
    service_id: service:asana,
    is_active: true;

CREATE resource:asana_user SET
    identity = {
        name: "user",
        slug: "asana_user",
        display_name_i18n: i18n_key:resource_asana_user_name,
        description_i18n: i18n_key:resource_asana_user_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 54,
        tooltip_i18n: i18n_key:resource_asana_user_tooltip,
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
    service_id: service:asana,
    is_active: true;

CREATE resource:automizy_contact SET
    identity = {
        name: "contact",
        slug: "automizy_contact",
        display_name_i18n: i18n_key:resource_automizy_contact_name,
        description_i18n: i18n_key:resource_automizy_contact_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 55,
        tooltip_i18n: i18n_key:resource_automizy_contact_tooltip,
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
    service_id: service:automizy,
    is_active: true;

CREATE resource:automizy_list SET
    identity = {
        name: "list",
        slug: "automizy_list",
        display_name_i18n: i18n_key:resource_automizy_list_name,
        description_i18n: i18n_key:resource_automizy_list_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 56,
        tooltip_i18n: i18n_key:resource_automizy_list_tooltip,
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
    service_id: service:automizy,
    is_active: true;

CREATE resource:autopilot_contact SET
    identity = {
        name: "contact",
        slug: "autopilot_contact",
        display_name_i18n: i18n_key:resource_autopilot_contact_name,
        description_i18n: i18n_key:resource_autopilot_contact_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 57,
        tooltip_i18n: i18n_key:resource_autopilot_contact_tooltip,
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
    service_id: service:autopilot,
    is_active: true;

CREATE resource:autopilot_contactJourney SET
    identity = {
        name: "contactJourney",
        slug: "autopilot_contactJourney",
        display_name_i18n: i18n_key:resource_autopilot_contactJourney_name,
        description_i18n: i18n_key:resource_autopilot_contactJourney_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 58,
        tooltip_i18n: i18n_key:resource_autopilot_contactJourney_tooltip,
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
    service_id: service:autopilot,
    is_active: true;

CREATE resource:autopilot_contactList SET
    identity = {
        name: "contactList",
        slug: "autopilot_contactList",
        display_name_i18n: i18n_key:resource_autopilot_contactList_name,
        description_i18n: i18n_key:resource_autopilot_contactList_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 59,
        tooltip_i18n: i18n_key:resource_autopilot_contactList_tooltip,
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
    service_id: service:autopilot,
    is_active: true;

CREATE resource:autopilot_list SET
    identity = {
        name: "list",
        slug: "autopilot_list",
        display_name_i18n: i18n_key:resource_autopilot_list_name,
        description_i18n: i18n_key:resource_autopilot_list_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 60,
        tooltip_i18n: i18n_key:resource_autopilot_list_tooltip,
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
    service_id: service:autopilot,
    is_active: true;

CREATE resource:autopilot_contactjourney SET
    identity = {
        name: "contactjourney",
        slug: "autopilot_contactjourney",
        display_name_i18n: i18n_key:resource_autopilot_contactjourney_name,
        description_i18n: i18n_key:resource_autopilot_contactjourney_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 61,
        tooltip_i18n: i18n_key:resource_autopilot_contactjourney_tooltip,
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
    service_id: service:autopilot,
    is_active: true;

CREATE resource:autopilot_contactlist SET
    identity = {
        name: "contactlist",
        slug: "autopilot_contactlist",
        display_name_i18n: i18n_key:resource_autopilot_contactlist_name,
        description_i18n: i18n_key:resource_autopilot_contactlist_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 62,
        tooltip_i18n: i18n_key:resource_autopilot_contactlist_tooltip,
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
    service_id: service:autopilot,
    is_active: true;

CREATE resource:awslambda_awslambda SET
    identity = {
        name: "awslambda",
        slug: "awslambda_awslambda",
        display_name_i18n: i18n_key:resource_awslambda_awslambda_name,
        description_i18n: i18n_key:resource_awslambda_awslambda_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 63,
        tooltip_i18n: i18n_key:resource_awslambda_awslambda_tooltip,
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
    service_id: service:awslambda,
    is_active: true;

CREATE resource:awssns_awssns SET
    identity = {
        name: "awssns",
        slug: "awssns_awssns",
        display_name_i18n: i18n_key:resource_awssns_awssns_name,
        description_i18n: i18n_key:resource_awssns_awssns_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 64,
        tooltip_i18n: i18n_key:resource_awssns_awssns_tooltip,
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
    service_id: service:awssns,
    is_active: true;

CREATE resource:awscertificatemanager_certificate SET
    identity = {
        name: "certificate",
        slug: "awscertificatemanager_certificate",
        display_name_i18n: i18n_key:resource_awscertificatemanager_certificate_name,
        description_i18n: i18n_key:resource_awscertificatemanager_certificate_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 65,
        tooltip_i18n: i18n_key:resource_awscertificatemanager_certificate_tooltip,
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
    service_id: service:awscertificatemanager,
    is_active: true;

CREATE resource:awscognito_group SET
    identity = {
        name: "group",
        slug: "awscognito_group",
        display_name_i18n: i18n_key:resource_awscognito_group_name,
        description_i18n: i18n_key:resource_awscognito_group_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 66,
        tooltip_i18n: i18n_key:resource_awscognito_group_tooltip,
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
    service_id: service:awscognito,
    is_active: true;

CREATE resource:awscognito_user SET
    identity = {
        name: "user",
        slug: "awscognito_user",
        display_name_i18n: i18n_key:resource_awscognito_user_name,
        description_i18n: i18n_key:resource_awscognito_user_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 67,
        tooltip_i18n: i18n_key:resource_awscognito_user_tooltip,
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
    service_id: service:awscognito,
    is_active: true;

CREATE resource:awscognito_userPool SET
    identity = {
        name: "userPool",
        slug: "awscognito_userPool",
        display_name_i18n: i18n_key:resource_awscognito_userPool_name,
        description_i18n: i18n_key:resource_awscognito_userPool_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 68,
        tooltip_i18n: i18n_key:resource_awscognito_userPool_tooltip,
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
    service_id: service:awscognito,
    is_active: true;

CREATE resource:awscomprehend_text SET
    identity = {
        name: "text",
        slug: "awscomprehend_text",
        display_name_i18n: i18n_key:resource_awscomprehend_text_name,
        description_i18n: i18n_key:resource_awscomprehend_text_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 69,
        tooltip_i18n: i18n_key:resource_awscomprehend_text_tooltip,
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
    service_id: service:awscomprehend,
    is_active: true;

CREATE resource:awsdynamodb_item SET
    identity = {
        name: "item",
        slug: "awsdynamodb_item",
        display_name_i18n: i18n_key:resource_awsdynamodb_item_name,
        description_i18n: i18n_key:resource_awsdynamodb_item_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 70,
        tooltip_i18n: i18n_key:resource_awsdynamodb_item_tooltip,
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
    service_id: service:awsdynamodb,
    is_active: true;

CREATE resource:awselb_listenerCertificate SET
    identity = {
        name: "listenerCertificate",
        slug: "awselb_listenerCertificate",
        display_name_i18n: i18n_key:resource_awselb_listenerCertificate_name,
        description_i18n: i18n_key:resource_awselb_listenerCertificate_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 71,
        tooltip_i18n: i18n_key:resource_awselb_listenerCertificate_tooltip,
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
    service_id: service:awselb,
    is_active: true;

CREATE resource:awselb_loadBalancer SET
    identity = {
        name: "loadBalancer",
        slug: "awselb_loadBalancer",
        display_name_i18n: i18n_key:resource_awselb_loadBalancer_name,
        description_i18n: i18n_key:resource_awselb_loadBalancer_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 72,
        tooltip_i18n: i18n_key:resource_awselb_loadBalancer_tooltip,
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
    service_id: service:awselb,
    is_active: true;

CREATE resource:awselb_listenercertificate SET
    identity = {
        name: "listenercertificate",
        slug: "awselb_listenercertificate",
        display_name_i18n: i18n_key:resource_awselb_listenercertificate_name,
        description_i18n: i18n_key:resource_awselb_listenercertificate_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 73,
        tooltip_i18n: i18n_key:resource_awselb_listenercertificate_tooltip,
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
    service_id: service:awselb,
    is_active: true;

CREATE resource:awselb_loadbalancer SET
    identity = {
        name: "loadbalancer",
        slug: "awselb_loadbalancer",
        display_name_i18n: i18n_key:resource_awselb_loadbalancer_name,
        description_i18n: i18n_key:resource_awselb_loadbalancer_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 74,
        tooltip_i18n: i18n_key:resource_awselb_loadbalancer_tooltip,
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
    service_id: service:awselb,
    is_active: true;

CREATE resource:awsiam_user SET
    identity = {
        name: "user",
        slug: "awsiam_user",
        display_name_i18n: i18n_key:resource_awsiam_user_name,
        description_i18n: i18n_key:resource_awsiam_user_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 75,
        tooltip_i18n: i18n_key:resource_awsiam_user_tooltip,
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
    service_id: service:awsiam,
    is_active: true;

CREATE resource:awsiam_group SET
    identity = {
        name: "group",
        slug: "awsiam_group",
        display_name_i18n: i18n_key:resource_awsiam_group_name,
        description_i18n: i18n_key:resource_awsiam_group_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 76,
        tooltip_i18n: i18n_key:resource_awsiam_group_tooltip,
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
    service_id: service:awsiam,
    is_active: true;

CREATE resource:awsrekognition_image SET
    identity = {
        name: "image",
        slug: "awsrekognition_image",
        display_name_i18n: i18n_key:resource_awsrekognition_image_name,
        description_i18n: i18n_key:resource_awsrekognition_image_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 77,
        tooltip_i18n: i18n_key:resource_awsrekognition_image_tooltip,
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
    service_id: service:awsrekognition,
    is_active: true;

CREATE resource:awss3_awss3 SET
    identity = {
        name: "awss3",
        slug: "awss3_awss3",
        display_name_i18n: i18n_key:resource_awss3_awss3_name,
        description_i18n: i18n_key:resource_awss3_awss3_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 78,
        tooltip_i18n: i18n_key:resource_awss3_awss3_tooltip,
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
    service_id: service:awss3,
    is_active: true;

CREATE resource:awss3v1_bucket SET
    identity = {
        name: "bucket",
        slug: "awss3v1_bucket",
        display_name_i18n: i18n_key:resource_awss3v1_bucket_name,
        description_i18n: i18n_key:resource_awss3v1_bucket_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 79,
        tooltip_i18n: i18n_key:resource_awss3v1_bucket_tooltip,
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
    service_id: service:awss3v1,
    is_active: true;

CREATE resource:awss3v1_file SET
    identity = {
        name: "file",
        slug: "awss3v1_file",
        display_name_i18n: i18n_key:resource_awss3v1_file_name,
        description_i18n: i18n_key:resource_awss3v1_file_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 80,
        tooltip_i18n: i18n_key:resource_awss3v1_file_tooltip,
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
    service_id: service:awss3v1,
    is_active: true;

CREATE resource:awss3v1_folder SET
    identity = {
        name: "folder",
        slug: "awss3v1_folder",
        display_name_i18n: i18n_key:resource_awss3v1_folder_name,
        description_i18n: i18n_key:resource_awss3v1_folder_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 81,
        tooltip_i18n: i18n_key:resource_awss3v1_folder_tooltip,
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
    service_id: service:awss3v1,
    is_active: true;

CREATE resource:awss3v2_bucket SET
    identity = {
        name: "bucket",
        slug: "awss3v2_bucket",
        display_name_i18n: i18n_key:resource_awss3v2_bucket_name,
        description_i18n: i18n_key:resource_awss3v2_bucket_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 82,
        tooltip_i18n: i18n_key:resource_awss3v2_bucket_tooltip,
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
    service_id: service:awss3v2,
    is_active: true;

CREATE resource:awss3v2_file SET
    identity = {
        name: "file",
        slug: "awss3v2_file",
        display_name_i18n: i18n_key:resource_awss3v2_file_name,
        description_i18n: i18n_key:resource_awss3v2_file_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 83,
        tooltip_i18n: i18n_key:resource_awss3v2_file_tooltip,
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
    service_id: service:awss3v2,
    is_active: true;

CREATE resource:awss3v2_folder SET
    identity = {
        name: "folder",
        slug: "awss3v2_folder",
        display_name_i18n: i18n_key:resource_awss3v2_folder_name,
        description_i18n: i18n_key:resource_awss3v2_folder_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 84,
        tooltip_i18n: i18n_key:resource_awss3v2_folder_tooltip,
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
    service_id: service:awss3v2,
    is_active: true;

CREATE resource:awsses_customVerificationEmail SET
    identity = {
        name: "customVerificationEmail",
        slug: "awsses_customVerificationEmail",
        display_name_i18n: i18n_key:resource_awsses_customVerificationEmail_name,
        description_i18n: i18n_key:resource_awsses_customVerificationEmail_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 85,
        tooltip_i18n: i18n_key:resource_awsses_customVerificationEmail_tooltip,
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
    service_id: service:awsses,
    is_active: true;

CREATE resource:awsses_email SET
    identity = {
        name: "email",
        slug: "awsses_email",
        display_name_i18n: i18n_key:resource_awsses_email_name,
        description_i18n: i18n_key:resource_awsses_email_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 86,
        tooltip_i18n: i18n_key:resource_awsses_email_tooltip,
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
    service_id: service:awsses,
    is_active: true;

CREATE resource:awsses_template SET
    identity = {
        name: "template",
        slug: "awsses_template",
        display_name_i18n: i18n_key:resource_awsses_template_name,
        description_i18n: i18n_key:resource_awsses_template_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 87,
        tooltip_i18n: i18n_key:resource_awsses_template_tooltip,
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
    service_id: service:awsses,
    is_active: true;

CREATE resource:awssqs_awssqs SET
    identity = {
        name: "awssqs",
        slug: "awssqs_awssqs",
        display_name_i18n: i18n_key:resource_awssqs_awssqs_name,
        description_i18n: i18n_key:resource_awssqs_awssqs_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 88,
        tooltip_i18n: i18n_key:resource_awssqs_awssqs_tooltip,
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
    service_id: service:awssqs,
    is_active: true;

CREATE resource:awstextract_awstextract SET
    identity = {
        name: "awstextract",
        slug: "awstextract_awstextract",
        display_name_i18n: i18n_key:resource_awstextract_awstextract_name,
        description_i18n: i18n_key:resource_awstextract_awstextract_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 89,
        tooltip_i18n: i18n_key:resource_awstextract_awstextract_tooltip,
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
    service_id: service:awstextract,
    is_active: true;

CREATE resource:awstranscribe_transcriptionJob SET
    identity = {
        name: "transcriptionJob",
        slug: "awstranscribe_transcriptionJob",
        display_name_i18n: i18n_key:resource_awstranscribe_transcriptionJob_name,
        description_i18n: i18n_key:resource_awstranscribe_transcriptionJob_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 90,
        tooltip_i18n: i18n_key:resource_awstranscribe_transcriptionJob_tooltip,
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
    service_id: service:awstranscribe,
    is_active: true;

CREATE resource:bamboohr_bamboohr SET
    identity = {
        name: "bamboohr",
        slug: "bamboohr_bamboohr",
        display_name_i18n: i18n_key:resource_bamboohr_bamboohr_name,
        description_i18n: i18n_key:resource_bamboohr_bamboohr_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 91,
        tooltip_i18n: i18n_key:resource_bamboohr_bamboohr_tooltip,
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
    service_id: service:bamboohr,
    is_active: true;

CREATE resource:bannerbear_image SET
    identity = {
        name: "image",
        slug: "bannerbear_image",
        display_name_i18n: i18n_key:resource_bannerbear_image_name,
        description_i18n: i18n_key:resource_bannerbear_image_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 92,
        tooltip_i18n: i18n_key:resource_bannerbear_image_tooltip,
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
    service_id: service:bannerbear,
    is_active: true;

CREATE resource:bannerbear_template SET
    identity = {
        name: "template",
        slug: "bannerbear_template",
        display_name_i18n: i18n_key:resource_bannerbear_template_name,
        description_i18n: i18n_key:resource_bannerbear_template_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 93,
        tooltip_i18n: i18n_key:resource_bannerbear_template_tooltip,
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
    service_id: service:bannerbear,
    is_active: true;

CREATE resource:baserow_row SET
    identity = {
        name: "row",
        slug: "baserow_row",
        display_name_i18n: i18n_key:resource_baserow_row_name,
        description_i18n: i18n_key:resource_baserow_row_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 94,
        tooltip_i18n: i18n_key:resource_baserow_row_tooltip,
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
    service_id: service:baserow,
    is_active: true;

CREATE resource:baserow_operation SET
    identity = {
        name: "operation",
        slug: "baserow_operation",
        display_name_i18n: i18n_key:resource_baserow_operation_name,
        description_i18n: i18n_key:resource_baserow_operation_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 95,
        tooltip_i18n: i18n_key:resource_baserow_operation_tooltip,
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
    service_id: service:baserow,
    is_active: true;

CREATE resource:beeminder_charge SET
    identity = {
        name: "charge",
        slug: "beeminder_charge",
        display_name_i18n: i18n_key:resource_beeminder_charge_name,
        description_i18n: i18n_key:resource_beeminder_charge_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 96,
        tooltip_i18n: i18n_key:resource_beeminder_charge_tooltip,
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
    service_id: service:beeminder,
    is_active: true;

CREATE resource:beeminder_datapoint SET
    identity = {
        name: "datapoint",
        slug: "beeminder_datapoint",
        display_name_i18n: i18n_key:resource_beeminder_datapoint_name,
        description_i18n: i18n_key:resource_beeminder_datapoint_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 97,
        tooltip_i18n: i18n_key:resource_beeminder_datapoint_tooltip,
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
    service_id: service:beeminder,
    is_active: true;

CREATE resource:beeminder_goal SET
    identity = {
        name: "goal",
        slug: "beeminder_goal",
        display_name_i18n: i18n_key:resource_beeminder_goal_name,
        description_i18n: i18n_key:resource_beeminder_goal_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 98,
        tooltip_i18n: i18n_key:resource_beeminder_goal_tooltip,
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
    service_id: service:beeminder,
    is_active: true;

CREATE resource:beeminder_user SET
    identity = {
        name: "user",
        slug: "beeminder_user",
        display_name_i18n: i18n_key:resource_beeminder_user_name,
        description_i18n: i18n_key:resource_beeminder_user_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 99,
        tooltip_i18n: i18n_key:resource_beeminder_user_tooltip,
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
    service_id: service:beeminder,
    is_active: true;

CREATE resource:bitly_link SET
    identity = {
        name: "link",
        slug: "bitly_link",
        display_name_i18n: i18n_key:resource_bitly_link_name,
        description_i18n: i18n_key:resource_bitly_link_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 100,
        tooltip_i18n: i18n_key:resource_bitly_link_tooltip,
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
    service_id: service:bitly,
    is_active: true;

