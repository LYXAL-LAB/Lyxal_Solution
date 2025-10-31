-- ========================================================================
-- BATCH 7 : PROVIDERS SEEDS (30 providers) - DONNÉES COMPLÈTES N8N
-- ========================================================================
-- Date: 2025-10-29
-- Source:
--    n8n credentials (documentationUrl, baseURL, auth types)
--    Official brand colors (45+ providers)
-- ========================================================================

CREATE provider:pushcut SET
    name = "pushcut",
    slug = "pushcut",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_pushcut_name,
        description_i18n: i18n_key:provider_pushcut_description
    },
    presentation = {
        logo_light: logo_brand:pushcut_light,
        logo_dark: logo_brand:pushcut_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_pushcut_tooltip,
        display_order: 7010
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:pushcut_documentation,
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

CREATE provider:pushover SET
    name = "pushover",
    slug = "pushover",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_pushover_name,
        description_i18n: i18n_key:provider_pushover_description
    },
    presentation = {
        logo_light: logo_brand:pushover_light,
        logo_dark: logo_brand:pushover_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_pushover_tooltip,
        display_order: 7020
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:pushover_documentation,
            api_base: "https://api.pushover.net/1",
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

CREATE provider:qualys SET
    name = "qualys",
    slug = "qualys",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_qualys_name,
        description_i18n: i18n_key:provider_qualys_description
    },
    presentation = {
        logo_light: logo_brand:qualys_light,
        logo_dark: logo_brand:qualys_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_qualys_tooltip,
        display_order: 7030
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:qualys_documentation,
            api_base: "https://qualysapi.qualys.com/api/",
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

CREATE provider:questdb SET
    name = "questdb",
    slug = "questdb",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_questdb_name,
        description_i18n: i18n_key:provider_questdb_description
    },
    presentation = {
        logo_light: logo_brand:questdb_light,
        logo_dark: logo_brand:questdb_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_questdb_tooltip,
        display_order: 7040
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:questdb_documentation,
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

CREATE provider:quickbase SET
    name = "quickbase",
    slug = "quickbase",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_quickbase_name,
        description_i18n: i18n_key:provider_quickbase_description
    },
    presentation = {
        logo_light: logo_brand:quickbase_light,
        logo_dark: logo_brand:quickbase_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_quickbase_tooltip,
        display_order: 7050
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:quickbase_documentation,
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

CREATE provider:quickbooks SET
    name = "quickbooks",
    slug = "quickbooks",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_quickbooks_name,
        description_i18n: i18n_key:provider_quickbooks_description
    },
    presentation = {
        logo_light: logo_brand:quickbooks_light,
        logo_dark: logo_brand:quickbooks_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_quickbooks_tooltip,
        display_order: 7060
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:quickbooks_documentation,
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

CREATE provider:rabbitmq SET
    name = "rabbitmq",
    slug = "rabbitmq",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_rabbitmq_name,
        description_i18n: i18n_key:provider_rabbitmq_description
    },
    presentation = {
        logo_light: logo_brand:rabbitmq_light,
        logo_dark: logo_brand:rabbitmq_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_rabbitmq_tooltip,
        display_order: 7070
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:rabbitmq_documentation,
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

CREATE provider:raindrop SET
    name = "raindrop",
    slug = "raindrop",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_raindrop_name,
        description_i18n: i18n_key:provider_raindrop_description
    },
    presentation = {
        logo_light: logo_brand:raindrop_light,
        logo_dark: logo_brand:raindrop_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_raindrop_tooltip,
        display_order: 7080
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:raindrop_documentation,
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

CREATE provider:rapid7 SET
    name = "rapid7",
    slug = "rapid7",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_rapid7_name,
        description_i18n: i18n_key:provider_rapid7_description
    },
    presentation = {
        logo_light: logo_brand:rapid7_light,
        logo_dark: logo_brand:rapid7_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_rapid7_tooltip,
        display_order: 7090
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

CREATE provider:recordedfuture SET
    name = "recordedfuture",
    slug = "recordedfuture",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_recordedfuture_name,
        description_i18n: i18n_key:provider_recordedfuture_description
    },
    presentation = {
        logo_light: logo_brand:recordedfuture_light,
        logo_dark: logo_brand:recordedfuture_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_recordedfuture_tooltip,
        display_order: 7100
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:recordedfuture_documentation,
            api_base: "https://api.recordedfuture.com/v2/",
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

CREATE provider:reddit SET
    name = "reddit",
    slug = "reddit",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_reddit_name,
        description_i18n: i18n_key:provider_reddit_description
    },
    presentation = {
        logo_light: logo_brand:reddit_light,
        logo_dark: logo_brand:reddit_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_reddit_tooltip,
        display_order: 7110
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:reddit_documentation,
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

CREATE provider:redis SET
    name = "redis",
    slug = "redis",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_redis_name,
        description_i18n: i18n_key:provider_redis_description
    },
    presentation = {
        logo_light: logo_brand:redis_light,
        logo_dark: logo_brand:redis_dark,
        color: "#DC382D",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_redis_tooltip,
        display_order: 7120
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:redis_documentation,
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

CREATE provider:rocketchat SET
    name = "rocketchat",
    slug = "rocketchat",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_rocketchat_name,
        description_i18n: i18n_key:provider_rocketchat_description
    },
    presentation = {
        logo_light: logo_brand:rocketchat_light,
        logo_dark: logo_brand:rocketchat_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_rocketchat_tooltip,
        display_order: 7130
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:rocketchat_documentation,
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

CREATE provider:rundeck SET
    name = "rundeck",
    slug = "rundeck",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_rundeck_name,
        description_i18n: i18n_key:provider_rundeck_description
    },
    presentation = {
        logo_light: logo_brand:rundeck_light,
        logo_dark: logo_brand:rundeck_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_rundeck_tooltip,
        display_order: 7140
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:rundeck_documentation,
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

CREATE provider:salesforce SET
    name = "salesforce",
    slug = "salesforce",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_salesforce_name,
        description_i18n: i18n_key:provider_salesforce_description
    },
    presentation = {
        logo_light: logo_brand:salesforce_light,
        logo_dark: logo_brand:salesforce_dark,
        color: "#00A1E0",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_salesforce_tooltip,
        display_order: 7150
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:salesforce_documentation,
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

CREATE provider:salesmate SET
    name = "salesmate",
    slug = "salesmate",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_salesmate_name,
        description_i18n: i18n_key:provider_salesmate_description
    },
    presentation = {
        logo_light: logo_brand:salesmate_light,
        logo_dark: logo_brand:salesmate_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_salesmate_tooltip,
        display_order: 7160
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:salesmate_documentation,
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

CREATE provider:seatable SET
    name = "seatable",
    slug = "seatable",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_seatable_name,
        description_i18n: i18n_key:provider_seatable_description
    },
    presentation = {
        logo_light: logo_brand:seatable_light,
        logo_dark: logo_brand:seatable_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_seatable_tooltip,
        display_order: 7170
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:seatable_documentation,
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

CREATE provider:securityscorecard SET
    name = "securityscorecard",
    slug = "securityscorecard",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_securityscorecard_name,
        description_i18n: i18n_key:provider_securityscorecard_description
    },
    presentation = {
        logo_light: logo_brand:securityscorecard_light,
        logo_dark: logo_brand:securityscorecard_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_securityscorecard_tooltip,
        display_order: 7180
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:securityscorecard_documentation,
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

CREATE provider:segment SET
    name = "segment",
    slug = "segment",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_segment_name,
        description_i18n: i18n_key:provider_segment_description
    },
    presentation = {
        logo_light: logo_brand:segment_light,
        logo_dark: logo_brand:segment_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_segment_tooltip,
        display_order: 7190
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:segment_documentation,
            api_base: NONE,
            status_page: NONE
        },
        capabilities: {
            supports_oauth2: false,
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

CREATE provider:sekoia SET
    name = "sekoia",
    slug = "sekoia",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_sekoia_name,
        description_i18n: i18n_key:provider_sekoia_description
    },
    presentation = {
        logo_light: logo_brand:sekoia_light,
        logo_dark: logo_brand:sekoia_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_sekoia_tooltip,
        display_order: 7200
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:sekoia_documentation,
            api_base: "https://api.sekoia.io/",
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

CREATE provider:sendgrid SET
    name = "sendgrid",
    slug = "sendgrid",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_sendgrid_name,
        description_i18n: i18n_key:provider_sendgrid_description
    },
    presentation = {
        logo_light: logo_brand:sendgrid_light,
        logo_dark: logo_brand:sendgrid_dark,
        color: "#1A82E2",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_sendgrid_tooltip,
        display_order: 7210
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:sendgrid_documentation,
            api_base: "https://api.sendgrid.com/v3",
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

CREATE provider:sendy SET
    name = "sendy",
    slug = "sendy",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_sendy_name,
        description_i18n: i18n_key:provider_sendy_description
    },
    presentation = {
        logo_light: logo_brand:sendy_light,
        logo_dark: logo_brand:sendy_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_sendy_tooltip,
        display_order: 7220
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:sendy_documentation,
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

CREATE provider:sentry SET
    name = "sentry",
    slug = "sentry",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_sentry_name,
        description_i18n: i18n_key:provider_sentry_description
    },
    presentation = {
        logo_light: logo_brand:sentry_light,
        logo_dark: logo_brand:sentry_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_sentry_tooltip,
        display_order: 7230
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

CREATE provider:servicenow SET
    name = "servicenow",
    slug = "servicenow",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_servicenow_name,
        description_i18n: i18n_key:provider_servicenow_description
    },
    presentation = {
        logo_light: logo_brand:servicenow_light,
        logo_dark: logo_brand:servicenow_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_servicenow_tooltip,
        display_order: 7240
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:servicenow_documentation,
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

CREATE provider:shopify SET
    name = "shopify",
    slug = "shopify",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_shopify_name,
        description_i18n: i18n_key:provider_shopify_description
    },
    presentation = {
        logo_light: logo_brand:shopify_light,
        logo_dark: logo_brand:shopify_dark,
        color: "#96BF48",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_shopify_tooltip,
        display_order: 7250
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:shopify_documentation,
            api_base: NONE,
            status_page: NONE
        },
        capabilities: {
            supports_oauth2: true,
            supports_api_key: true,
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

CREATE provider:shuffler SET
    name = "shuffler",
    slug = "shuffler",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_shuffler_name,
        description_i18n: i18n_key:provider_shuffler_description
    },
    presentation = {
        logo_light: logo_brand:shuffler_light,
        logo_dark: logo_brand:shuffler_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_shuffler_tooltip,
        display_order: 7260
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:shuffler_documentation,
            api_base: "https://shuffler.io/api/v1/",
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

CREATE provider:signl4 SET
    name = "signl4",
    slug = "signl4",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_signl4_name,
        description_i18n: i18n_key:provider_signl4_description
    },
    presentation = {
        logo_light: logo_brand:signl4_light,
        logo_dark: logo_brand:signl4_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_signl4_tooltip,
        display_order: 7270
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:signl4_documentation,
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

CREATE provider:slack SET
    name = "slack",
    slug = "slack",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_slack_name,
        description_i18n: i18n_key:provider_slack_description
    },
    presentation = {
        logo_light: logo_brand:slack_light,
        logo_dark: logo_brand:slack_dark,
        color: "#4A154B",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_slack_tooltip,
        display_order: 7280
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:slack_documentation,
            api_base: "https://slack.com",
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

CREATE provider:sms77 SET
    name = "sms77",
    slug = "sms77",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_sms77_name,
        description_i18n: i18n_key:provider_sms77_description
    },
    presentation = {
        logo_light: logo_brand:sms77_light,
        logo_dark: logo_brand:sms77_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_sms77_tooltip,
        display_order: 7290
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:sms77_documentation,
            api_base: "https://gateway.seven.io/api",
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

CREATE provider:smtp SET
    name = "smtp",
    slug = "smtp",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_smtp_name,
        description_i18n: i18n_key:provider_smtp_description
    },
    presentation = {
        logo_light: logo_brand:smtp_light,
        logo_dark: logo_brand:smtp_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_smtp_tooltip,
        display_order: 7300
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:smtp_documentation,
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


