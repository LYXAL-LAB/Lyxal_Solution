-- ========================================================================
-- BATCH 8 : PROVIDERS SEEDS (30 providers) - DONNÉES COMPLÈTES N8N
-- ========================================================================
-- Date: 2025-10-29
-- Source:
--    n8n credentials (documentationUrl, baseURL, auth types)
--    Official brand colors (45+ providers)
-- ========================================================================

CREATE provider:snowflake SET
    name = "snowflake",
    slug = "snowflake",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_snowflake_name,
        description_i18n: i18n_key:provider_snowflake_description
    },
    presentation = {
        logo_light: logo_brand:snowflake_light,
        logo_dark: logo_brand:snowflake_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_snowflake_tooltip,
        display_order: 8010
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:snowflake_documentation,
            api_base: NONE,
            status_page: NONE
        },
        capabilities: {
            supports_oauth2: false,
            supports_api_key: false,
            supports_basic_auth: false,
            supports_webhooks: false,
            supports_rate_limiting: true
        },
        api_version: NONE
    },
    metadata = {
        founded_year: NONE,
        headquarters: NONE,
        industry: [],
        company_size: NONE,
        stock_symbol: NONE,
        tags: []
    },
    documentation = {
        getting_started_url: NONE,
        api_reference_url: NONE,
        sdk_urls: NONE,
        community_url: NONE
    };

CREATE provider:solarwinds SET
    name = "solarwinds",
    slug = "solarwinds",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_solarwinds_name,
        description_i18n: i18n_key:provider_solarwinds_description
    },
    presentation = {
        logo_light: logo_brand:solarwinds_light,
        logo_dark: logo_brand:solarwinds_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_solarwinds_tooltip,
        display_order: 8020
    },
    config = {
        urls: {
            website: NONE,
            documentation: NONE,
            api_base: NONE,
            status_page: NONE
        },
        capabilities: {
            supports_oauth2: false,
            supports_api_key: true,
            supports_basic_auth: false,
            supports_webhooks: false,
            supports_rate_limiting: true
        },
        api_version: NONE
    },
    metadata = {
        founded_year: NONE,
        headquarters: NONE,
        industry: [],
        company_size: NONE,
        stock_symbol: NONE,
        tags: []
    },
    documentation = {
        getting_started_url: NONE,
        api_reference_url: NONE,
        sdk_urls: NONE,
        community_url: NONE
    };

CREATE provider:splunk SET
    name = "splunk",
    slug = "splunk",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_splunk_name,
        description_i18n: i18n_key:provider_splunk_description
    },
    presentation = {
        logo_light: logo_brand:splunk_light,
        logo_dark: logo_brand:splunk_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_splunk_tooltip,
        display_order: 8030
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:splunk_documentation,
            api_base: NONE,
            status_page: NONE
        },
        capabilities: {
            supports_oauth2: false,
            supports_api_key: false,
            supports_basic_auth: false,
            supports_webhooks: false,
            supports_rate_limiting: true
        },
        api_version: NONE
    },
    metadata = {
        founded_year: NONE,
        headquarters: NONE,
        industry: [],
        company_size: NONE,
        stock_symbol: NONE,
        tags: []
    },
    documentation = {
        getting_started_url: NONE,
        api_reference_url: NONE,
        sdk_urls: NONE,
        community_url: NONE
    };

CREATE provider:spontit SET
    name = "spontit",
    slug = "spontit",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_spontit_name,
        description_i18n: i18n_key:provider_spontit_description
    },
    presentation = {
        logo_light: logo_brand:spontit_light,
        logo_dark: logo_brand:spontit_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_spontit_tooltip,
        display_order: 8040
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:spontit_documentation,
            api_base: NONE,
            status_page: NONE
        },
        capabilities: {
            supports_oauth2: false,
            supports_api_key: true,
            supports_basic_auth: false,
            supports_webhooks: false,
            supports_rate_limiting: true
        },
        api_version: NONE
    },
    metadata = {
        founded_year: NONE,
        headquarters: NONE,
        industry: [],
        company_size: NONE,
        stock_symbol: NONE,
        tags: []
    },
    documentation = {
        getting_started_url: NONE,
        api_reference_url: NONE,
        sdk_urls: NONE,
        community_url: NONE
    };

