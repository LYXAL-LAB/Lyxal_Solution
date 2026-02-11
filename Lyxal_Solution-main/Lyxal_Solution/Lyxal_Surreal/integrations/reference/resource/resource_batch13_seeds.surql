-- Batch 13: 50 ressources Lyxal

CREATE resource:azurestorage_blob SET
    identity = {
        name: "blob",
        slug: "azurestorage_blob",
        display_name_i18n: i18n_key:resource_azurestorage_blob_name,
        description_i18n: i18n_key:resource_azurestorage_blob_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 601,
        tooltip_i18n: i18n_key:resource_azurestorage_blob_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:azurestorage,
    is_active: true;

CREATE resource:azurestorage_container SET
    identity = {
        name: "container",
        slug: "azurestorage_container",
        display_name_i18n: i18n_key:resource_azurestorage_container_name,
        description_i18n: i18n_key:resource_azurestorage_container_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 602,
        tooltip_i18n: i18n_key:resource_azurestorage_container_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:azurestorage,
    is_active: true;

CREATE resource:microsoftteams_microsoftteams SET
    identity = {
        name: "microsoftteams",
        slug: "microsoftteams_microsoftteams",
        display_name_i18n: i18n_key:resource_microsoftteams_microsoftteams_name,
        description_i18n: i18n_key:resource_microsoftteams_microsoftteams_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 603,
        tooltip_i18n: i18n_key:resource_microsoftteams_microsoftteams_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:microsoftteams,
    is_active: true;

CREATE resource:microsoftteamsv1_channel SET
    identity = {
        name: "channel",
        slug: "microsoftteamsv1_channel",
        display_name_i18n: i18n_key:resource_microsoftteamsv1_channel_name,
        description_i18n: i18n_key:resource_microsoftteamsv1_channel_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 604,
        tooltip_i18n: i18n_key:resource_microsoftteamsv1_channel_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:microsoftteamsv1,
    is_active: true;

CREATE resource:microsoftteamsv1_channelMessage SET
    identity = {
        name: "channelMessage",
        slug: "microsoftteamsv1_channelMessage",
        display_name_i18n: i18n_key:resource_microsoftteamsv1_channelMessage_name,
        description_i18n: i18n_key:resource_microsoftteamsv1_channelMessage_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 605,
        tooltip_i18n: i18n_key:resource_microsoftteamsv1_channelMessage_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:microsoftteamsv1,
    is_active: true;

CREATE resource:microsoftteamsv1_chatMessage SET
    identity = {
        name: "chatMessage",
        slug: "microsoftteamsv1_chatMessage",
        display_name_i18n: i18n_key:resource_microsoftteamsv1_chatMessage_name,
        description_i18n: i18n_key:resource_microsoftteamsv1_chatMessage_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 606,
        tooltip_i18n: i18n_key:resource_microsoftteamsv1_chatMessage_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:microsoftteamsv1,
    is_active: true;

CREATE resource:microsoftteamsv1_task SET
    identity = {
        name: "task",
        slug: "microsoftteamsv1_task",
        display_name_i18n: i18n_key:resource_microsoftteamsv1_task_name,
        description_i18n: i18n_key:resource_microsoftteamsv1_task_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 607,
        tooltip_i18n: i18n_key:resource_microsoftteamsv1_task_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:microsoftteamsv1,
    is_active: true;

CREATE resource:microsoftteamsv1_channelmessage SET
    identity = {
        name: "channelmessage",
        slug: "microsoftteamsv1_channelmessage",
        display_name_i18n: i18n_key:resource_microsoftteamsv1_channelmessage_name,
        description_i18n: i18n_key:resource_microsoftteamsv1_channelmessage_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 608,
        tooltip_i18n: i18n_key:resource_microsoftteamsv1_channelmessage_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:microsoftteamsv1,
    is_active: true;

CREATE resource:microsoftteamsv1_chatmessage SET
    identity = {
        name: "chatmessage",
        slug: "microsoftteamsv1_chatmessage",
        display_name_i18n: i18n_key:resource_microsoftteamsv1_chatmessage_name,
        description_i18n: i18n_key:resource_microsoftteamsv1_chatmessage_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 609,
        tooltip_i18n: i18n_key:resource_microsoftteamsv1_chatmessage_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:microsoftteamsv1,
    is_active: true;

CREATE resource:microsoftteamsv2_microsoftteamsv2 SET
    identity = {
        name: "microsoftteamsv2",
        slug: "microsoftteamsv2_microsoftteamsv2",
        display_name_i18n: i18n_key:resource_microsoftteamsv2_microsoftteamsv2_name,
        description_i18n: i18n_key:resource_microsoftteamsv2_microsoftteamsv2_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 610,
        tooltip_i18n: i18n_key:resource_microsoftteamsv2_microsoftteamsv2_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:microsoftteamsv2,
    is_active: true;

CREATE resource:microsofttodo_linkedResource SET
    identity = {
        name: "linkedResource",
        slug: "microsofttodo_linkedResource",
        display_name_i18n: i18n_key:resource_microsofttodo_linkedResource_name,
        description_i18n: i18n_key:resource_microsofttodo_linkedResource_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 611,
        tooltip_i18n: i18n_key:resource_microsofttodo_linkedResource_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:microsofttodo,
    is_active: true;

CREATE resource:microsofttodo_list SET
    identity = {
        name: "list",
        slug: "microsofttodo_list",
        display_name_i18n: i18n_key:resource_microsofttodo_list_name,
        description_i18n: i18n_key:resource_microsofttodo_list_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 612,
        tooltip_i18n: i18n_key:resource_microsofttodo_list_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:microsofttodo,
    is_active: true;

CREATE resource:microsofttodo_task SET
    identity = {
        name: "task",
        slug: "microsofttodo_task",
        display_name_i18n: i18n_key:resource_microsofttodo_task_name,
        description_i18n: i18n_key:resource_microsofttodo_task_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 613,
        tooltip_i18n: i18n_key:resource_microsofttodo_task_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:microsofttodo,
    is_active: true;

CREATE resource:microsofttodo_linkedresource SET
    identity = {
        name: "linkedresource",
        slug: "microsofttodo_linkedresource",
        display_name_i18n: i18n_key:resource_microsofttodo_linkedresource_name,
        description_i18n: i18n_key:resource_microsofttodo_linkedresource_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 614,
        tooltip_i18n: i18n_key:resource_microsofttodo_linkedresource_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:microsofttodo,
    is_active: true;

CREATE resource:mindee_invoice SET
    identity = {
        name: "invoice",
        slug: "mindee_invoice",
        display_name_i18n: i18n_key:resource_mindee_invoice_name,
        description_i18n: i18n_key:resource_mindee_invoice_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 615,
        tooltip_i18n: i18n_key:resource_mindee_invoice_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:mindee,
    is_active: true;

CREATE resource:mindee_receipt SET
    identity = {
        name: "receipt",
        slug: "mindee_receipt",
        display_name_i18n: i18n_key:resource_mindee_receipt_name,
        description_i18n: i18n_key:resource_mindee_receipt_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 616,
        tooltip_i18n: i18n_key:resource_mindee_receipt_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:mindee,
    is_active: true;

CREATE resource:misp_attribute SET
    identity = {
        name: "attribute",
        slug: "misp_attribute",
        display_name_i18n: i18n_key:resource_misp_attribute_name,
        description_i18n: i18n_key:resource_misp_attribute_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 617,
        tooltip_i18n: i18n_key:resource_misp_attribute_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:misp,
    is_active: true;

CREATE resource:misp_event SET
    identity = {
        name: "event",
        slug: "misp_event",
        display_name_i18n: i18n_key:resource_misp_event_name,
        description_i18n: i18n_key:resource_misp_event_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 618,
        tooltip_i18n: i18n_key:resource_misp_event_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:misp,
    is_active: true;

CREATE resource:misp_eventTag SET
    identity = {
        name: "eventTag",
        slug: "misp_eventTag",
        display_name_i18n: i18n_key:resource_misp_eventTag_name,
        description_i18n: i18n_key:resource_misp_eventTag_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 619,
        tooltip_i18n: i18n_key:resource_misp_eventTag_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:misp,
    is_active: true;

CREATE resource:misp_feed SET
    identity = {
        name: "feed",
        slug: "misp_feed",
        display_name_i18n: i18n_key:resource_misp_feed_name,
        description_i18n: i18n_key:resource_misp_feed_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 620,
        tooltip_i18n: i18n_key:resource_misp_feed_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:misp,
    is_active: true;

CREATE resource:misp_galaxy SET
    identity = {
        name: "galaxy",
        slug: "misp_galaxy",
        display_name_i18n: i18n_key:resource_misp_galaxy_name,
        description_i18n: i18n_key:resource_misp_galaxy_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 621,
        tooltip_i18n: i18n_key:resource_misp_galaxy_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:misp,
    is_active: true;

CREATE resource:misp_noticelist SET
    identity = {
        name: "noticelist",
        slug: "misp_noticelist",
        display_name_i18n: i18n_key:resource_misp_noticelist_name,
        description_i18n: i18n_key:resource_misp_noticelist_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 622,
        tooltip_i18n: i18n_key:resource_misp_noticelist_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:misp,
    is_active: true;

CREATE resource:misp_object SET
    identity = {
        name: "object",
        slug: "misp_object",
        display_name_i18n: i18n_key:resource_misp_object_name,
        description_i18n: i18n_key:resource_misp_object_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 623,
        tooltip_i18n: i18n_key:resource_misp_object_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:misp,
    is_active: true;

CREATE resource:misp_organisation SET
    identity = {
        name: "organisation",
        slug: "misp_organisation",
        display_name_i18n: i18n_key:resource_misp_organisation_name,
        description_i18n: i18n_key:resource_misp_organisation_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 624,
        tooltip_i18n: i18n_key:resource_misp_organisation_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:misp,
    is_active: true;

CREATE resource:misp_tag SET
    identity = {
        name: "tag",
        slug: "misp_tag",
        display_name_i18n: i18n_key:resource_misp_tag_name,
        description_i18n: i18n_key:resource_misp_tag_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 625,
        tooltip_i18n: i18n_key:resource_misp_tag_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:misp,
    is_active: true;

CREATE resource:misp_user SET
    identity = {
        name: "user",
        slug: "misp_user",
        display_name_i18n: i18n_key:resource_misp_user_name,
        description_i18n: i18n_key:resource_misp_user_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 626,
        tooltip_i18n: i18n_key:resource_misp_user_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:misp,
    is_active: true;

CREATE resource:misp_warninglist SET
    identity = {
        name: "warninglist",
        slug: "misp_warninglist",
        display_name_i18n: i18n_key:resource_misp_warninglist_name,
        description_i18n: i18n_key:resource_misp_warninglist_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 627,
        tooltip_i18n: i18n_key:resource_misp_warninglist_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:misp,
    is_active: true;

CREATE resource:mistralai_document SET
    identity = {
        name: "document",
        slug: "mistralai_document",
        display_name_i18n: i18n_key:resource_mistralai_document_name,
        description_i18n: i18n_key:resource_mistralai_document_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 628,
        tooltip_i18n: i18n_key:resource_mistralai_document_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:mistralai,
    is_active: true;

CREATE resource:mocean_sms SET
    identity = {
        name: "sms",
        slug: "mocean_sms",
        display_name_i18n: i18n_key:resource_mocean_sms_name,
        description_i18n: i18n_key:resource_mocean_sms_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 629,
        tooltip_i18n: i18n_key:resource_mocean_sms_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:mocean,
    is_active: true;

CREATE resource:mocean_voice SET
    identity = {
        name: "voice",
        slug: "mocean_voice",
        display_name_i18n: i18n_key:resource_mocean_voice_name,
        description_i18n: i18n_key:resource_mocean_voice_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 630,
        tooltip_i18n: i18n_key:resource_mocean_voice_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:mocean,
    is_active: true;

CREATE resource:mondaycom_board SET
    identity = {
        name: "board",
        slug: "mondaycom_board",
        display_name_i18n: i18n_key:resource_mondaycom_board_name,
        description_i18n: i18n_key:resource_mondaycom_board_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 631,
        tooltip_i18n: i18n_key:resource_mondaycom_board_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:mondaycom,
    is_active: true;

CREATE resource:mondaycom_boardColumn SET
    identity = {
        name: "boardColumn",
        slug: "mondaycom_boardColumn",
        display_name_i18n: i18n_key:resource_mondaycom_boardColumn_name,
        description_i18n: i18n_key:resource_mondaycom_boardColumn_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 632,
        tooltip_i18n: i18n_key:resource_mondaycom_boardColumn_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:mondaycom,
    is_active: true;

CREATE resource:mondaycom_boardGroup SET
    identity = {
        name: "boardGroup",
        slug: "mondaycom_boardGroup",
        display_name_i18n: i18n_key:resource_mondaycom_boardGroup_name,
        description_i18n: i18n_key:resource_mondaycom_boardGroup_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 633,
        tooltip_i18n: i18n_key:resource_mondaycom_boardGroup_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:mondaycom,
    is_active: true;

CREATE resource:mondaycom_boardItem SET
    identity = {
        name: "boardItem",
        slug: "mondaycom_boardItem",
        display_name_i18n: i18n_key:resource_mondaycom_boardItem_name,
        description_i18n: i18n_key:resource_mondaycom_boardItem_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 634,
        tooltip_i18n: i18n_key:resource_mondaycom_boardItem_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:mondaycom,
    is_active: true;

CREATE resource:mondaycom_boardcolumn SET
    identity = {
        name: "boardcolumn",
        slug: "mondaycom_boardcolumn",
        display_name_i18n: i18n_key:resource_mondaycom_boardcolumn_name,
        description_i18n: i18n_key:resource_mondaycom_boardcolumn_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 635,
        tooltip_i18n: i18n_key:resource_mondaycom_boardcolumn_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:mondaycom,
    is_active: true;

CREATE resource:mondaycom_boardgroup SET
    identity = {
        name: "boardgroup",
        slug: "mondaycom_boardgroup",
        display_name_i18n: i18n_key:resource_mondaycom_boardgroup_name,
        description_i18n: i18n_key:resource_mondaycom_boardgroup_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 636,
        tooltip_i18n: i18n_key:resource_mondaycom_boardgroup_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:mondaycom,
    is_active: true;

CREATE resource:mondaycom_boarditem SET
    identity = {
        name: "boarditem",
        slug: "mondaycom_boarditem",
        display_name_i18n: i18n_key:resource_mondaycom_boarditem_name,
        description_i18n: i18n_key:resource_mondaycom_boarditem_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 637,
        tooltip_i18n: i18n_key:resource_mondaycom_boarditem_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:mondaycom,
    is_active: true;

CREATE resource:mongodb_mongodb SET
    identity = {
        name: "mongodb",
        slug: "mongodb_mongodb",
        display_name_i18n: i18n_key:resource_mongodb_mongodb_name,
        description_i18n: i18n_key:resource_mongodb_mongodb_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 638,
        tooltip_i18n: i18n_key:resource_mongodb_mongodb_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:mongodb,
    is_active: true;

CREATE resource:monicacrm_activity SET
    identity = {
        name: "activity",
        slug: "monicacrm_activity",
        display_name_i18n: i18n_key:resource_monicacrm_activity_name,
        description_i18n: i18n_key:resource_monicacrm_activity_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 639,
        tooltip_i18n: i18n_key:resource_monicacrm_activity_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:monicacrm,
    is_active: true;

CREATE resource:monicacrm_call SET
    identity = {
        name: "call",
        slug: "monicacrm_call",
        display_name_i18n: i18n_key:resource_monicacrm_call_name,
        description_i18n: i18n_key:resource_monicacrm_call_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 640,
        tooltip_i18n: i18n_key:resource_monicacrm_call_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:monicacrm,
    is_active: true;

CREATE resource:monicacrm_contact SET
    identity = {
        name: "contact",
        slug: "monicacrm_contact",
        display_name_i18n: i18n_key:resource_monicacrm_contact_name,
        description_i18n: i18n_key:resource_monicacrm_contact_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 641,
        tooltip_i18n: i18n_key:resource_monicacrm_contact_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:monicacrm,
    is_active: true;

CREATE resource:monicacrm_contactField SET
    identity = {
        name: "contactField",
        slug: "monicacrm_contactField",
        display_name_i18n: i18n_key:resource_monicacrm_contactField_name,
        description_i18n: i18n_key:resource_monicacrm_contactField_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 642,
        tooltip_i18n: i18n_key:resource_monicacrm_contactField_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:monicacrm,
    is_active: true;

CREATE resource:monicacrm_contactTag SET
    identity = {
        name: "contactTag",
        slug: "monicacrm_contactTag",
        display_name_i18n: i18n_key:resource_monicacrm_contactTag_name,
        description_i18n: i18n_key:resource_monicacrm_contactTag_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 643,
        tooltip_i18n: i18n_key:resource_monicacrm_contactTag_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:monicacrm,
    is_active: true;

CREATE resource:monicacrm_conversation SET
    identity = {
        name: "conversation",
        slug: "monicacrm_conversation",
        display_name_i18n: i18n_key:resource_monicacrm_conversation_name,
        description_i18n: i18n_key:resource_monicacrm_conversation_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 644,
        tooltip_i18n: i18n_key:resource_monicacrm_conversation_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:monicacrm,
    is_active: true;

CREATE resource:monicacrm_conversationMessage SET
    identity = {
        name: "conversationMessage",
        slug: "monicacrm_conversationMessage",
        display_name_i18n: i18n_key:resource_monicacrm_conversationMessage_name,
        description_i18n: i18n_key:resource_monicacrm_conversationMessage_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 645,
        tooltip_i18n: i18n_key:resource_monicacrm_conversationMessage_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:monicacrm,
    is_active: true;

CREATE resource:monicacrm_journalEntry SET
    identity = {
        name: "journalEntry",
        slug: "monicacrm_journalEntry",
        display_name_i18n: i18n_key:resource_monicacrm_journalEntry_name,
        description_i18n: i18n_key:resource_monicacrm_journalEntry_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 646,
        tooltip_i18n: i18n_key:resource_monicacrm_journalEntry_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:monicacrm,
    is_active: true;

CREATE resource:monicacrm_note SET
    identity = {
        name: "note",
        slug: "monicacrm_note",
        display_name_i18n: i18n_key:resource_monicacrm_note_name,
        description_i18n: i18n_key:resource_monicacrm_note_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 647,
        tooltip_i18n: i18n_key:resource_monicacrm_note_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:monicacrm,
    is_active: true;

CREATE resource:monicacrm_reminder SET
    identity = {
        name: "reminder",
        slug: "monicacrm_reminder",
        display_name_i18n: i18n_key:resource_monicacrm_reminder_name,
        description_i18n: i18n_key:resource_monicacrm_reminder_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 648,
        tooltip_i18n: i18n_key:resource_monicacrm_reminder_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:monicacrm,
    is_active: true;

CREATE resource:monicacrm_tag SET
    identity = {
        name: "tag",
        slug: "monicacrm_tag",
        display_name_i18n: i18n_key:resource_monicacrm_tag_name,
        description_i18n: i18n_key:resource_monicacrm_tag_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 649,
        tooltip_i18n: i18n_key:resource_monicacrm_tag_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:monicacrm,
    is_active: true;

CREATE resource:monicacrm_task SET
    identity = {
        name: "task",
        slug: "monicacrm_task",
        display_name_i18n: i18n_key:resource_monicacrm_task_name,
        description_i18n: i18n_key:resource_monicacrm_task_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 650,
        tooltip_i18n: i18n_key:resource_monicacrm_task_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:monicacrm,
    is_active: true;

