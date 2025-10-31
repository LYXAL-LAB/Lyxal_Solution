-- Batch 7: 50 ressources Lyxal

CREATE resource:gitlab_repository SET
    identity = {
        name: "repository",
        slug: "gitlab_repository",
        display_name_i18n: i18n_key:resource_gitlab_repository_name,
        description_i18n: i18n_key:resource_gitlab_repository_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 301,
        tooltip_i18n: i18n_key:resource_gitlab_repository_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:gitlab,
    is_active: true;

CREATE resource:gitlab_user SET
    identity = {
        name: "user",
        slug: "gitlab_user",
        display_name_i18n: i18n_key:resource_gitlab_user_name,
        description_i18n: i18n_key:resource_gitlab_user_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 302,
        tooltip_i18n: i18n_key:resource_gitlab_user_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:gitlab,
    is_active: true;

CREATE resource:gong_call SET
    identity = {
        name: "call",
        slug: "gong_call",
        display_name_i18n: i18n_key:resource_gong_call_name,
        description_i18n: i18n_key:resource_gong_call_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 303,
        tooltip_i18n: i18n_key:resource_gong_call_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:gong,
    is_active: true;

CREATE resource:gong_user SET
    identity = {
        name: "user",
        slug: "gong_user",
        display_name_i18n: i18n_key:resource_gong_user_name,
        description_i18n: i18n_key:resource_gong_user_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 304,
        tooltip_i18n: i18n_key:resource_gong_user_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:gong,
    is_active: true;

CREATE resource:googleads_campaign SET
    identity = {
        name: "campaign",
        slug: "googleads_campaign",
        display_name_i18n: i18n_key:resource_googleads_campaign_name,
        description_i18n: i18n_key:resource_googleads_campaign_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 305,
        tooltip_i18n: i18n_key:resource_googleads_campaign_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:googleads,
    is_active: true;

CREATE resource:googleanalytics_googleanalytics SET
    identity = {
        name: "googleanalytics",
        slug: "googleanalytics_googleanalytics",
        display_name_i18n: i18n_key:resource_googleanalytics_googleanalytics_name,
        description_i18n: i18n_key:resource_googleanalytics_googleanalytics_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 306,
        tooltip_i18n: i18n_key:resource_googleanalytics_googleanalytics_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:googleanalytics,
    is_active: true;

CREATE resource:googleanalyticsv1_report SET
    identity = {
        name: "report",
        slug: "googleanalyticsv1_report",
        display_name_i18n: i18n_key:resource_googleanalyticsv1_report_name,
        description_i18n: i18n_key:resource_googleanalyticsv1_report_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 307,
        tooltip_i18n: i18n_key:resource_googleanalyticsv1_report_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:googleanalyticsv1,
    is_active: true;

CREATE resource:googleanalyticsv1_userActivity SET
    identity = {
        name: "userActivity",
        slug: "googleanalyticsv1_userActivity",
        display_name_i18n: i18n_key:resource_googleanalyticsv1_userActivity_name,
        description_i18n: i18n_key:resource_googleanalyticsv1_userActivity_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 308,
        tooltip_i18n: i18n_key:resource_googleanalyticsv1_userActivity_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:googleanalyticsv1,
    is_active: true;

CREATE resource:googleanalyticsv1_useractivity SET
    identity = {
        name: "useractivity",
        slug: "googleanalyticsv1_useractivity",
        display_name_i18n: i18n_key:resource_googleanalyticsv1_useractivity_name,
        description_i18n: i18n_key:resource_googleanalyticsv1_useractivity_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 309,
        tooltip_i18n: i18n_key:resource_googleanalyticsv1_useractivity_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:googleanalyticsv1,
    is_active: true;

CREATE resource:googleanalyticsv2_googleanalyticsv2 SET
    identity = {
        name: "googleanalyticsv2",
        slug: "googleanalyticsv2_googleanalyticsv2",
        display_name_i18n: i18n_key:resource_googleanalyticsv2_googleanalyticsv2_name,
        description_i18n: i18n_key:resource_googleanalyticsv2_googleanalyticsv2_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 310,
        tooltip_i18n: i18n_key:resource_googleanalyticsv2_googleanalyticsv2_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:googleanalyticsv2,
    is_active: true;

CREATE resource:googlebigquery_googlebigquery SET
    identity = {
        name: "googlebigquery",
        slug: "googlebigquery_googlebigquery",
        display_name_i18n: i18n_key:resource_googlebigquery_googlebigquery_name,
        description_i18n: i18n_key:resource_googlebigquery_googlebigquery_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 311,
        tooltip_i18n: i18n_key:resource_googlebigquery_googlebigquery_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:googlebigquery,
    is_active: true;

CREATE resource:googlebigqueryv1_record SET
    identity = {
        name: "record",
        slug: "googlebigqueryv1_record",
        display_name_i18n: i18n_key:resource_googlebigqueryv1_record_name,
        description_i18n: i18n_key:resource_googlebigqueryv1_record_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 312,
        tooltip_i18n: i18n_key:resource_googlebigqueryv1_record_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:googlebigqueryv1,
    is_active: true;

CREATE resource:googlebigqueryv2_googlebigqueryv2 SET
    identity = {
        name: "googlebigqueryv2",
        slug: "googlebigqueryv2_googlebigqueryv2",
        display_name_i18n: i18n_key:resource_googlebigqueryv2_googlebigqueryv2_name,
        description_i18n: i18n_key:resource_googlebigqueryv2_googlebigqueryv2_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 313,
        tooltip_i18n: i18n_key:resource_googlebigqueryv2_googlebigqueryv2_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:googlebigqueryv2,
    is_active: true;

CREATE resource:googlebooks_bookshelf SET
    identity = {
        name: "bookshelf",
        slug: "googlebooks_bookshelf",
        display_name_i18n: i18n_key:resource_googlebooks_bookshelf_name,
        description_i18n: i18n_key:resource_googlebooks_bookshelf_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 314,
        tooltip_i18n: i18n_key:resource_googlebooks_bookshelf_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:googlebooks,
    is_active: true;

CREATE resource:googlebooks_bookshelfVolume SET
    identity = {
        name: "bookshelfVolume",
        slug: "googlebooks_bookshelfVolume",
        display_name_i18n: i18n_key:resource_googlebooks_bookshelfVolume_name,
        description_i18n: i18n_key:resource_googlebooks_bookshelfVolume_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 315,
        tooltip_i18n: i18n_key:resource_googlebooks_bookshelfVolume_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:googlebooks,
    is_active: true;

CREATE resource:googlebooks_volume SET
    identity = {
        name: "volume",
        slug: "googlebooks_volume",
        display_name_i18n: i18n_key:resource_googlebooks_volume_name,
        description_i18n: i18n_key:resource_googlebooks_volume_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 316,
        tooltip_i18n: i18n_key:resource_googlebooks_volume_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:googlebooks,
    is_active: true;

CREATE resource:googlebusinessprofile_post SET
    identity = {
        name: "post",
        slug: "googlebusinessprofile_post",
        display_name_i18n: i18n_key:resource_googlebusinessprofile_post_name,
        description_i18n: i18n_key:resource_googlebusinessprofile_post_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 317,
        tooltip_i18n: i18n_key:resource_googlebusinessprofile_post_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:googlebusinessprofile,
    is_active: true;

CREATE resource:googlebusinessprofile_review SET
    identity = {
        name: "review",
        slug: "googlebusinessprofile_review",
        display_name_i18n: i18n_key:resource_googlebusinessprofile_review_name,
        description_i18n: i18n_key:resource_googlebusinessprofile_review_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 318,
        tooltip_i18n: i18n_key:resource_googlebusinessprofile_review_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:googlebusinessprofile,
    is_active: true;

CREATE resource:googlecalendar_calendar SET
    identity = {
        name: "calendar",
        slug: "googlecalendar_calendar",
        display_name_i18n: i18n_key:resource_googlecalendar_calendar_name,
        description_i18n: i18n_key:resource_googlecalendar_calendar_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 319,
        tooltip_i18n: i18n_key:resource_googlecalendar_calendar_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:googlecalendar,
    is_active: true;

CREATE resource:googlecalendar_event SET
    identity = {
        name: "event",
        slug: "googlecalendar_event",
        display_name_i18n: i18n_key:resource_googlecalendar_event_name,
        description_i18n: i18n_key:resource_googlecalendar_event_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 320,
        tooltip_i18n: i18n_key:resource_googlecalendar_event_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:googlecalendar,
    is_active: true;

CREATE resource:googlechat_member SET
    identity = {
        name: "member",
        slug: "googlechat_member",
        display_name_i18n: i18n_key:resource_googlechat_member_name,
        description_i18n: i18n_key:resource_googlechat_member_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 321,
        tooltip_i18n: i18n_key:resource_googlechat_member_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:googlechat,
    is_active: true;

CREATE resource:googlechat_message SET
    identity = {
        name: "message",
        slug: "googlechat_message",
        display_name_i18n: i18n_key:resource_googlechat_message_name,
        description_i18n: i18n_key:resource_googlechat_message_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 322,
        tooltip_i18n: i18n_key:resource_googlechat_message_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:googlechat,
    is_active: true;

CREATE resource:googlechat_space SET
    identity = {
        name: "space",
        slug: "googlechat_space",
        display_name_i18n: i18n_key:resource_googlechat_space_name,
        description_i18n: i18n_key:resource_googlechat_space_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 323,
        tooltip_i18n: i18n_key:resource_googlechat_space_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:googlechat,
    is_active: true;

CREATE resource:googlecloudnaturallanguage_document SET
    identity = {
        name: "document",
        slug: "googlecloudnaturallanguage_document",
        display_name_i18n: i18n_key:resource_googlecloudnaturallanguage_document_name,
        description_i18n: i18n_key:resource_googlecloudnaturallanguage_document_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 324,
        tooltip_i18n: i18n_key:resource_googlecloudnaturallanguage_document_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:googlecloudnaturallanguage,
    is_active: true;

CREATE resource:googlecloudstorage_bucket SET
    identity = {
        name: "bucket",
        slug: "googlecloudstorage_bucket",
        display_name_i18n: i18n_key:resource_googlecloudstorage_bucket_name,
        description_i18n: i18n_key:resource_googlecloudstorage_bucket_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 325,
        tooltip_i18n: i18n_key:resource_googlecloudstorage_bucket_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:googlecloudstorage,
    is_active: true;

CREATE resource:googlecloudstorage_object SET
    identity = {
        name: "object",
        slug: "googlecloudstorage_object",
        display_name_i18n: i18n_key:resource_googlecloudstorage_object_name,
        description_i18n: i18n_key:resource_googlecloudstorage_object_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 326,
        tooltip_i18n: i18n_key:resource_googlecloudstorage_object_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:googlecloudstorage,
    is_active: true;

CREATE resource:googlecontacts_contact SET
    identity = {
        name: "contact",
        slug: "googlecontacts_contact",
        display_name_i18n: i18n_key:resource_googlecontacts_contact_name,
        description_i18n: i18n_key:resource_googlecontacts_contact_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 327,
        tooltip_i18n: i18n_key:resource_googlecontacts_contact_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:googlecontacts,
    is_active: true;

CREATE resource:googledocs_document SET
    identity = {
        name: "document",
        slug: "googledocs_document",
        display_name_i18n: i18n_key:resource_googledocs_document_name,
        description_i18n: i18n_key:resource_googledocs_document_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 328,
        tooltip_i18n: i18n_key:resource_googledocs_document_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:googledocs,
    is_active: true;

CREATE resource:googledrive_googledrive SET
    identity = {
        name: "googledrive",
        slug: "googledrive_googledrive",
        display_name_i18n: i18n_key:resource_googledrive_googledrive_name,
        description_i18n: i18n_key:resource_googledrive_googledrive_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 329,
        tooltip_i18n: i18n_key:resource_googledrive_googledrive_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:googledrive,
    is_active: true;

CREATE resource:googledrivev1_drive SET
    identity = {
        name: "drive",
        slug: "googledrivev1_drive",
        display_name_i18n: i18n_key:resource_googledrivev1_drive_name,
        description_i18n: i18n_key:resource_googledrivev1_drive_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 330,
        tooltip_i18n: i18n_key:resource_googledrivev1_drive_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:googledrivev1,
    is_active: true;

CREATE resource:googledrivev1_file SET
    identity = {
        name: "file",
        slug: "googledrivev1_file",
        display_name_i18n: i18n_key:resource_googledrivev1_file_name,
        description_i18n: i18n_key:resource_googledrivev1_file_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 331,
        tooltip_i18n: i18n_key:resource_googledrivev1_file_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:googledrivev1,
    is_active: true;

CREATE resource:googledrivev1_folder SET
    identity = {
        name: "folder",
        slug: "googledrivev1_folder",
        display_name_i18n: i18n_key:resource_googledrivev1_folder_name,
        description_i18n: i18n_key:resource_googledrivev1_folder_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 332,
        tooltip_i18n: i18n_key:resource_googledrivev1_folder_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:googledrivev1,
    is_active: true;

CREATE resource:googledrivev2_googledrivev2 SET
    identity = {
        name: "googledrivev2",
        slug: "googledrivev2_googledrivev2",
        display_name_i18n: i18n_key:resource_googledrivev2_googledrivev2_name,
        description_i18n: i18n_key:resource_googledrivev2_googledrivev2_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 333,
        tooltip_i18n: i18n_key:resource_googledrivev2_googledrivev2_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:googledrivev2,
    is_active: true;

CREATE resource:googlefirebasecloudfirestore_document SET
    identity = {
        name: "document",
        slug: "googlefirebasecloudfirestore_document",
        display_name_i18n: i18n_key:resource_googlefirebasecloudfirestore_document_name,
        description_i18n: i18n_key:resource_googlefirebasecloudfirestore_document_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 334,
        tooltip_i18n: i18n_key:resource_googlefirebasecloudfirestore_document_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:googlefirebasecloudfirestore,
    is_active: true;

CREATE resource:googlefirebasecloudfirestore_collection SET
    identity = {
        name: "collection",
        slug: "googlefirebasecloudfirestore_collection",
        display_name_i18n: i18n_key:resource_googlefirebasecloudfirestore_collection_name,
        description_i18n: i18n_key:resource_googlefirebasecloudfirestore_collection_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 335,
        tooltip_i18n: i18n_key:resource_googlefirebasecloudfirestore_collection_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:googlefirebasecloudfirestore,
    is_active: true;

CREATE resource:googlefirebaserealtimedatabase_googlefirebaserealtimedatabase SET
    identity = {
        name: "googlefirebaserealtimedatabase",
        slug: "googlefirebaserealtimedatabase_googlefirebaserealtimedatabase",
        display_name_i18n: i18n_key:resource_googlefirebaserealtimedatabase_googlefirebaserealtimedatabase_name,
        description_i18n: i18n_key:resource_googlefirebaserealtimedatabase_googlefirebaserealtimedatabase_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 336,
        tooltip_i18n: i18n_key:resource_googlefirebaserealtimedatabase_googlefirebaserealtimedatabase_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:googlefirebaserealtimedatabase,
    is_active: true;

CREATE resource:gmail_gmail SET
    identity = {
        name: "gmail",
        slug: "gmail_gmail",
        display_name_i18n: i18n_key:resource_gmail_gmail_name,
        description_i18n: i18n_key:resource_gmail_gmail_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 337,
        tooltip_i18n: i18n_key:resource_gmail_gmail_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:gmail,
    is_active: true;

CREATE resource:gmailv1_draft SET
    identity = {
        name: "draft",
        slug: "gmailv1_draft",
        display_name_i18n: i18n_key:resource_gmailv1_draft_name,
        description_i18n: i18n_key:resource_gmailv1_draft_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 338,
        tooltip_i18n: i18n_key:resource_gmailv1_draft_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:gmailv1,
    is_active: true;

CREATE resource:gmailv1_label SET
    identity = {
        name: "label",
        slug: "gmailv1_label",
        display_name_i18n: i18n_key:resource_gmailv1_label_name,
        description_i18n: i18n_key:resource_gmailv1_label_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 339,
        tooltip_i18n: i18n_key:resource_gmailv1_label_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:gmailv1,
    is_active: true;

CREATE resource:gmailv1_message SET
    identity = {
        name: "message",
        slug: "gmailv1_message",
        display_name_i18n: i18n_key:resource_gmailv1_message_name,
        description_i18n: i18n_key:resource_gmailv1_message_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 340,
        tooltip_i18n: i18n_key:resource_gmailv1_message_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:gmailv1,
    is_active: true;

CREATE resource:gmailv1_messageLabel SET
    identity = {
        name: "messageLabel",
        slug: "gmailv1_messageLabel",
        display_name_i18n: i18n_key:resource_gmailv1_messageLabel_name,
        description_i18n: i18n_key:resource_gmailv1_messageLabel_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 341,
        tooltip_i18n: i18n_key:resource_gmailv1_messageLabel_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:gmailv1,
    is_active: true;

CREATE resource:gmailv1_messagelabel SET
    identity = {
        name: "messagelabel",
        slug: "gmailv1_messagelabel",
        display_name_i18n: i18n_key:resource_gmailv1_messagelabel_name,
        description_i18n: i18n_key:resource_gmailv1_messagelabel_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 342,
        tooltip_i18n: i18n_key:resource_gmailv1_messagelabel_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:gmailv1,
    is_active: true;

CREATE resource:gmailv2_message SET
    identity = {
        name: "message",
        slug: "gmailv2_message",
        display_name_i18n: i18n_key:resource_gmailv2_message_name,
        description_i18n: i18n_key:resource_gmailv2_message_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 343,
        tooltip_i18n: i18n_key:resource_gmailv2_message_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:gmailv2,
    is_active: true;

CREATE resource:gmailv2_label SET
    identity = {
        name: "label",
        slug: "gmailv2_label",
        display_name_i18n: i18n_key:resource_gmailv2_label_name,
        description_i18n: i18n_key:resource_gmailv2_label_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 344,
        tooltip_i18n: i18n_key:resource_gmailv2_label_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:gmailv2,
    is_active: true;

CREATE resource:gmailv2_draft SET
    identity = {
        name: "draft",
        slug: "gmailv2_draft",
        display_name_i18n: i18n_key:resource_gmailv2_draft_name,
        description_i18n: i18n_key:resource_gmailv2_draft_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 345,
        tooltip_i18n: i18n_key:resource_gmailv2_draft_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:gmailv2,
    is_active: true;

CREATE resource:gmailv2_thread SET
    identity = {
        name: "thread",
        slug: "gmailv2_thread",
        display_name_i18n: i18n_key:resource_gmailv2_thread_name,
        description_i18n: i18n_key:resource_gmailv2_thread_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 346,
        tooltip_i18n: i18n_key:resource_gmailv2_thread_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:gmailv2,
    is_active: true;

CREATE resource:gsuiteadmin_device SET
    identity = {
        name: "device",
        slug: "gsuiteadmin_device",
        display_name_i18n: i18n_key:resource_gsuiteadmin_device_name,
        description_i18n: i18n_key:resource_gsuiteadmin_device_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 347,
        tooltip_i18n: i18n_key:resource_gsuiteadmin_device_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:gsuiteadmin,
    is_active: true;

CREATE resource:gsuiteadmin_group SET
    identity = {
        name: "group",
        slug: "gsuiteadmin_group",
        display_name_i18n: i18n_key:resource_gsuiteadmin_group_name,
        description_i18n: i18n_key:resource_gsuiteadmin_group_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 348,
        tooltip_i18n: i18n_key:resource_gsuiteadmin_group_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:gsuiteadmin,
    is_active: true;

CREATE resource:gsuiteadmin_user SET
    identity = {
        name: "user",
        slug: "gsuiteadmin_user",
        display_name_i18n: i18n_key:resource_gsuiteadmin_user_name,
        description_i18n: i18n_key:resource_gsuiteadmin_user_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 349,
        tooltip_i18n: i18n_key:resource_gsuiteadmin_user_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:gsuiteadmin,
    is_active: true;

CREATE resource:gsuiteadmin_device SET
    identity = {
        name: "device",
        slug: "gsuiteadmin_device",
        display_name_i18n: i18n_key:resource_gsuiteadmin_device_name,
        description_i18n: i18n_key:resource_gsuiteadmin_device_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 350,
        tooltip_i18n: i18n_key:resource_gsuiteadmin_device_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:gsuiteadmin,
    is_active: true;

