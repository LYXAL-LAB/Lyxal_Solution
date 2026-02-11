-- Batch 10: 50 ressources Lyxal

CREATE resource:invoiceninja_banktransaction SET
    identity = {
        name: "banktransaction",
        slug: "invoiceninja_banktransaction",
        display_name_i18n: i18n_key:resource_invoiceninja_banktransaction_name,
        description_i18n: i18n_key:resource_invoiceninja_banktransaction_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 451,
        tooltip_i18n: i18n_key:resource_invoiceninja_banktransaction_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:invoiceninja,
    is_active: true;

CREATE resource:invoiceninja_client SET
    identity = {
        name: "client",
        slug: "invoiceninja_client",
        display_name_i18n: i18n_key:resource_invoiceninja_client_name,
        description_i18n: i18n_key:resource_invoiceninja_client_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 452,
        tooltip_i18n: i18n_key:resource_invoiceninja_client_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:invoiceninja,
    is_active: true;

CREATE resource:invoiceninja_expense SET
    identity = {
        name: "expense",
        slug: "invoiceninja_expense",
        display_name_i18n: i18n_key:resource_invoiceninja_expense_name,
        description_i18n: i18n_key:resource_invoiceninja_expense_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 453,
        tooltip_i18n: i18n_key:resource_invoiceninja_expense_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:invoiceninja,
    is_active: true;

CREATE resource:invoiceninja_invoice SET
    identity = {
        name: "invoice",
        slug: "invoiceninja_invoice",
        display_name_i18n: i18n_key:resource_invoiceninja_invoice_name,
        description_i18n: i18n_key:resource_invoiceninja_invoice_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 454,
        tooltip_i18n: i18n_key:resource_invoiceninja_invoice_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:invoiceninja,
    is_active: true;

CREATE resource:invoiceninja_payment SET
    identity = {
        name: "payment",
        slug: "invoiceninja_payment",
        display_name_i18n: i18n_key:resource_invoiceninja_payment_name,
        description_i18n: i18n_key:resource_invoiceninja_payment_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 455,
        tooltip_i18n: i18n_key:resource_invoiceninja_payment_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:invoiceninja,
    is_active: true;

CREATE resource:invoiceninja_quote SET
    identity = {
        name: "quote",
        slug: "invoiceninja_quote",
        display_name_i18n: i18n_key:resource_invoiceninja_quote_name,
        description_i18n: i18n_key:resource_invoiceninja_quote_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 456,
        tooltip_i18n: i18n_key:resource_invoiceninja_quote_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:invoiceninja,
    is_active: true;

CREATE resource:invoiceninja_task SET
    identity = {
        name: "task",
        slug: "invoiceninja_task",
        display_name_i18n: i18n_key:resource_invoiceninja_task_name,
        description_i18n: i18n_key:resource_invoiceninja_task_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 457,
        tooltip_i18n: i18n_key:resource_invoiceninja_task_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:invoiceninja,
    is_active: true;

CREATE resource:itemlists_itemlists SET
    identity = {
        name: "itemlists",
        slug: "itemlists_itemlists",
        display_name_i18n: i18n_key:resource_itemlists_itemlists_name,
        description_i18n: i18n_key:resource_itemlists_itemlists_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 458,
        tooltip_i18n: i18n_key:resource_itemlists_itemlists_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:itemlists,
    is_active: true;

CREATE resource:itemlistsv1_itemList SET
    identity = {
        name: "itemList",
        slug: "itemlistsv1_itemList",
        display_name_i18n: i18n_key:resource_itemlistsv1_itemList_name,
        description_i18n: i18n_key:resource_itemlistsv1_itemList_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 459,
        tooltip_i18n: i18n_key:resource_itemlistsv1_itemList_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:itemlistsv1,
    is_active: true;

CREATE resource:itemlistsv2_itemList SET
    identity = {
        name: "itemList",
        slug: "itemlistsv2_itemList",
        display_name_i18n: i18n_key:resource_itemlistsv2_itemList_name,
        description_i18n: i18n_key:resource_itemlistsv2_itemList_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 460,
        tooltip_i18n: i18n_key:resource_itemlistsv2_itemList_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:itemlistsv2,
    is_active: true;

CREATE resource:itemlistsv3_itemlistsv3 SET
    identity = {
        name: "itemlistsv3",
        slug: "itemlistsv3_itemlistsv3",
        display_name_i18n: i18n_key:resource_itemlistsv3_itemlistsv3_name,
        description_i18n: i18n_key:resource_itemlistsv3_itemlistsv3_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 461,
        tooltip_i18n: i18n_key:resource_itemlistsv3_itemlistsv3_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:itemlistsv3,
    is_active: true;

CREATE resource:iterable_event SET
    identity = {
        name: "event",
        slug: "iterable_event",
        display_name_i18n: i18n_key:resource_iterable_event_name,
        description_i18n: i18n_key:resource_iterable_event_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 462,
        tooltip_i18n: i18n_key:resource_iterable_event_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:iterable,
    is_active: true;

CREATE resource:iterable_user SET
    identity = {
        name: "user",
        slug: "iterable_user",
        display_name_i18n: i18n_key:resource_iterable_user_name,
        description_i18n: i18n_key:resource_iterable_user_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 463,
        tooltip_i18n: i18n_key:resource_iterable_user_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:iterable,
    is_active: true;

CREATE resource:iterable_userList SET
    identity = {
        name: "userList",
        slug: "iterable_userList",
        display_name_i18n: i18n_key:resource_iterable_userList_name,
        description_i18n: i18n_key:resource_iterable_userList_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 464,
        tooltip_i18n: i18n_key:resource_iterable_userList_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:iterable,
    is_active: true;

CREATE resource:iterable_userlist SET
    identity = {
        name: "userlist",
        slug: "iterable_userlist",
        display_name_i18n: i18n_key:resource_iterable_userlist_name,
        description_i18n: i18n_key:resource_iterable_userlist_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 465,
        tooltip_i18n: i18n_key:resource_iterable_userlist_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:iterable,
    is_active: true;

CREATE resource:jenkins_build SET
    identity = {
        name: "build",
        slug: "jenkins_build",
        display_name_i18n: i18n_key:resource_jenkins_build_name,
        description_i18n: i18n_key:resource_jenkins_build_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 466,
        tooltip_i18n: i18n_key:resource_jenkins_build_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:jenkins,
    is_active: true;

CREATE resource:jenkins_instance SET
    identity = {
        name: "instance",
        slug: "jenkins_instance",
        display_name_i18n: i18n_key:resource_jenkins_instance_name,
        description_i18n: i18n_key:resource_jenkins_instance_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 467,
        tooltip_i18n: i18n_key:resource_jenkins_instance_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:jenkins,
    is_active: true;

CREATE resource:jenkins_job SET
    identity = {
        name: "job",
        slug: "jenkins_job",
        display_name_i18n: i18n_key:resource_jenkins_job_name,
        description_i18n: i18n_key:resource_jenkins_job_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 468,
        tooltip_i18n: i18n_key:resource_jenkins_job_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:jenkins,
    is_active: true;

CREATE resource:jinaai_reader SET
    identity = {
        name: "reader",
        slug: "jinaai_reader",
        display_name_i18n: i18n_key:resource_jinaai_reader_name,
        description_i18n: i18n_key:resource_jinaai_reader_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 469,
        tooltip_i18n: i18n_key:resource_jinaai_reader_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:jinaai,
    is_active: true;

CREATE resource:jinaai_research SET
    identity = {
        name: "research",
        slug: "jinaai_research",
        display_name_i18n: i18n_key:resource_jinaai_research_name,
        description_i18n: i18n_key:resource_jinaai_research_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 470,
        tooltip_i18n: i18n_key:resource_jinaai_research_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:jinaai,
    is_active: true;

CREATE resource:jira_issue SET
    identity = {
        name: "issue",
        slug: "jira_issue",
        display_name_i18n: i18n_key:resource_jira_issue_name,
        description_i18n: i18n_key:resource_jira_issue_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 471,
        tooltip_i18n: i18n_key:resource_jira_issue_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:jira,
    is_active: true;

CREATE resource:jira_issueAttachment SET
    identity = {
        name: "issueAttachment",
        slug: "jira_issueAttachment",
        display_name_i18n: i18n_key:resource_jira_issueAttachment_name,
        description_i18n: i18n_key:resource_jira_issueAttachment_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 472,
        tooltip_i18n: i18n_key:resource_jira_issueAttachment_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:jira,
    is_active: true;

CREATE resource:jira_issueComment SET
    identity = {
        name: "issueComment",
        slug: "jira_issueComment",
        display_name_i18n: i18n_key:resource_jira_issueComment_name,
        description_i18n: i18n_key:resource_jira_issueComment_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 473,
        tooltip_i18n: i18n_key:resource_jira_issueComment_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:jira,
    is_active: true;

CREATE resource:jira_user SET
    identity = {
        name: "user",
        slug: "jira_user",
        display_name_i18n: i18n_key:resource_jira_user_name,
        description_i18n: i18n_key:resource_jira_user_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 474,
        tooltip_i18n: i18n_key:resource_jira_user_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:jira,
    is_active: true;

CREATE resource:jira_issueattachment SET
    identity = {
        name: "issueattachment",
        slug: "jira_issueattachment",
        display_name_i18n: i18n_key:resource_jira_issueattachment_name,
        description_i18n: i18n_key:resource_jira_issueattachment_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 475,
        tooltip_i18n: i18n_key:resource_jira_issueattachment_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:jira,
    is_active: true;

CREATE resource:jira_issuecomment SET
    identity = {
        name: "issuecomment",
        slug: "jira_issuecomment",
        display_name_i18n: i18n_key:resource_jira_issuecomment_name,
        description_i18n: i18n_key:resource_jira_issuecomment_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 476,
        tooltip_i18n: i18n_key:resource_jira_issuecomment_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:jira,
    is_active: true;

CREATE resource:jwt_jwt SET
    identity = {
        name: "jwt",
        slug: "jwt_jwt",
        display_name_i18n: i18n_key:resource_jwt_jwt_name,
        description_i18n: i18n_key:resource_jwt_jwt_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 477,
        tooltip_i18n: i18n_key:resource_jwt_jwt_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:jwt,
    is_active: true;

CREATE resource:kafka_kafka SET
    identity = {
        name: "kafka",
        slug: "kafka_kafka",
        display_name_i18n: i18n_key:resource_kafka_kafka_name,
        description_i18n: i18n_key:resource_kafka_kafka_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 478,
        tooltip_i18n: i18n_key:resource_kafka_kafka_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:kafka,
    is_active: true;

CREATE resource:keap_company SET
    identity = {
        name: "company",
        slug: "keap_company",
        display_name_i18n: i18n_key:resource_keap_company_name,
        description_i18n: i18n_key:resource_keap_company_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 479,
        tooltip_i18n: i18n_key:resource_keap_company_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:keap,
    is_active: true;

CREATE resource:keap_contact SET
    identity = {
        name: "contact",
        slug: "keap_contact",
        display_name_i18n: i18n_key:resource_keap_contact_name,
        description_i18n: i18n_key:resource_keap_contact_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 480,
        tooltip_i18n: i18n_key:resource_keap_contact_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:keap,
    is_active: true;

CREATE resource:keap_contactNote SET
    identity = {
        name: "contactNote",
        slug: "keap_contactNote",
        display_name_i18n: i18n_key:resource_keap_contactNote_name,
        description_i18n: i18n_key:resource_keap_contactNote_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 481,
        tooltip_i18n: i18n_key:resource_keap_contactNote_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:keap,
    is_active: true;

CREATE resource:keap_contactTag SET
    identity = {
        name: "contactTag",
        slug: "keap_contactTag",
        display_name_i18n: i18n_key:resource_keap_contactTag_name,
        description_i18n: i18n_key:resource_keap_contactTag_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 482,
        tooltip_i18n: i18n_key:resource_keap_contactTag_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:keap,
    is_active: true;

CREATE resource:keap_ecommerceOrder SET
    identity = {
        name: "ecommerceOrder",
        slug: "keap_ecommerceOrder",
        display_name_i18n: i18n_key:resource_keap_ecommerceOrder_name,
        description_i18n: i18n_key:resource_keap_ecommerceOrder_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 483,
        tooltip_i18n: i18n_key:resource_keap_ecommerceOrder_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:keap,
    is_active: true;

CREATE resource:keap_ecommerceProduct SET
    identity = {
        name: "ecommerceProduct",
        slug: "keap_ecommerceProduct",
        display_name_i18n: i18n_key:resource_keap_ecommerceProduct_name,
        description_i18n: i18n_key:resource_keap_ecommerceProduct_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 484,
        tooltip_i18n: i18n_key:resource_keap_ecommerceProduct_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:keap,
    is_active: true;

CREATE resource:keap_email SET
    identity = {
        name: "email",
        slug: "keap_email",
        display_name_i18n: i18n_key:resource_keap_email_name,
        description_i18n: i18n_key:resource_keap_email_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 485,
        tooltip_i18n: i18n_key:resource_keap_email_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:keap,
    is_active: true;

CREATE resource:keap_file SET
    identity = {
        name: "file",
        slug: "keap_file",
        display_name_i18n: i18n_key:resource_keap_file_name,
        description_i18n: i18n_key:resource_keap_file_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 486,
        tooltip_i18n: i18n_key:resource_keap_file_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:keap,
    is_active: true;

CREATE resource:keap_contactnote SET
    identity = {
        name: "contactnote",
        slug: "keap_contactnote",
        display_name_i18n: i18n_key:resource_keap_contactnote_name,
        description_i18n: i18n_key:resource_keap_contactnote_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 487,
        tooltip_i18n: i18n_key:resource_keap_contactnote_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:keap,
    is_active: true;

CREATE resource:keap_contacttag SET
    identity = {
        name: "contacttag",
        slug: "keap_contacttag",
        display_name_i18n: i18n_key:resource_keap_contacttag_name,
        description_i18n: i18n_key:resource_keap_contacttag_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 488,
        tooltip_i18n: i18n_key:resource_keap_contacttag_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:keap,
    is_active: true;

CREATE resource:keap_ecommerceproduct SET
    identity = {
        name: "ecommerceproduct",
        slug: "keap_ecommerceproduct",
        display_name_i18n: i18n_key:resource_keap_ecommerceproduct_name,
        description_i18n: i18n_key:resource_keap_ecommerceproduct_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 489,
        tooltip_i18n: i18n_key:resource_keap_ecommerceproduct_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:keap,
    is_active: true;

CREATE resource:kitemaker_organization SET
    identity = {
        name: "organization",
        slug: "kitemaker_organization",
        display_name_i18n: i18n_key:resource_kitemaker_organization_name,
        description_i18n: i18n_key:resource_kitemaker_organization_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 490,
        tooltip_i18n: i18n_key:resource_kitemaker_organization_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:kitemaker,
    is_active: true;

CREATE resource:kitemaker_space SET
    identity = {
        name: "space",
        slug: "kitemaker_space",
        display_name_i18n: i18n_key:resource_kitemaker_space_name,
        description_i18n: i18n_key:resource_kitemaker_space_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 491,
        tooltip_i18n: i18n_key:resource_kitemaker_space_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:kitemaker,
    is_active: true;

CREATE resource:kitemaker_user SET
    identity = {
        name: "user",
        slug: "kitemaker_user",
        display_name_i18n: i18n_key:resource_kitemaker_user_name,
        description_i18n: i18n_key:resource_kitemaker_user_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 492,
        tooltip_i18n: i18n_key:resource_kitemaker_user_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:kitemaker,
    is_active: true;

CREATE resource:kitemaker_workItem SET
    identity = {
        name: "workItem",
        slug: "kitemaker_workItem",
        display_name_i18n: i18n_key:resource_kitemaker_workItem_name,
        description_i18n: i18n_key:resource_kitemaker_workItem_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 493,
        tooltip_i18n: i18n_key:resource_kitemaker_workItem_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:kitemaker,
    is_active: true;

CREATE resource:kobotoolbox_file SET
    identity = {
        name: "file",
        slug: "kobotoolbox_file",
        display_name_i18n: i18n_key:resource_kobotoolbox_file_name,
        description_i18n: i18n_key:resource_kobotoolbox_file_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 494,
        tooltip_i18n: i18n_key:resource_kobotoolbox_file_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:kobotoolbox,
    is_active: true;

CREATE resource:kobotoolbox_form SET
    identity = {
        name: "form",
        slug: "kobotoolbox_form",
        display_name_i18n: i18n_key:resource_kobotoolbox_form_name,
        description_i18n: i18n_key:resource_kobotoolbox_form_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 495,
        tooltip_i18n: i18n_key:resource_kobotoolbox_form_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:kobotoolbox,
    is_active: true;

CREATE resource:kobotoolbox_hook SET
    identity = {
        name: "hook",
        slug: "kobotoolbox_hook",
        display_name_i18n: i18n_key:resource_kobotoolbox_hook_name,
        description_i18n: i18n_key:resource_kobotoolbox_hook_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 496,
        tooltip_i18n: i18n_key:resource_kobotoolbox_hook_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:kobotoolbox,
    is_active: true;

CREATE resource:kobotoolbox_submission SET
    identity = {
        name: "submission",
        slug: "kobotoolbox_submission",
        display_name_i18n: i18n_key:resource_kobotoolbox_submission_name,
        description_i18n: i18n_key:resource_kobotoolbox_submission_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 497,
        tooltip_i18n: i18n_key:resource_kobotoolbox_submission_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:kobotoolbox,
    is_active: true;

CREATE resource:ldap_ldap SET
    identity = {
        name: "ldap",
        slug: "ldap_ldap",
        display_name_i18n: i18n_key:resource_ldap_ldap_name,
        description_i18n: i18n_key:resource_ldap_ldap_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 498,
        tooltip_i18n: i18n_key:resource_ldap_ldap_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:ldap,
    is_active: true;

CREATE resource:lemlist_lemlist SET
    identity = {
        name: "lemlist",
        slug: "lemlist_lemlist",
        display_name_i18n: i18n_key:resource_lemlist_lemlist_name,
        description_i18n: i18n_key:resource_lemlist_lemlist_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 499,
        tooltip_i18n: i18n_key:resource_lemlist_lemlist_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:lemlist,
    is_active: true;

CREATE resource:lemlistv1_activity SET
    identity = {
        name: "activity",
        slug: "lemlistv1_activity",
        display_name_i18n: i18n_key:resource_lemlistv1_activity_name,
        description_i18n: i18n_key:resource_lemlistv1_activity_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 500,
        tooltip_i18n: i18n_key:resource_lemlistv1_activity_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
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