CREATE provider:spotify SET
    name = "spotify",
    slug = "spotify",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_spotify_name,
        description_i18n: i18n_key:provider_spotify_description
    },
    presentation = {
        logo_light: logo_brand:spotify_light,
        logo_dark: logo_brand:spotify_dark,
        color: "#1DB954",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_spotify_tooltip,
        display_order: 8050
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:spotify_documentation,
            api_base: NONE,
            status_page: NONE
        },
        capabilities: {
            supports_oauth2: true,
            supports_api_key: false,
            supports_basic_auth: false,
            supports_webhooks: false,
            supports_rate_limiting: true
        },
        api_version: NONE
    },
    metadata = {
        founded_year: NONE,
        headquarters: NONE,
        industry: [],
        company_size: NONE,
        stock_symbol: NONE,
        tags: []
    },
    documentation = {
        getting_started_url: NONE,
        api_reference_url: NONE,
        sdk_urls: NONE,
        community_url: NONE
    };

CREATE provider:stackby SET
    name = "stackby",
    slug = "stackby",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_stackby_name,
        description_i18n: i18n_key:provider_stackby_description
    },
    presentation = {
        logo_light: logo_brand:stackby_light,
        logo_dark: logo_brand:stackby_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_stackby_tooltip,
        display_order: 8060
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:stackby_documentation,
            api_base: NONE,
            status_page: NONE
        },
        capabilities: {
            supports_oauth2: false,
            supports_api_key: true,
            supports_basic_auth: false,
            supports_webhooks: false,
            supports_rate_limiting: true
        },
        api_version: NONE
    },
    metadata = {
        founded_year: NONE,
        headquarters: NONE,
        industry: [],
        company_size: NONE,
        stock_symbol: NONE,
        tags: []
    },
    documentation = {
        getting_started_url: NONE,
        api_reference_url: NONE,
        sdk_urls: NONE,
        community_url: NONE
    };

CREATE provider:storyblok SET
    name = "storyblok",
    slug = "storyblok",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_storyblok_name,
        description_i18n: i18n_key:provider_storyblok_description
    },
    presentation = {
        logo_light: logo_brand:storyblok_light,
        logo_dark: logo_brand:storyblok_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_storyblok_tooltip,
        display_order: 8070
    },
    config = {
        urls: {
            website: NONE,
            documentation: NONE,
            api_base: NONE,
            status_page: NONE
        },
        capabilities: {
            supports_oauth2: false,
            supports_api_key: true,
            supports_basic_auth: false,
            supports_webhooks: false,
            supports_rate_limiting: true
        },
        api_version: NONE
    },
    metadata = {
        founded_year: NONE,
        headquarters: NONE,
        industry: [],
        company_size: NONE,
        stock_symbol: NONE,
        tags: []
    },
    documentation = {
        getting_started_url: NONE,
        api_reference_url: NONE,
        sdk_urls: NONE,
        community_url: NONE
    };

CREATE provider:strapi SET
    name = "strapi",
    slug = "strapi",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_strapi_name,
        description_i18n: i18n_key:provider_strapi_description
    },
    presentation = {
        logo_light: logo_brand:strapi_light,
        logo_dark: logo_brand:strapi_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_strapi_tooltip,
        display_order: 8080
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:strapi_documentation,
            api_base: NONE,
            status_page: NONE
        },
        capabilities: {
            supports_oauth2: false,
            supports_api_key: false,
            supports_basic_auth: false,
            supports_webhooks: false,
            supports_rate_limiting: true
        },
        api_version: NONE
    },
    metadata = {
        founded_year: NONE,
        headquarters: NONE,
        industry: [],
        company_size: NONE,
        stock_symbol: NONE,
        tags: []
    },
    documentation = {
        getting_started_url: NONE,
        api_reference_url: NONE,
        sdk_urls: NONE,
        community_url: NONE
    };

