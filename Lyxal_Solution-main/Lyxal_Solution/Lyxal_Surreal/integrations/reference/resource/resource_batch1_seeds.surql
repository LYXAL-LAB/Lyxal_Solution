-- Batch 1: 50 ressources Lyxal

CREATE resource:actionnetwork_attendance SET
    identity = {
        name: "attendance",
        slug: "actionnetwork_attendance",
        display_name_i18n: i18n_key:resource_actionnetwork_attendance_name,
        description_i18n: i18n_key:resource_actionnetwork_attendance_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 1,
        tooltip_i18n: i18n_key:resource_actionnetwork_attendance_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:actionnetwork,
    is_active: true;

CREATE resource:actionnetwork_event SET
    identity = {
        name: "event",
        slug: "actionnetwork_event",
        display_name_i18n: i18n_key:resource_actionnetwork_event_name,
        description_i18n: i18n_key:resource_actionnetwork_event_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 2,
        tooltip_i18n: i18n_key:resource_actionnetwork_event_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:actionnetwork,
    is_active: true;

CREATE resource:actionnetwork_person SET
    identity = {
        name: "person",
        slug: "actionnetwork_person",
        display_name_i18n: i18n_key:resource_actionnetwork_person_name,
        description_i18n: i18n_key:resource_actionnetwork_person_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 3,
        tooltip_i18n: i18n_key:resource_actionnetwork_person_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:actionnetwork,
    is_active: true;

CREATE resource:actionnetwork_personTag SET
    identity = {
        name: "personTag",
        slug: "actionnetwork_personTag",
        display_name_i18n: i18n_key:resource_actionnetwork_personTag_name,
        description_i18n: i18n_key:resource_actionnetwork_personTag_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 4,
        tooltip_i18n: i18n_key:resource_actionnetwork_personTag_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:actionnetwork,
    is_active: true;

CREATE resource:actionnetwork_petition SET
    identity = {
        name: "petition",
        slug: "actionnetwork_petition",
        display_name_i18n: i18n_key:resource_actionnetwork_petition_name,
        description_i18n: i18n_key:resource_actionnetwork_petition_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 5,
        tooltip_i18n: i18n_key:resource_actionnetwork_petition_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:actionnetwork,
    is_active: true;

CREATE resource:actionnetwork_signature SET
    identity = {
        name: "signature",
        slug: "actionnetwork_signature",
        display_name_i18n: i18n_key:resource_actionnetwork_signature_name,
        description_i18n: i18n_key:resource_actionnetwork_signature_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 6,
        tooltip_i18n: i18n_key:resource_actionnetwork_signature_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:actionnetwork,
    is_active: true;

CREATE resource:actionnetwork_tag SET
    identity = {
        name: "tag",
        slug: "actionnetwork_tag",
        display_name_i18n: i18n_key:resource_actionnetwork_tag_name,
        description_i18n: i18n_key:resource_actionnetwork_tag_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 7,
        tooltip_i18n: i18n_key:resource_actionnetwork_tag_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:actionnetwork,
    is_active: true;

CREATE resource:activecampaign_account SET
    identity = {
        name: "account",
        slug: "activecampaign_account",
        display_name_i18n: i18n_key:resource_activecampaign_account_name,
        description_i18n: i18n_key:resource_activecampaign_account_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 8,
        tooltip_i18n: i18n_key:resource_activecampaign_account_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:activecampaign,
    is_active: true;

CREATE resource:activecampaign_accountContact SET
    identity = {
        name: "accountContact",
        slug: "activecampaign_accountContact",
        display_name_i18n: i18n_key:resource_activecampaign_accountContact_name,
        description_i18n: i18n_key:resource_activecampaign_accountContact_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 9,
        tooltip_i18n: i18n_key:resource_activecampaign_accountContact_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:activecampaign,
    is_active: true;

CREATE resource:activecampaign_connection SET
    identity = {
        name: "connection",
        slug: "activecampaign_connection",
        display_name_i18n: i18n_key:resource_activecampaign_connection_name,
        description_i18n: i18n_key:resource_activecampaign_connection_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 10,
        tooltip_i18n: i18n_key:resource_activecampaign_connection_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:activecampaign,
    is_active: true;

CREATE resource:activecampaign_contact SET
    identity = {
        name: "contact",
        slug: "activecampaign_contact",
        display_name_i18n: i18n_key:resource_activecampaign_contact_name,
        description_i18n: i18n_key:resource_activecampaign_contact_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 11,
        tooltip_i18n: i18n_key:resource_activecampaign_contact_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:activecampaign,
    is_active: true;

CREATE resource:activecampaign_contactList SET
    identity = {
        name: "contactList",
        slug: "activecampaign_contactList",
        display_name_i18n: i18n_key:resource_activecampaign_contactList_name,
        description_i18n: i18n_key:resource_activecampaign_contactList_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 12,
        tooltip_i18n: i18n_key:resource_activecampaign_contactList_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:activecampaign,
    is_active: true;

CREATE resource:activecampaign_contactTag SET
    identity = {
        name: "contactTag",
        slug: "activecampaign_contactTag",
        display_name_i18n: i18n_key:resource_activecampaign_contactTag_name,
        description_i18n: i18n_key:resource_activecampaign_contactTag_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 13,
        tooltip_i18n: i18n_key:resource_activecampaign_contactTag_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:activecampaign,
    is_active: true;

CREATE resource:activecampaign_deal SET
    identity = {
        name: "deal",
        slug: "activecampaign_deal",
        display_name_i18n: i18n_key:resource_activecampaign_deal_name,
        description_i18n: i18n_key:resource_activecampaign_deal_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 14,
        tooltip_i18n: i18n_key:resource_activecampaign_deal_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:activecampaign,
    is_active: true;

CREATE resource:activecampaign_ecommerceCustomer SET
    identity = {
        name: "ecommerceCustomer",
        slug: "activecampaign_ecommerceCustomer",
        display_name_i18n: i18n_key:resource_activecampaign_ecommerceCustomer_name,
        description_i18n: i18n_key:resource_activecampaign_ecommerceCustomer_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 15,
        tooltip_i18n: i18n_key:resource_activecampaign_ecommerceCustomer_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:activecampaign,
    is_active: true;

CREATE resource:activecampaign_ecommerceOrder SET
    identity = {
        name: "ecommerceOrder",
        slug: "activecampaign_ecommerceOrder",
        display_name_i18n: i18n_key:resource_activecampaign_ecommerceOrder_name,
        description_i18n: i18n_key:resource_activecampaign_ecommerceOrder_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 16,
        tooltip_i18n: i18n_key:resource_activecampaign_ecommerceOrder_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:activecampaign,
    is_active: true;

CREATE resource:activecampaign_ecommerceOrderProducts SET
    identity = {
        name: "ecommerceOrderProducts",
        slug: "activecampaign_ecommerceOrderProducts",
        display_name_i18n: i18n_key:resource_activecampaign_ecommerceOrderProducts_name,
        description_i18n: i18n_key:resource_activecampaign_ecommerceOrderProducts_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 17,
        tooltip_i18n: i18n_key:resource_activecampaign_ecommerceOrderProducts_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:activecampaign,
    is_active: true;

CREATE resource:activecampaign_list SET
    identity = {
        name: "list",
        slug: "activecampaign_list",
        display_name_i18n: i18n_key:resource_activecampaign_list_name,
        description_i18n: i18n_key:resource_activecampaign_list_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 18,
        tooltip_i18n: i18n_key:resource_activecampaign_list_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:activecampaign,
    is_active: true;

CREATE resource:activecampaign_tag SET
    identity = {
        name: "tag",
        slug: "activecampaign_tag",
        display_name_i18n: i18n_key:resource_activecampaign_tag_name,
        description_i18n: i18n_key:resource_activecampaign_tag_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 19,
        tooltip_i18n: i18n_key:resource_activecampaign_tag_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:activecampaign,
    is_active: true;

CREATE resource:activecampaign_accountcontact SET
    identity = {
        name: "accountcontact",
        slug: "activecampaign_accountcontact",
        display_name_i18n: i18n_key:resource_activecampaign_accountcontact_name,
        description_i18n: i18n_key:resource_activecampaign_accountcontact_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 20,
        tooltip_i18n: i18n_key:resource_activecampaign_accountcontact_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:activecampaign,
    is_active: true;

CREATE resource:activecampaign_contactlist SET
    identity = {
        name: "contactlist",
        slug: "activecampaign_contactlist",
        display_name_i18n: i18n_key:resource_activecampaign_contactlist_name,
        description_i18n: i18n_key:resource_activecampaign_contactlist_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 21,
        tooltip_i18n: i18n_key:resource_activecampaign_contactlist_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:activecampaign,
    is_active: true;

CREATE resource:activecampaign_contacttag SET
    identity = {
        name: "contacttag",
        slug: "activecampaign_contacttag",
        display_name_i18n: i18n_key:resource_activecampaign_contacttag_name,
        description_i18n: i18n_key:resource_activecampaign_contacttag_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 22,
        tooltip_i18n: i18n_key:resource_activecampaign_contacttag_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:activecampaign,
    is_active: true;

CREATE resource:activecampaign_ecomcustomer SET
    identity = {
        name: "ecomcustomer",
        slug: "activecampaign_ecomcustomer",
        display_name_i18n: i18n_key:resource_activecampaign_ecomcustomer_name,
        description_i18n: i18n_key:resource_activecampaign_ecomcustomer_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 23,
        tooltip_i18n: i18n_key:resource_activecampaign_ecomcustomer_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:activecampaign,
    is_active: true;

CREATE resource:activecampaign_ecomorder SET
    identity = {
        name: "ecomorder",
        slug: "activecampaign_ecomorder",
        display_name_i18n: i18n_key:resource_activecampaign_ecomorder_name,
        description_i18n: i18n_key:resource_activecampaign_ecomorder_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 24,
        tooltip_i18n: i18n_key:resource_activecampaign_ecomorder_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:activecampaign,
    is_active: true;

CREATE resource:activecampaign_ecomorderproducts SET
    identity = {
        name: "ecomorderproducts",
        slug: "activecampaign_ecomorderproducts",
        display_name_i18n: i18n_key:resource_activecampaign_ecomorderproducts_name,
        description_i18n: i18n_key:resource_activecampaign_ecomorderproducts_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 25,
        tooltip_i18n: i18n_key:resource_activecampaign_ecomorderproducts_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:activecampaign,
    is_active: true;

CREATE resource:adalo_collection SET
    identity = {
        name: "collection",
        slug: "adalo_collection",
        display_name_i18n: i18n_key:resource_adalo_collection_name,
        description_i18n: i18n_key:resource_adalo_collection_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 26,
        tooltip_i18n: i18n_key:resource_adalo_collection_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:adalo,
    is_active: true;

CREATE resource:affinity_list SET
    identity = {
        name: "list",
        slug: "affinity_list",
        display_name_i18n: i18n_key:resource_affinity_list_name,
        description_i18n: i18n_key:resource_affinity_list_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 27,
        tooltip_i18n: i18n_key:resource_affinity_list_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:affinity,
    is_active: true;

CREATE resource:affinity_listEntry SET
    identity = {
        name: "listEntry",
        slug: "affinity_listEntry",
        display_name_i18n: i18n_key:resource_affinity_listEntry_name,
        description_i18n: i18n_key:resource_affinity_listEntry_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 28,
        tooltip_i18n: i18n_key:resource_affinity_listEntry_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:affinity,
    is_active: true;

CREATE resource:affinity_organization SET
    identity = {
        name: "organization",
        slug: "affinity_organization",
        display_name_i18n: i18n_key:resource_affinity_organization_name,
        description_i18n: i18n_key:resource_affinity_organization_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 29,
        tooltip_i18n: i18n_key:resource_affinity_organization_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:affinity,
    is_active: true;

CREATE resource:affinity_person SET
    identity = {
        name: "person",
        slug: "affinity_person",
        display_name_i18n: i18n_key:resource_affinity_person_name,
        description_i18n: i18n_key:resource_affinity_person_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 30,
        tooltip_i18n: i18n_key:resource_affinity_person_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:affinity,
    is_active: true;

CREATE resource:affinity_listentry SET
    identity = {
        name: "listentry",
        slug: "affinity_listentry",
        display_name_i18n: i18n_key:resource_affinity_listentry_name,
        description_i18n: i18n_key:resource_affinity_listentry_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 31,
        tooltip_i18n: i18n_key:resource_affinity_listentry_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:affinity,
    is_active: true;

CREATE resource:agilecrm_company SET
    identity = {
        name: "company",
        slug: "agilecrm_company",
        display_name_i18n: i18n_key:resource_agilecrm_company_name,
        description_i18n: i18n_key:resource_agilecrm_company_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 32,
        tooltip_i18n: i18n_key:resource_agilecrm_company_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:agilecrm,
    is_active: true;

CREATE resource:agilecrm_contact SET
    identity = {
        name: "contact",
        slug: "agilecrm_contact",
        display_name_i18n: i18n_key:resource_agilecrm_contact_name,
        description_i18n: i18n_key:resource_agilecrm_contact_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 33,
        tooltip_i18n: i18n_key:resource_agilecrm_contact_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:agilecrm,
    is_active: true;

CREATE resource:agilecrm_deal SET
    identity = {
        name: "deal",
        slug: "agilecrm_deal",
        display_name_i18n: i18n_key:resource_agilecrm_deal_name,
        description_i18n: i18n_key:resource_agilecrm_deal_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 34,
        tooltip_i18n: i18n_key:resource_agilecrm_deal_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:agilecrm,
    is_active: true;

CREATE resource:airtable_airtable SET
    identity = {
        name: "airtable",
        slug: "airtable_airtable",
        display_name_i18n: i18n_key:resource_airtable_airtable_name,
        description_i18n: i18n_key:resource_airtable_airtable_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 35,
        tooltip_i18n: i18n_key:resource_airtable_airtable_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:airtable,
    is_active: true;

CREATE resource:airtablev1_airtablev1 SET
    identity = {
        name: "airtablev1",
        slug: "airtablev1_airtablev1",
        display_name_i18n: i18n_key:resource_airtablev1_airtablev1_name,
        description_i18n: i18n_key:resource_airtablev1_airtablev1_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 36,
        tooltip_i18n: i18n_key:resource_airtablev1_airtablev1_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:airtablev1,
    is_active: true;

CREATE resource:airtablev2_airtablev2 SET
    identity = {
        name: "airtablev2",
        slug: "airtablev2_airtablev2",
        display_name_i18n: i18n_key:resource_airtablev2_airtablev2_name,
        description_i18n: i18n_key:resource_airtablev2_airtablev2_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 37,
        tooltip_i18n: i18n_key:resource_airtablev2_airtablev2_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:airtablev2,
    is_active: true;

CREATE resource:airtop_extraction SET
    identity = {
        name: "extraction",
        slug: "airtop_extraction",
        display_name_i18n: i18n_key:resource_airtop_extraction_name,
        description_i18n: i18n_key:resource_airtop_extraction_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 38,
        tooltip_i18n: i18n_key:resource_airtop_extraction_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:airtop,
    is_active: true;

CREATE resource:airtop_file SET
    identity = {
        name: "file",
        slug: "airtop_file",
        display_name_i18n: i18n_key:resource_airtop_file_name,
        description_i18n: i18n_key:resource_airtop_file_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 39,
        tooltip_i18n: i18n_key:resource_airtop_file_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:airtop,
    is_active: true;

CREATE resource:airtop_interaction SET
    identity = {
        name: "interaction",
        slug: "airtop_interaction",
        display_name_i18n: i18n_key:resource_airtop_interaction_name,
        description_i18n: i18n_key:resource_airtop_interaction_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 40,
        tooltip_i18n: i18n_key:resource_airtop_interaction_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:airtop,
    is_active: true;

CREATE resource:airtop_session SET
    identity = {
        name: "session",
        slug: "airtop_session",
        display_name_i18n: i18n_key:resource_airtop_session_name,
        description_i18n: i18n_key:resource_airtop_session_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 41,
        tooltip_i18n: i18n_key:resource_airtop_session_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:airtop,
    is_active: true;

CREATE resource:airtop_window SET
    identity = {
        name: "window",
        slug: "airtop_window",
        display_name_i18n: i18n_key:resource_airtop_window_name,
        description_i18n: i18n_key:resource_airtop_window_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 42,
        tooltip_i18n: i18n_key:resource_airtop_window_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:airtop,
    is_active: true;

CREATE resource:aitransform_aitransform SET
    identity = {
        name: "aitransform",
        slug: "aitransform_aitransform",
        display_name_i18n: i18n_key:resource_aitransform_aitransform_name,
        description_i18n: i18n_key:resource_aitransform_aitransform_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 43,
        tooltip_i18n: i18n_key:resource_aitransform_aitransform_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:aitransform,
    is_active: true;

CREATE resource:amqp_amqp SET
    identity = {
        name: "amqp",
        slug: "amqp_amqp",
        display_name_i18n: i18n_key:resource_amqp_amqp_name,
        description_i18n: i18n_key:resource_amqp_amqp_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 44,
        tooltip_i18n: i18n_key:resource_amqp_amqp_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:amqp,
    is_active: true;

CREATE resource:apitemplateio_account SET
    identity = {
        name: "account",
        slug: "apitemplateio_account",
        display_name_i18n: i18n_key:resource_apitemplateio_account_name,
        description_i18n: i18n_key:resource_apitemplateio_account_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 45,
        tooltip_i18n: i18n_key:resource_apitemplateio_account_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:apitemplateio,
    is_active: true;

CREATE resource:apitemplateio_image SET
    identity = {
        name: "image",
        slug: "apitemplateio_image",
        display_name_i18n: i18n_key:resource_apitemplateio_image_name,
        description_i18n: i18n_key:resource_apitemplateio_image_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 46,
        tooltip_i18n: i18n_key:resource_apitemplateio_image_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:apitemplateio,
    is_active: true;

CREATE resource:apitemplateio_pdf SET
    identity = {
        name: "pdf",
        slug: "apitemplateio_pdf",
        display_name_i18n: i18n_key:resource_apitemplateio_pdf_name,
        description_i18n: i18n_key:resource_apitemplateio_pdf_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 47,
        tooltip_i18n: i18n_key:resource_apitemplateio_pdf_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:apitemplateio,
    is_active: true;

CREATE resource:asana_project SET
    identity = {
        name: "project",
        slug: "asana_project",
        display_name_i18n: i18n_key:resource_asana_project_name,
        description_i18n: i18n_key:resource_asana_project_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 48,
        tooltip_i18n: i18n_key:resource_asana_project_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
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

CREATE resource:asana_subtask SET
    identity = {
        name: "subtask",
        slug: "asana_subtask",
        display_name_i18n: i18n_key:resource_asana_subtask_name,
        description_i18n: i18n_key:resource_asana_subtask_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 49,
        tooltip_i18n: i18n_key:resource_asana_subtask_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
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

CREATE resource:asana_task SET
    identity = {
        name: "task",
        slug: "asana_task",
        display_name_i18n: i18n_key:resource_asana_task_name,
        description_i18n: i18n_key:resource_asana_task_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 50,
        tooltip_i18n: i18n_key:resource_asana_task_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
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

