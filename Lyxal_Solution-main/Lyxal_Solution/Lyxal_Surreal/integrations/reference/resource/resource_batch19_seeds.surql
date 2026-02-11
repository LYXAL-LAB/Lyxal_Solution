-- Batch 19: 50 ressources Lyxal

CREATE resource:splunkv1_firedAlert SET
    identity = {
        name: "firedAlert",
        slug: "splunkv1_firedAlert",
        display_name_i18n: i18n_key:resource_splunkv1_firedAlert_name,
        description_i18n: i18n_key:resource_splunkv1_firedAlert_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 901,
        tooltip_i18n: i18n_key:resource_splunkv1_firedAlert_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:splunkv1,
    is_active: true;

CREATE resource:splunkv1_searchConfiguration SET
    identity = {
        name: "searchConfiguration",
        slug: "splunkv1_searchConfiguration",
        display_name_i18n: i18n_key:resource_splunkv1_searchConfiguration_name,
        description_i18n: i18n_key:resource_splunkv1_searchConfiguration_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 902,
        tooltip_i18n: i18n_key:resource_splunkv1_searchConfiguration_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:splunkv1,
    is_active: true;

CREATE resource:splunkv1_searchJob SET
    identity = {
        name: "searchJob",
        slug: "splunkv1_searchJob",
        display_name_i18n: i18n_key:resource_splunkv1_searchJob_name,
        description_i18n: i18n_key:resource_splunkv1_searchJob_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 903,
        tooltip_i18n: i18n_key:resource_splunkv1_searchJob_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:splunkv1,
    is_active: true;

CREATE resource:splunkv1_searchResult SET
    identity = {
        name: "searchResult",
        slug: "splunkv1_searchResult",
        display_name_i18n: i18n_key:resource_splunkv1_searchResult_name,
        description_i18n: i18n_key:resource_splunkv1_searchResult_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 904,
        tooltip_i18n: i18n_key:resource_splunkv1_searchResult_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:splunkv1,
    is_active: true;

CREATE resource:splunkv1_user SET
    identity = {
        name: "user",
        slug: "splunkv1_user",
        display_name_i18n: i18n_key:resource_splunkv1_user_name,
        description_i18n: i18n_key:resource_splunkv1_user_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 905,
        tooltip_i18n: i18n_key:resource_splunkv1_user_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:splunkv1,
    is_active: true;

CREATE resource:splunkv2_splunkv2 SET
    identity = {
        name: "splunkv2",
        slug: "splunkv2_splunkv2",
        display_name_i18n: i18n_key:resource_splunkv2_splunkv2_name,
        description_i18n: i18n_key:resource_splunkv2_splunkv2_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 906,
        tooltip_i18n: i18n_key:resource_splunkv2_splunkv2_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:splunkv2,
    is_active: true;

CREATE resource:spontit_push SET
    identity = {
        name: "push",
        slug: "spontit_push",
        display_name_i18n: i18n_key:resource_spontit_push_name,
        description_i18n: i18n_key:resource_spontit_push_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 907,
        tooltip_i18n: i18n_key:resource_spontit_push_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:spontit,
    is_active: true;

CREATE resource:spotify_album SET
    identity = {
        name: "album",
        slug: "spotify_album",
        display_name_i18n: i18n_key:resource_spotify_album_name,
        description_i18n: i18n_key:resource_spotify_album_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 908,
        tooltip_i18n: i18n_key:resource_spotify_album_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:spotify,
    is_active: true;

CREATE resource:spotify_artist SET
    identity = {
        name: "artist",
        slug: "spotify_artist",
        display_name_i18n: i18n_key:resource_spotify_artist_name,
        description_i18n: i18n_key:resource_spotify_artist_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 909,
        tooltip_i18n: i18n_key:resource_spotify_artist_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:spotify,
    is_active: true;

CREATE resource:spotify_library SET
    identity = {
        name: "library",
        slug: "spotify_library",
        display_name_i18n: i18n_key:resource_spotify_library_name,
        description_i18n: i18n_key:resource_spotify_library_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 910,
        tooltip_i18n: i18n_key:resource_spotify_library_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:spotify,
    is_active: true;

CREATE resource:spotify_myData SET
    identity = {
        name: "myData",
        slug: "spotify_myData",
        display_name_i18n: i18n_key:resource_spotify_myData_name,
        description_i18n: i18n_key:resource_spotify_myData_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 911,
        tooltip_i18n: i18n_key:resource_spotify_myData_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:spotify,
    is_active: true;

CREATE resource:spotify_player SET
    identity = {
        name: "player",
        slug: "spotify_player",
        display_name_i18n: i18n_key:resource_spotify_player_name,
        description_i18n: i18n_key:resource_spotify_player_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 912,
        tooltip_i18n: i18n_key:resource_spotify_player_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:spotify,
    is_active: true;

CREATE resource:spotify_playlist SET
    identity = {
        name: "playlist",
        slug: "spotify_playlist",
        display_name_i18n: i18n_key:resource_spotify_playlist_name,
        description_i18n: i18n_key:resource_spotify_playlist_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 913,
        tooltip_i18n: i18n_key:resource_spotify_playlist_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:spotify,
    is_active: true;

CREATE resource:spotify_track SET
    identity = {
        name: "track",
        slug: "spotify_track",
        display_name_i18n: i18n_key:resource_spotify_track_name,
        description_i18n: i18n_key:resource_spotify_track_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 914,
        tooltip_i18n: i18n_key:resource_spotify_track_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:spotify,
    is_active: true;

CREATE resource:spreadsheetfile_spreadsheetfile SET
    identity = {
        name: "spreadsheetfile",
        slug: "spreadsheetfile_spreadsheetfile",
        display_name_i18n: i18n_key:resource_spreadsheetfile_spreadsheetfile_name,
        description_i18n: i18n_key:resource_spreadsheetfile_spreadsheetfile_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 915,
        tooltip_i18n: i18n_key:resource_spreadsheetfile_spreadsheetfile_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:spreadsheetfile,
    is_active: true;

CREATE resource:spreadsheetfilev1_spreadsheetfilev1 SET
    identity = {
        name: "spreadsheetfilev1",
        slug: "spreadsheetfilev1_spreadsheetfilev1",
        display_name_i18n: i18n_key:resource_spreadsheetfilev1_spreadsheetfilev1_name,
        description_i18n: i18n_key:resource_spreadsheetfilev1_spreadsheetfilev1_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 916,
        tooltip_i18n: i18n_key:resource_spreadsheetfilev1_spreadsheetfilev1_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:spreadsheetfilev1,
    is_active: true;

CREATE resource:spreadsheetfilev2_spreadsheetfilev2 SET
    identity = {
        name: "spreadsheetfilev2",
        slug: "spreadsheetfilev2_spreadsheetfilev2",
        display_name_i18n: i18n_key:resource_spreadsheetfilev2_spreadsheetfilev2_name,
        description_i18n: i18n_key:resource_spreadsheetfilev2_spreadsheetfilev2_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 917,
        tooltip_i18n: i18n_key:resource_spreadsheetfilev2_spreadsheetfilev2_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:spreadsheetfilev2,
    is_active: true;

CREATE resource:ssh_command SET
    identity = {
        name: "command",
        slug: "ssh_command",
        display_name_i18n: i18n_key:resource_ssh_command_name,
        description_i18n: i18n_key:resource_ssh_command_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 918,
        tooltip_i18n: i18n_key:resource_ssh_command_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:ssh,
    is_active: true;

CREATE resource:ssh_file SET
    identity = {
        name: "file",
        slug: "ssh_file",
        display_name_i18n: i18n_key:resource_ssh_file_name,
        description_i18n: i18n_key:resource_ssh_file_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 919,
        tooltip_i18n: i18n_key:resource_ssh_file_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:ssh,
    is_active: true;

CREATE resource:stackby_stackby SET
    identity = {
        name: "stackby",
        slug: "stackby_stackby",
        display_name_i18n: i18n_key:resource_stackby_stackby_name,
        description_i18n: i18n_key:resource_stackby_stackby_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 920,
        tooltip_i18n: i18n_key:resource_stackby_stackby_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:stackby,
    is_active: true;

CREATE resource:start_start SET
    identity = {
        name: "start",
        slug: "start_start",
        display_name_i18n: i18n_key:resource_start_start_name,
        description_i18n: i18n_key:resource_start_start_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 921,
        tooltip_i18n: i18n_key:resource_start_start_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:start,
    is_active: true;

CREATE resource:stickynote_stickynote SET
    identity = {
        name: "stickynote",
        slug: "stickynote_stickynote",
        display_name_i18n: i18n_key:resource_stickynote_stickynote_name,
        description_i18n: i18n_key:resource_stickynote_stickynote_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 922,
        tooltip_i18n: i18n_key:resource_stickynote_stickynote_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:stickynote,
    is_active: true;

CREATE resource:stopanderror_stopanderror SET
    identity = {
        name: "stopanderror",
        slug: "stopanderror_stopanderror",
        display_name_i18n: i18n_key:resource_stopanderror_stopanderror_name,
        description_i18n: i18n_key:resource_stopanderror_stopanderror_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 923,
        tooltip_i18n: i18n_key:resource_stopanderror_stopanderror_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:stopanderror,
    is_active: true;

CREATE resource:storyblok_story SET
    identity = {
        name: "story",
        slug: "storyblok_story",
        display_name_i18n: i18n_key:resource_storyblok_story_name,
        description_i18n: i18n_key:resource_storyblok_story_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 924,
        tooltip_i18n: i18n_key:resource_storyblok_story_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:storyblok,
    is_active: true;

CREATE resource:storyblok_storycontent SET
    identity = {
        name: "storycontent",
        slug: "storyblok_storycontent",
        display_name_i18n: i18n_key:resource_storyblok_storycontent_name,
        description_i18n: i18n_key:resource_storyblok_storycontent_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 925,
        tooltip_i18n: i18n_key:resource_storyblok_storycontent_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:storyblok,
    is_active: true;

CREATE resource:storyblok_storymanagement SET
    identity = {
        name: "storymanagement",
        slug: "storyblok_storymanagement",
        display_name_i18n: i18n_key:resource_storyblok_storymanagement_name,
        description_i18n: i18n_key:resource_storyblok_storymanagement_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 926,
        tooltip_i18n: i18n_key:resource_storyblok_storymanagement_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:storyblok,
    is_active: true;

CREATE resource:strapi_entry SET
    identity = {
        name: "entry",
        slug: "strapi_entry",
        display_name_i18n: i18n_key:resource_strapi_entry_name,
        description_i18n: i18n_key:resource_strapi_entry_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 927,
        tooltip_i18n: i18n_key:resource_strapi_entry_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:strapi,
    is_active: true;

CREATE resource:strava_activity SET
    identity = {
        name: "activity",
        slug: "strava_activity",
        display_name_i18n: i18n_key:resource_strava_activity_name,
        description_i18n: i18n_key:resource_strava_activity_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 928,
        tooltip_i18n: i18n_key:resource_strava_activity_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:strava,
    is_active: true;

CREATE resource:stripe_balance SET
    identity = {
        name: "balance",
        slug: "stripe_balance",
        display_name_i18n: i18n_key:resource_stripe_balance_name,
        description_i18n: i18n_key:resource_stripe_balance_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 929,
        tooltip_i18n: i18n_key:resource_stripe_balance_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:stripe,
    is_active: true;

CREATE resource:stripe_charge SET
    identity = {
        name: "charge",
        slug: "stripe_charge",
        display_name_i18n: i18n_key:resource_stripe_charge_name,
        description_i18n: i18n_key:resource_stripe_charge_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 930,
        tooltip_i18n: i18n_key:resource_stripe_charge_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:stripe,
    is_active: true;

CREATE resource:stripe_coupon SET
    identity = {
        name: "coupon",
        slug: "stripe_coupon",
        display_name_i18n: i18n_key:resource_stripe_coupon_name,
        description_i18n: i18n_key:resource_stripe_coupon_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 931,
        tooltip_i18n: i18n_key:resource_stripe_coupon_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:stripe,
    is_active: true;

CREATE resource:stripe_customer SET
    identity = {
        name: "customer",
        slug: "stripe_customer",
        display_name_i18n: i18n_key:resource_stripe_customer_name,
        description_i18n: i18n_key:resource_stripe_customer_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 932,
        tooltip_i18n: i18n_key:resource_stripe_customer_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:stripe,
    is_active: true;

CREATE resource:stripe_customerCard SET
    identity = {
        name: "customerCard",
        slug: "stripe_customerCard",
        display_name_i18n: i18n_key:resource_stripe_customerCard_name,
        description_i18n: i18n_key:resource_stripe_customerCard_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 933,
        tooltip_i18n: i18n_key:resource_stripe_customerCard_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:stripe,
    is_active: true;

CREATE resource:stripe_source SET
    identity = {
        name: "source",
        slug: "stripe_source",
        display_name_i18n: i18n_key:resource_stripe_source_name,
        description_i18n: i18n_key:resource_stripe_source_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 934,
        tooltip_i18n: i18n_key:resource_stripe_source_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:stripe,
    is_active: true;

CREATE resource:stripe_token SET
    identity = {
        name: "token",
        slug: "stripe_token",
        display_name_i18n: i18n_key:resource_stripe_token_name,
        description_i18n: i18n_key:resource_stripe_token_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 935,
        tooltip_i18n: i18n_key:resource_stripe_token_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:stripe,
    is_active: true;

CREATE resource:supabase_row SET
    identity = {
        name: "row",
        slug: "supabase_row",
        display_name_i18n: i18n_key:resource_supabase_row_name,
        description_i18n: i18n_key:resource_supabase_row_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 936,
        tooltip_i18n: i18n_key:resource_supabase_row_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:supabase,
    is_active: true;

CREATE resource:switch_switch SET
    identity = {
        name: "switch",
        slug: "switch_switch",
        display_name_i18n: i18n_key:resource_switch_switch_name,
        description_i18n: i18n_key:resource_switch_switch_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 937,
        tooltip_i18n: i18n_key:resource_switch_switch_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:switch,
    is_active: true;

CREATE resource:switchv1_switchv1 SET
    identity = {
        name: "switchv1",
        slug: "switchv1_switchv1",
        display_name_i18n: i18n_key:resource_switchv1_switchv1_name,
        description_i18n: i18n_key:resource_switchv1_switchv1_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 938,
        tooltip_i18n: i18n_key:resource_switchv1_switchv1_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:switchv1,
    is_active: true;

CREATE resource:switchv2_switchv2 SET
    identity = {
        name: "switchv2",
        slug: "switchv2_switchv2",
        display_name_i18n: i18n_key:resource_switchv2_switchv2_name,
        description_i18n: i18n_key:resource_switchv2_switchv2_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 939,
        tooltip_i18n: i18n_key:resource_switchv2_switchv2_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:switchv2,
    is_active: true;

CREATE resource:switchv3_switchv3 SET
    identity = {
        name: "switchv3",
        slug: "switchv3_switchv3",
        display_name_i18n: i18n_key:resource_switchv3_switchv3_name,
        description_i18n: i18n_key:resource_switchv3_switchv3_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 940,
        tooltip_i18n: i18n_key:resource_switchv3_switchv3_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:switchv3,
    is_active: true;

CREATE resource:syncromsp_syncromsp SET
    identity = {
        name: "syncromsp",
        slug: "syncromsp_syncromsp",
        display_name_i18n: i18n_key:resource_syncromsp_syncromsp_name,
        description_i18n: i18n_key:resource_syncromsp_syncromsp_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 941,
        tooltip_i18n: i18n_key:resource_syncromsp_syncromsp_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:syncromsp,
    is_active: true;

CREATE resource:syncromspv1_syncromspv1 SET
    identity = {
        name: "syncromspv1",
        slug: "syncromspv1_syncromspv1",
        display_name_i18n: i18n_key:resource_syncromspv1_syncromspv1_name,
        description_i18n: i18n_key:resource_syncromspv1_syncromspv1_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 942,
        tooltip_i18n: i18n_key:resource_syncromspv1_syncromspv1_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:syncromspv1,
    is_active: true;

CREATE resource:taiga_epic SET
    identity = {
        name: "epic",
        slug: "taiga_epic",
        display_name_i18n: i18n_key:resource_taiga_epic_name,
        description_i18n: i18n_key:resource_taiga_epic_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 943,
        tooltip_i18n: i18n_key:resource_taiga_epic_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:taiga,
    is_active: true;

CREATE resource:taiga_issue SET
    identity = {
        name: "issue",
        slug: "taiga_issue",
        display_name_i18n: i18n_key:resource_taiga_issue_name,
        description_i18n: i18n_key:resource_taiga_issue_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 944,
        tooltip_i18n: i18n_key:resource_taiga_issue_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:taiga,
    is_active: true;

CREATE resource:taiga_task SET
    identity = {
        name: "task",
        slug: "taiga_task",
        display_name_i18n: i18n_key:resource_taiga_task_name,
        description_i18n: i18n_key:resource_taiga_task_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 945,
        tooltip_i18n: i18n_key:resource_taiga_task_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:taiga,
    is_active: true;

CREATE resource:taiga_userStory SET
    identity = {
        name: "userStory",
        slug: "taiga_userStory",
        display_name_i18n: i18n_key:resource_taiga_userStory_name,
        description_i18n: i18n_key:resource_taiga_userStory_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 946,
        tooltip_i18n: i18n_key:resource_taiga_userStory_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:taiga,
    is_active: true;

CREATE resource:tapfiliate_affiliate SET
    identity = {
        name: "affiliate",
        slug: "tapfiliate_affiliate",
        display_name_i18n: i18n_key:resource_tapfiliate_affiliate_name,
        description_i18n: i18n_key:resource_tapfiliate_affiliate_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 947,
        tooltip_i18n: i18n_key:resource_tapfiliate_affiliate_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:tapfiliate,
    is_active: true;

CREATE resource:tapfiliate_affiliateMetadata SET
    identity = {
        name: "affiliateMetadata",
        slug: "tapfiliate_affiliateMetadata",
        display_name_i18n: i18n_key:resource_tapfiliate_affiliateMetadata_name,
        description_i18n: i18n_key:resource_tapfiliate_affiliateMetadata_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 948,
        tooltip_i18n: i18n_key:resource_tapfiliate_affiliateMetadata_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:tapfiliate,
    is_active: true;

CREATE resource:tapfiliate_programAffiliate SET
    identity = {
        name: "programAffiliate",
        slug: "tapfiliate_programAffiliate",
        display_name_i18n: i18n_key:resource_tapfiliate_programAffiliate_name,
        description_i18n: i18n_key:resource_tapfiliate_programAffiliate_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 949,
        tooltip_i18n: i18n_key:resource_tapfiliate_programAffiliate_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:tapfiliate,
    is_active: true;

CREATE resource:tapfiliate_affiliatemetadata SET
    identity = {
        name: "affiliatemetadata",
        slug: "tapfiliate_affiliatemetadata",
        display_name_i18n: i18n_key:resource_tapfiliate_affiliatemetadata_name,
        description_i18n: i18n_key:resource_tapfiliate_affiliatemetadata_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 950,
        tooltip_i18n: i18n_key:resource_tapfiliate_affiliatemetadata_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:tapfiliate,
    is_active: true;