CREATE provider:strava SET
    name = "strava",
    slug = "strava",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_strava_name,
        description_i18n: i18n_key:provider_strava_description
    },
    presentation = {
        logo_light: logo_brand:strava_light,
        logo_dark: logo_brand:strava_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_strava_tooltip,
        display_order: 8090
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:strava_documentation,
            api_base: NONE,
            status_page: NONE
        },
        capabilities: {
            supports_oauth2: true,
            supports_api_key: false,
            supports_basic_auth: false,
            supports_webhooks: false,
            supports_rate_limiting: true
        },
        api_version: NONE
    },
    metadata = {
        founded_year: NONE,
        headquarters: NONE,
        industry: [],
        company_size: NONE,
        stock_symbol: NONE,
        tags: []
    },
    documentation = {
        getting_started_url: NONE,
        api_reference_url: NONE,
        sdk_urls: NONE,
        community_url: NONE
    };

CREATE provider:stripe SET
    name = "stripe",
    slug = "stripe",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_stripe_name,
        description_i18n: i18n_key:provider_stripe_description
    },
    presentation = {
        logo_light: logo_brand:stripe_light,
        logo_dark: logo_brand:stripe_dark,
        color: "#635BFF",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_stripe_tooltip,
        display_order: 8100
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:stripe_documentation,
            api_base: "https://api.stripe.com/v1",
            status_page: NONE
        },
        capabilities: {
            supports_oauth2: false,
            supports_api_key: false,
            supports_basic_auth: false,
            supports_webhooks: false,
            supports_rate_limiting: true
        },
        api_version: NONE
    },
    metadata = {
        founded_year: NONE,
        headquarters: NONE,
        industry: [],
        company_size: NONE,
        stock_symbol: NONE,
        tags: []
    },
    documentation = {
        getting_started_url: NONE,
        api_reference_url: NONE,
        sdk_urls: NONE,
        community_url: NONE
    };

CREATE provider:supabase SET
    name = "supabase",
    slug = "supabase",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_supabase_name,
        description_i18n: i18n_key:provider_supabase_description
    },
    presentation = {
        logo_light: logo_brand:supabase_light,
        logo_dark: logo_brand:supabase_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_supabase_tooltip,
        display_order: 8110
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:supabase_documentation,
            api_base: NONE,
            status_page: NONE
        },
        capabilities: {
            supports_oauth2: false,
            supports_api_key: true,
            supports_basic_auth: false,
            supports_webhooks: false,
            supports_rate_limiting: true
        },
        api_version: NONE
    },
    metadata = {
        founded_year: NONE,
        headquarters: NONE,
        industry: [],
        company_size: NONE,
        stock_symbol: NONE,
        tags: []
    },
    documentation = {
        getting_started_url: NONE,
        api_reference_url: NONE,
        sdk_urls: NONE,
        community_url: NONE
    };

CREATE provider:surveymonkey SET
    name = "surveymonkey",
    slug = "surveymonkey",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_surveymonkey_name,
        description_i18n: i18n_key:provider_surveymonkey_description
    },
    presentation = {
        logo_light: logo_brand:surveymonkey_light,
        logo_dark: logo_brand:surveymonkey_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_surveymonkey_tooltip,
        display_order: 8120
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:surveymonkey_documentation,
            api_base: NONE,
            status_page: NONE
        },
        capabilities: {
            supports_oauth2: true,
            supports_api_key: false,
            supports_basic_auth: false,
            supports_webhooks: false,
            supports_rate_limiting: true
        },
        api_version: NONE
    },
    metadata = {
        founded_year: NONE,
        headquarters: NONE,
        industry: [],
        company_size: NONE,
        stock_symbol: NONE,
        tags: []
    },
    documentation = {
        getting_started_url: NONE,
        api_reference_url: NONE,
        sdk_urls: NONE,
        community_url: NONE
    };

CREATE provider:syncro SET
    name = "syncro",
    slug = "syncro",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_syncro_name,
        description_i18n: i18n_key:provider_syncro_description
    },
    presentation = {
        logo_light: logo_brand:syncro_light,
        logo_dark: logo_brand:syncro_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_syncro_tooltip,
        display_order: 8130
    },
    config = {
        urls: {
            website: NONE,
            documentation: NONE,
            api_base: NONE,
            status_page: NONE
        },
        capabilities: {
            supports_oauth2: false,
            supports_api_key: true,
            supports_basic_auth: false,
            supports_webhooks: false,
            supports_rate_limiting: true
        },
        api_version: NONE
    },
    metadata = {
        founded_year: NONE,
        headquarters: NONE,
        industry: [],
        company_size: NONE,
        stock_symbol: NONE,
        tags: []
    },
    documentation = {
        getting_started_url: NONE,
        api_reference_url: NONE,
        sdk_urls: NONE,
        community_url: NONE
    };

