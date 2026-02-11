-- Batch 15: 50 ressources Lyxal

CREATE resource:onesimpleapi_utility SET
    identity = {
        name: "utility",
        slug: "onesimpleapi_utility",
        display_name_i18n: i18n_key:resource_onesimpleapi_utility_name,
        description_i18n: i18n_key:resource_onesimpleapi_utility_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 701,
        tooltip_i18n: i18n_key:resource_onesimpleapi_utility_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
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

CREATE resource:onesimpleapi_website SET
    identity = {
        name: "website",
        slug: "onesimpleapi_website",
        display_name_i18n: i18n_key:resource_onesimpleapi_website_name,
        description_i18n: i18n_key:resource_onesimpleapi_website_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 702,
        tooltip_i18n: i18n_key:resource_onesimpleapi_website_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
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

CREATE resource:onfleet_admin SET
    identity = {
        name: "admin",
        slug: "onfleet_admin",
        display_name_i18n: i18n_key:resource_onfleet_admin_name,
        description_i18n: i18n_key:resource_onfleet_admin_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 703,
        tooltip_i18n: i18n_key:resource_onfleet_admin_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:onfleet,
    is_active: true;

CREATE resource:onfleet_container SET
    identity = {
        name: "container",
        slug: "onfleet_container",
        display_name_i18n: i18n_key:resource_onfleet_container_name,
        description_i18n: i18n_key:resource_onfleet_container_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 704,
        tooltip_i18n: i18n_key:resource_onfleet_container_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:onfleet,
    is_active: true;

CREATE resource:onfleet_destination SET
    identity = {
        name: "destination",
        slug: "onfleet_destination",
        display_name_i18n: i18n_key:resource_onfleet_destination_name,
        description_i18n: i18n_key:resource_onfleet_destination_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 705,
        tooltip_i18n: i18n_key:resource_onfleet_destination_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:onfleet,
    is_active: true;

CREATE resource:onfleet_hub SET
    identity = {
        name: "hub",
        slug: "onfleet_hub",
        display_name_i18n: i18n_key:resource_onfleet_hub_name,
        description_i18n: i18n_key:resource_onfleet_hub_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 706,
        tooltip_i18n: i18n_key:resource_onfleet_hub_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:onfleet,
    is_active: true;

CREATE resource:onfleet_organization SET
    identity = {
        name: "organization",
        slug: "onfleet_organization",
        display_name_i18n: i18n_key:resource_onfleet_organization_name,
        description_i18n: i18n_key:resource_onfleet_organization_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 707,
        tooltip_i18n: i18n_key:resource_onfleet_organization_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:onfleet,
    is_active: true;

CREATE resource:onfleet_recipient SET
    identity = {
        name: "recipient",
        slug: "onfleet_recipient",
        display_name_i18n: i18n_key:resource_onfleet_recipient_name,
        description_i18n: i18n_key:resource_onfleet_recipient_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 708,
        tooltip_i18n: i18n_key:resource_onfleet_recipient_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:onfleet,
    is_active: true;

CREATE resource:onfleet_task SET
    identity = {
        name: "task",
        slug: "onfleet_task",
        display_name_i18n: i18n_key:resource_onfleet_task_name,
        description_i18n: i18n_key:resource_onfleet_task_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 709,
        tooltip_i18n: i18n_key:resource_onfleet_task_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:onfleet,
    is_active: true;

CREATE resource:onfleet_team SET
    identity = {
        name: "team",
        slug: "onfleet_team",
        display_name_i18n: i18n_key:resource_onfleet_team_name,
        description_i18n: i18n_key:resource_onfleet_team_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 710,
        tooltip_i18n: i18n_key:resource_onfleet_team_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:onfleet,
    is_active: true;

CREATE resource:onfleet_worker SET
    identity = {
        name: "worker",
        slug: "onfleet_worker",
        display_name_i18n: i18n_key:resource_onfleet_worker_name,
        description_i18n: i18n_key:resource_onfleet_worker_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 711,
        tooltip_i18n: i18n_key:resource_onfleet_worker_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:onfleet,
    is_active: true;

CREATE resource:openai_chat SET
    identity = {
        name: "chat",
        slug: "openai_chat",
        display_name_i18n: i18n_key:resource_openai_chat_name,
        description_i18n: i18n_key:resource_openai_chat_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 712,
        tooltip_i18n: i18n_key:resource_openai_chat_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:openai,
    is_active: true;

CREATE resource:openai_image SET
    identity = {
        name: "image",
        slug: "openai_image",
        display_name_i18n: i18n_key:resource_openai_image_name,
        description_i18n: i18n_key:resource_openai_image_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 713,
        tooltip_i18n: i18n_key:resource_openai_image_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:openai,
    is_active: true;

CREATE resource:openai_text SET
    identity = {
        name: "text",
        slug: "openai_text",
        display_name_i18n: i18n_key:resource_openai_text_name,
        description_i18n: i18n_key:resource_openai_text_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 714,
        tooltip_i18n: i18n_key:resource_openai_text_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:openai,
    is_active: true;

CREATE resource:openthesaurus_openthesaurus SET
    identity = {
        name: "openthesaurus",
        slug: "openthesaurus_openthesaurus",
        display_name_i18n: i18n_key:resource_openthesaurus_openthesaurus_name,
        description_i18n: i18n_key:resource_openthesaurus_openthesaurus_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 715,
        tooltip_i18n: i18n_key:resource_openthesaurus_openthesaurus_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:openthesaurus,
    is_active: true;

CREATE resource:openweathermap_openweathermap SET
    identity = {
        name: "openweathermap",
        slug: "openweathermap_openweathermap",
        display_name_i18n: i18n_key:resource_openweathermap_openweathermap_name,
        description_i18n: i18n_key:resource_openweathermap_openweathermap_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 716,
        tooltip_i18n: i18n_key:resource_openweathermap_openweathermap_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:openweathermap,
    is_active: true;

CREATE resource:oraclesql_oraclesql SET
    identity = {
        name: "oraclesql",
        slug: "oraclesql_oraclesql",
        display_name_i18n: i18n_key:resource_oraclesql_oraclesql_name,
        description_i18n: i18n_key:resource_oraclesql_oraclesql_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 717,
        tooltip_i18n: i18n_key:resource_oraclesql_oraclesql_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:oraclesql,
    is_active: true;

CREATE resource:orbit_activity SET
    identity = {
        name: "activity",
        slug: "orbit_activity",
        display_name_i18n: i18n_key:resource_orbit_activity_name,
        description_i18n: i18n_key:resource_orbit_activity_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 718,
        tooltip_i18n: i18n_key:resource_orbit_activity_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:orbit,
    is_active: true;

CREATE resource:orbit_member SET
    identity = {
        name: "member",
        slug: "orbit_member",
        display_name_i18n: i18n_key:resource_orbit_member_name,
        description_i18n: i18n_key:resource_orbit_member_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 719,
        tooltip_i18n: i18n_key:resource_orbit_member_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:orbit,
    is_active: true;

CREATE resource:orbit_note SET
    identity = {
        name: "note",
        slug: "orbit_note",
        display_name_i18n: i18n_key:resource_orbit_note_name,
        description_i18n: i18n_key:resource_orbit_note_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 720,
        tooltip_i18n: i18n_key:resource_orbit_note_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:orbit,
    is_active: true;

CREATE resource:orbit_post SET
    identity = {
        name: "post",
        slug: "orbit_post",
        display_name_i18n: i18n_key:resource_orbit_post_name,
        description_i18n: i18n_key:resource_orbit_post_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 721,
        tooltip_i18n: i18n_key:resource_orbit_post_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:orbit,
    is_active: true;

CREATE resource:oura_profile SET
    identity = {
        name: "profile",
        slug: "oura_profile",
        display_name_i18n: i18n_key:resource_oura_profile_name,
        description_i18n: i18n_key:resource_oura_profile_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 722,
        tooltip_i18n: i18n_key:resource_oura_profile_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:oura,
    is_active: true;

CREATE resource:oura_summary SET
    identity = {
        name: "summary",
        slug: "oura_summary",
        display_name_i18n: i18n_key:resource_oura_summary_name,
        description_i18n: i18n_key:resource_oura_summary_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 723,
        tooltip_i18n: i18n_key:resource_oura_summary_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:oura,
    is_active: true;

CREATE resource:paddle_coupon SET
    identity = {
        name: "coupon",
        slug: "paddle_coupon",
        display_name_i18n: i18n_key:resource_paddle_coupon_name,
        description_i18n: i18n_key:resource_paddle_coupon_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 724,
        tooltip_i18n: i18n_key:resource_paddle_coupon_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:paddle,
    is_active: true;

CREATE resource:paddle_payment SET
    identity = {
        name: "payment",
        slug: "paddle_payment",
        display_name_i18n: i18n_key:resource_paddle_payment_name,
        description_i18n: i18n_key:resource_paddle_payment_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 725,
        tooltip_i18n: i18n_key:resource_paddle_payment_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:paddle,
    is_active: true;

CREATE resource:paddle_plan SET
    identity = {
        name: "plan",
        slug: "paddle_plan",
        display_name_i18n: i18n_key:resource_paddle_plan_name,
        description_i18n: i18n_key:resource_paddle_plan_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 726,
        tooltip_i18n: i18n_key:resource_paddle_plan_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:paddle,
    is_active: true;

CREATE resource:paddle_product SET
    identity = {
        name: "product",
        slug: "paddle_product",
        display_name_i18n: i18n_key:resource_paddle_product_name,
        description_i18n: i18n_key:resource_paddle_product_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 727,
        tooltip_i18n: i18n_key:resource_paddle_product_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:paddle,
    is_active: true;

CREATE resource:paddle_user SET
    identity = {
        name: "user",
        slug: "paddle_user",
        display_name_i18n: i18n_key:resource_paddle_user_name,
        description_i18n: i18n_key:resource_paddle_user_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 728,
        tooltip_i18n: i18n_key:resource_paddle_user_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:paddle,
    is_active: true;

CREATE resource:paddle_order SET
    identity = {
        name: "order",
        slug: "paddle_order",
        display_name_i18n: i18n_key:resource_paddle_order_name,
        description_i18n: i18n_key:resource_paddle_order_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 729,
        tooltip_i18n: i18n_key:resource_paddle_order_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:paddle,
    is_active: true;

CREATE resource:pagerduty_incident SET
    identity = {
        name: "incident",
        slug: "pagerduty_incident",
        display_name_i18n: i18n_key:resource_pagerduty_incident_name,
        description_i18n: i18n_key:resource_pagerduty_incident_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 730,
        tooltip_i18n: i18n_key:resource_pagerduty_incident_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:pagerduty,
    is_active: true;

CREATE resource:pagerduty_incidentNote SET
    identity = {
        name: "incidentNote",
        slug: "pagerduty_incidentNote",
        display_name_i18n: i18n_key:resource_pagerduty_incidentNote_name,
        description_i18n: i18n_key:resource_pagerduty_incidentNote_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 731,
        tooltip_i18n: i18n_key:resource_pagerduty_incidentNote_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:pagerduty,
    is_active: true;

CREATE resource:pagerduty_logEntry SET
    identity = {
        name: "logEntry",
        slug: "pagerduty_logEntry",
        display_name_i18n: i18n_key:resource_pagerduty_logEntry_name,
        description_i18n: i18n_key:resource_pagerduty_logEntry_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 732,
        tooltip_i18n: i18n_key:resource_pagerduty_logEntry_tooltip,
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
            supports_search: true
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:pagerduty,
    is_active: true;

CREATE resource:pagerduty_user SET
    identity = {
        name: "user",
        slug: "pagerduty_user",
        display_name_i18n: i18n_key:resource_pagerduty_user_name,
        description_i18n: i18n_key:resource_pagerduty_user_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 733,
        tooltip_i18n: i18n_key:resource_pagerduty_user_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:pagerduty,
    is_active: true;

CREATE resource:pagerduty_incidentnote SET
    identity = {
        name: "incidentnote",
        slug: "pagerduty_incidentnote",
        display_name_i18n: i18n_key:resource_pagerduty_incidentnote_name,
        description_i18n: i18n_key:resource_pagerduty_incidentnote_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 734,
        tooltip_i18n: i18n_key:resource_pagerduty_incidentnote_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:pagerduty,
    is_active: true;

CREATE resource:pagerduty_logentry SET
    identity = {
        name: "logentry",
        slug: "pagerduty_logentry",
        display_name_i18n: i18n_key:resource_pagerduty_logentry_name,
        description_i18n: i18n_key:resource_pagerduty_logentry_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 735,
        tooltip_i18n: i18n_key:resource_pagerduty_logentry_tooltip,
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
            supports_search: true
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:pagerduty,
    is_active: true;

CREATE resource:paypal_payout SET
    identity = {
        name: "payout",
        slug: "paypal_payout",
        display_name_i18n: i18n_key:resource_paypal_payout_name,
        description_i18n: i18n_key:resource_paypal_payout_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 736,
        tooltip_i18n: i18n_key:resource_paypal_payout_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:paypal,
    is_active: true;

CREATE resource:paypal_payoutItem SET
    identity = {
        name: "payoutItem",
        slug: "paypal_payoutItem",
        display_name_i18n: i18n_key:resource_paypal_payoutItem_name,
        description_i18n: i18n_key:resource_paypal_payoutItem_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 737,
        tooltip_i18n: i18n_key:resource_paypal_payoutItem_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:paypal,
    is_active: true;

CREATE resource:paypal_payment SET
    identity = {
        name: "payment",
        slug: "paypal_payment",
        display_name_i18n: i18n_key:resource_paypal_payment_name,
        description_i18n: i18n_key:resource_paypal_payment_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 738,
        tooltip_i18n: i18n_key:resource_paypal_payment_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:paypal,
    is_active: true;

CREATE resource:peekalink_peekalink SET
    identity = {
        name: "peekalink",
        slug: "peekalink_peekalink",
        display_name_i18n: i18n_key:resource_peekalink_peekalink_name,
        description_i18n: i18n_key:resource_peekalink_peekalink_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 739,
        tooltip_i18n: i18n_key:resource_peekalink_peekalink_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:peekalink,
    is_active: true;

CREATE resource:perplexity_chat SET
    identity = {
        name: "chat",
        slug: "perplexity_chat",
        display_name_i18n: i18n_key:resource_perplexity_chat_name,
        description_i18n: i18n_key:resource_perplexity_chat_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 740,
        tooltip_i18n: i18n_key:resource_perplexity_chat_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:perplexity,
    is_active: true;

CREATE resource:phantombuster_agent SET
    identity = {
        name: "agent",
        slug: "phantombuster_agent",
        display_name_i18n: i18n_key:resource_phantombuster_agent_name,
        description_i18n: i18n_key:resource_phantombuster_agent_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 741,
        tooltip_i18n: i18n_key:resource_phantombuster_agent_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:phantombuster,
    is_active: true;

CREATE resource:philipshue_light SET
    identity = {
        name: "light",
        slug: "philipshue_light",
        display_name_i18n: i18n_key:resource_philipshue_light_name,
        description_i18n: i18n_key:resource_philipshue_light_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 742,
        tooltip_i18n: i18n_key:resource_philipshue_light_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:philipshue,
    is_active: true;

CREATE resource:pipedrive_activity SET
    identity = {
        name: "activity",
        slug: "pipedrive_activity",
        display_name_i18n: i18n_key:resource_pipedrive_activity_name,
        description_i18n: i18n_key:resource_pipedrive_activity_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 743,
        tooltip_i18n: i18n_key:resource_pipedrive_activity_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:pipedrive,
    is_active: true;

CREATE resource:pipedrive_deal SET
    identity = {
        name: "deal",
        slug: "pipedrive_deal",
        display_name_i18n: i18n_key:resource_pipedrive_deal_name,
        description_i18n: i18n_key:resource_pipedrive_deal_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 744,
        tooltip_i18n: i18n_key:resource_pipedrive_deal_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:pipedrive,
    is_active: true;

CREATE resource:pipedrive_dealActivity SET
    identity = {
        name: "dealActivity",
        slug: "pipedrive_dealActivity",
        display_name_i18n: i18n_key:resource_pipedrive_dealActivity_name,
        description_i18n: i18n_key:resource_pipedrive_dealActivity_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 745,
        tooltip_i18n: i18n_key:resource_pipedrive_dealActivity_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:pipedrive,
    is_active: true;

CREATE resource:pipedrive_dealProduct SET
    identity = {
        name: "dealProduct",
        slug: "pipedrive_dealProduct",
        display_name_i18n: i18n_key:resource_pipedrive_dealProduct_name,
        description_i18n: i18n_key:resource_pipedrive_dealProduct_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 746,
        tooltip_i18n: i18n_key:resource_pipedrive_dealProduct_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:pipedrive,
    is_active: true;

CREATE resource:pipedrive_file SET
    identity = {
        name: "file",
        slug: "pipedrive_file",
        display_name_i18n: i18n_key:resource_pipedrive_file_name,
        description_i18n: i18n_key:resource_pipedrive_file_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 747,
        tooltip_i18n: i18n_key:resource_pipedrive_file_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:pipedrive,
    is_active: true;

CREATE resource:pipedrive_lead SET
    identity = {
        name: "lead",
        slug: "pipedrive_lead",
        display_name_i18n: i18n_key:resource_pipedrive_lead_name,
        description_i18n: i18n_key:resource_pipedrive_lead_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 748,
        tooltip_i18n: i18n_key:resource_pipedrive_lead_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:pipedrive,
    is_active: true;

CREATE resource:pipedrive_note SET
    identity = {
        name: "note",
        slug: "pipedrive_note",
        display_name_i18n: i18n_key:resource_pipedrive_note_name,
        description_i18n: i18n_key:resource_pipedrive_note_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 749,
        tooltip_i18n: i18n_key:resource_pipedrive_note_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:pipedrive,
    is_active: true;

CREATE resource:pipedrive_organization SET
    identity = {
        name: "organization",
        slug: "pipedrive_organization",
        display_name_i18n: i18n_key:resource_pipedrive_organization_name,
        description_i18n: i18n_key:resource_pipedrive_organization_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 750,
        tooltip_i18n: i18n_key:resource_pipedrive_organization_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:pipedrive,
    is_active: true;

