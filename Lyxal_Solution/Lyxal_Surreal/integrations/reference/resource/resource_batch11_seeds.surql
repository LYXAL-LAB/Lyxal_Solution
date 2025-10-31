-- Batch 11: 50 ressources Lyxal

CREATE resource:lemlistv1_campaign SET
    identity = {
        name: "campaign",
        slug: "lemlistv1_campaign",
        display_name_i18n: i18n_key:resource_lemlistv1_campaign_name,
        description_i18n: i18n_key:resource_lemlistv1_campaign_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 501,
        tooltip_i18n: i18n_key:resource_lemlistv1_campaign_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:lemlistv1,
    is_active: true;

CREATE resource:lemlistv1_lead SET
    identity = {
        name: "lead",
        slug: "lemlistv1_lead",
        display_name_i18n: i18n_key:resource_lemlistv1_lead_name,
        description_i18n: i18n_key:resource_lemlistv1_lead_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 502,
        tooltip_i18n: i18n_key:resource_lemlistv1_lead_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:lemlistv1,
    is_active: true;

CREATE resource:lemlistv1_team SET
    identity = {
        name: "team",
        slug: "lemlistv1_team",
        display_name_i18n: i18n_key:resource_lemlistv1_team_name,
        description_i18n: i18n_key:resource_lemlistv1_team_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 503,
        tooltip_i18n: i18n_key:resource_lemlistv1_team_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:lemlistv1,
    is_active: true;

CREATE resource:lemlistv1_unsubscribe SET
    identity = {
        name: "unsubscribe",
        slug: "lemlistv1_unsubscribe",
        display_name_i18n: i18n_key:resource_lemlistv1_unsubscribe_name,
        description_i18n: i18n_key:resource_lemlistv1_unsubscribe_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 504,
        tooltip_i18n: i18n_key:resource_lemlistv1_unsubscribe_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:lemlistv1,
    is_active: true;

CREATE resource:lemlistv2_activity SET
    identity = {
        name: "activity",
        slug: "lemlistv2_activity",
        display_name_i18n: i18n_key:resource_lemlistv2_activity_name,
        description_i18n: i18n_key:resource_lemlistv2_activity_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 505,
        tooltip_i18n: i18n_key:resource_lemlistv2_activity_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:lemlistv2,
    is_active: true;

CREATE resource:lemlistv2_campaign SET
    identity = {
        name: "campaign",
        slug: "lemlistv2_campaign",
        display_name_i18n: i18n_key:resource_lemlistv2_campaign_name,
        description_i18n: i18n_key:resource_lemlistv2_campaign_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 506,
        tooltip_i18n: i18n_key:resource_lemlistv2_campaign_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:lemlistv2,
    is_active: true;

CREATE resource:lemlistv2_enrich SET
    identity = {
        name: "enrich",
        slug: "lemlistv2_enrich",
        display_name_i18n: i18n_key:resource_lemlistv2_enrich_name,
        description_i18n: i18n_key:resource_lemlistv2_enrich_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 507,
        tooltip_i18n: i18n_key:resource_lemlistv2_enrich_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:lemlistv2,
    is_active: true;

CREATE resource:lemlistv2_lead SET
    identity = {
        name: "lead",
        slug: "lemlistv2_lead",
        display_name_i18n: i18n_key:resource_lemlistv2_lead_name,
        description_i18n: i18n_key:resource_lemlistv2_lead_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 508,
        tooltip_i18n: i18n_key:resource_lemlistv2_lead_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:lemlistv2,
    is_active: true;

CREATE resource:lemlistv2_team SET
    identity = {
        name: "team",
        slug: "lemlistv2_team",
        display_name_i18n: i18n_key:resource_lemlistv2_team_name,
        description_i18n: i18n_key:resource_lemlistv2_team_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 509,
        tooltip_i18n: i18n_key:resource_lemlistv2_team_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:lemlistv2,
    is_active: true;

CREATE resource:lemlistv2_unsubscribe SET
    identity = {
        name: "unsubscribe",
        slug: "lemlistv2_unsubscribe",
        display_name_i18n: i18n_key:resource_lemlistv2_unsubscribe_name,
        description_i18n: i18n_key:resource_lemlistv2_unsubscribe_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 510,
        tooltip_i18n: i18n_key:resource_lemlistv2_unsubscribe_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:lemlistv2,
    is_active: true;

CREATE resource:line_notification SET
    identity = {
        name: "notification",
        slug: "line_notification",
        display_name_i18n: i18n_key:resource_line_notification_name,
        description_i18n: i18n_key:resource_line_notification_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 511,
        tooltip_i18n: i18n_key:resource_line_notification_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:line,
    is_active: true;

CREATE resource:linear_comment SET
    identity = {
        name: "comment",
        slug: "linear_comment",
        display_name_i18n: i18n_key:resource_linear_comment_name,
        description_i18n: i18n_key:resource_linear_comment_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 512,
        tooltip_i18n: i18n_key:resource_linear_comment_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:linear,
    is_active: true;

CREATE resource:linear_issue SET
    identity = {
        name: "issue",
        slug: "linear_issue",
        display_name_i18n: i18n_key:resource_linear_issue_name,
        description_i18n: i18n_key:resource_linear_issue_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 513,
        tooltip_i18n: i18n_key:resource_linear_issue_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:linear,
    is_active: true;

CREATE resource:lingvanex_lingvanex SET
    identity = {
        name: "lingvanex",
        slug: "lingvanex_lingvanex",
        display_name_i18n: i18n_key:resource_lingvanex_lingvanex_name,
        description_i18n: i18n_key:resource_lingvanex_lingvanex_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 514,
        tooltip_i18n: i18n_key:resource_lingvanex_lingvanex_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:lingvanex,
    is_active: true;

CREATE resource:linkedin_post SET
    identity = {
        name: "post",
        slug: "linkedin_post",
        display_name_i18n: i18n_key:resource_linkedin_post_name,
        description_i18n: i18n_key:resource_linkedin_post_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 515,
        tooltip_i18n: i18n_key:resource_linkedin_post_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:linkedin,
    is_active: true;

CREATE resource:lonescale_list SET
    identity = {
        name: "list",
        slug: "lonescale_list",
        display_name_i18n: i18n_key:resource_lonescale_list_name,
        description_i18n: i18n_key:resource_lonescale_list_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 516,
        tooltip_i18n: i18n_key:resource_lonescale_list_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:lonescale,
    is_active: true;

CREATE resource:lonescale_item SET
    identity = {
        name: "item",
        slug: "lonescale_item",
        display_name_i18n: i18n_key:resource_lonescale_item_name,
        description_i18n: i18n_key:resource_lonescale_item_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 517,
        tooltip_i18n: i18n_key:resource_lonescale_item_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:lonescale,
    is_active: true;

CREATE resource:magento2_customer SET
    identity = {
        name: "customer",
        slug: "magento2_customer",
        display_name_i18n: i18n_key:resource_magento2_customer_name,
        description_i18n: i18n_key:resource_magento2_customer_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 518,
        tooltip_i18n: i18n_key:resource_magento2_customer_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:magento2,
    is_active: true;

CREATE resource:magento2_invoice SET
    identity = {
        name: "invoice",
        slug: "magento2_invoice",
        display_name_i18n: i18n_key:resource_magento2_invoice_name,
        description_i18n: i18n_key:resource_magento2_invoice_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 519,
        tooltip_i18n: i18n_key:resource_magento2_invoice_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:magento2,
    is_active: true;

CREATE resource:magento2_order SET
    identity = {
        name: "order",
        slug: "magento2_order",
        display_name_i18n: i18n_key:resource_magento2_order_name,
        description_i18n: i18n_key:resource_magento2_order_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 520,
        tooltip_i18n: i18n_key:resource_magento2_order_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:magento2,
    is_active: true;

CREATE resource:magento2_product SET
    identity = {
        name: "product",
        slug: "magento2_product",
        display_name_i18n: i18n_key:resource_magento2_product_name,
        description_i18n: i18n_key:resource_magento2_product_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 521,
        tooltip_i18n: i18n_key:resource_magento2_product_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:magento2,
    is_active: true;

CREATE resource:mailcheck_email SET
    identity = {
        name: "email",
        slug: "mailcheck_email",
        display_name_i18n: i18n_key:resource_mailcheck_email_name,
        description_i18n: i18n_key:resource_mailcheck_email_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 522,
        tooltip_i18n: i18n_key:resource_mailcheck_email_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:mailcheck,
    is_active: true;

CREATE resource:mailchimp_campaign SET
    identity = {
        name: "campaign",
        slug: "mailchimp_campaign",
        display_name_i18n: i18n_key:resource_mailchimp_campaign_name,
        description_i18n: i18n_key:resource_mailchimp_campaign_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 523,
        tooltip_i18n: i18n_key:resource_mailchimp_campaign_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:mailchimp,
    is_active: true;

CREATE resource:mailchimp_listGroup SET
    identity = {
        name: "listGroup",
        slug: "mailchimp_listGroup",
        display_name_i18n: i18n_key:resource_mailchimp_listGroup_name,
        description_i18n: i18n_key:resource_mailchimp_listGroup_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 524,
        tooltip_i18n: i18n_key:resource_mailchimp_listGroup_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:mailchimp,
    is_active: true;

CREATE resource:mailchimp_member SET
    identity = {
        name: "member",
        slug: "mailchimp_member",
        display_name_i18n: i18n_key:resource_mailchimp_member_name,
        description_i18n: i18n_key:resource_mailchimp_member_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 525,
        tooltip_i18n: i18n_key:resource_mailchimp_member_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:mailchimp,
    is_active: true;

CREATE resource:mailchimp_memberTag SET
    identity = {
        name: "memberTag",
        slug: "mailchimp_memberTag",
        display_name_i18n: i18n_key:resource_mailchimp_memberTag_name,
        description_i18n: i18n_key:resource_mailchimp_memberTag_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 526,
        tooltip_i18n: i18n_key:resource_mailchimp_memberTag_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:mailchimp,
    is_active: true;

CREATE resource:mailerlite_mailerlite SET
    identity = {
        name: "mailerlite",
        slug: "mailerlite_mailerlite",
        display_name_i18n: i18n_key:resource_mailerlite_mailerlite_name,
        description_i18n: i18n_key:resource_mailerlite_mailerlite_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 527,
        tooltip_i18n: i18n_key:resource_mailerlite_mailerlite_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:mailerlite,
    is_active: true;

CREATE resource:mailerlitev1_subscriber SET
    identity = {
        name: "subscriber",
        slug: "mailerlitev1_subscriber",
        display_name_i18n: i18n_key:resource_mailerlitev1_subscriber_name,
        description_i18n: i18n_key:resource_mailerlitev1_subscriber_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 528,
        tooltip_i18n: i18n_key:resource_mailerlitev1_subscriber_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:mailerlitev1,
    is_active: true;

CREATE resource:mailerlitev2_subscriber SET
    identity = {
        name: "subscriber",
        slug: "mailerlitev2_subscriber",
        display_name_i18n: i18n_key:resource_mailerlitev2_subscriber_name,
        description_i18n: i18n_key:resource_mailerlitev2_subscriber_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 529,
        tooltip_i18n: i18n_key:resource_mailerlitev2_subscriber_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:mailerlitev2,
    is_active: true;

CREATE resource:mailgun_mailgun SET
    identity = {
        name: "mailgun",
        slug: "mailgun_mailgun",
        display_name_i18n: i18n_key:resource_mailgun_mailgun_name,
        description_i18n: i18n_key:resource_mailgun_mailgun_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 530,
        tooltip_i18n: i18n_key:resource_mailgun_mailgun_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:mailgun,
    is_active: true;

CREATE resource:mailjet_email SET
    identity = {
        name: "email",
        slug: "mailjet_email",
        display_name_i18n: i18n_key:resource_mailjet_email_name,
        description_i18n: i18n_key:resource_mailjet_email_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 531,
        tooltip_i18n: i18n_key:resource_mailjet_email_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:mailjet,
    is_active: true;

CREATE resource:mailjet_sms SET
    identity = {
        name: "sms",
        slug: "mailjet_sms",
        display_name_i18n: i18n_key:resource_mailjet_sms_name,
        description_i18n: i18n_key:resource_mailjet_sms_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 532,
        tooltip_i18n: i18n_key:resource_mailjet_sms_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:mailjet,
    is_active: true;

CREATE resource:mailjet_sms SET
    identity = {
        name: "sms",
        slug: "mailjet_sms",
        display_name_i18n: i18n_key:resource_mailjet_sms_name,
        description_i18n: i18n_key:resource_mailjet_sms_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 533,
        tooltip_i18n: i18n_key:resource_mailjet_sms_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:mailjet,
    is_active: true;

CREATE resource:mandrill_message SET
    identity = {
        name: "message",
        slug: "mandrill_message",
        display_name_i18n: i18n_key:resource_mandrill_message_name,
        description_i18n: i18n_key:resource_mandrill_message_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 534,
        tooltip_i18n: i18n_key:resource_mandrill_message_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:mandrill,
    is_active: true;

CREATE resource:markdown_markdown SET
    identity = {
        name: "markdown",
        slug: "markdown_markdown",
        display_name_i18n: i18n_key:resource_markdown_markdown_name,
        description_i18n: i18n_key:resource_markdown_markdown_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 535,
        tooltip_i18n: i18n_key:resource_markdown_markdown_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:markdown,
    is_active: true;

CREATE resource:marketstack_endOfDayData SET
    identity = {
        name: "endOfDayData",
        slug: "marketstack_endOfDayData",
        display_name_i18n: i18n_key:resource_marketstack_endOfDayData_name,
        description_i18n: i18n_key:resource_marketstack_endOfDayData_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 536,
        tooltip_i18n: i18n_key:resource_marketstack_endOfDayData_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:marketstack,
    is_active: true;

CREATE resource:marketstack_exchange SET
    identity = {
        name: "exchange",
        slug: "marketstack_exchange",
        display_name_i18n: i18n_key:resource_marketstack_exchange_name,
        description_i18n: i18n_key:resource_marketstack_exchange_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 537,
        tooltip_i18n: i18n_key:resource_marketstack_exchange_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:marketstack,
    is_active: true;

CREATE resource:marketstack_ticker SET
    identity = {
        name: "ticker",
        slug: "marketstack_ticker",
        display_name_i18n: i18n_key:resource_marketstack_ticker_name,
        description_i18n: i18n_key:resource_marketstack_ticker_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 538,
        tooltip_i18n: i18n_key:resource_marketstack_ticker_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:marketstack,
    is_active: true;

CREATE resource:matrix_account SET
    identity = {
        name: "account",
        slug: "matrix_account",
        display_name_i18n: i18n_key:resource_matrix_account_name,
        description_i18n: i18n_key:resource_matrix_account_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 539,
        tooltip_i18n: i18n_key:resource_matrix_account_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:matrix,
    is_active: true;

CREATE resource:matrix_event SET
    identity = {
        name: "event",
        slug: "matrix_event",
        display_name_i18n: i18n_key:resource_matrix_event_name,
        description_i18n: i18n_key:resource_matrix_event_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 540,
        tooltip_i18n: i18n_key:resource_matrix_event_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:matrix,
    is_active: true;

CREATE resource:matrix_media SET
    identity = {
        name: "media",
        slug: "matrix_media",
        display_name_i18n: i18n_key:resource_matrix_media_name,
        description_i18n: i18n_key:resource_matrix_media_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 541,
        tooltip_i18n: i18n_key:resource_matrix_media_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:matrix,
    is_active: true;

CREATE resource:matrix_message SET
    identity = {
        name: "message",
        slug: "matrix_message",
        display_name_i18n: i18n_key:resource_matrix_message_name,
        description_i18n: i18n_key:resource_matrix_message_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 542,
        tooltip_i18n: i18n_key:resource_matrix_message_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:matrix,
    is_active: true;

CREATE resource:matrix_room SET
    identity = {
        name: "room",
        slug: "matrix_room",
        display_name_i18n: i18n_key:resource_matrix_room_name,
        description_i18n: i18n_key:resource_matrix_room_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 543,
        tooltip_i18n: i18n_key:resource_matrix_room_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:matrix,
    is_active: true;

CREATE resource:matrix_roomMember SET
    identity = {
        name: "roomMember",
        slug: "matrix_roomMember",
        display_name_i18n: i18n_key:resource_matrix_roomMember_name,
        description_i18n: i18n_key:resource_matrix_roomMember_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 544,
        tooltip_i18n: i18n_key:resource_matrix_roomMember_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:matrix,
    is_active: true;

CREATE resource:matrix_roommember SET
    identity = {
        name: "roommember",
        slug: "matrix_roommember",
        display_name_i18n: i18n_key:resource_matrix_roommember_name,
        description_i18n: i18n_key:resource_matrix_roommember_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 545,
        tooltip_i18n: i18n_key:resource_matrix_roommember_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:matrix,
    is_active: true;

CREATE resource:mattermost_mattermost SET
    identity = {
        name: "mattermost",
        slug: "mattermost_mattermost",
        display_name_i18n: i18n_key:resource_mattermost_mattermost_name,
        description_i18n: i18n_key:resource_mattermost_mattermost_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 546,
        tooltip_i18n: i18n_key:resource_mattermost_mattermost_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:mattermost,
    is_active: true;

CREATE resource:mattermostv1_mattermostv1 SET
    identity = {
        name: "mattermostv1",
        slug: "mattermostv1_mattermostv1",
        display_name_i18n: i18n_key:resource_mattermostv1_mattermostv1_name,
        description_i18n: i18n_key:resource_mattermostv1_mattermostv1_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 547,
        tooltip_i18n: i18n_key:resource_mattermostv1_mattermostv1_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:mattermostv1,
    is_active: true;

CREATE resource:mautic_campaignContact SET
    identity = {
        name: "campaignContact",
        slug: "mautic_campaignContact",
        display_name_i18n: i18n_key:resource_mautic_campaignContact_name,
        description_i18n: i18n_key:resource_mautic_campaignContact_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 548,
        tooltip_i18n: i18n_key:resource_mautic_campaignContact_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
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

CREATE resource:mautic_company SET
    identity = {
        name: "company",
        slug: "mautic_company",
        display_name_i18n: i18n_key:resource_mautic_company_name,
        description_i18n: i18n_key:resource_mautic_company_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 549,
        tooltip_i18n: i18n_key:resource_mautic_company_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
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

CREATE resource:mautic_companyContact SET
    identity = {
        name: "companyContact",
        slug: "mautic_companyContact",
        display_name_i18n: i18n_key:resource_mautic_companyContact_name,
        description_i18n: i18n_key:resource_mautic_companyContact_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 550,
        tooltip_i18n: i18n_key:resource_mautic_companyContact_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
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