CREATE provider:sysdig SET
    name = "sysdig",
    slug = "sysdig",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_sysdig_name,
        description_i18n: i18n_key:provider_sysdig_description
    },
    presentation = {
        logo_light: logo_brand:sysdig_light,
        logo_dark: logo_brand:sysdig_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_sysdig_tooltip,
        display_order: 8140
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:sysdig_documentation,
            api_base: "https://app.us1.sysdig.com",
            status_page: NONE
        },
        capabilities: {
            supports_oauth2: false,
            supports_api_key: false,
            supports_basic_auth: false,
            supports_webhooks: false,
            supports_rate_limiting: true
        },
        api_version: NONE
    },
    metadata = {
        founded_year: NONE,
        headquarters: NONE,
        industry: [],
        company_size: NONE,
        stock_symbol: NONE,
        tags: []
    },
    documentation = {
        getting_started_url: NONE,
        api_reference_url: NONE,
        sdk_urls: NONE,
        community_url: NONE
    };

CREATE provider:taiga SET
    name = "taiga",
    slug = "taiga",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_taiga_name,
        description_i18n: i18n_key:provider_taiga_description
    },
    presentation = {
        logo_light: logo_brand:taiga_light,
        logo_dark: logo_brand:taiga_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_taiga_tooltip,
        display_order: 8150
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:taiga_documentation,
            api_base: NONE,
            status_page: NONE
        },
        capabilities: {
            supports_oauth2: false,
            supports_api_key: false,
            supports_basic_auth: false,
            supports_webhooks: false,
            supports_rate_limiting: true
        },
        api_version: NONE
    },
    metadata = {
        founded_year: NONE,
        headquarters: NONE,
        industry: [],
        company_size: NONE,
        stock_symbol: NONE,
        tags: []
    },
    documentation = {
        getting_started_url: NONE,
        api_reference_url: NONE,
        sdk_urls: NONE,
        community_url: NONE
    };

CREATE provider:tapfiliate SET
    name = "tapfiliate",
    slug = "tapfiliate",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_tapfiliate_name,
        description_i18n: i18n_key:provider_tapfiliate_description
    },
    presentation = {
        logo_light: logo_brand:tapfiliate_light,
        logo_dark: logo_brand:tapfiliate_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_tapfiliate_tooltip,
        display_order: 8160
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:tapfiliate_documentation,
            api_base: NONE,
            status_page: NONE
        },
        capabilities: {
            supports_oauth2: false,
            supports_api_key: true,
            supports_basic_auth: false,
            supports_webhooks: false,
            supports_rate_limiting: true
        },
        api_version: NONE
    },
    metadata = {
        founded_year: NONE,
        headquarters: NONE,
        industry: [],
        company_size: NONE,
        stock_symbol: NONE,
        tags: []
    },
    documentation = {
        getting_started_url: NONE,
        api_reference_url: NONE,
        sdk_urls: NONE,
        community_url: NONE
    };

CREATE provider:telegram SET
    name = "telegram",
    slug = "telegram",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_telegram_name,
        description_i18n: i18n_key:provider_telegram_description
    },
    presentation = {
        logo_light: logo_brand:telegram_light,
        logo_dark: logo_brand:telegram_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_telegram_tooltip,
        display_order: 8170
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:telegram_documentation,
            api_base: NONE,
            status_page: NONE
        },
        capabilities: {
            supports_oauth2: false,
            supports_api_key: false,
            supports_basic_auth: false,
            supports_webhooks: false,
            supports_rate_limiting: true
        },
        api_version: NONE
    },
    metadata = {
        founded_year: NONE,
        headquarters: NONE,
        industry: [],
        company_size: NONE,
        stock_symbol: NONE,
        tags: []
    },
    documentation = {
        getting_started_url: NONE,
        api_reference_url: NONE,
        sdk_urls: NONE,
        community_url: NONE
    };

