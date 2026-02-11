-- Batch 12: 50 ressources Lyxal

CREATE resource:mautic_contact SET
    identity = {
        name: "contact",
        slug: "mautic_contact",
        display_name_i18n: i18n_key:resource_mautic_contact_name,
        description_i18n: i18n_key:resource_mautic_contact_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 551,
        tooltip_i18n: i18n_key:resource_mautic_contact_tooltip,
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
    service_id: service:mautic,
    is_active: true;

CREATE resource:mautic_contactSegment SET
    identity = {
        name: "contactSegment",
        slug: "mautic_contactSegment",
        display_name_i18n: i18n_key:resource_mautic_contactSegment_name,
        description_i18n: i18n_key:resource_mautic_contactSegment_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 552,
        tooltip_i18n: i18n_key:resource_mautic_contactSegment_tooltip,
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
    service_id: service:mautic,
    is_active: true;

CREATE resource:mautic_segmentEmail SET
    identity = {
        name: "segmentEmail",
        slug: "mautic_segmentEmail",
        display_name_i18n: i18n_key:resource_mautic_segmentEmail_name,
        description_i18n: i18n_key:resource_mautic_segmentEmail_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 553,
        tooltip_i18n: i18n_key:resource_mautic_segmentEmail_tooltip,
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
    service_id: service:mautic,
    is_active: true;

CREATE resource:mautic_campaigncontact SET
    identity = {
        name: "campaigncontact",
        slug: "mautic_campaigncontact",
        display_name_i18n: i18n_key:resource_mautic_campaigncontact_name,
        description_i18n: i18n_key:resource_mautic_campaigncontact_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 554,
        tooltip_i18n: i18n_key:resource_mautic_campaigncontact_tooltip,
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
    service_id: service:mautic,
    is_active: true;

CREATE resource:mautic_companycontact SET
    identity = {
        name: "companycontact",
        slug: "mautic_companycontact",
        display_name_i18n: i18n_key:resource_mautic_companycontact_name,
        description_i18n: i18n_key:resource_mautic_companycontact_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 555,
        tooltip_i18n: i18n_key:resource_mautic_companycontact_tooltip,
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
    service_id: service:mautic,
    is_active: true;

CREATE resource:mautic_contactsegment SET
    identity = {
        name: "contactsegment",
        slug: "mautic_contactsegment",
        display_name_i18n: i18n_key:resource_mautic_contactsegment_name,
        description_i18n: i18n_key:resource_mautic_contactsegment_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 556,
        tooltip_i18n: i18n_key:resource_mautic_contactsegment_tooltip,
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
    service_id: service:mautic,
    is_active: true;

CREATE resource:mautic_segmentemail SET
    identity = {
        name: "segmentemail",
        slug: "mautic_segmentemail",
        display_name_i18n: i18n_key:resource_mautic_segmentemail_name,
        description_i18n: i18n_key:resource_mautic_segmentemail_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 557,
        tooltip_i18n: i18n_key:resource_mautic_segmentemail_tooltip,
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
    service_id: service:mautic,
    is_active: true;

CREATE resource:medium_post SET
    identity = {
        name: "post",
        slug: "medium_post",
        display_name_i18n: i18n_key:resource_medium_post_name,
        description_i18n: i18n_key:resource_medium_post_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 558,
        tooltip_i18n: i18n_key:resource_medium_post_tooltip,
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
    service_id: service:medium,
    is_active: true;

CREATE resource:medium_publication SET
    identity = {
        name: "publication",
        slug: "medium_publication",
        display_name_i18n: i18n_key:resource_medium_publication_name,
        description_i18n: i18n_key:resource_medium_publication_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 559,
        tooltip_i18n: i18n_key:resource_medium_publication_tooltip,
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
    service_id: service:medium,
    is_active: true;

CREATE resource:merge_merge SET
    identity = {
        name: "merge",
        slug: "merge_merge",
        display_name_i18n: i18n_key:resource_merge_merge_name,
        description_i18n: i18n_key:resource_merge_merge_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 560,
        tooltip_i18n: i18n_key:resource_merge_merge_tooltip,
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
    service_id: service:merge,
    is_active: true;

CREATE resource:mergev1_mergev1 SET
    identity = {
        name: "mergev1",
        slug: "mergev1_mergev1",
        display_name_i18n: i18n_key:resource_mergev1_mergev1_name,
        description_i18n: i18n_key:resource_mergev1_mergev1_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 561,
        tooltip_i18n: i18n_key:resource_mergev1_mergev1_tooltip,
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
    service_id: service:mergev1,
    is_active: true;

CREATE resource:mergev2_mergev2 SET
    identity = {
        name: "mergev2",
        slug: "mergev2_mergev2",
        display_name_i18n: i18n_key:resource_mergev2_mergev2_name,
        description_i18n: i18n_key:resource_mergev2_mergev2_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 562,
        tooltip_i18n: i18n_key:resource_mergev2_mergev2_tooltip,
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
    service_id: service:mergev2,
    is_active: true;

CREATE resource:mergev3_mergev3 SET
    identity = {
        name: "mergev3",
        slug: "mergev3_mergev3",
        display_name_i18n: i18n_key:resource_mergev3_mergev3_name,
        description_i18n: i18n_key:resource_mergev3_mergev3_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 563,
        tooltip_i18n: i18n_key:resource_mergev3_mergev3_tooltip,
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
    service_id: service:mergev3,
    is_active: true;

CREATE resource:messagebird_sms SET
    identity = {
        name: "sms",
        slug: "messagebird_sms",
        display_name_i18n: i18n_key:resource_messagebird_sms_name,
        description_i18n: i18n_key:resource_messagebird_sms_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 564,
        tooltip_i18n: i18n_key:resource_messagebird_sms_tooltip,
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
    service_id: service:messagebird,
    is_active: true;

CREATE resource:messagebird_balance SET
    identity = {
        name: "balance",
        slug: "messagebird_balance",
        display_name_i18n: i18n_key:resource_messagebird_balance_name,
        description_i18n: i18n_key:resource_messagebird_balance_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 565,
        tooltip_i18n: i18n_key:resource_messagebird_balance_tooltip,
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
    service_id: service:messagebird,
    is_active: true;

CREATE resource:metabase_alerts SET
    identity = {
        name: "alerts",
        slug: "metabase_alerts",
        display_name_i18n: i18n_key:resource_metabase_alerts_name,
        description_i18n: i18n_key:resource_metabase_alerts_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 566,
        tooltip_i18n: i18n_key:resource_metabase_alerts_tooltip,
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
    service_id: service:metabase,
    is_active: true;

CREATE resource:metabase_databases SET
    identity = {
        name: "databases",
        slug: "metabase_databases",
        display_name_i18n: i18n_key:resource_metabase_databases_name,
        description_i18n: i18n_key:resource_metabase_databases_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 567,
        tooltip_i18n: i18n_key:resource_metabase_databases_tooltip,
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
    service_id: service:metabase,
    is_active: true;

CREATE resource:metabase_metrics SET
    identity = {
        name: "metrics",
        slug: "metabase_metrics",
        display_name_i18n: i18n_key:resource_metabase_metrics_name,
        description_i18n: i18n_key:resource_metabase_metrics_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 568,
        tooltip_i18n: i18n_key:resource_metabase_metrics_tooltip,
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
    service_id: service:metabase,
    is_active: true;

CREATE resource:metabase_questions SET
    identity = {
        name: "questions",
        slug: "metabase_questions",
        display_name_i18n: i18n_key:resource_metabase_questions_name,
        description_i18n: i18n_key:resource_metabase_questions_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 569,
        tooltip_i18n: i18n_key:resource_metabase_questions_tooltip,
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
    service_id: service:metabase,
    is_active: true;

CREATE resource:metabase_alerts SET
    identity = {
        name: "alerts",
        slug: "metabase_alerts",
        display_name_i18n: i18n_key:resource_metabase_alerts_name,
        description_i18n: i18n_key:resource_metabase_alerts_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 570,
        tooltip_i18n: i18n_key:resource_metabase_alerts_tooltip,
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
    service_id: service:metabase,
    is_active: true;

CREATE resource:metabase_databases SET
    identity = {
        name: "databases",
        slug: "metabase_databases",
        display_name_i18n: i18n_key:resource_metabase_databases_name,
        description_i18n: i18n_key:resource_metabase_databases_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 571,
        tooltip_i18n: i18n_key:resource_metabase_databases_tooltip,
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
    service_id: service:metabase,
    is_active: true;

CREATE resource:metabase_metrics SET
    identity = {
        name: "metrics",
        slug: "metabase_metrics",
        display_name_i18n: i18n_key:resource_metabase_metrics_name,
        description_i18n: i18n_key:resource_metabase_metrics_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 572,
        tooltip_i18n: i18n_key:resource_metabase_metrics_tooltip,
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
    service_id: service:metabase,
    is_active: true;

CREATE resource:metabase_questions SET
    identity = {
        name: "questions",
        slug: "metabase_questions",
        display_name_i18n: i18n_key:resource_metabase_questions_name,
        description_i18n: i18n_key:resource_metabase_questions_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 573,
        tooltip_i18n: i18n_key:resource_metabase_questions_tooltip,
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
    service_id: service:metabase,
    is_active: true;

CREATE resource:azurecosmosdb_container SET
    identity = {
        name: "container",
        slug: "azurecosmosdb_container",
        display_name_i18n: i18n_key:resource_azurecosmosdb_container_name,
        description_i18n: i18n_key:resource_azurecosmosdb_container_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 574,
        tooltip_i18n: i18n_key:resource_azurecosmosdb_container_tooltip,
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
    service_id: service:azurecosmosdb,
    is_active: true;

CREATE resource:azurecosmosdb_item SET
    identity = {
        name: "item",
        slug: "azurecosmosdb_item",
        display_name_i18n: i18n_key:resource_azurecosmosdb_item_name,
        description_i18n: i18n_key:resource_azurecosmosdb_item_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 575,
        tooltip_i18n: i18n_key:resource_azurecosmosdb_item_tooltip,
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
    service_id: service:azurecosmosdb,
    is_active: true;

CREATE resource:microsoftdynamicscrm_account SET
    identity = {
        name: "account",
        slug: "microsoftdynamicscrm_account",
        display_name_i18n: i18n_key:resource_microsoftdynamicscrm_account_name,
        description_i18n: i18n_key:resource_microsoftdynamicscrm_account_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 576,
        tooltip_i18n: i18n_key:resource_microsoftdynamicscrm_account_tooltip,
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
    service_id: service:microsoftdynamicscrm,
    is_active: true;

CREATE resource:microsoftentra_group SET
    identity = {
        name: "group",
        slug: "microsoftentra_group",
        display_name_i18n: i18n_key:resource_microsoftentra_group_name,
        description_i18n: i18n_key:resource_microsoftentra_group_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 577,
        tooltip_i18n: i18n_key:resource_microsoftentra_group_tooltip,
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
    service_id: service:microsoftentra,
    is_active: true;

CREATE resource:microsoftentra_user SET
    identity = {
        name: "user",
        slug: "microsoftentra_user",
        display_name_i18n: i18n_key:resource_microsoftentra_user_name,
        description_i18n: i18n_key:resource_microsoftentra_user_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 578,
        tooltip_i18n: i18n_key:resource_microsoftentra_user_tooltip,
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
    service_id: service:microsoftentra,
    is_active: true;

CREATE resource:microsoftexcel_microsoftexcel SET
    identity = {
        name: "microsoftexcel",
        slug: "microsoftexcel_microsoftexcel",
        display_name_i18n: i18n_key:resource_microsoftexcel_microsoftexcel_name,
        description_i18n: i18n_key:resource_microsoftexcel_microsoftexcel_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 579,
        tooltip_i18n: i18n_key:resource_microsoftexcel_microsoftexcel_tooltip,
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
    service_id: service:microsoftexcel,
    is_active: true;

CREATE resource:microsoftexcelv1_table SET
    identity = {
        name: "table",
        slug: "microsoftexcelv1_table",
        display_name_i18n: i18n_key:resource_microsoftexcelv1_table_name,
        description_i18n: i18n_key:resource_microsoftexcelv1_table_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 580,
        tooltip_i18n: i18n_key:resource_microsoftexcelv1_table_tooltip,
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
    service_id: service:microsoftexcelv1,
    is_active: true;

CREATE resource:microsoftexcelv1_workbook SET
    identity = {
        name: "workbook",
        slug: "microsoftexcelv1_workbook",
        display_name_i18n: i18n_key:resource_microsoftexcelv1_workbook_name,
        description_i18n: i18n_key:resource_microsoftexcelv1_workbook_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 581,
        tooltip_i18n: i18n_key:resource_microsoftexcelv1_workbook_tooltip,
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
    service_id: service:microsoftexcelv1,
    is_active: true;

CREATE resource:microsoftexcelv1_worksheet SET
    identity = {
        name: "worksheet",
        slug: "microsoftexcelv1_worksheet",
        display_name_i18n: i18n_key:resource_microsoftexcelv1_worksheet_name,
        description_i18n: i18n_key:resource_microsoftexcelv1_worksheet_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 582,
        tooltip_i18n: i18n_key:resource_microsoftexcelv1_worksheet_tooltip,
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
    service_id: service:microsoftexcelv1,
    is_active: true;

CREATE resource:microsoftexcelv2_microsoftexcelv2 SET
    identity = {
        name: "microsoftexcelv2",
        slug: "microsoftexcelv2_microsoftexcelv2",
        display_name_i18n: i18n_key:resource_microsoftexcelv2_microsoftexcelv2_name,
        description_i18n: i18n_key:resource_microsoftexcelv2_microsoftexcelv2_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 583,
        tooltip_i18n: i18n_key:resource_microsoftexcelv2_microsoftexcelv2_tooltip,
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
    service_id: service:microsoftexcelv2,
    is_active: true;

CREATE resource:microsoftgraphsecurity_secureScore SET
    identity = {
        name: "secureScore",
        slug: "microsoftgraphsecurity_secureScore",
        display_name_i18n: i18n_key:resource_microsoftgraphsecurity_secureScore_name,
        description_i18n: i18n_key:resource_microsoftgraphsecurity_secureScore_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 584,
        tooltip_i18n: i18n_key:resource_microsoftgraphsecurity_secureScore_tooltip,
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
    service_id: service:microsoftgraphsecurity,
    is_active: true;

CREATE resource:microsoftgraphsecurity_secureScoreControlProfile SET
    identity = {
        name: "secureScoreControlProfile",
        slug: "microsoftgraphsecurity_secureScoreControlProfile",
        display_name_i18n: i18n_key:resource_microsoftgraphsecurity_secureScoreControlProfile_name,
        description_i18n: i18n_key:resource_microsoftgraphsecurity_secureScoreControlProfile_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 585,
        tooltip_i18n: i18n_key:resource_microsoftgraphsecurity_secureScoreControlProfile_tooltip,
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
    service_id: service:microsoftgraphsecurity,
    is_active: true;

CREATE resource:microsoftonedrive_file SET
    identity = {
        name: "file",
        slug: "microsoftonedrive_file",
        display_name_i18n: i18n_key:resource_microsoftonedrive_file_name,
        description_i18n: i18n_key:resource_microsoftonedrive_file_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 586,
        tooltip_i18n: i18n_key:resource_microsoftonedrive_file_tooltip,
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
    service_id: service:microsoftonedrive,
    is_active: true;

CREATE resource:microsoftonedrive_folder SET
    identity = {
        name: "folder",
        slug: "microsoftonedrive_folder",
        display_name_i18n: i18n_key:resource_microsoftonedrive_folder_name,
        description_i18n: i18n_key:resource_microsoftonedrive_folder_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 587,
        tooltip_i18n: i18n_key:resource_microsoftonedrive_folder_tooltip,
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
    service_id: service:microsoftonedrive,
    is_active: true;

CREATE resource:microsoftoutlook_microsoftoutlook SET
    identity = {
        name: "microsoftoutlook",
        slug: "microsoftoutlook_microsoftoutlook",
        display_name_i18n: i18n_key:resource_microsoftoutlook_microsoftoutlook_name,
        description_i18n: i18n_key:resource_microsoftoutlook_microsoftoutlook_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 588,
        tooltip_i18n: i18n_key:resource_microsoftoutlook_microsoftoutlook_tooltip,
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
    service_id: service:microsoftoutlook,
    is_active: true;

CREATE resource:microsoftoutlookv1_draft SET
    identity = {
        name: "draft",
        slug: "microsoftoutlookv1_draft",
        display_name_i18n: i18n_key:resource_microsoftoutlookv1_draft_name,
        description_i18n: i18n_key:resource_microsoftoutlookv1_draft_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 589,
        tooltip_i18n: i18n_key:resource_microsoftoutlookv1_draft_tooltip,
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
    service_id: service:microsoftoutlookv1,
    is_active: true;

CREATE resource:microsoftoutlookv1_folder SET
    identity = {
        name: "folder",
        slug: "microsoftoutlookv1_folder",
        display_name_i18n: i18n_key:resource_microsoftoutlookv1_folder_name,
        description_i18n: i18n_key:resource_microsoftoutlookv1_folder_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 590,
        tooltip_i18n: i18n_key:resource_microsoftoutlookv1_folder_tooltip,
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
    service_id: service:microsoftoutlookv1,
    is_active: true;

CREATE resource:microsoftoutlookv1_folderMessage SET
    identity = {
        name: "folderMessage",
        slug: "microsoftoutlookv1_folderMessage",
        display_name_i18n: i18n_key:resource_microsoftoutlookv1_folderMessage_name,
        description_i18n: i18n_key:resource_microsoftoutlookv1_folderMessage_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 591,
        tooltip_i18n: i18n_key:resource_microsoftoutlookv1_folderMessage_tooltip,
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
    service_id: service:microsoftoutlookv1,
    is_active: true;

CREATE resource:microsoftoutlookv1_message SET
    identity = {
        name: "message",
        slug: "microsoftoutlookv1_message",
        display_name_i18n: i18n_key:resource_microsoftoutlookv1_message_name,
        description_i18n: i18n_key:resource_microsoftoutlookv1_message_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 592,
        tooltip_i18n: i18n_key:resource_microsoftoutlookv1_message_tooltip,
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
    service_id: service:microsoftoutlookv1,
    is_active: true;

CREATE resource:microsoftoutlookv1_messageAttachment SET
    identity = {
        name: "messageAttachment",
        slug: "microsoftoutlookv1_messageAttachment",
        display_name_i18n: i18n_key:resource_microsoftoutlookv1_messageAttachment_name,
        description_i18n: i18n_key:resource_microsoftoutlookv1_messageAttachment_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 593,
        tooltip_i18n: i18n_key:resource_microsoftoutlookv1_messageAttachment_tooltip,
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
    service_id: service:microsoftoutlookv1,
    is_active: true;

CREATE resource:microsoftoutlookv1_draftmessageshared SET
    identity = {
        name: "draftmessageshared",
        slug: "microsoftoutlookv1_draftmessageshared",
        display_name_i18n: i18n_key:resource_microsoftoutlookv1_draftmessageshared_name,
        description_i18n: i18n_key:resource_microsoftoutlookv1_draftmessageshared_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 594,
        tooltip_i18n: i18n_key:resource_microsoftoutlookv1_draftmessageshared_tooltip,
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
    service_id: service:microsoftoutlookv1,
    is_active: true;

CREATE resource:microsoftoutlookv1_messageattachment SET
    identity = {
        name: "messageattachment",
        slug: "microsoftoutlookv1_messageattachment",
        display_name_i18n: i18n_key:resource_microsoftoutlookv1_messageattachment_name,
        description_i18n: i18n_key:resource_microsoftoutlookv1_messageattachment_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 595,
        tooltip_i18n: i18n_key:resource_microsoftoutlookv1_messageattachment_tooltip,
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
    service_id: service:microsoftoutlookv1,
    is_active: true;

CREATE resource:microsoftoutlookv2_microsoftoutlookv2 SET
    identity = {
        name: "microsoftoutlookv2",
        slug: "microsoftoutlookv2_microsoftoutlookv2",
        display_name_i18n: i18n_key:resource_microsoftoutlookv2_microsoftoutlookv2_name,
        description_i18n: i18n_key:resource_microsoftoutlookv2_microsoftoutlookv2_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 596,
        tooltip_i18n: i18n_key:resource_microsoftoutlookv2_microsoftoutlookv2_tooltip,
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
    service_id: service:microsoftoutlookv2,
    is_active: true;

CREATE resource:microsoftsharepoint_file SET
    identity = {
        name: "file",
        slug: "microsoftsharepoint_file",
        display_name_i18n: i18n_key:resource_microsoftsharepoint_file_name,
        description_i18n: i18n_key:resource_microsoftsharepoint_file_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 597,
        tooltip_i18n: i18n_key:resource_microsoftsharepoint_file_tooltip,
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
    service_id: service:microsoftsharepoint,
    is_active: true;

CREATE resource:microsoftsharepoint_item SET
    identity = {
        name: "item",
        slug: "microsoftsharepoint_item",
        display_name_i18n: i18n_key:resource_microsoftsharepoint_item_name,
        description_i18n: i18n_key:resource_microsoftsharepoint_item_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 598,
        tooltip_i18n: i18n_key:resource_microsoftsharepoint_item_tooltip,
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
    service_id: service:microsoftsharepoint,
    is_active: true;

CREATE resource:microsoftsharepoint_list SET
    identity = {
        name: "list",
        slug: "microsoftsharepoint_list",
        display_name_i18n: i18n_key:resource_microsoftsharepoint_list_name,
        description_i18n: i18n_key:resource_microsoftsharepoint_list_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 599,
        tooltip_i18n: i18n_key:resource_microsoftsharepoint_list_tooltip,
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
    service_id: service:microsoftsharepoint,
    is_active: true;

CREATE resource:microsoftsql_microsoftsql SET
    identity = {
        name: "microsoftsql",
        slug: "microsoftsql_microsoftsql",
        display_name_i18n: i18n_key:resource_microsoftsql_microsoftsql_name,
        description_i18n: i18n_key:resource_microsoftsql_microsoftsql_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 600,
        tooltip_i18n: i18n_key:resource_microsoftsql_microsoftsql_tooltip,
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
    service_id: service:microsoftsql,
    is_active: true;

