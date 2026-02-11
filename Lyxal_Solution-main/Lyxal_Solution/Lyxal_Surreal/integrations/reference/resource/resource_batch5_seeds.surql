-- Batch 5: 50 ressources Lyxal

CREATE resource:datetimev2_currentdate SET
    identity = {
        name: "currentdate",
        slug: "datetimev2_currentdate",
        display_name_i18n: i18n_key:resource_datetimev2_currentdate_name,
        description_i18n: i18n_key:resource_datetimev2_currentdate_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 201,
        tooltip_i18n: i18n_key:resource_datetimev2_currentdate_tooltip,
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
    service_id: service:datetimev2,
    is_active: true;

CREATE resource:datetimev2_extractdate SET
    identity = {
        name: "extractdate",
        slug: "datetimev2_extractdate",
        display_name_i18n: i18n_key:resource_datetimev2_extractdate_name,
        description_i18n: i18n_key:resource_datetimev2_extractdate_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 202,
        tooltip_i18n: i18n_key:resource_datetimev2_extractdate_tooltip,
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
    service_id: service:datetimev2,
    is_active: true;

CREATE resource:datetimev2_formatdate SET
    identity = {
        name: "formatdate",
        slug: "datetimev2_formatdate",
        display_name_i18n: i18n_key:resource_datetimev2_formatdate_name,
        description_i18n: i18n_key:resource_datetimev2_formatdate_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 203,
        tooltip_i18n: i18n_key:resource_datetimev2_formatdate_tooltip,
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
    service_id: service:datetimev2,
    is_active: true;

CREATE resource:datetimev2_rounddate SET
    identity = {
        name: "rounddate",
        slug: "datetimev2_rounddate",
        display_name_i18n: i18n_key:resource_datetimev2_rounddate_name,
        description_i18n: i18n_key:resource_datetimev2_rounddate_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 204,
        tooltip_i18n: i18n_key:resource_datetimev2_rounddate_tooltip,
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
    service_id: service:datetimev2,
    is_active: true;

CREATE resource:datetimev2_subtractfromdate SET
    identity = {
        name: "subtractfromdate",
        slug: "datetimev2_subtractfromdate",
        display_name_i18n: i18n_key:resource_datetimev2_subtractfromdate_name,
        description_i18n: i18n_key:resource_datetimev2_subtractfromdate_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 205,
        tooltip_i18n: i18n_key:resource_datetimev2_subtractfromdate_tooltip,
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
    service_id: service:datetimev2,
    is_active: true;

CREATE resource:debughelper_debughelper SET
    identity = {
        name: "debughelper",
        slug: "debughelper_debughelper",
        display_name_i18n: i18n_key:resource_debughelper_debughelper_name,
        description_i18n: i18n_key:resource_debughelper_debughelper_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 206,
        tooltip_i18n: i18n_key:resource_debughelper_debughelper_tooltip,
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
    service_id: service:debughelper,
    is_active: true;

CREATE resource:deepl_language SET
    identity = {
        name: "language",
        slug: "deepl_language",
        display_name_i18n: i18n_key:resource_deepl_language_name,
        description_i18n: i18n_key:resource_deepl_language_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 207,
        tooltip_i18n: i18n_key:resource_deepl_language_tooltip,
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
    service_id: service:deepl,
    is_active: true;

CREATE resource:deepl_text SET
    identity = {
        name: "text",
        slug: "deepl_text",
        display_name_i18n: i18n_key:resource_deepl_text_name,
        description_i18n: i18n_key:resource_deepl_text_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 208,
        tooltip_i18n: i18n_key:resource_deepl_text_tooltip,
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
    service_id: service:deepl,
    is_active: true;

CREATE resource:demio_event SET
    identity = {
        name: "event",
        slug: "demio_event",
        display_name_i18n: i18n_key:resource_demio_event_name,
        description_i18n: i18n_key:resource_demio_event_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 209,
        tooltip_i18n: i18n_key:resource_demio_event_tooltip,
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
    service_id: service:demio,
    is_active: true;

CREATE resource:demio_report SET
    identity = {
        name: "report",
        slug: "demio_report",
        display_name_i18n: i18n_key:resource_demio_report_name,
        description_i18n: i18n_key:resource_demio_report_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 210,
        tooltip_i18n: i18n_key:resource_demio_report_tooltip,
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
    service_id: service:demio,
    is_active: true;

CREATE resource:dhl_shipment SET
    identity = {
        name: "shipment",
        slug: "dhl_shipment",
        display_name_i18n: i18n_key:resource_dhl_shipment_name,
        description_i18n: i18n_key:resource_dhl_shipment_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 211,
        tooltip_i18n: i18n_key:resource_dhl_shipment_tooltip,
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
    service_id: service:dhl,
    is_active: true;

CREATE resource:discord_discord SET
    identity = {
        name: "discord",
        slug: "discord_discord",
        display_name_i18n: i18n_key:resource_discord_discord_name,
        description_i18n: i18n_key:resource_discord_discord_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 212,
        tooltip_i18n: i18n_key:resource_discord_discord_tooltip,
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
    service_id: service:discord,
    is_active: true;

CREATE resource:discordv1_discordv1 SET
    identity = {
        name: "discordv1",
        slug: "discordv1_discordv1",
        display_name_i18n: i18n_key:resource_discordv1_discordv1_name,
        description_i18n: i18n_key:resource_discordv1_discordv1_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 213,
        tooltip_i18n: i18n_key:resource_discordv1_discordv1_tooltip,
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
    service_id: service:discordv1,
    is_active: true;

CREATE resource:discordv2_discordv2 SET
    identity = {
        name: "discordv2",
        slug: "discordv2_discordv2",
        display_name_i18n: i18n_key:resource_discordv2_discordv2_name,
        description_i18n: i18n_key:resource_discordv2_discordv2_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 214,
        tooltip_i18n: i18n_key:resource_discordv2_discordv2_tooltip,
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
    service_id: service:discordv2,
    is_active: true;

CREATE resource:discourse_category SET
    identity = {
        name: "category",
        slug: "discourse_category",
        display_name_i18n: i18n_key:resource_discourse_category_name,
        description_i18n: i18n_key:resource_discourse_category_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 215,
        tooltip_i18n: i18n_key:resource_discourse_category_tooltip,
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
    service_id: service:discourse,
    is_active: true;

CREATE resource:discourse_group SET
    identity = {
        name: "group",
        slug: "discourse_group",
        display_name_i18n: i18n_key:resource_discourse_group_name,
        description_i18n: i18n_key:resource_discourse_group_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 216,
        tooltip_i18n: i18n_key:resource_discourse_group_tooltip,
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
    service_id: service:discourse,
    is_active: true;

CREATE resource:discourse_post SET
    identity = {
        name: "post",
        slug: "discourse_post",
        display_name_i18n: i18n_key:resource_discourse_post_name,
        description_i18n: i18n_key:resource_discourse_post_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 217,
        tooltip_i18n: i18n_key:resource_discourse_post_tooltip,
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
    service_id: service:discourse,
    is_active: true;

CREATE resource:discourse_user SET
    identity = {
        name: "user",
        slug: "discourse_user",
        display_name_i18n: i18n_key:resource_discourse_user_name,
        description_i18n: i18n_key:resource_discourse_user_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 218,
        tooltip_i18n: i18n_key:resource_discourse_user_tooltip,
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
    service_id: service:discourse,
    is_active: true;

CREATE resource:discourse_userGroup SET
    identity = {
        name: "userGroup",
        slug: "discourse_userGroup",
        display_name_i18n: i18n_key:resource_discourse_userGroup_name,
        description_i18n: i18n_key:resource_discourse_userGroup_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 219,
        tooltip_i18n: i18n_key:resource_discourse_userGroup_tooltip,
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
    service_id: service:discourse,
    is_active: true;

CREATE resource:discourse_usergroup SET
    identity = {
        name: "usergroup",
        slug: "discourse_usergroup",
        display_name_i18n: i18n_key:resource_discourse_usergroup_name,
        description_i18n: i18n_key:resource_discourse_usergroup_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 220,
        tooltip_i18n: i18n_key:resource_discourse_usergroup_tooltip,
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
    service_id: service:discourse,
    is_active: true;

CREATE resource:disqus_forum SET
    identity = {
        name: "forum",
        slug: "disqus_forum",
        display_name_i18n: i18n_key:resource_disqus_forum_name,
        description_i18n: i18n_key:resource_disqus_forum_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 221,
        tooltip_i18n: i18n_key:resource_disqus_forum_tooltip,
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
    service_id: service:disqus,
    is_active: true;

CREATE resource:drift_contact SET
    identity = {
        name: "contact",
        slug: "drift_contact",
        display_name_i18n: i18n_key:resource_drift_contact_name,
        description_i18n: i18n_key:resource_drift_contact_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 222,
        tooltip_i18n: i18n_key:resource_drift_contact_tooltip,
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
    service_id: service:drift,
    is_active: true;

CREATE resource:dropbox_file SET
    identity = {
        name: "file",
        slug: "dropbox_file",
        display_name_i18n: i18n_key:resource_dropbox_file_name,
        description_i18n: i18n_key:resource_dropbox_file_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 223,
        tooltip_i18n: i18n_key:resource_dropbox_file_tooltip,
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
    service_id: service:dropbox,
    is_active: true;

CREATE resource:dropbox_folder SET
    identity = {
        name: "folder",
        slug: "dropbox_folder",
        display_name_i18n: i18n_key:resource_dropbox_folder_name,
        description_i18n: i18n_key:resource_dropbox_folder_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 224,
        tooltip_i18n: i18n_key:resource_dropbox_folder_tooltip,
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
    service_id: service:dropbox,
    is_active: true;

CREATE resource:dropbox_search SET
    identity = {
        name: "search",
        slug: "dropbox_search",
        display_name_i18n: i18n_key:resource_dropbox_search_name,
        description_i18n: i18n_key:resource_dropbox_search_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 225,
        tooltip_i18n: i18n_key:resource_dropbox_search_tooltip,
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
    service_id: service:dropbox,
    is_active: true;

CREATE resource:dropcontact_dropcontact SET
    identity = {
        name: "dropcontact",
        slug: "dropcontact_dropcontact",
        display_name_i18n: i18n_key:resource_dropcontact_dropcontact_name,
        description_i18n: i18n_key:resource_dropcontact_dropcontact_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 226,
        tooltip_i18n: i18n_key:resource_dropcontact_dropcontact_tooltip,
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
    service_id: service:dropcontact,
    is_active: true;

CREATE resource:editimage_editimage SET
    identity = {
        name: "editimage",
        slug: "editimage_editimage",
        display_name_i18n: i18n_key:resource_editimage_editimage_name,
        description_i18n: i18n_key:resource_editimage_editimage_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 227,
        tooltip_i18n: i18n_key:resource_editimage_editimage_tooltip,
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
    service_id: service:editimage,
    is_active: true;

CREATE resource:egoi_contact SET
    identity = {
        name: "contact",
        slug: "egoi_contact",
        display_name_i18n: i18n_key:resource_egoi_contact_name,
        description_i18n: i18n_key:resource_egoi_contact_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 228,
        tooltip_i18n: i18n_key:resource_egoi_contact_tooltip,
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
    service_id: service:egoi,
    is_active: true;

CREATE resource:elasticsearch_document SET
    identity = {
        name: "document",
        slug: "elasticsearch_document",
        display_name_i18n: i18n_key:resource_elasticsearch_document_name,
        description_i18n: i18n_key:resource_elasticsearch_document_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 229,
        tooltip_i18n: i18n_key:resource_elasticsearch_document_tooltip,
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
    service_id: service:elasticsearch,
    is_active: true;

CREATE resource:elasticsearch_index SET
    identity = {
        name: "index",
        slug: "elasticsearch_index",
        display_name_i18n: i18n_key:resource_elasticsearch_index_name,
        description_i18n: i18n_key:resource_elasticsearch_index_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 230,
        tooltip_i18n: i18n_key:resource_elasticsearch_index_tooltip,
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
    service_id: service:elasticsearch,
    is_active: true;

CREATE resource:elasticsecurity_case SET
    identity = {
        name: "case",
        slug: "elasticsecurity_case",
        display_name_i18n: i18n_key:resource_elasticsecurity_case_name,
        description_i18n: i18n_key:resource_elasticsecurity_case_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 231,
        tooltip_i18n: i18n_key:resource_elasticsecurity_case_tooltip,
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
    service_id: service:elasticsecurity,
    is_active: true;

CREATE resource:elasticsecurity_caseComment SET
    identity = {
        name: "caseComment",
        slug: "elasticsecurity_caseComment",
        display_name_i18n: i18n_key:resource_elasticsecurity_caseComment_name,
        description_i18n: i18n_key:resource_elasticsecurity_caseComment_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 232,
        tooltip_i18n: i18n_key:resource_elasticsecurity_caseComment_tooltip,
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
    service_id: service:elasticsecurity,
    is_active: true;

CREATE resource:elasticsecurity_caseTag SET
    identity = {
        name: "caseTag",
        slug: "elasticsecurity_caseTag",
        display_name_i18n: i18n_key:resource_elasticsecurity_caseTag_name,
        description_i18n: i18n_key:resource_elasticsecurity_caseTag_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 233,
        tooltip_i18n: i18n_key:resource_elasticsecurity_caseTag_tooltip,
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
    service_id: service:elasticsecurity,
    is_active: true;

CREATE resource:elasticsecurity_connector SET
    identity = {
        name: "connector",
        slug: "elasticsecurity_connector",
        display_name_i18n: i18n_key:resource_elasticsecurity_connector_name,
        description_i18n: i18n_key:resource_elasticsecurity_connector_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 234,
        tooltip_i18n: i18n_key:resource_elasticsecurity_connector_tooltip,
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
    service_id: service:elasticsecurity,
    is_active: true;

CREATE resource:emailreadimap_emailreadimap SET
    identity = {
        name: "emailreadimap",
        slug: "emailreadimap_emailreadimap",
        display_name_i18n: i18n_key:resource_emailreadimap_emailreadimap_name,
        description_i18n: i18n_key:resource_emailreadimap_emailreadimap_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 235,
        tooltip_i18n: i18n_key:resource_emailreadimap_emailreadimap_tooltip,
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
    service_id: service:emailreadimap,
    is_active: true;

CREATE resource:emailreadimapv1_emailreadimapv1 SET
    identity = {
        name: "emailreadimapv1",
        slug: "emailreadimapv1_emailreadimapv1",
        display_name_i18n: i18n_key:resource_emailreadimapv1_emailreadimapv1_name,
        description_i18n: i18n_key:resource_emailreadimapv1_emailreadimapv1_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 236,
        tooltip_i18n: i18n_key:resource_emailreadimapv1_emailreadimapv1_tooltip,
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
    service_id: service:emailreadimapv1,
    is_active: true;

CREATE resource:emailreadimapv2_emailreadimapv2 SET
    identity = {
        name: "emailreadimapv2",
        slug: "emailreadimapv2_emailreadimapv2",
        display_name_i18n: i18n_key:resource_emailreadimapv2_emailreadimapv2_name,
        description_i18n: i18n_key:resource_emailreadimapv2_emailreadimapv2_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 237,
        tooltip_i18n: i18n_key:resource_emailreadimapv2_emailreadimapv2_tooltip,
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
    service_id: service:emailreadimapv2,
    is_active: true;

CREATE resource:emailsend_emailsend SET
    identity = {
        name: "emailsend",
        slug: "emailsend_emailsend",
        display_name_i18n: i18n_key:resource_emailsend_emailsend_name,
        description_i18n: i18n_key:resource_emailsend_emailsend_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 238,
        tooltip_i18n: i18n_key:resource_emailsend_emailsend_tooltip,
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
    service_id: service:emailsend,
    is_active: true;

CREATE resource:emailsendv1_emailsendv1 SET
    identity = {
        name: "emailsendv1",
        slug: "emailsendv1_emailsendv1",
        display_name_i18n: i18n_key:resource_emailsendv1_emailsendv1_name,
        description_i18n: i18n_key:resource_emailsendv1_emailsendv1_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 239,
        tooltip_i18n: i18n_key:resource_emailsendv1_emailsendv1_tooltip,
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
    service_id: service:emailsendv1,
    is_active: true;

CREATE resource:emailsendv2_email SET
    identity = {
        name: "email",
        slug: "emailsendv2_email",
        display_name_i18n: i18n_key:resource_emailsendv2_email_name,
        description_i18n: i18n_key:resource_emailsendv2_email_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 240,
        tooltip_i18n: i18n_key:resource_emailsendv2_email_tooltip,
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
    service_id: service:emailsendv2,
    is_active: true;

CREATE resource:emelia_campaign SET
    identity = {
        name: "campaign",
        slug: "emelia_campaign",
        display_name_i18n: i18n_key:resource_emelia_campaign_name,
        description_i18n: i18n_key:resource_emelia_campaign_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 241,
        tooltip_i18n: i18n_key:resource_emelia_campaign_tooltip,
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
    service_id: service:emelia,
    is_active: true;

CREATE resource:emelia_contactList SET
    identity = {
        name: "contactList",
        slug: "emelia_contactList",
        display_name_i18n: i18n_key:resource_emelia_contactList_name,
        description_i18n: i18n_key:resource_emelia_contactList_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 242,
        tooltip_i18n: i18n_key:resource_emelia_contactList_tooltip,
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
    service_id: service:emelia,
    is_active: true;

CREATE resource:emelia_contactlist SET
    identity = {
        name: "contactlist",
        slug: "emelia_contactlist",
        display_name_i18n: i18n_key:resource_emelia_contactlist_name,
        description_i18n: i18n_key:resource_emelia_contactlist_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 243,
        tooltip_i18n: i18n_key:resource_emelia_contactlist_tooltip,
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
    service_id: service:emelia,
    is_active: true;

CREATE resource:erpnext_document SET
    identity = {
        name: "document",
        slug: "erpnext_document",
        display_name_i18n: i18n_key:resource_erpnext_document_name,
        description_i18n: i18n_key:resource_erpnext_document_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 244,
        tooltip_i18n: i18n_key:resource_erpnext_document_tooltip,
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
    service_id: service:erpnext,
    is_active: true;

CREATE resource:description_description SET
    identity = {
        name: "description",
        slug: "description_description",
        display_name_i18n: i18n_key:resource_description_description_name,
        description_i18n: i18n_key:resource_description_description_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 245,
        tooltip_i18n: i18n_key:resource_description_description_tooltip,
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
    service_id: service:description,
    is_active: true;

CREATE resource:executecommand_executecommand SET
    identity = {
        name: "executecommand",
        slug: "executecommand_executecommand",
        display_name_i18n: i18n_key:resource_executecommand_executecommand_name,
        description_i18n: i18n_key:resource_executecommand_executecommand_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 246,
        tooltip_i18n: i18n_key:resource_executecommand_executecommand_tooltip,
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
    service_id: service:executecommand,
    is_active: true;

CREATE resource:executeworkflow_executeworkflow SET
    identity = {
        name: "executeworkflow",
        slug: "executeworkflow_executeworkflow",
        display_name_i18n: i18n_key:resource_executeworkflow_executeworkflow_name,
        description_i18n: i18n_key:resource_executeworkflow_executeworkflow_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 247,
        tooltip_i18n: i18n_key:resource_executeworkflow_executeworkflow_tooltip,
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
    service_id: service:executeworkflow,
    is_active: true;

CREATE resource:executiondata_executiondata SET
    identity = {
        name: "executiondata",
        slug: "executiondata_executiondata",
        display_name_i18n: i18n_key:resource_executiondata_executiondata_name,
        description_i18n: i18n_key:resource_executiondata_executiondata_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 248,
        tooltip_i18n: i18n_key:resource_executiondata_executiondata_tooltip,
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
    service_id: service:executiondata,
    is_active: true;

CREATE resource:facebookgraphapi_facebookgraphapi SET
    identity = {
        name: "facebookgraphapi",
        slug: "facebookgraphapi_facebookgraphapi",
        display_name_i18n: i18n_key:resource_facebookgraphapi_facebookgraphapi_name,
        description_i18n: i18n_key:resource_facebookgraphapi_facebookgraphapi_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 249,
        tooltip_i18n: i18n_key:resource_facebookgraphapi_facebookgraphapi_tooltip,
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
    service_id: service:facebookgraphapi,
    is_active: true;

CREATE resource:filemaker_filemaker SET
    identity = {
        name: "filemaker",
        slug: "filemaker_filemaker",
        display_name_i18n: i18n_key:resource_filemaker_filemaker_name,
        description_i18n: i18n_key:resource_filemaker_filemaker_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 250,
        tooltip_i18n: i18n_key:resource_filemaker_filemaker_tooltip,
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
    service_id: service:filemaker,
    is_active: true;