CREATE provider:thehive SET
    name = "thehive",
    slug = "thehive",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_thehive_name,
        description_i18n: i18n_key:provider_thehive_description
    },
    presentation = {
        logo_light: logo_brand:thehive_light,
        logo_dark: logo_brand:thehive_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_thehive_tooltip,
        display_order: 8180
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:thehive_documentation,
            api_base: NONE,
            status_page: NONE
        },
        capabilities: {
            supports_oauth2: false,
            supports_api_key: true,
            supports_basic_auth: false,
            supports_webhooks: false,
            supports_rate_limiting: true
        },
        api_version: NONE
    },
    metadata = {
        founded_year: NONE,
        headquarters: NONE,
        industry: [],
        company_size: NONE,
        stock_symbol: NONE,
        tags: []
    },
    documentation = {
        getting_started_url: NONE,
        api_reference_url: NONE,
        sdk_urls: NONE,
        community_url: NONE
    };

CREATE provider:timescaledb SET
    name = "timescaledb",
    slug = "timescaledb",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_timescaledb_name,
        description_i18n: i18n_key:provider_timescaledb_description
    },
    presentation = {
        logo_light: logo_brand:timescaledb_light,
        logo_dark: logo_brand:timescaledb_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_timescaledb_tooltip,
        display_order: 8190
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:timescaledb_documentation,
            api_base: NONE,
            status_page: NONE
        },
        capabilities: {
            supports_oauth2: false,
            supports_api_key: false,
            supports_basic_auth: false,
            supports_webhooks: false,
            supports_rate_limiting: true
        },
        api_version: NONE
    },
    metadata = {
        founded_year: NONE,
        headquarters: NONE,
        industry: [],
        company_size: NONE,
        stock_symbol: NONE,
        tags: []
    },
    documentation = {
        getting_started_url: NONE,
        api_reference_url: NONE,
        sdk_urls: NONE,
        community_url: NONE
    };

CREATE provider:todoist SET
    name = "todoist",
    slug = "todoist",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_todoist_name,
        description_i18n: i18n_key:provider_todoist_description
    },
    presentation = {
        logo_light: logo_brand:todoist_light,
        logo_dark: logo_brand:todoist_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_todoist_tooltip,
        display_order: 8200
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:todoist_documentation,
            api_base: "https://api.todoist.com/rest/v2",
            status_page: NONE
        },
        capabilities: {
            supports_oauth2: true,
            supports_api_key: true,
            supports_basic_auth: false,
            supports_webhooks: false,
            supports_rate_limiting: true
        },
        api_version: NONE
    },
    metadata = {
        founded_year: NONE,
        headquarters: NONE,
        industry: [],
        company_size: NONE,
        stock_symbol: NONE,
        tags: []
    },
    documentation = {
        getting_started_url: NONE,
        api_reference_url: NONE,
        sdk_urls: NONE,
        community_url: NONE
    };

CREATE provider:toggl SET
    name = "toggl",
    slug = "toggl",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_toggl_name,
        description_i18n: i18n_key:provider_toggl_description
    },
    presentation = {
        logo_light: logo_brand:toggl_light,
        logo_dark: logo_brand:toggl_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_toggl_tooltip,
        display_order: 8210
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:toggl_documentation,
            api_base: "https://api.track.toggl.com/api/v9",
            status_page: NONE
        },
        capabilities: {
            supports_oauth2: false,
            supports_api_key: false,
            supports_basic_auth: false,
            supports_webhooks: false,
            supports_rate_limiting: true
        },
        api_version: NONE
    },
    metadata = {
        founded_year: NONE,
        headquarters: NONE,
        industry: [],
        company_size: NONE,
        stock_symbol: NONE,
        tags: []
    },
    documentation = {
        getting_started_url: NONE,
        api_reference_url: NONE,
        sdk_urls: NONE,
        community_url: NONE
    };

