-- Batch 14: 50 ressources Lyxal

CREATE resource:movebinarydata_movebinarydata SET
    identity = {
        name: "movebinarydata",
        slug: "movebinarydata_movebinarydata",
        display_name_i18n: i18n_key:resource_movebinarydata_movebinarydata_name,
        description_i18n: i18n_key:resource_movebinarydata_movebinarydata_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 651,
        tooltip_i18n: i18n_key:resource_movebinarydata_movebinarydata_tooltip,
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
    service_id: service:movebinarydata,
    is_active: true;

CREATE resource:mqtt_mqtt SET
    identity = {
        name: "mqtt",
        slug: "mqtt_mqtt",
        display_name_i18n: i18n_key:resource_mqtt_mqtt_name,
        description_i18n: i18n_key:resource_mqtt_mqtt_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 652,
        tooltip_i18n: i18n_key:resource_mqtt_mqtt_tooltip,
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
    service_id: service:mqtt,
    is_active: true;

CREATE resource:msg91_sms SET
    identity = {
        name: "sms",
        slug: "msg91_sms",
        display_name_i18n: i18n_key:resource_msg91_sms_name,
        description_i18n: i18n_key:resource_msg91_sms_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 653,
        tooltip_i18n: i18n_key:resource_msg91_sms_tooltip,
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
    service_id: service:msg91,
    is_active: true;

CREATE resource:mysql_mysql SET
    identity = {
        name: "mysql",
        slug: "mysql_mysql",
        display_name_i18n: i18n_key:resource_mysql_mysql_name,
        description_i18n: i18n_key:resource_mysql_mysql_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 654,
        tooltip_i18n: i18n_key:resource_mysql_mysql_tooltip,
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
    service_id: service:mysql,
    is_active: true;

CREATE resource:mysqlv1_mysqlv1 SET
    identity = {
        name: "mysqlv1",
        slug: "mysqlv1_mysqlv1",
        display_name_i18n: i18n_key:resource_mysqlv1_mysqlv1_name,
        description_i18n: i18n_key:resource_mysqlv1_mysqlv1_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 655,
        tooltip_i18n: i18n_key:resource_mysqlv1_mysqlv1_tooltip,
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
    service_id: service:mysqlv1,
    is_active: true;

CREATE resource:mysqlv2_mysqlv2 SET
    identity = {
        name: "mysqlv2",
        slug: "mysqlv2_mysqlv2",
        display_name_i18n: i18n_key:resource_mysqlv2_mysqlv2_name,
        description_i18n: i18n_key:resource_mysqlv2_mysqlv2_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 656,
        tooltip_i18n: i18n_key:resource_mysqlv2_mysqlv2_tooltip,
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
    service_id: service:mysqlv2,
    is_active: true;

CREATE resource:n8n_audit SET
    identity = {
        name: "audit",
        slug: "n8n_audit",
        display_name_i18n: i18n_key:resource_n8n_audit_name,
        description_i18n: i18n_key:resource_n8n_audit_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 657,
        tooltip_i18n: i18n_key:resource_n8n_audit_tooltip,
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
    service_id: service:n8n,
    is_active: true;

CREATE resource:n8n_credential SET
    identity = {
        name: "credential",
        slug: "n8n_credential",
        display_name_i18n: i18n_key:resource_n8n_credential_name,
        description_i18n: i18n_key:resource_n8n_credential_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 658,
        tooltip_i18n: i18n_key:resource_n8n_credential_tooltip,
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
    service_id: service:n8n,
    is_active: true;

CREATE resource:n8n_execution SET
    identity = {
        name: "execution",
        slug: "n8n_execution",
        display_name_i18n: i18n_key:resource_n8n_execution_name,
        description_i18n: i18n_key:resource_n8n_execution_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 659,
        tooltip_i18n: i18n_key:resource_n8n_execution_tooltip,
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
    service_id: service:n8n,
    is_active: true;

CREATE resource:n8n_workflow SET
    identity = {
        name: "workflow",
        slug: "n8n_workflow",
        display_name_i18n: i18n_key:resource_n8n_workflow_name,
        description_i18n: i18n_key:resource_n8n_workflow_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 660,
        tooltip_i18n: i18n_key:resource_n8n_workflow_tooltip,
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
    service_id: service:n8n,
    is_active: true;

CREATE resource:n8ntrainingcustomerdatastore_n8ntrainingcustomerdatastore SET
    identity = {
        name: "n8ntrainingcustomerdatastore",
        slug: "n8ntrainingcustomerdatastore_n8ntrainingcustomerdatastore",
        display_name_i18n: i18n_key:resource_n8ntrainingcustomerdatastore_n8ntrainingcustomerdatastore_name,
        description_i18n: i18n_key:resource_n8ntrainingcustomerdatastore_n8ntrainingcustomerdatastore_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 661,
        tooltip_i18n: i18n_key:resource_n8ntrainingcustomerdatastore_n8ntrainingcustomerdatastore_tooltip,
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
    service_id: service:n8ntrainingcustomerdatastore,
    is_active: true;

CREATE resource:n8ntrainingcustomermessenger_n8ntrainingcustomermessenger SET
    identity = {
        name: "n8ntrainingcustomermessenger",
        slug: "n8ntrainingcustomermessenger_n8ntrainingcustomermessenger",
        display_name_i18n: i18n_key:resource_n8ntrainingcustomermessenger_n8ntrainingcustomermessenger_name,
        description_i18n: i18n_key:resource_n8ntrainingcustomermessenger_n8ntrainingcustomermessenger_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 662,
        tooltip_i18n: i18n_key:resource_n8ntrainingcustomermessenger_n8ntrainingcustomermessenger_tooltip,
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
    service_id: service:n8ntrainingcustomermessenger,
    is_active: true;

CREATE resource:nasa_asteroidNeoBrowse SET
    identity = {
        name: "asteroidNeoBrowse",
        slug: "nasa_asteroidNeoBrowse",
        display_name_i18n: i18n_key:resource_nasa_asteroidNeoBrowse_name,
        description_i18n: i18n_key:resource_nasa_asteroidNeoBrowse_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 663,
        tooltip_i18n: i18n_key:resource_nasa_asteroidNeoBrowse_tooltip,
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
    service_id: service:nasa,
    is_active: true;

CREATE resource:nasa_asteroidNeoFeed SET
    identity = {
        name: "asteroidNeoFeed",
        slug: "nasa_asteroidNeoFeed",
        display_name_i18n: i18n_key:resource_nasa_asteroidNeoFeed_name,
        description_i18n: i18n_key:resource_nasa_asteroidNeoFeed_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 664,
        tooltip_i18n: i18n_key:resource_nasa_asteroidNeoFeed_tooltip,
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
    service_id: service:nasa,
    is_active: true;

CREATE resource:nasa_asteroidNeoLookup SET
    identity = {
        name: "asteroidNeoLookup",
        slug: "nasa_asteroidNeoLookup",
        display_name_i18n: i18n_key:resource_nasa_asteroidNeoLookup_name,
        description_i18n: i18n_key:resource_nasa_asteroidNeoLookup_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 665,
        tooltip_i18n: i18n_key:resource_nasa_asteroidNeoLookup_tooltip,
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
    service_id: service:nasa,
    is_active: true;

CREATE resource:nasa_astronomyPictureOfTheDay SET
    identity = {
        name: "astronomyPictureOfTheDay",
        slug: "nasa_astronomyPictureOfTheDay",
        display_name_i18n: i18n_key:resource_nasa_astronomyPictureOfTheDay_name,
        description_i18n: i18n_key:resource_nasa_astronomyPictureOfTheDay_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 666,
        tooltip_i18n: i18n_key:resource_nasa_astronomyPictureOfTheDay_tooltip,
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
    service_id: service:nasa,
    is_active: true;

CREATE resource:nasa_donkiCoronalMassEjection SET
    identity = {
        name: "donkiCoronalMassEjection",
        slug: "nasa_donkiCoronalMassEjection",
        display_name_i18n: i18n_key:resource_nasa_donkiCoronalMassEjection_name,
        description_i18n: i18n_key:resource_nasa_donkiCoronalMassEjection_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 667,
        tooltip_i18n: i18n_key:resource_nasa_donkiCoronalMassEjection_tooltip,
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
    service_id: service:nasa,
    is_active: true;

CREATE resource:nasa_donkiHighSpeedStream SET
    identity = {
        name: "donkiHighSpeedStream",
        slug: "nasa_donkiHighSpeedStream",
        display_name_i18n: i18n_key:resource_nasa_donkiHighSpeedStream_name,
        description_i18n: i18n_key:resource_nasa_donkiHighSpeedStream_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 668,
        tooltip_i18n: i18n_key:resource_nasa_donkiHighSpeedStream_tooltip,
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
    service_id: service:nasa,
    is_active: true;

CREATE resource:nasa_donkiInterplanetaryShock SET
    identity = {
        name: "donkiInterplanetaryShock",
        slug: "nasa_donkiInterplanetaryShock",
        display_name_i18n: i18n_key:resource_nasa_donkiInterplanetaryShock_name,
        description_i18n: i18n_key:resource_nasa_donkiInterplanetaryShock_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 669,
        tooltip_i18n: i18n_key:resource_nasa_donkiInterplanetaryShock_tooltip,
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
    service_id: service:nasa,
    is_active: true;

CREATE resource:nasa_donkiMagnetopauseCrossing SET
    identity = {
        name: "donkiMagnetopauseCrossing",
        slug: "nasa_donkiMagnetopauseCrossing",
        display_name_i18n: i18n_key:resource_nasa_donkiMagnetopauseCrossing_name,
        description_i18n: i18n_key:resource_nasa_donkiMagnetopauseCrossing_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 670,
        tooltip_i18n: i18n_key:resource_nasa_donkiMagnetopauseCrossing_tooltip,
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
    service_id: service:nasa,
    is_active: true;

CREATE resource:nasa_donkiNotifications SET
    identity = {
        name: "donkiNotifications",
        slug: "nasa_donkiNotifications",
        display_name_i18n: i18n_key:resource_nasa_donkiNotifications_name,
        description_i18n: i18n_key:resource_nasa_donkiNotifications_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 671,
        tooltip_i18n: i18n_key:resource_nasa_donkiNotifications_tooltip,
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
    service_id: service:nasa,
    is_active: true;

CREATE resource:nasa_donkiRadiationBeltEnhancement SET
    identity = {
        name: "donkiRadiationBeltEnhancement",
        slug: "nasa_donkiRadiationBeltEnhancement",
        display_name_i18n: i18n_key:resource_nasa_donkiRadiationBeltEnhancement_name,
        description_i18n: i18n_key:resource_nasa_donkiRadiationBeltEnhancement_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 672,
        tooltip_i18n: i18n_key:resource_nasa_donkiRadiationBeltEnhancement_tooltip,
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
    service_id: service:nasa,
    is_active: true;

CREATE resource:nasa_donkiSolarEnergeticParticle SET
    identity = {
        name: "donkiSolarEnergeticParticle",
        slug: "nasa_donkiSolarEnergeticParticle",
        display_name_i18n: i18n_key:resource_nasa_donkiSolarEnergeticParticle_name,
        description_i18n: i18n_key:resource_nasa_donkiSolarEnergeticParticle_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 673,
        tooltip_i18n: i18n_key:resource_nasa_donkiSolarEnergeticParticle_tooltip,
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
    service_id: service:nasa,
    is_active: true;

CREATE resource:nasa_donkiSolarFlare SET
    identity = {
        name: "donkiSolarFlare",
        slug: "nasa_donkiSolarFlare",
        display_name_i18n: i18n_key:resource_nasa_donkiSolarFlare_name,
        description_i18n: i18n_key:resource_nasa_donkiSolarFlare_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 674,
        tooltip_i18n: i18n_key:resource_nasa_donkiSolarFlare_tooltip,
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
    service_id: service:nasa,
    is_active: true;

CREATE resource:nasa_donkiWsaEnlilSimulation SET
    identity = {
        name: "donkiWsaEnlilSimulation",
        slug: "nasa_donkiWsaEnlilSimulation",
        display_name_i18n: i18n_key:resource_nasa_donkiWsaEnlilSimulation_name,
        description_i18n: i18n_key:resource_nasa_donkiWsaEnlilSimulation_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 675,
        tooltip_i18n: i18n_key:resource_nasa_donkiWsaEnlilSimulation_tooltip,
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
    service_id: service:nasa,
    is_active: true;

CREATE resource:nasa_earthAssets SET
    identity = {
        name: "earthAssets",
        slug: "nasa_earthAssets",
        display_name_i18n: i18n_key:resource_nasa_earthAssets_name,
        description_i18n: i18n_key:resource_nasa_earthAssets_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 676,
        tooltip_i18n: i18n_key:resource_nasa_earthAssets_tooltip,
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
    service_id: service:nasa,
    is_active: true;

CREATE resource:nasa_earthImagery SET
    identity = {
        name: "earthImagery",
        slug: "nasa_earthImagery",
        display_name_i18n: i18n_key:resource_nasa_earthImagery_name,
        description_i18n: i18n_key:resource_nasa_earthImagery_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 677,
        tooltip_i18n: i18n_key:resource_nasa_earthImagery_tooltip,
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
    service_id: service:nasa,
    is_active: true;

CREATE resource:netlify_deploy SET
    identity = {
        name: "deploy",
        slug: "netlify_deploy",
        display_name_i18n: i18n_key:resource_netlify_deploy_name,
        description_i18n: i18n_key:resource_netlify_deploy_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 678,
        tooltip_i18n: i18n_key:resource_netlify_deploy_tooltip,
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
    service_id: service:netlify,
    is_active: true;

CREATE resource:netlify_site SET
    identity = {
        name: "site",
        slug: "netlify_site",
        display_name_i18n: i18n_key:resource_netlify_site_name,
        description_i18n: i18n_key:resource_netlify_site_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 679,
        tooltip_i18n: i18n_key:resource_netlify_site_tooltip,
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
    service_id: service:netlify,
    is_active: true;

CREATE resource:netscaleradc_certificate SET
    identity = {
        name: "certificate",
        slug: "netscaleradc_certificate",
        display_name_i18n: i18n_key:resource_netscaleradc_certificate_name,
        description_i18n: i18n_key:resource_netscaleradc_certificate_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 680,
        tooltip_i18n: i18n_key:resource_netscaleradc_certificate_tooltip,
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
    service_id: service:netscaleradc,
    is_active: true;

CREATE resource:netscaleradc_file SET
    identity = {
        name: "file",
        slug: "netscaleradc_file",
        display_name_i18n: i18n_key:resource_netscaleradc_file_name,
        description_i18n: i18n_key:resource_netscaleradc_file_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 681,
        tooltip_i18n: i18n_key:resource_netscaleradc_file_tooltip,
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
    service_id: service:netscaleradc,
    is_active: true;

CREATE resource:nextcloud_file SET
    identity = {
        name: "file",
        slug: "nextcloud_file",
        display_name_i18n: i18n_key:resource_nextcloud_file_name,
        description_i18n: i18n_key:resource_nextcloud_file_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 682,
        tooltip_i18n: i18n_key:resource_nextcloud_file_tooltip,
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
    service_id: service:nextcloud,
    is_active: true;

CREATE resource:nextcloud_folder SET
    identity = {
        name: "folder",
        slug: "nextcloud_folder",
        display_name_i18n: i18n_key:resource_nextcloud_folder_name,
        description_i18n: i18n_key:resource_nextcloud_folder_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 683,
        tooltip_i18n: i18n_key:resource_nextcloud_folder_tooltip,
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
    service_id: service:nextcloud,
    is_active: true;

CREATE resource:nextcloud_user SET
    identity = {
        name: "user",
        slug: "nextcloud_user",
        display_name_i18n: i18n_key:resource_nextcloud_user_name,
        description_i18n: i18n_key:resource_nextcloud_user_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 684,
        tooltip_i18n: i18n_key:resource_nextcloud_user_tooltip,
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
    service_id: service:nextcloud,
    is_active: true;

CREATE resource:nocodb_row SET
    identity = {
        name: "row",
        slug: "nocodb_row",
        display_name_i18n: i18n_key:resource_nocodb_row_name,
        description_i18n: i18n_key:resource_nocodb_row_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 685,
        tooltip_i18n: i18n_key:resource_nocodb_row_tooltip,
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
    service_id: service:nocodb,
    is_active: true;

CREATE resource:nocodb_operation SET
    identity = {
        name: "operation",
        slug: "nocodb_operation",
        display_name_i18n: i18n_key:resource_nocodb_operation_name,
        description_i18n: i18n_key:resource_nocodb_operation_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 686,
        tooltip_i18n: i18n_key:resource_nocodb_operation_tooltip,
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
    service_id: service:nocodb,
    is_active: true;

CREATE resource:noop_noop SET
    identity = {
        name: "noop",
        slug: "noop_noop",
        display_name_i18n: i18n_key:resource_noop_noop_name,
        description_i18n: i18n_key:resource_noop_noop_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 687,
        tooltip_i18n: i18n_key:resource_noop_noop_tooltip,
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
    service_id: service:noop,
    is_active: true;

CREATE resource:notion_notion SET
    identity = {
        name: "notion",
        slug: "notion_notion",
        display_name_i18n: i18n_key:resource_notion_notion_name,
        description_i18n: i18n_key:resource_notion_notion_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 688,
        tooltip_i18n: i18n_key:resource_notion_notion_tooltip,
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
    service_id: service:notion,
    is_active: true;

CREATE resource:notionv1_version SET
    identity = {
        name: "version",
        slug: "notionv1_version",
        display_name_i18n: i18n_key:resource_notionv1_version_name,
        description_i18n: i18n_key:resource_notionv1_version_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 689,
        tooltip_i18n: i18n_key:resource_notionv1_version_tooltip,
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
    service_id: service:notionv1,
    is_active: true;

CREATE resource:notionv2_version SET
    identity = {
        name: "version",
        slug: "notionv2_version",
        display_name_i18n: i18n_key:resource_notionv2_version_name,
        description_i18n: i18n_key:resource_notionv2_version_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 690,
        tooltip_i18n: i18n_key:resource_notionv2_version_tooltip,
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
    service_id: service:notionv2,
    is_active: true;

CREATE resource:npm_package SET
    identity = {
        name: "package",
        slug: "npm_package",
        display_name_i18n: i18n_key:resource_npm_package_name,
        description_i18n: i18n_key:resource_npm_package_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 691,
        tooltip_i18n: i18n_key:resource_npm_package_tooltip,
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
    service_id: service:npm,
    is_active: true;

CREATE resource:npm_distTag SET
    identity = {
        name: "distTag",
        slug: "npm_distTag",
        display_name_i18n: i18n_key:resource_npm_distTag_name,
        description_i18n: i18n_key:resource_npm_distTag_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 692,
        tooltip_i18n: i18n_key:resource_npm_distTag_tooltip,
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
    service_id: service:npm,
    is_active: true;

CREATE resource:npm_disttag SET
    identity = {
        name: "disttag",
        slug: "npm_disttag",
        display_name_i18n: i18n_key:resource_npm_disttag_name,
        description_i18n: i18n_key:resource_npm_disttag_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 693,
        tooltip_i18n: i18n_key:resource_npm_disttag_tooltip,
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
    service_id: service:npm,
    is_active: true;

CREATE resource:odoo_contact SET
    identity = {
        name: "contact",
        slug: "odoo_contact",
        display_name_i18n: i18n_key:resource_odoo_contact_name,
        description_i18n: i18n_key:resource_odoo_contact_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 694,
        tooltip_i18n: i18n_key:resource_odoo_contact_tooltip,
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
    service_id: service:odoo,
    is_active: true;

CREATE resource:odoo_custom SET
    identity = {
        name: "custom",
        slug: "odoo_custom",
        display_name_i18n: i18n_key:resource_odoo_custom_name,
        description_i18n: i18n_key:resource_odoo_custom_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 695,
        tooltip_i18n: i18n_key:resource_odoo_custom_tooltip,
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
    service_id: service:odoo,
    is_active: true;

CREATE resource:odoo_note SET
    identity = {
        name: "note",
        slug: "odoo_note",
        display_name_i18n: i18n_key:resource_odoo_note_name,
        description_i18n: i18n_key:resource_odoo_note_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 696,
        tooltip_i18n: i18n_key:resource_odoo_note_tooltip,
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
    service_id: service:odoo,
    is_active: true;

CREATE resource:odoo_opportunity SET
    identity = {
        name: "opportunity",
        slug: "odoo_opportunity",
        display_name_i18n: i18n_key:resource_odoo_opportunity_name,
        description_i18n: i18n_key:resource_odoo_opportunity_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 697,
        tooltip_i18n: i18n_key:resource_odoo_opportunity_tooltip,
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
    service_id: service:odoo,
    is_active: true;

CREATE resource:okta_user SET
    identity = {
        name: "user",
        slug: "okta_user",
        display_name_i18n: i18n_key:resource_okta_user_name,
        description_i18n: i18n_key:resource_okta_user_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 698,
        tooltip_i18n: i18n_key:resource_okta_user_tooltip,
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
    service_id: service:okta,
    is_active: true;

CREATE resource:onesimpleapi_information SET
    identity = {
        name: "information",
        slug: "onesimpleapi_information",
        display_name_i18n: i18n_key:resource_onesimpleapi_information_name,
        description_i18n: i18n_key:resource_onesimpleapi_information_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 699,
        tooltip_i18n: i18n_key:resource_onesimpleapi_information_tooltip,
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
    service_id: service:onesimpleapi,
    is_active: true;

CREATE resource:onesimpleapi_socialProfile SET
    identity = {
        name: "socialProfile",
        slug: "onesimpleapi_socialProfile",
        display_name_i18n: i18n_key:resource_onesimpleapi_socialProfile_name,
        description_i18n: i18n_key:resource_onesimpleapi_socialProfile_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 700,
        tooltip_i18n: i18n_key:resource_onesimpleapi_socialProfile_tooltip,
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
    service_id: service:onesimpleapi,
    is_active: true;

