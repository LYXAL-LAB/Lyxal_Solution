-- Batch 21: 100 tools Lyxal

CREATE tool:spotify_myData_previousSong SET
    identity = {
        name: "previousSong",
        slug: "spotify_myData_previousSong",
        display_name_i18n: i18n_key:tool_spotify_myData_previousSong_name,
        description_i18n: i18n_key:tool_spotify_myData_previousSong_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 2001,
        tooltip_i18n: i18n_key:tool_spotify_myData_previousSong_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_spotify_myData_previousSong_success,
        error_message_i18n: i18n_key:tool_spotify_myData_previousSong_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "POST",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:spotify_myData,
    is_active: true;

CREATE tool:spotify_myData_recentlyPlayed SET
    identity = {
        name: "recentlyPlayed",
        slug: "spotify_myData_recentlyPlayed",
        display_name_i18n: i18n_key:tool_spotify_myData_recentlyPlayed_name,
        description_i18n: i18n_key:tool_spotify_myData_recentlyPlayed_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 2002,
        tooltip_i18n: i18n_key:tool_spotify_myData_recentlyPlayed_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_spotify_myData_recentlyPlayed_success,
        error_message_i18n: i18n_key:tool_spotify_myData_recentlyPlayed_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "POST",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:spotify_myData,
    is_active: true;

CREATE tool:spotify_myData_resume SET
    identity = {
        name: "resume",
        slug: "spotify_myData_resume",
        display_name_i18n: i18n_key:tool_spotify_myData_resume_name,
        description_i18n: i18n_key:tool_spotify_myData_resume_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 2003,
        tooltip_i18n: i18n_key:tool_spotify_myData_resume_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_spotify_myData_resume_success,
        error_message_i18n: i18n_key:tool_spotify_myData_resume_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "POST",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:spotify_myData,
    is_active: true;

CREATE tool:spotify_myData_volume SET
    identity = {
        name: "volume",
        slug: "spotify_myData_volume",
        display_name_i18n: i18n_key:tool_spotify_myData_volume_name,
        description_i18n: i18n_key:tool_spotify_myData_volume_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 2004,
        tooltip_i18n: i18n_key:tool_spotify_myData_volume_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_spotify_myData_volume_success,
        error_message_i18n: i18n_key:tool_spotify_myData_volume_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "POST",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:spotify_myData,
    is_active: true;

CREATE tool:spotify_myData_startMusic SET
    identity = {
        name: "startMusic",
        slug: "spotify_myData_startMusic",
        display_name_i18n: i18n_key:tool_spotify_myData_startMusic_name,
        description_i18n: i18n_key:tool_spotify_myData_startMusic_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 2005,
        tooltip_i18n: i18n_key:tool_spotify_myData_startMusic_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_spotify_myData_startMusic_success,
        error_message_i18n: i18n_key:tool_spotify_myData_startMusic_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "POST",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:spotify_myData,
    is_active: true;

CREATE tool:spotify_player_addSongToQueue SET
    identity = {
        name: "addSongToQueue",
        slug: "spotify_player_addSongToQueue",
        display_name_i18n: i18n_key:tool_spotify_player_addSongToQueue_name,
        description_i18n: i18n_key:tool_spotify_player_addSongToQueue_desc,
        operation_type: "create",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#4CAF50",
        display_order: 2006,
        tooltip_i18n: i18n_key:tool_spotify_player_addSongToQueue_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_spotify_player_addSongToQueue_success,
        error_message_i18n: i18n_key:tool_spotify_player_addSongToQueue_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "POST",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:spotify_player,
    is_active: true;

CREATE tool:spotify_player_currentlyPlaying SET
    identity = {
        name: "currentlyPlaying",
        slug: "spotify_player_currentlyPlaying",
        display_name_i18n: i18n_key:tool_spotify_player_currentlyPlaying_name,
        description_i18n: i18n_key:tool_spotify_player_currentlyPlaying_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 2007,
        tooltip_i18n: i18n_key:tool_spotify_player_currentlyPlaying_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_spotify_player_currentlyPlaying_success,
        error_message_i18n: i18n_key:tool_spotify_player_currentlyPlaying_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "POST",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:spotify_player,
    is_active: true;

CREATE tool:spotify_player_nextSong SET
    identity = {
        name: "nextSong",
        slug: "spotify_player_nextSong",
        display_name_i18n: i18n_key:tool_spotify_player_nextSong_name,
        description_i18n: i18n_key:tool_spotify_player_nextSong_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 2008,
        tooltip_i18n: i18n_key:tool_spotify_player_nextSong_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_spotify_player_nextSong_success,
        error_message_i18n: i18n_key:tool_spotify_player_nextSong_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "POST",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:spotify_player,
    is_active: true;

CREATE tool:spotify_player_pause SET
    identity = {
        name: "pause",
        slug: "spotify_player_pause",
        display_name_i18n: i18n_key:tool_spotify_player_pause_name,
        description_i18n: i18n_key:tool_spotify_player_pause_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 2009,
        tooltip_i18n: i18n_key:tool_spotify_player_pause_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_spotify_player_pause_success,
        error_message_i18n: i18n_key:tool_spotify_player_pause_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "POST",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:spotify_player,
    is_active: true;

CREATE tool:spotify_player_previousSong SET
    identity = {
        name: "previousSong",
        slug: "spotify_player_previousSong",
        display_name_i18n: i18n_key:tool_spotify_player_previousSong_name,
        description_i18n: i18n_key:tool_spotify_player_previousSong_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 2010,
        tooltip_i18n: i18n_key:tool_spotify_player_previousSong_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_spotify_player_previousSong_success,
        error_message_i18n: i18n_key:tool_spotify_player_previousSong_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "POST",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:spotify_player,
    is_active: true;

CREATE tool:spotify_player_recentlyPlayed SET
    identity = {
        name: "recentlyPlayed",
        slug: "spotify_player_recentlyPlayed",
        display_name_i18n: i18n_key:tool_spotify_player_recentlyPlayed_name,
        description_i18n: i18n_key:tool_spotify_player_recentlyPlayed_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 2011,
        tooltip_i18n: i18n_key:tool_spotify_player_recentlyPlayed_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_spotify_player_recentlyPlayed_success,
        error_message_i18n: i18n_key:tool_spotify_player_recentlyPlayed_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "POST",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:spotify_player,
    is_active: true;

CREATE tool:spotify_player_resume SET
    identity = {
        name: "resume",
        slug: "spotify_player_resume",
        display_name_i18n: i18n_key:tool_spotify_player_resume_name,
        description_i18n: i18n_key:tool_spotify_player_resume_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 2012,
        tooltip_i18n: i18n_key:tool_spotify_player_resume_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_spotify_player_resume_success,
        error_message_i18n: i18n_key:tool_spotify_player_resume_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "POST",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:spotify_player,
    is_active: true;

CREATE tool:spotify_player_volume SET
    identity = {
        name: "volume",
        slug: "spotify_player_volume",
        display_name_i18n: i18n_key:tool_spotify_player_volume_name,
        description_i18n: i18n_key:tool_spotify_player_volume_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 2013,
        tooltip_i18n: i18n_key:tool_spotify_player_volume_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_spotify_player_volume_success,
        error_message_i18n: i18n_key:tool_spotify_player_volume_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "POST",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:spotify_player,
    is_active: true;

CREATE tool:spotify_player_startMusic SET
    identity = {
        name: "startMusic",
        slug: "spotify_player_startMusic",
        display_name_i18n: i18n_key:tool_spotify_player_startMusic_name,
        description_i18n: i18n_key:tool_spotify_player_startMusic_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 2014,
        tooltip_i18n: i18n_key:tool_spotify_player_startMusic_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_spotify_player_startMusic_success,
        error_message_i18n: i18n_key:tool_spotify_player_startMusic_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "POST",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:spotify_player,
    is_active: true;

CREATE tool:spotify_playlist_addSongToQueue SET
    identity = {
        name: "addSongToQueue",
        slug: "spotify_playlist_addSongToQueue",
        display_name_i18n: i18n_key:tool_spotify_playlist_addSongToQueue_name,
        description_i18n: i18n_key:tool_spotify_playlist_addSongToQueue_desc,
        operation_type: "create",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#4CAF50",
        display_order: 2015,
        tooltip_i18n: i18n_key:tool_spotify_playlist_addSongToQueue_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_spotify_playlist_addSongToQueue_success,
        error_message_i18n: i18n_key:tool_spotify_playlist_addSongToQueue_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "POST",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:spotify_playlist,
    is_active: true;

CREATE tool:spotify_playlist_currentlyPlaying SET
    identity = {
        name: "currentlyPlaying",
        slug: "spotify_playlist_currentlyPlaying",
        display_name_i18n: i18n_key:tool_spotify_playlist_currentlyPlaying_name,
        description_i18n: i18n_key:tool_spotify_playlist_currentlyPlaying_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 2016,
        tooltip_i18n: i18n_key:tool_spotify_playlist_currentlyPlaying_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_spotify_playlist_currentlyPlaying_success,
        error_message_i18n: i18n_key:tool_spotify_playlist_currentlyPlaying_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "POST",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:spotify_playlist,
    is_active: true;

CREATE tool:spotify_playlist_nextSong SET
    identity = {
        name: "nextSong",
        slug: "spotify_playlist_nextSong",
        display_name_i18n: i18n_key:tool_spotify_playlist_nextSong_name,
        description_i18n: i18n_key:tool_spotify_playlist_nextSong_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 2017,
        tooltip_i18n: i18n_key:tool_spotify_playlist_nextSong_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_spotify_playlist_nextSong_success,
        error_message_i18n: i18n_key:tool_spotify_playlist_nextSong_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "POST",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:spotify_playlist,
    is_active: true;

CREATE tool:spotify_playlist_pause SET
    identity = {
        name: "pause",
        slug: "spotify_playlist_pause",
        display_name_i18n: i18n_key:tool_spotify_playlist_pause_name,
        description_i18n: i18n_key:tool_spotify_playlist_pause_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 2018,
        tooltip_i18n: i18n_key:tool_spotify_playlist_pause_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_spotify_playlist_pause_success,
        error_message_i18n: i18n_key:tool_spotify_playlist_pause_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "POST",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:spotify_playlist,
    is_active: true;

CREATE tool:spotify_playlist_previousSong SET
    identity = {
        name: "previousSong",
        slug: "spotify_playlist_previousSong",
        display_name_i18n: i18n_key:tool_spotify_playlist_previousSong_name,
        description_i18n: i18n_key:tool_spotify_playlist_previousSong_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 2019,
        tooltip_i18n: i18n_key:tool_spotify_playlist_previousSong_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_spotify_playlist_previousSong_success,
        error_message_i18n: i18n_key:tool_spotify_playlist_previousSong_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "POST",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:spotify_playlist,
    is_active: true;

CREATE tool:spotify_playlist_recentlyPlayed SET
    identity = {
        name: "recentlyPlayed",
        slug: "spotify_playlist_recentlyPlayed",
        display_name_i18n: i18n_key:tool_spotify_playlist_recentlyPlayed_name,
        description_i18n: i18n_key:tool_spotify_playlist_recentlyPlayed_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 2020,
        tooltip_i18n: i18n_key:tool_spotify_playlist_recentlyPlayed_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_spotify_playlist_recentlyPlayed_success,
        error_message_i18n: i18n_key:tool_spotify_playlist_recentlyPlayed_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "POST",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:spotify_playlist,
    is_active: true;

CREATE tool:spotify_playlist_resume SET
    identity = {
        name: "resume",
        slug: "spotify_playlist_resume",
        display_name_i18n: i18n_key:tool_spotify_playlist_resume_name,
        description_i18n: i18n_key:tool_spotify_playlist_resume_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 2021,
        tooltip_i18n: i18n_key:tool_spotify_playlist_resume_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_spotify_playlist_resume_success,
        error_message_i18n: i18n_key:tool_spotify_playlist_resume_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "POST",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:spotify_playlist,
    is_active: true;

CREATE tool:spotify_playlist_volume SET
    identity = {
        name: "volume",
        slug: "spotify_playlist_volume",
        display_name_i18n: i18n_key:tool_spotify_playlist_volume_name,
        description_i18n: i18n_key:tool_spotify_playlist_volume_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 2022,
        tooltip_i18n: i18n_key:tool_spotify_playlist_volume_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_spotify_playlist_volume_success,
        error_message_i18n: i18n_key:tool_spotify_playlist_volume_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "POST",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:spotify_playlist,
    is_active: true;

CREATE tool:spotify_playlist_startMusic SET
    identity = {
        name: "startMusic",
        slug: "spotify_playlist_startMusic",
        display_name_i18n: i18n_key:tool_spotify_playlist_startMusic_name,
        description_i18n: i18n_key:tool_spotify_playlist_startMusic_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 2023,
        tooltip_i18n: i18n_key:tool_spotify_playlist_startMusic_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_spotify_playlist_startMusic_success,
        error_message_i18n: i18n_key:tool_spotify_playlist_startMusic_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "POST",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:spotify_playlist,
    is_active: true;

CREATE tool:spotify_track_addSongToQueue SET
    identity = {
        name: "addSongToQueue",
        slug: "spotify_track_addSongToQueue",
        display_name_i18n: i18n_key:tool_spotify_track_addSongToQueue_name,
        description_i18n: i18n_key:tool_spotify_track_addSongToQueue_desc,
        operation_type: "create",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#4CAF50",
        display_order: 2024,
        tooltip_i18n: i18n_key:tool_spotify_track_addSongToQueue_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_spotify_track_addSongToQueue_success,
        error_message_i18n: i18n_key:tool_spotify_track_addSongToQueue_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "POST",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:spotify_track,
    is_active: true;

CREATE tool:spotify_track_currentlyPlaying SET
    identity = {
        name: "currentlyPlaying",
        slug: "spotify_track_currentlyPlaying",
        display_name_i18n: i18n_key:tool_spotify_track_currentlyPlaying_name,
        description_i18n: i18n_key:tool_spotify_track_currentlyPlaying_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 2025,
        tooltip_i18n: i18n_key:tool_spotify_track_currentlyPlaying_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_spotify_track_currentlyPlaying_success,
        error_message_i18n: i18n_key:tool_spotify_track_currentlyPlaying_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "POST",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:spotify_track,
    is_active: true;

CREATE tool:spotify_track_nextSong SET
    identity = {
        name: "nextSong",
        slug: "spotify_track_nextSong",
        display_name_i18n: i18n_key:tool_spotify_track_nextSong_name,
        description_i18n: i18n_key:tool_spotify_track_nextSong_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 2026,
        tooltip_i18n: i18n_key:tool_spotify_track_nextSong_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_spotify_track_nextSong_success,
        error_message_i18n: i18n_key:tool_spotify_track_nextSong_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "POST",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:spotify_track,
    is_active: true;

CREATE tool:spotify_track_pause SET
    identity = {
        name: "pause",
        slug: "spotify_track_pause",
        display_name_i18n: i18n_key:tool_spotify_track_pause_name,
        description_i18n: i18n_key:tool_spotify_track_pause_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 2027,
        tooltip_i18n: i18n_key:tool_spotify_track_pause_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_spotify_track_pause_success,
        error_message_i18n: i18n_key:tool_spotify_track_pause_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "POST",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:spotify_track,
    is_active: true;

CREATE tool:spotify_track_previousSong SET
    identity = {
        name: "previousSong",
        slug: "spotify_track_previousSong",
        display_name_i18n: i18n_key:tool_spotify_track_previousSong_name,
        description_i18n: i18n_key:tool_spotify_track_previousSong_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 2028,
        tooltip_i18n: i18n_key:tool_spotify_track_previousSong_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_spotify_track_previousSong_success,
        error_message_i18n: i18n_key:tool_spotify_track_previousSong_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "POST",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:spotify_track,
    is_active: true;

CREATE tool:spotify_track_recentlyPlayed SET
    identity = {
        name: "recentlyPlayed",
        slug: "spotify_track_recentlyPlayed",
        display_name_i18n: i18n_key:tool_spotify_track_recentlyPlayed_name,
        description_i18n: i18n_key:tool_spotify_track_recentlyPlayed_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 2029,
        tooltip_i18n: i18n_key:tool_spotify_track_recentlyPlayed_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_spotify_track_recentlyPlayed_success,
        error_message_i18n: i18n_key:tool_spotify_track_recentlyPlayed_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "POST",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:spotify_track,
    is_active: true;

CREATE tool:spotify_track_resume SET
    identity = {
        name: "resume",
        slug: "spotify_track_resume",
        display_name_i18n: i18n_key:tool_spotify_track_resume_name,
        description_i18n: i18n_key:tool_spotify_track_resume_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 2030,
        tooltip_i18n: i18n_key:tool_spotify_track_resume_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_spotify_track_resume_success,
        error_message_i18n: i18n_key:tool_spotify_track_resume_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "POST",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:spotify_track,
    is_active: true;

CREATE tool:spotify_track_volume SET
    identity = {
        name: "volume",
        slug: "spotify_track_volume",
        display_name_i18n: i18n_key:tool_spotify_track_volume_name,
        description_i18n: i18n_key:tool_spotify_track_volume_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 2031,
        tooltip_i18n: i18n_key:tool_spotify_track_volume_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_spotify_track_volume_success,
        error_message_i18n: i18n_key:tool_spotify_track_volume_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "POST",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:spotify_track,
    is_active: true;

CREATE tool:spotify_track_startMusic SET
    identity = {
        name: "startMusic",
        slug: "spotify_track_startMusic",
        display_name_i18n: i18n_key:tool_spotify_track_startMusic_name,
        description_i18n: i18n_key:tool_spotify_track_startMusic_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 2032,
        tooltip_i18n: i18n_key:tool_spotify_track_startMusic_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_spotify_track_startMusic_success,
        error_message_i18n: i18n_key:tool_spotify_track_startMusic_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "POST",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:spotify_track,
    is_active: true;

CREATE tool:spreadsheetfile_spreadsheetfile_get SET
    identity = {
        name: "get",
        slug: "spreadsheetfile_spreadsheetfile_get",
        display_name_i18n: i18n_key:tool_spreadsheetfile_spreadsheetfile_get_name,
        description_i18n: i18n_key:tool_spreadsheetfile_spreadsheetfile_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 2033,
        tooltip_i18n: i18n_key:tool_spreadsheetfile_spreadsheetfile_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_spreadsheetfile_spreadsheetfile_get_success,
        error_message_i18n: i18n_key:tool_spreadsheetfile_spreadsheetfile_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:spreadsheetfile_spreadsheetfile,
    is_active: true;

CREATE tool:spreadsheetfile_spreadsheetfile_getMany SET
    identity = {
        name: "getMany",
        slug: "spreadsheetfile_spreadsheetfile_getMany",
        display_name_i18n: i18n_key:tool_spreadsheetfile_spreadsheetfile_getMany_name,
        description_i18n: i18n_key:tool_spreadsheetfile_spreadsheetfile_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 2034,
        tooltip_i18n: i18n_key:tool_spreadsheetfile_spreadsheetfile_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_spreadsheetfile_spreadsheetfile_getMany_success,
        error_message_i18n: i18n_key:tool_spreadsheetfile_spreadsheetfile_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:spreadsheetfile_spreadsheetfile,
    is_active: true;

CREATE tool:spreadsheetfilev1_spreadsheetfilev1_get SET
    identity = {
        name: "get",
        slug: "spreadsheetfilev1_spreadsheetfilev1_get",
        display_name_i18n: i18n_key:tool_spreadsheetfilev1_spreadsheetfilev1_get_name,
        description_i18n: i18n_key:tool_spreadsheetfilev1_spreadsheetfilev1_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 2035,
        tooltip_i18n: i18n_key:tool_spreadsheetfilev1_spreadsheetfilev1_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_spreadsheetfilev1_spreadsheetfilev1_get_success,
        error_message_i18n: i18n_key:tool_spreadsheetfilev1_spreadsheetfilev1_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:spreadsheetfilev1_spreadsheetfilev1,
    is_active: true;

CREATE tool:spreadsheetfilev1_spreadsheetfilev1_getMany SET
    identity = {
        name: "getMany",
        slug: "spreadsheetfilev1_spreadsheetfilev1_getMany",
        display_name_i18n: i18n_key:tool_spreadsheetfilev1_spreadsheetfilev1_getMany_name,
        description_i18n: i18n_key:tool_spreadsheetfilev1_spreadsheetfilev1_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 2036,
        tooltip_i18n: i18n_key:tool_spreadsheetfilev1_spreadsheetfilev1_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_spreadsheetfilev1_spreadsheetfilev1_getMany_success,
        error_message_i18n: i18n_key:tool_spreadsheetfilev1_spreadsheetfilev1_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:spreadsheetfilev1_spreadsheetfilev1,
    is_active: true;

CREATE tool:spreadsheetfilev2_spreadsheetfilev2_get SET
    identity = {
        name: "get",
        slug: "spreadsheetfilev2_spreadsheetfilev2_get",
        display_name_i18n: i18n_key:tool_spreadsheetfilev2_spreadsheetfilev2_get_name,
        description_i18n: i18n_key:tool_spreadsheetfilev2_spreadsheetfilev2_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 2037,
        tooltip_i18n: i18n_key:tool_spreadsheetfilev2_spreadsheetfilev2_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_spreadsheetfilev2_spreadsheetfilev2_get_success,
        error_message_i18n: i18n_key:tool_spreadsheetfilev2_spreadsheetfilev2_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:spreadsheetfilev2_spreadsheetfilev2,
    is_active: true;

CREATE tool:spreadsheetfilev2_spreadsheetfilev2_getMany SET
    identity = {
        name: "getMany",
        slug: "spreadsheetfilev2_spreadsheetfilev2_getMany",
        display_name_i18n: i18n_key:tool_spreadsheetfilev2_spreadsheetfilev2_getMany_name,
        description_i18n: i18n_key:tool_spreadsheetfilev2_spreadsheetfilev2_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 2038,
        tooltip_i18n: i18n_key:tool_spreadsheetfilev2_spreadsheetfilev2_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_spreadsheetfilev2_spreadsheetfilev2_getMany_success,
        error_message_i18n: i18n_key:tool_spreadsheetfilev2_spreadsheetfilev2_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:spreadsheetfilev2_spreadsheetfilev2,
    is_active: true;

CREATE tool:ssh_command_execute SET
    identity = {
        name: "execute",
        slug: "ssh_command_execute",
        display_name_i18n: i18n_key:tool_ssh_command_execute_name,
        description_i18n: i18n_key:tool_ssh_command_execute_desc,
        operation_type: "execute",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#FFC107",
        display_order: 2039,
        tooltip_i18n: i18n_key:tool_ssh_command_execute_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_ssh_command_execute_success,
        error_message_i18n: i18n_key:tool_ssh_command_execute_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "POST",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:ssh_command,
    is_active: true;

CREATE tool:ssh_file_execute SET
    identity = {
        name: "execute",
        slug: "ssh_file_execute",
        display_name_i18n: i18n_key:tool_ssh_file_execute_name,
        description_i18n: i18n_key:tool_ssh_file_execute_desc,
        operation_type: "execute",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#FFC107",
        display_order: 2040,
        tooltip_i18n: i18n_key:tool_ssh_file_execute_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_ssh_file_execute_success,
        error_message_i18n: i18n_key:tool_ssh_file_execute_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "POST",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:ssh_file,
    is_active: true;

CREATE tool:stackby_stackby_append SET
    identity = {
        name: "append",
        slug: "stackby_stackby_append",
        display_name_i18n: i18n_key:tool_stackby_stackby_append_name,
        description_i18n: i18n_key:tool_stackby_stackby_append_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 2041,
        tooltip_i18n: i18n_key:tool_stackby_stackby_append_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_stackby_stackby_append_success,
        error_message_i18n: i18n_key:tool_stackby_stackby_append_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "POST",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:stackby_stackby,
    is_active: true;

CREATE tool:stackby_stackby_delete SET
    identity = {
        name: "delete",
        slug: "stackby_stackby_delete",
        display_name_i18n: i18n_key:tool_stackby_stackby_delete_name,
        description_i18n: i18n_key:tool_stackby_stackby_delete_desc,
        operation_type: "delete",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#F44336",
        display_order: 2042,
        tooltip_i18n: i18n_key:tool_stackby_stackby_delete_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_stackby_stackby_delete_success,
        error_message_i18n: i18n_key:tool_stackby_stackby_delete_error,
        confirmation_required: true,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: true
    },
    config = {
        request: {
            method: "DELETE",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [204],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: true
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:stackby_stackby,
    is_active: true;

CREATE tool:stackby_stackby_list SET
    identity = {
        name: "list",
        slug: "stackby_stackby_list",
        display_name_i18n: i18n_key:tool_stackby_stackby_list_name,
        description_i18n: i18n_key:tool_stackby_stackby_list_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 2043,
        tooltip_i18n: i18n_key:tool_stackby_stackby_list_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_stackby_stackby_list_success,
        error_message_i18n: i18n_key:tool_stackby_stackby_list_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:stackby_stackby,
    is_active: true;

CREATE tool:stackby_stackby_read SET
    identity = {
        name: "read",
        slug: "stackby_stackby_read",
        display_name_i18n: i18n_key:tool_stackby_stackby_read_name,
        description_i18n: i18n_key:tool_stackby_stackby_read_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 2044,
        tooltip_i18n: i18n_key:tool_stackby_stackby_read_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_stackby_stackby_read_success,
        error_message_i18n: i18n_key:tool_stackby_stackby_read_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "POST",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:stackby_stackby,
    is_active: true;

CREATE tool:start_start_get SET
    identity = {
        name: "get",
        slug: "start_start_get",
        display_name_i18n: i18n_key:tool_start_start_get_name,
        description_i18n: i18n_key:tool_start_start_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 2045,
        tooltip_i18n: i18n_key:tool_start_start_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_start_start_get_success,
        error_message_i18n: i18n_key:tool_start_start_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:start_start,
    is_active: true;

CREATE tool:start_start_getMany SET
    identity = {
        name: "getMany",
        slug: "start_start_getMany",
        display_name_i18n: i18n_key:tool_start_start_getMany_name,
        description_i18n: i18n_key:tool_start_start_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 2046,
        tooltip_i18n: i18n_key:tool_start_start_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_start_start_getMany_success,
        error_message_i18n: i18n_key:tool_start_start_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:start_start,
    is_active: true;

CREATE tool:stickynote_stickynote_get SET
    identity = {
        name: "get",
        slug: "stickynote_stickynote_get",
        display_name_i18n: i18n_key:tool_stickynote_stickynote_get_name,
        description_i18n: i18n_key:tool_stickynote_stickynote_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 2047,
        tooltip_i18n: i18n_key:tool_stickynote_stickynote_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_stickynote_stickynote_get_success,
        error_message_i18n: i18n_key:tool_stickynote_stickynote_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:stickynote_stickynote,
    is_active: true;

CREATE tool:stickynote_stickynote_getMany SET
    identity = {
        name: "getMany",
        slug: "stickynote_stickynote_getMany",
        display_name_i18n: i18n_key:tool_stickynote_stickynote_getMany_name,
        description_i18n: i18n_key:tool_stickynote_stickynote_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 2048,
        tooltip_i18n: i18n_key:tool_stickynote_stickynote_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_stickynote_stickynote_getMany_success,
        error_message_i18n: i18n_key:tool_stickynote_stickynote_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:stickynote_stickynote,
    is_active: true;

CREATE tool:stopanderror_stopanderror_get SET
    identity = {
        name: "get",
        slug: "stopanderror_stopanderror_get",
        display_name_i18n: i18n_key:tool_stopanderror_stopanderror_get_name,
        description_i18n: i18n_key:tool_stopanderror_stopanderror_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 2049,
        tooltip_i18n: i18n_key:tool_stopanderror_stopanderror_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_stopanderror_stopanderror_get_success,
        error_message_i18n: i18n_key:tool_stopanderror_stopanderror_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:stopanderror_stopanderror,
    is_active: true;

CREATE tool:stopanderror_stopanderror_getMany SET
    identity = {
        name: "getMany",
        slug: "stopanderror_stopanderror_getMany",
        display_name_i18n: i18n_key:tool_stopanderror_stopanderror_getMany_name,
        description_i18n: i18n_key:tool_stopanderror_stopanderror_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 2050,
        tooltip_i18n: i18n_key:tool_stopanderror_stopanderror_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_stopanderror_stopanderror_getMany_success,
        error_message_i18n: i18n_key:tool_stopanderror_stopanderror_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:stopanderror_stopanderror,
    is_active: true;

CREATE tool:storyblok_story_get SET
    identity = {
        name: "get",
        slug: "storyblok_story_get",
        display_name_i18n: i18n_key:tool_storyblok_story_get_name,
        description_i18n: i18n_key:tool_storyblok_story_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 2051,
        tooltip_i18n: i18n_key:tool_storyblok_story_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_storyblok_story_get_success,
        error_message_i18n: i18n_key:tool_storyblok_story_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:storyblok_story,
    is_active: true;

CREATE tool:storyblok_story_getMany SET
    identity = {
        name: "getMany",
        slug: "storyblok_story_getMany",
        display_name_i18n: i18n_key:tool_storyblok_story_getMany_name,
        description_i18n: i18n_key:tool_storyblok_story_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 2052,
        tooltip_i18n: i18n_key:tool_storyblok_story_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_storyblok_story_getMany_success,
        error_message_i18n: i18n_key:tool_storyblok_story_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:storyblok_story,
    is_active: true;

CREATE tool:storyblok_storycontent_get SET
    identity = {
        name: "get",
        slug: "storyblok_storycontent_get",
        display_name_i18n: i18n_key:tool_storyblok_storycontent_get_name,
        description_i18n: i18n_key:tool_storyblok_storycontent_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 2053,
        tooltip_i18n: i18n_key:tool_storyblok_storycontent_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_storyblok_storycontent_get_success,
        error_message_i18n: i18n_key:tool_storyblok_storycontent_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:storyblok_storycontent,
    is_active: true;

CREATE tool:storyblok_storycontent_getMany SET
    identity = {
        name: "getMany",
        slug: "storyblok_storycontent_getMany",
        display_name_i18n: i18n_key:tool_storyblok_storycontent_getMany_name,
        description_i18n: i18n_key:tool_storyblok_storycontent_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 2054,
        tooltip_i18n: i18n_key:tool_storyblok_storycontent_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_storyblok_storycontent_getMany_success,
        error_message_i18n: i18n_key:tool_storyblok_storycontent_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:storyblok_storycontent,
    is_active: true;

CREATE tool:storyblok_storymanagement_get SET
    identity = {
        name: "get",
        slug: "storyblok_storymanagement_get",
        display_name_i18n: i18n_key:tool_storyblok_storymanagement_get_name,
        description_i18n: i18n_key:tool_storyblok_storymanagement_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 2055,
        tooltip_i18n: i18n_key:tool_storyblok_storymanagement_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_storyblok_storymanagement_get_success,
        error_message_i18n: i18n_key:tool_storyblok_storymanagement_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:storyblok_storymanagement,
    is_active: true;

CREATE tool:storyblok_storymanagement_getMany SET
    identity = {
        name: "getMany",
        slug: "storyblok_storymanagement_getMany",
        display_name_i18n: i18n_key:tool_storyblok_storymanagement_getMany_name,
        description_i18n: i18n_key:tool_storyblok_storymanagement_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 2056,
        tooltip_i18n: i18n_key:tool_storyblok_storymanagement_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_storyblok_storymanagement_getMany_success,
        error_message_i18n: i18n_key:tool_storyblok_storymanagement_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:storyblok_storymanagement,
    is_active: true;

CREATE tool:strapi_entry_get SET
    identity = {
        name: "get",
        slug: "strapi_entry_get",
        display_name_i18n: i18n_key:tool_strapi_entry_get_name,
        description_i18n: i18n_key:tool_strapi_entry_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 2057,
        tooltip_i18n: i18n_key:tool_strapi_entry_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_strapi_entry_get_success,
        error_message_i18n: i18n_key:tool_strapi_entry_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:strapi_entry,
    is_active: true;

CREATE tool:strapi_entry_getMany SET
    identity = {
        name: "getMany",
        slug: "strapi_entry_getMany",
        display_name_i18n: i18n_key:tool_strapi_entry_getMany_name,
        description_i18n: i18n_key:tool_strapi_entry_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 2058,
        tooltip_i18n: i18n_key:tool_strapi_entry_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_strapi_entry_getMany_success,
        error_message_i18n: i18n_key:tool_strapi_entry_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:strapi_entry,
    is_active: true;

CREATE tool:strava_activity_get SET
    identity = {
        name: "get",
        slug: "strava_activity_get",
        display_name_i18n: i18n_key:tool_strava_activity_get_name,
        description_i18n: i18n_key:tool_strava_activity_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 2059,
        tooltip_i18n: i18n_key:tool_strava_activity_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_strava_activity_get_success,
        error_message_i18n: i18n_key:tool_strava_activity_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:strava_activity,
    is_active: true;

CREATE tool:strava_activity_getMany SET
    identity = {
        name: "getMany",
        slug: "strava_activity_getMany",
        display_name_i18n: i18n_key:tool_strava_activity_getMany_name,
        description_i18n: i18n_key:tool_strava_activity_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 2060,
        tooltip_i18n: i18n_key:tool_strava_activity_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_strava_activity_getMany_success,
        error_message_i18n: i18n_key:tool_strava_activity_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:strava_activity,
    is_active: true;

CREATE tool:stripe_balance_get SET
    identity = {
        name: "get",
        slug: "stripe_balance_get",
        display_name_i18n: i18n_key:tool_stripe_balance_get_name,
        description_i18n: i18n_key:tool_stripe_balance_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 2061,
        tooltip_i18n: i18n_key:tool_stripe_balance_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_stripe_balance_get_success,
        error_message_i18n: i18n_key:tool_stripe_balance_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:stripe_balance,
    is_active: true;

CREATE tool:stripe_balance_getMany SET
    identity = {
        name: "getMany",
        slug: "stripe_balance_getMany",
        display_name_i18n: i18n_key:tool_stripe_balance_getMany_name,
        description_i18n: i18n_key:tool_stripe_balance_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 2062,
        tooltip_i18n: i18n_key:tool_stripe_balance_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_stripe_balance_getMany_success,
        error_message_i18n: i18n_key:tool_stripe_balance_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:stripe_balance,
    is_active: true;

CREATE tool:stripe_charge_get SET
    identity = {
        name: "get",
        slug: "stripe_charge_get",
        display_name_i18n: i18n_key:tool_stripe_charge_get_name,
        description_i18n: i18n_key:tool_stripe_charge_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 2063,
        tooltip_i18n: i18n_key:tool_stripe_charge_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_stripe_charge_get_success,
        error_message_i18n: i18n_key:tool_stripe_charge_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:stripe_charge,
    is_active: true;

CREATE tool:stripe_charge_getMany SET
    identity = {
        name: "getMany",
        slug: "stripe_charge_getMany",
        display_name_i18n: i18n_key:tool_stripe_charge_getMany_name,
        description_i18n: i18n_key:tool_stripe_charge_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 2064,
        tooltip_i18n: i18n_key:tool_stripe_charge_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_stripe_charge_getMany_success,
        error_message_i18n: i18n_key:tool_stripe_charge_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:stripe_charge,
    is_active: true;

CREATE tool:stripe_coupon_get SET
    identity = {
        name: "get",
        slug: "stripe_coupon_get",
        display_name_i18n: i18n_key:tool_stripe_coupon_get_name,
        description_i18n: i18n_key:tool_stripe_coupon_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 2065,
        tooltip_i18n: i18n_key:tool_stripe_coupon_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_stripe_coupon_get_success,
        error_message_i18n: i18n_key:tool_stripe_coupon_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:stripe_coupon,
    is_active: true;

CREATE tool:stripe_coupon_getMany SET
    identity = {
        name: "getMany",
        slug: "stripe_coupon_getMany",
        display_name_i18n: i18n_key:tool_stripe_coupon_getMany_name,
        description_i18n: i18n_key:tool_stripe_coupon_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 2066,
        tooltip_i18n: i18n_key:tool_stripe_coupon_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_stripe_coupon_getMany_success,
        error_message_i18n: i18n_key:tool_stripe_coupon_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:stripe_coupon,
    is_active: true;

CREATE tool:stripe_customer_get SET
    identity = {
        name: "get",
        slug: "stripe_customer_get",
        display_name_i18n: i18n_key:tool_stripe_customer_get_name,
        description_i18n: i18n_key:tool_stripe_customer_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 2067,
        tooltip_i18n: i18n_key:tool_stripe_customer_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_stripe_customer_get_success,
        error_message_i18n: i18n_key:tool_stripe_customer_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:stripe_customer,
    is_active: true;

CREATE tool:stripe_customer_getMany SET
    identity = {
        name: "getMany",
        slug: "stripe_customer_getMany",
        display_name_i18n: i18n_key:tool_stripe_customer_getMany_name,
        description_i18n: i18n_key:tool_stripe_customer_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 2068,
        tooltip_i18n: i18n_key:tool_stripe_customer_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_stripe_customer_getMany_success,
        error_message_i18n: i18n_key:tool_stripe_customer_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:stripe_customer,
    is_active: true;

CREATE tool:stripe_customerCard_get SET
    identity = {
        name: "get",
        slug: "stripe_customerCard_get",
        display_name_i18n: i18n_key:tool_stripe_customerCard_get_name,
        description_i18n: i18n_key:tool_stripe_customerCard_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 2069,
        tooltip_i18n: i18n_key:tool_stripe_customerCard_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_stripe_customerCard_get_success,
        error_message_i18n: i18n_key:tool_stripe_customerCard_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:stripe_customerCard,
    is_active: true;

CREATE tool:stripe_customerCard_getMany SET
    identity = {
        name: "getMany",
        slug: "stripe_customerCard_getMany",
        display_name_i18n: i18n_key:tool_stripe_customerCard_getMany_name,
        description_i18n: i18n_key:tool_stripe_customerCard_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 2070,
        tooltip_i18n: i18n_key:tool_stripe_customerCard_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_stripe_customerCard_getMany_success,
        error_message_i18n: i18n_key:tool_stripe_customerCard_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:stripe_customerCard,
    is_active: true;

CREATE tool:stripe_source_get SET
    identity = {
        name: "get",
        slug: "stripe_source_get",
        display_name_i18n: i18n_key:tool_stripe_source_get_name,
        description_i18n: i18n_key:tool_stripe_source_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 2071,
        tooltip_i18n: i18n_key:tool_stripe_source_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_stripe_source_get_success,
        error_message_i18n: i18n_key:tool_stripe_source_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:stripe_source,
    is_active: true;

CREATE tool:stripe_source_getMany SET
    identity = {
        name: "getMany",
        slug: "stripe_source_getMany",
        display_name_i18n: i18n_key:tool_stripe_source_getMany_name,
        description_i18n: i18n_key:tool_stripe_source_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 2072,
        tooltip_i18n: i18n_key:tool_stripe_source_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_stripe_source_getMany_success,
        error_message_i18n: i18n_key:tool_stripe_source_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:stripe_source,
    is_active: true;

CREATE tool:stripe_token_get SET
    identity = {
        name: "get",
        slug: "stripe_token_get",
        display_name_i18n: i18n_key:tool_stripe_token_get_name,
        description_i18n: i18n_key:tool_stripe_token_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 2073,
        tooltip_i18n: i18n_key:tool_stripe_token_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_stripe_token_get_success,
        error_message_i18n: i18n_key:tool_stripe_token_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:stripe_token,
    is_active: true;

CREATE tool:stripe_token_getMany SET
    identity = {
        name: "getMany",
        slug: "stripe_token_getMany",
        display_name_i18n: i18n_key:tool_stripe_token_getMany_name,
        description_i18n: i18n_key:tool_stripe_token_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 2074,
        tooltip_i18n: i18n_key:tool_stripe_token_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_stripe_token_getMany_success,
        error_message_i18n: i18n_key:tool_stripe_token_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:stripe_token,
    is_active: true;

CREATE tool:supabase_row_get SET
    identity = {
        name: "get",
        slug: "supabase_row_get",
        display_name_i18n: i18n_key:tool_supabase_row_get_name,
        description_i18n: i18n_key:tool_supabase_row_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 2075,
        tooltip_i18n: i18n_key:tool_supabase_row_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_supabase_row_get_success,
        error_message_i18n: i18n_key:tool_supabase_row_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:supabase_row,
    is_active: true;

CREATE tool:supabase_row_getMany SET
    identity = {
        name: "getMany",
        slug: "supabase_row_getMany",
        display_name_i18n: i18n_key:tool_supabase_row_getMany_name,
        description_i18n: i18n_key:tool_supabase_row_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 2076,
        tooltip_i18n: i18n_key:tool_supabase_row_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_supabase_row_getMany_success,
        error_message_i18n: i18n_key:tool_supabase_row_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:supabase_row,
    is_active: true;

CREATE tool:switch_switch_get SET
    identity = {
        name: "get",
        slug: "switch_switch_get",
        display_name_i18n: i18n_key:tool_switch_switch_get_name,
        description_i18n: i18n_key:tool_switch_switch_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 2077,
        tooltip_i18n: i18n_key:tool_switch_switch_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_switch_switch_get_success,
        error_message_i18n: i18n_key:tool_switch_switch_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:switch_switch,
    is_active: true;

CREATE tool:switch_switch_getMany SET
    identity = {
        name: "getMany",
        slug: "switch_switch_getMany",
        display_name_i18n: i18n_key:tool_switch_switch_getMany_name,
        description_i18n: i18n_key:tool_switch_switch_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 2078,
        tooltip_i18n: i18n_key:tool_switch_switch_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_switch_switch_getMany_success,
        error_message_i18n: i18n_key:tool_switch_switch_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:switch_switch,
    is_active: true;

CREATE tool:switchv1_switchv1_equal SET
    identity = {
        name: "equal",
        slug: "switchv1_switchv1_equal",
        display_name_i18n: i18n_key:tool_switchv1_switchv1_equal_name,
        description_i18n: i18n_key:tool_switchv1_switchv1_equal_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 2079,
        tooltip_i18n: i18n_key:tool_switchv1_switchv1_equal_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_switchv1_switchv1_equal_success,
        error_message_i18n: i18n_key:tool_switchv1_switchv1_equal_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "POST",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:switchv1_switchv1,
    is_active: true;

CREATE tool:switchv1_switchv1_notEqual SET
    identity = {
        name: "notEqual",
        slug: "switchv1_switchv1_notEqual",
        display_name_i18n: i18n_key:tool_switchv1_switchv1_notEqual_name,
        description_i18n: i18n_key:tool_switchv1_switchv1_notEqual_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 2080,
        tooltip_i18n: i18n_key:tool_switchv1_switchv1_notEqual_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_switchv1_switchv1_notEqual_success,
        error_message_i18n: i18n_key:tool_switchv1_switchv1_notEqual_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "POST",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:switchv1_switchv1,
    is_active: true;

CREATE tool:switchv2_switchv2_equal SET
    identity = {
        name: "equal",
        slug: "switchv2_switchv2_equal",
        display_name_i18n: i18n_key:tool_switchv2_switchv2_equal_name,
        description_i18n: i18n_key:tool_switchv2_switchv2_equal_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 2081,
        tooltip_i18n: i18n_key:tool_switchv2_switchv2_equal_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_switchv2_switchv2_equal_success,
        error_message_i18n: i18n_key:tool_switchv2_switchv2_equal_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "POST",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:switchv2_switchv2,
    is_active: true;

CREATE tool:switchv2_switchv2_notEqual SET
    identity = {
        name: "notEqual",
        slug: "switchv2_switchv2_notEqual",
        display_name_i18n: i18n_key:tool_switchv2_switchv2_notEqual_name,
        description_i18n: i18n_key:tool_switchv2_switchv2_notEqual_desc,
        operation_type: "custom",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#607D8B",
        display_order: 2082,
        tooltip_i18n: i18n_key:tool_switchv2_switchv2_notEqual_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_switchv2_switchv2_notEqual_success,
        error_message_i18n: i18n_key:tool_switchv2_switchv2_notEqual_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "POST",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:switchv2_switchv2,
    is_active: true;

CREATE tool:switchv3_switchv3_get SET
    identity = {
        name: "get",
        slug: "switchv3_switchv3_get",
        display_name_i18n: i18n_key:tool_switchv3_switchv3_get_name,
        description_i18n: i18n_key:tool_switchv3_switchv3_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 2083,
        tooltip_i18n: i18n_key:tool_switchv3_switchv3_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_switchv3_switchv3_get_success,
        error_message_i18n: i18n_key:tool_switchv3_switchv3_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:switchv3_switchv3,
    is_active: true;

CREATE tool:switchv3_switchv3_getMany SET
    identity = {
        name: "getMany",
        slug: "switchv3_switchv3_getMany",
        display_name_i18n: i18n_key:tool_switchv3_switchv3_getMany_name,
        description_i18n: i18n_key:tool_switchv3_switchv3_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 2084,
        tooltip_i18n: i18n_key:tool_switchv3_switchv3_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_switchv3_switchv3_getMany_success,
        error_message_i18n: i18n_key:tool_switchv3_switchv3_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:switchv3_switchv3,
    is_active: true;

CREATE tool:syncromsp_syncromsp_get SET
    identity = {
        name: "get",
        slug: "syncromsp_syncromsp_get",
        display_name_i18n: i18n_key:tool_syncromsp_syncromsp_get_name,
        description_i18n: i18n_key:tool_syncromsp_syncromsp_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 2085,
        tooltip_i18n: i18n_key:tool_syncromsp_syncromsp_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_syncromsp_syncromsp_get_success,
        error_message_i18n: i18n_key:tool_syncromsp_syncromsp_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:syncromsp_syncromsp,
    is_active: true;

CREATE tool:syncromsp_syncromsp_getMany SET
    identity = {
        name: "getMany",
        slug: "syncromsp_syncromsp_getMany",
        display_name_i18n: i18n_key:tool_syncromsp_syncromsp_getMany_name,
        description_i18n: i18n_key:tool_syncromsp_syncromsp_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 2086,
        tooltip_i18n: i18n_key:tool_syncromsp_syncromsp_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_syncromsp_syncromsp_getMany_success,
        error_message_i18n: i18n_key:tool_syncromsp_syncromsp_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:syncromsp_syncromsp,
    is_active: true;

CREATE tool:syncromspv1_syncromspv1_get SET
    identity = {
        name: "get",
        slug: "syncromspv1_syncromspv1_get",
        display_name_i18n: i18n_key:tool_syncromspv1_syncromspv1_get_name,
        description_i18n: i18n_key:tool_syncromspv1_syncromspv1_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 2087,
        tooltip_i18n: i18n_key:tool_syncromspv1_syncromspv1_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_syncromspv1_syncromspv1_get_success,
        error_message_i18n: i18n_key:tool_syncromspv1_syncromspv1_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:syncromspv1_syncromspv1,
    is_active: true;

CREATE tool:syncromspv1_syncromspv1_getMany SET
    identity = {
        name: "getMany",
        slug: "syncromspv1_syncromspv1_getMany",
        display_name_i18n: i18n_key:tool_syncromspv1_syncromspv1_getMany_name,
        description_i18n: i18n_key:tool_syncromspv1_syncromspv1_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 2088,
        tooltip_i18n: i18n_key:tool_syncromspv1_syncromspv1_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_syncromspv1_syncromspv1_getMany_success,
        error_message_i18n: i18n_key:tool_syncromspv1_syncromspv1_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:syncromspv1_syncromspv1,
    is_active: true;

CREATE tool:taiga_epic_get SET
    identity = {
        name: "get",
        slug: "taiga_epic_get",
        display_name_i18n: i18n_key:tool_taiga_epic_get_name,
        description_i18n: i18n_key:tool_taiga_epic_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 2089,
        tooltip_i18n: i18n_key:tool_taiga_epic_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_taiga_epic_get_success,
        error_message_i18n: i18n_key:tool_taiga_epic_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:taiga_epic,
    is_active: true;

CREATE tool:taiga_epic_getMany SET
    identity = {
        name: "getMany",
        slug: "taiga_epic_getMany",
        display_name_i18n: i18n_key:tool_taiga_epic_getMany_name,
        description_i18n: i18n_key:tool_taiga_epic_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 2090,
        tooltip_i18n: i18n_key:tool_taiga_epic_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_taiga_epic_getMany_success,
        error_message_i18n: i18n_key:tool_taiga_epic_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:taiga_epic,
    is_active: true;

CREATE tool:taiga_issue_get SET
    identity = {
        name: "get",
        slug: "taiga_issue_get",
        display_name_i18n: i18n_key:tool_taiga_issue_get_name,
        description_i18n: i18n_key:tool_taiga_issue_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 2091,
        tooltip_i18n: i18n_key:tool_taiga_issue_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_taiga_issue_get_success,
        error_message_i18n: i18n_key:tool_taiga_issue_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:taiga_issue,
    is_active: true;

CREATE tool:taiga_issue_getMany SET
    identity = {
        name: "getMany",
        slug: "taiga_issue_getMany",
        display_name_i18n: i18n_key:tool_taiga_issue_getMany_name,
        description_i18n: i18n_key:tool_taiga_issue_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 2092,
        tooltip_i18n: i18n_key:tool_taiga_issue_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_taiga_issue_getMany_success,
        error_message_i18n: i18n_key:tool_taiga_issue_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:taiga_issue,
    is_active: true;

CREATE tool:taiga_task_get SET
    identity = {
        name: "get",
        slug: "taiga_task_get",
        display_name_i18n: i18n_key:tool_taiga_task_get_name,
        description_i18n: i18n_key:tool_taiga_task_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 2093,
        tooltip_i18n: i18n_key:tool_taiga_task_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_taiga_task_get_success,
        error_message_i18n: i18n_key:tool_taiga_task_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:taiga_task,
    is_active: true;

CREATE tool:taiga_task_getMany SET
    identity = {
        name: "getMany",
        slug: "taiga_task_getMany",
        display_name_i18n: i18n_key:tool_taiga_task_getMany_name,
        description_i18n: i18n_key:tool_taiga_task_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 2094,
        tooltip_i18n: i18n_key:tool_taiga_task_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_taiga_task_getMany_success,
        error_message_i18n: i18n_key:tool_taiga_task_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:taiga_task,
    is_active: true;

CREATE tool:taiga_userStory_get SET
    identity = {
        name: "get",
        slug: "taiga_userStory_get",
        display_name_i18n: i18n_key:tool_taiga_userStory_get_name,
        description_i18n: i18n_key:tool_taiga_userStory_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 2095,
        tooltip_i18n: i18n_key:tool_taiga_userStory_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_taiga_userStory_get_success,
        error_message_i18n: i18n_key:tool_taiga_userStory_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:taiga_userStory,
    is_active: true;

CREATE tool:taiga_userStory_getMany SET
    identity = {
        name: "getMany",
        slug: "taiga_userStory_getMany",
        display_name_i18n: i18n_key:tool_taiga_userStory_getMany_name,
        description_i18n: i18n_key:tool_taiga_userStory_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 2096,
        tooltip_i18n: i18n_key:tool_taiga_userStory_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_taiga_userStory_getMany_success,
        error_message_i18n: i18n_key:tool_taiga_userStory_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:taiga_userStory,
    is_active: true;

CREATE tool:tapfiliate_affiliate_get SET
    identity = {
        name: "get",
        slug: "tapfiliate_affiliate_get",
        display_name_i18n: i18n_key:tool_tapfiliate_affiliate_get_name,
        description_i18n: i18n_key:tool_tapfiliate_affiliate_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 2097,
        tooltip_i18n: i18n_key:tool_tapfiliate_affiliate_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_tapfiliate_affiliate_get_success,
        error_message_i18n: i18n_key:tool_tapfiliate_affiliate_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:tapfiliate_affiliate,
    is_active: true;

CREATE tool:tapfiliate_affiliate_getMany SET
    identity = {
        name: "getMany",
        slug: "tapfiliate_affiliate_getMany",
        display_name_i18n: i18n_key:tool_tapfiliate_affiliate_getMany_name,
        description_i18n: i18n_key:tool_tapfiliate_affiliate_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 2098,
        tooltip_i18n: i18n_key:tool_tapfiliate_affiliate_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_tapfiliate_affiliate_getMany_success,
        error_message_i18n: i18n_key:tool_tapfiliate_affiliate_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:tapfiliate_affiliate,
    is_active: true;

CREATE tool:tapfiliate_affiliateMetadata_get SET
    identity = {
        name: "get",
        slug: "tapfiliate_affiliateMetadata_get",
        display_name_i18n: i18n_key:tool_tapfiliate_affiliateMetadata_get_name,
        description_i18n: i18n_key:tool_tapfiliate_affiliateMetadata_get_desc,
        operation_type: "read",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#2196F3",
        display_order: 2099,
        tooltip_i18n: i18n_key:tool_tapfiliate_affiliateMetadata_get_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_tapfiliate_affiliateMetadata_get_success,
        error_message_i18n: i18n_key:tool_tapfiliate_affiliateMetadata_get_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:tapfiliate_affiliateMetadata,
    is_active: true;

CREATE tool:tapfiliate_affiliateMetadata_getMany SET
    identity = {
        name: "getMany",
        slug: "tapfiliate_affiliateMetadata_getMany",
        display_name_i18n: i18n_key:tool_tapfiliate_affiliateMetadata_getMany_name,
        description_i18n: i18n_key:tool_tapfiliate_affiliateMetadata_getMany_desc,
        operation_type: "list",
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: "#9C27B0",
        display_order: 2100,
        tooltip_i18n: i18n_key:tool_tapfiliate_affiliateMetadata_getMany_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_tapfiliate_affiliateMetadata_getMany_success,
        error_message_i18n: i18n_key:tool_tapfiliate_affiliateMetadata_getMany_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "GET",
            endpoint: "/api/endpoint",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 60,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = NONE,
    metadata = {
        usage_count: 0,
        average_duration: NONE,
        success_rate: NONE,
        custom_data: NONE
    },
    resource_id: resource:tapfiliate_affiliateMetadata,
    is_active: true;