CREATE provider:travis_ci SET
    name = "travis_ci",
    slug = "travis_ci",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_travis_ci_name,
        description_i18n: i18n_key:provider_travis_ci_description
    },
    presentation = {
        logo_light: logo_brand:travis_ci_light,
        logo_dark: logo_brand:travis_ci_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_travis_ci_tooltip,
        display_order: 8220
    },
    config = {
        urls: {
            website: NONE,
            documentation: NONE,
            api_base: NONE,
            status_page: NONE
        },
        capabilities: {
            supports_oauth2: false,
            supports_api_key: true,
            supports_basic_auth: false,
            supports_webhooks: false,
            supports_rate_limiting: true
        },
        api_version: NONE
    },
    metadata = {
        founded_year: NONE,
        headquarters: NONE,
        industry: [],
        company_size: NONE,
        stock_symbol: NONE,
        tags: []
    },
    documentation = {
        getting_started_url: NONE,
        api_reference_url: NONE,
        sdk_urls: NONE,
        community_url: NONE
    };

CREATE provider:trellix SET
    name = "trellix",
    slug = "trellix",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_trellix_name,
        description_i18n: i18n_key:provider_trellix_description
    },
    presentation = {
        logo_light: logo_brand:trellix_light,
        logo_dark: logo_brand:trellix_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_trellix_tooltip,
        display_order: 8230
    },
    config = {
        urls: {
            website: NONE,
            documentation: NONE,
            api_base: NONE,
            status_page: NONE
        },
        capabilities: {
            supports_oauth2: false,
            supports_api_key: true,
            supports_basic_auth: false,
            supports_webhooks: false,
            supports_rate_limiting: true
        },
        api_version: NONE
    },
    metadata = {
        founded_year: NONE,
        headquarters: NONE,
        industry: [],
        company_size: NONE,
        stock_symbol: NONE,
        tags: []
    },
    documentation = {
        getting_started_url: NONE,
        api_reference_url: NONE,
        sdk_urls: NONE,
        community_url: NONE
    };

CREATE provider:trello SET
    name = "trello",
    slug = "trello",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_trello_name,
        description_i18n: i18n_key:provider_trello_description
    },
    presentation = {
        logo_light: logo_brand:trello_light,
        logo_dark: logo_brand:trello_dark,
        color: "#0079BF",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_trello_tooltip,
        display_order: 8240
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:trello_documentation,
            api_base: "https://api.trello.com",
            status_page: NONE
        },
        capabilities: {
            supports_oauth2: false,
            supports_api_key: true,
            supports_basic_auth: false,
            supports_webhooks: false,
            supports_rate_limiting: true
        },
        api_version: NONE
    },
    metadata = {
        founded_year: NONE,
        headquarters: NONE,
        industry: [],
        company_size: NONE,
        stock_symbol: NONE,
        tags: []
    },
    documentation = {
        getting_started_url: NONE,
        api_reference_url: NONE,
        sdk_urls: NONE,
        community_url: NONE
    };

CREATE provider:twake SET
    name = "twake",
    slug = "twake",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_twake_name,
        description_i18n: i18n_key:provider_twake_description
    },
    presentation = {
        logo_light: logo_brand:twake_light,
        logo_dark: logo_brand:twake_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_twake_tooltip,
        display_order: 8250
    },
    config = {
        urls: {
            website: NONE,
            documentation: NONE,
            api_base: NONE,
            status_page: NONE
        },
        capabilities: {
            supports_oauth2: false,
            supports_api_key: true,
            supports_basic_auth: false,
            supports_webhooks: false,
            supports_rate_limiting: true
        },
        api_version: NONE
    },
    metadata = {
        founded_year: NONE,
        headquarters: NONE,
        industry: [],
        company_size: NONE,
        stock_symbol: NONE,
        tags: []
    },
    documentation = {
        getting_started_url: NONE,
        api_reference_url: NONE,
        sdk_urls: NONE,
        community_url: NONE
    };

CREATE provider:twilio SET
    name = "twilio",
    slug = "twilio",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_twilio_name,
        description_i18n: i18n_key:provider_twilio_description
    },
    presentation = {
        logo_light: logo_brand:twilio_light,
        logo_dark: logo_brand:twilio_dark,
        color: "#F22F46",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_twilio_tooltip,
        display_order: 8260
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:twilio_documentation,
            api_base: NONE,
            status_page: NONE
        },
        capabilities: {
            supports_oauth2: false,
            supports_api_key: true,
            supports_basic_auth: false,
            supports_webhooks: false,
            supports_rate_limiting: true
        },
        api_version: NONE
    },
    metadata = {
        founded_year: NONE,
        headquarters: NONE,
        industry: [],
        company_size: NONE,
        stock_symbol: NONE,
        tags: []
    },
    documentation = {
        getting_started_url: NONE,
        api_reference_url: NONE,
        sdk_urls: NONE,
        community_url: NONE
    };

