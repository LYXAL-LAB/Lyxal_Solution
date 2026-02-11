-- Batch 21: 50 ressources Lyxal

CREATE resource:twitterv1_tweet SET
    identity = {
        name: "tweet",
        slug: "twitterv1_tweet",
        display_name_i18n: i18n_key:resource_twitterv1_tweet_name,
        description_i18n: i18n_key:resource_twitterv1_tweet_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 1001,
        tooltip_i18n: i18n_key:resource_twitterv1_tweet_tooltip,
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
    service_id: service:twitterv1,
    is_active: true;

CREATE resource:twitterv1_directmessage SET
    identity = {
        name: "directmessage",
        slug: "twitterv1_directmessage",
        display_name_i18n: i18n_key:resource_twitterv1_directmessage_name,
        description_i18n: i18n_key:resource_twitterv1_directmessage_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 1002,
        tooltip_i18n: i18n_key:resource_twitterv1_directmessage_tooltip,
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
    service_id: service:twitterv1,
    is_active: true;

CREATE resource:twitterv2_directMessage SET
    identity = {
        name: "directMessage",
        slug: "twitterv2_directMessage",
        display_name_i18n: i18n_key:resource_twitterv2_directMessage_name,
        description_i18n: i18n_key:resource_twitterv2_directMessage_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 1003,
        tooltip_i18n: i18n_key:resource_twitterv2_directMessage_tooltip,
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
    service_id: service:twitterv2,
    is_active: true;

CREATE resource:twitterv2_list SET
    identity = {
        name: "list",
        slug: "twitterv2_list",
        display_name_i18n: i18n_key:resource_twitterv2_list_name,
        description_i18n: i18n_key:resource_twitterv2_list_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 1004,
        tooltip_i18n: i18n_key:resource_twitterv2_list_tooltip,
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
    service_id: service:twitterv2,
    is_active: true;

CREATE resource:twitterv2_tweet SET
    identity = {
        name: "tweet",
        slug: "twitterv2_tweet",
        display_name_i18n: i18n_key:resource_twitterv2_tweet_name,
        description_i18n: i18n_key:resource_twitterv2_tweet_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 1005,
        tooltip_i18n: i18n_key:resource_twitterv2_tweet_tooltip,
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
    service_id: service:twitterv2,
    is_active: true;

CREATE resource:twitterv2_user SET
    identity = {
        name: "user",
        slug: "twitterv2_user",
        display_name_i18n: i18n_key:resource_twitterv2_user_name,
        description_i18n: i18n_key:resource_twitterv2_user_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 1006,
        tooltip_i18n: i18n_key:resource_twitterv2_user_tooltip,
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
    service_id: service:twitterv2,
    is_active: true;

CREATE resource:twitterv2_directmessage SET
    identity = {
        name: "directmessage",
        slug: "twitterv2_directmessage",
        display_name_i18n: i18n_key:resource_twitterv2_directmessage_name,
        description_i18n: i18n_key:resource_twitterv2_directmessage_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 1007,
        tooltip_i18n: i18n_key:resource_twitterv2_directmessage_tooltip,
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
    service_id: service:twitterv2,
    is_active: true;

CREATE resource:unleashedsoftware_salesOrder SET
    identity = {
        name: "salesOrder",
        slug: "unleashedsoftware_salesOrder",
        display_name_i18n: i18n_key:resource_unleashedsoftware_salesOrder_name,
        description_i18n: i18n_key:resource_unleashedsoftware_salesOrder_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 1008,
        tooltip_i18n: i18n_key:resource_unleashedsoftware_salesOrder_tooltip,
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
    service_id: service:unleashedsoftware,
    is_active: true;

CREATE resource:unleashedsoftware_stockOnHand SET
    identity = {
        name: "stockOnHand",
        slug: "unleashedsoftware_stockOnHand",
        display_name_i18n: i18n_key:resource_unleashedsoftware_stockOnHand_name,
        description_i18n: i18n_key:resource_unleashedsoftware_stockOnHand_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 1009,
        tooltip_i18n: i18n_key:resource_unleashedsoftware_stockOnHand_tooltip,
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
    service_id: service:unleashedsoftware,
    is_active: true;

CREATE resource:unleashedsoftware_salesorder SET
    identity = {
        name: "salesorder",
        slug: "unleashedsoftware_salesorder",
        display_name_i18n: i18n_key:resource_unleashedsoftware_salesorder_name,
        description_i18n: i18n_key:resource_unleashedsoftware_salesorder_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 1010,
        tooltip_i18n: i18n_key:resource_unleashedsoftware_salesorder_tooltip,
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
    service_id: service:unleashedsoftware,
    is_active: true;

CREATE resource:unleashedsoftware_stockonhand SET
    identity = {
        name: "stockonhand",
        slug: "unleashedsoftware_stockonhand",
        display_name_i18n: i18n_key:resource_unleashedsoftware_stockonhand_name,
        description_i18n: i18n_key:resource_unleashedsoftware_stockonhand_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 1011,
        tooltip_i18n: i18n_key:resource_unleashedsoftware_stockonhand_tooltip,
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
    service_id: service:unleashedsoftware,
    is_active: true;

CREATE resource:uplead_company SET
    identity = {
        name: "company",
        slug: "uplead_company",
        display_name_i18n: i18n_key:resource_uplead_company_name,
        description_i18n: i18n_key:resource_uplead_company_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 1012,
        tooltip_i18n: i18n_key:resource_uplead_company_tooltip,
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
    service_id: service:uplead,
    is_active: true;

CREATE resource:uplead_person SET
    identity = {
        name: "person",
        slug: "uplead_person",
        display_name_i18n: i18n_key:resource_uplead_person_name,
        description_i18n: i18n_key:resource_uplead_person_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 1013,
        tooltip_i18n: i18n_key:resource_uplead_person_tooltip,
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
    service_id: service:uplead,
    is_active: true;

CREATE resource:uproc_group SET
    identity = {
        name: "group",
        slug: "uproc_group",
        display_name_i18n: i18n_key:resource_uproc_group_name,
        description_i18n: i18n_key:resource_uproc_group_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 1014,
        tooltip_i18n: i18n_key:resource_uproc_group_tooltip,
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
    service_id: service:uproc,
    is_active: true;

CREATE resource:uproc_tool SET
    identity = {
        name: "tool",
        slug: "uproc_tool",
        display_name_i18n: i18n_key:resource_uproc_tool_name,
        description_i18n: i18n_key:resource_uproc_tool_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 1015,
        tooltip_i18n: i18n_key:resource_uproc_tool_tooltip,
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
    service_id: service:uproc,
    is_active: true;

CREATE resource:uptimerobot_account SET
    identity = {
        name: "account",
        slug: "uptimerobot_account",
        display_name_i18n: i18n_key:resource_uptimerobot_account_name,
        description_i18n: i18n_key:resource_uptimerobot_account_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 1016,
        tooltip_i18n: i18n_key:resource_uptimerobot_account_tooltip,
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
    service_id: service:uptimerobot,
    is_active: true;

CREATE resource:uptimerobot_alertContact SET
    identity = {
        name: "alertContact",
        slug: "uptimerobot_alertContact",
        display_name_i18n: i18n_key:resource_uptimerobot_alertContact_name,
        description_i18n: i18n_key:resource_uptimerobot_alertContact_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 1017,
        tooltip_i18n: i18n_key:resource_uptimerobot_alertContact_tooltip,
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
    service_id: service:uptimerobot,
    is_active: true;

CREATE resource:uptimerobot_maintenanceWindow SET
    identity = {
        name: "maintenanceWindow",
        slug: "uptimerobot_maintenanceWindow",
        display_name_i18n: i18n_key:resource_uptimerobot_maintenanceWindow_name,
        description_i18n: i18n_key:resource_uptimerobot_maintenanceWindow_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 1018,
        tooltip_i18n: i18n_key:resource_uptimerobot_maintenanceWindow_tooltip,
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
    service_id: service:uptimerobot,
    is_active: true;

CREATE resource:uptimerobot_monitor SET
    identity = {
        name: "monitor",
        slug: "uptimerobot_monitor",
        display_name_i18n: i18n_key:resource_uptimerobot_monitor_name,
        description_i18n: i18n_key:resource_uptimerobot_monitor_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 1019,
        tooltip_i18n: i18n_key:resource_uptimerobot_monitor_tooltip,
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
    service_id: service:uptimerobot,
    is_active: true;

CREATE resource:uptimerobot_publicStatusPage SET
    identity = {
        name: "publicStatusPage",
        slug: "uptimerobot_publicStatusPage",
        display_name_i18n: i18n_key:resource_uptimerobot_publicStatusPage_name,
        description_i18n: i18n_key:resource_uptimerobot_publicStatusPage_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 1020,
        tooltip_i18n: i18n_key:resource_uptimerobot_publicStatusPage_tooltip,
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
    service_id: service:uptimerobot,
    is_active: true;

CREATE resource:uptimerobot_alertcontact SET
    identity = {
        name: "alertcontact",
        slug: "uptimerobot_alertcontact",
        display_name_i18n: i18n_key:resource_uptimerobot_alertcontact_name,
        description_i18n: i18n_key:resource_uptimerobot_alertcontact_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 1021,
        tooltip_i18n: i18n_key:resource_uptimerobot_alertcontact_tooltip,
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
    service_id: service:uptimerobot,
    is_active: true;

CREATE resource:uptimerobot_maintenancewindow SET
    identity = {
        name: "maintenancewindow",
        slug: "uptimerobot_maintenancewindow",
        display_name_i18n: i18n_key:resource_uptimerobot_maintenancewindow_name,
        description_i18n: i18n_key:resource_uptimerobot_maintenancewindow_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 1022,
        tooltip_i18n: i18n_key:resource_uptimerobot_maintenancewindow_tooltip,
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
    service_id: service:uptimerobot,
    is_active: true;

CREATE resource:uptimerobot_publicstatuspage SET
    identity = {
        name: "publicstatuspage",
        slug: "uptimerobot_publicstatuspage",
        display_name_i18n: i18n_key:resource_uptimerobot_publicstatuspage_name,
        description_i18n: i18n_key:resource_uptimerobot_publicstatuspage_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 1023,
        tooltip_i18n: i18n_key:resource_uptimerobot_publicstatuspage_tooltip,
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
    service_id: service:uptimerobot,
    is_active: true;

CREATE resource:urlscanio_scan SET
    identity = {
        name: "scan",
        slug: "urlscanio_scan",
        display_name_i18n: i18n_key:resource_urlscanio_scan_name,
        description_i18n: i18n_key:resource_urlscanio_scan_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 1024,
        tooltip_i18n: i18n_key:resource_urlscanio_scan_tooltip,
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
    service_id: service:urlscanio,
    is_active: true;

CREATE resource:venafitlsprotectdatacenter_certificate SET
    identity = {
        name: "certificate",
        slug: "venafitlsprotectdatacenter_certificate",
        display_name_i18n: i18n_key:resource_venafitlsprotectdatacenter_certificate_name,
        description_i18n: i18n_key:resource_venafitlsprotectdatacenter_certificate_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 1025,
        tooltip_i18n: i18n_key:resource_venafitlsprotectdatacenter_certificate_tooltip,
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
    service_id: service:venafitlsprotectdatacenter,
    is_active: true;

CREATE resource:venafitlsprotectdatacenter_policy SET
    identity = {
        name: "policy",
        slug: "venafitlsprotectdatacenter_policy",
        display_name_i18n: i18n_key:resource_venafitlsprotectdatacenter_policy_name,
        description_i18n: i18n_key:resource_venafitlsprotectdatacenter_policy_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 1026,
        tooltip_i18n: i18n_key:resource_venafitlsprotectdatacenter_policy_tooltip,
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
    service_id: service:venafitlsprotectdatacenter,
    is_active: true;

CREATE resource:venafitlsprotectcloud_certificate SET
    identity = {
        name: "certificate",
        slug: "venafitlsprotectcloud_certificate",
        display_name_i18n: i18n_key:resource_venafitlsprotectcloud_certificate_name,
        description_i18n: i18n_key:resource_venafitlsprotectcloud_certificate_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 1027,
        tooltip_i18n: i18n_key:resource_venafitlsprotectcloud_certificate_tooltip,
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
    service_id: service:venafitlsprotectcloud,
    is_active: true;

CREATE resource:venafitlsprotectcloud_certificateRequest SET
    identity = {
        name: "certificateRequest",
        slug: "venafitlsprotectcloud_certificateRequest",
        display_name_i18n: i18n_key:resource_venafitlsprotectcloud_certificateRequest_name,
        description_i18n: i18n_key:resource_venafitlsprotectcloud_certificateRequest_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 1028,
        tooltip_i18n: i18n_key:resource_venafitlsprotectcloud_certificateRequest_tooltip,
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
    service_id: service:venafitlsprotectcloud,
    is_active: true;

CREATE resource:venafitlsprotectcloud_certificaterequest SET
    identity = {
        name: "certificaterequest",
        slug: "venafitlsprotectcloud_certificaterequest",
        display_name_i18n: i18n_key:resource_venafitlsprotectcloud_certificaterequest_name,
        description_i18n: i18n_key:resource_venafitlsprotectcloud_certificaterequest_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 1029,
        tooltip_i18n: i18n_key:resource_venafitlsprotectcloud_certificaterequest_tooltip,
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
    service_id: service:venafitlsprotectcloud,
    is_active: true;

CREATE resource:vero_user SET
    identity = {
        name: "user",
        slug: "vero_user",
        display_name_i18n: i18n_key:resource_vero_user_name,
        description_i18n: i18n_key:resource_vero_user_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 1030,
        tooltip_i18n: i18n_key:resource_vero_user_tooltip,
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
    service_id: service:vero,
    is_active: true;

CREATE resource:vero_event SET
    identity = {
        name: "event",
        slug: "vero_event",
        display_name_i18n: i18n_key:resource_vero_event_name,
        description_i18n: i18n_key:resource_vero_event_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 1031,
        tooltip_i18n: i18n_key:resource_vero_event_tooltip,
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
    service_id: service:vero,
    is_active: true;

CREATE resource:vonage_sms SET
    identity = {
        name: "sms",
        slug: "vonage_sms",
        display_name_i18n: i18n_key:resource_vonage_sms_name,
        description_i18n: i18n_key:resource_vonage_sms_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 1032,
        tooltip_i18n: i18n_key:resource_vonage_sms_tooltip,
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
    service_id: service:vonage,
    is_active: true;

CREATE resource:wait_wait SET
    identity = {
        name: "wait",
        slug: "wait_wait",
        display_name_i18n: i18n_key:resource_wait_wait_name,
        description_i18n: i18n_key:resource_wait_wait_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 1033,
        tooltip_i18n: i18n_key:resource_wait_wait_tooltip,
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
    service_id: service:wait,
    is_active: true;

CREATE resource:webflow_webflow SET
    identity = {
        name: "webflow",
        slug: "webflow_webflow",
        display_name_i18n: i18n_key:resource_webflow_webflow_name,
        description_i18n: i18n_key:resource_webflow_webflow_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 1034,
        tooltip_i18n: i18n_key:resource_webflow_webflow_tooltip,
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
    service_id: service:webflow,
    is_active: true;

CREATE resource:webflowv1_item SET
    identity = {
        name: "item",
        slug: "webflowv1_item",
        display_name_i18n: i18n_key:resource_webflowv1_item_name,
        description_i18n: i18n_key:resource_webflowv1_item_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 1035,
        tooltip_i18n: i18n_key:resource_webflowv1_item_tooltip,
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
    service_id: service:webflowv1,
    is_active: true;

CREATE resource:webflowv2_webflowv2 SET
    identity = {
        name: "webflowv2",
        slug: "webflowv2_webflowv2",
        display_name_i18n: i18n_key:resource_webflowv2_webflowv2_name,
        description_i18n: i18n_key:resource_webflowv2_webflowv2_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 1036,
        tooltip_i18n: i18n_key:resource_webflowv2_webflowv2_tooltip,
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
    service_id: service:webflowv2,
    is_active: true;

CREATE resource:webhook_webhook SET
    identity = {
        name: "webhook",
        slug: "webhook_webhook",
        display_name_i18n: i18n_key:resource_webhook_webhook_name,
        description_i18n: i18n_key:resource_webhook_webhook_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 1037,
        tooltip_i18n: i18n_key:resource_webhook_webhook_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: false,
            supports_read: true,
            supports_update: false,
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
    service_id: service:webhook,
    is_active: true;

CREATE resource:wekan_board SET
    identity = {
        name: "board",
        slug: "wekan_board",
        display_name_i18n: i18n_key:resource_wekan_board_name,
        description_i18n: i18n_key:resource_wekan_board_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 1038,
        tooltip_i18n: i18n_key:resource_wekan_board_tooltip,
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
    service_id: service:wekan,
    is_active: true;

CREATE resource:wekan_card SET
    identity = {
        name: "card",
        slug: "wekan_card",
        display_name_i18n: i18n_key:resource_wekan_card_name,
        description_i18n: i18n_key:resource_wekan_card_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 1039,
        tooltip_i18n: i18n_key:resource_wekan_card_tooltip,
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
    service_id: service:wekan,
    is_active: true;

CREATE resource:wekan_cardComment SET
    identity = {
        name: "cardComment",
        slug: "wekan_cardComment",
        display_name_i18n: i18n_key:resource_wekan_cardComment_name,
        description_i18n: i18n_key:resource_wekan_cardComment_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 1040,
        tooltip_i18n: i18n_key:resource_wekan_cardComment_tooltip,
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
    service_id: service:wekan,
    is_active: true;

CREATE resource:wekan_checklist SET
    identity = {
        name: "checklist",
        slug: "wekan_checklist",
        display_name_i18n: i18n_key:resource_wekan_checklist_name,
        description_i18n: i18n_key:resource_wekan_checklist_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 1041,
        tooltip_i18n: i18n_key:resource_wekan_checklist_tooltip,
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
    service_id: service:wekan,
    is_active: true;

CREATE resource:wekan_checklistItem SET
    identity = {
        name: "checklistItem",
        slug: "wekan_checklistItem",
        display_name_i18n: i18n_key:resource_wekan_checklistItem_name,
        description_i18n: i18n_key:resource_wekan_checklistItem_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 1042,
        tooltip_i18n: i18n_key:resource_wekan_checklistItem_tooltip,
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
    service_id: service:wekan,
    is_active: true;

CREATE resource:wekan_list SET
    identity = {
        name: "list",
        slug: "wekan_list",
        display_name_i18n: i18n_key:resource_wekan_list_name,
        description_i18n: i18n_key:resource_wekan_list_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 1043,
        tooltip_i18n: i18n_key:resource_wekan_list_tooltip,
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
    service_id: service:wekan,
    is_active: true;

CREATE resource:wekan_cardcomment SET
    identity = {
        name: "cardcomment",
        slug: "wekan_cardcomment",
        display_name_i18n: i18n_key:resource_wekan_cardcomment_name,
        description_i18n: i18n_key:resource_wekan_cardcomment_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 1044,
        tooltip_i18n: i18n_key:resource_wekan_cardcomment_tooltip,
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
    service_id: service:wekan,
    is_active: true;

CREATE resource:wekan_checklistitem SET
    identity = {
        name: "checklistitem",
        slug: "wekan_checklistitem",
        display_name_i18n: i18n_key:resource_wekan_checklistitem_name,
        description_i18n: i18n_key:resource_wekan_checklistitem_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 1045,
        tooltip_i18n: i18n_key:resource_wekan_checklistitem_tooltip,
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
    service_id: service:wekan,
    is_active: true;

CREATE resource:whatsapp_message SET
    identity = {
        name: "message",
        slug: "whatsapp_message",
        display_name_i18n: i18n_key:resource_whatsapp_message_name,
        description_i18n: i18n_key:resource_whatsapp_message_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 1046,
        tooltip_i18n: i18n_key:resource_whatsapp_message_tooltip,
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
    service_id: service:whatsapp,
    is_active: true;

CREATE resource:whatsapp_media SET
    identity = {
        name: "media",
        slug: "whatsapp_media",
        display_name_i18n: i18n_key:resource_whatsapp_media_name,
        description_i18n: i18n_key:resource_whatsapp_media_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 1047,
        tooltip_i18n: i18n_key:resource_whatsapp_media_tooltip,
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
    service_id: service:whatsapp,
    is_active: true;

CREATE resource:whatsapp_messages SET
    identity = {
        name: "messages",
        slug: "whatsapp_messages",
        display_name_i18n: i18n_key:resource_whatsapp_messages_name,
        description_i18n: i18n_key:resource_whatsapp_messages_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 1048,
        tooltip_i18n: i18n_key:resource_whatsapp_messages_tooltip,
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
    service_id: service:whatsapp,
    is_active: true;

CREATE resource:wise_account SET
    identity = {
        name: "account",
        slug: "wise_account",
        display_name_i18n: i18n_key:resource_wise_account_name,
        description_i18n: i18n_key:resource_wise_account_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 1049,
        tooltip_i18n: i18n_key:resource_wise_account_tooltip,
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
    service_id: service:wise,
    is_active: true;

CREATE resource:wise_exchangeRate SET
    identity = {
        name: "exchangeRate",
        slug: "wise_exchangeRate",
        display_name_i18n: i18n_key:resource_wise_exchangeRate_name,
        description_i18n: i18n_key:resource_wise_exchangeRate_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 1050,
        tooltip_i18n: i18n_key:resource_wise_exchangeRate_tooltip,
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
    service_id: service:wise,
    is_active: true;