CREATE provider:twist SET
    name = "twist",
    slug = "twist",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_twist_name,
        description_i18n: i18n_key:provider_twist_description
    },
    presentation = {
        logo_light: logo_brand:twist_light,
        logo_dark: logo_brand:twist_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_twist_tooltip,
        display_order: 8270
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:twist_documentation,
            api_base: NONE,
            status_page: NONE
        },
        capabilities: {
            supports_oauth2: true,
            supports_api_key: false,
            supports_basic_auth: false,
            supports_webhooks: false,
            supports_rate_limiting: true
        },
        api_version: NONE
    },
    metadata = {
        founded_year: NONE,
        headquarters: NONE,
        industry: [],
        company_size: NONE,
        stock_symbol: NONE,
        tags: []
    },
    documentation = {
        getting_started_url: NONE,
        api_reference_url: NONE,
        sdk_urls: NONE,
        community_url: NONE
    };

CREATE provider:twitter SET
    name = "twitter",
    slug = "twitter",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_twitter_name,
        description_i18n: i18n_key:provider_twitter_description
    },
    presentation = {
        logo_light: logo_brand:twitter_light,
        logo_dark: logo_brand:twitter_dark,
        color: "#1DA1F2",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_twitter_tooltip,
        display_order: 8280
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:twitter_documentation,
            api_base: NONE,
            status_page: NONE
        },
        capabilities: {
            supports_oauth2: true,
            supports_api_key: false,
            supports_basic_auth: true,
            supports_webhooks: false,
            supports_rate_limiting: true
        },
        api_version: NONE
    },
    metadata = {
        founded_year: NONE,
        headquarters: NONE,
        industry: [],
        company_size: NONE,
        stock_symbol: NONE,
        tags: []
    },
    documentation = {
        getting_started_url: NONE,
        api_reference_url: NONE,
        sdk_urls: NONE,
        community_url: NONE
    };

CREATE provider:typeform SET
    name = "typeform",
    slug = "typeform",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_typeform_name,
        description_i18n: i18n_key:provider_typeform_description
    },
    presentation = {
        logo_light: logo_brand:typeform_light,
        logo_dark: logo_brand:typeform_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_typeform_tooltip,
        display_order: 8290
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:typeform_documentation,
            api_base: "https://api.typeform.com",
            status_page: NONE
        },
        capabilities: {
            supports_oauth2: true,
            supports_api_key: false,
            supports_basic_auth: false,
            supports_webhooks: false,
            supports_rate_limiting: true
        },
        api_version: NONE
    },
    metadata = {
        founded_year: NONE,
        headquarters: NONE,
        industry: [],
        company_size: NONE,
        stock_symbol: NONE,
        tags: []
    },
    documentation = {
        getting_started_url: NONE,
        api_reference_url: NONE,
        sdk_urls: NONE,
        community_url: NONE
    };

CREATE provider:unleashed SET
    name = "unleashed",
    slug = "unleashed",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_unleashed_name,
        description_i18n: i18n_key:provider_unleashed_description
    },
    presentation = {
        logo_light: logo_brand:unleashed_light,
        logo_dark: logo_brand:unleashed_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_unleashed_tooltip,
        display_order: 8300
    },
    config = {
        urls: {
            website: NONE,
            documentation: NONE,
            api_base: NONE,
            status_page: NONE
        },
        capabilities: {
            supports_oauth2: false,
            supports_api_key: true,
            supports_basic_auth: false,
            supports_webhooks: false,
            supports_rate_limiting: true
        },
        api_version: NONE
    },
    metadata = {
        founded_year: NONE,
        headquarters: NONE,
        industry: [],
        company_size: NONE,
        stock_symbol: NONE,
        tags: []
    },
    documentation = {
        getting_started_url: NONE,
        api_reference_url: NONE,
        sdk_urls: NONE,
        community_url: NONE
    };


