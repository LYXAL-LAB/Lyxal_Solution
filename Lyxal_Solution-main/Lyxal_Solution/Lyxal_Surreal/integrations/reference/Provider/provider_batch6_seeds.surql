-- ========================================================================
-- BATCH 6 : PROVIDERS SEEDS (30 providers) - DONNÉES COMPLÈTES N8N
-- ========================================================================
-- Date: 2025-10-29
-- Source:
--    n8n credentials (documentationUrl, baseURL, auth types)
--    Official brand colors (45+ providers)
-- ========================================================================

CREATE provider:nasa SET
    name = "nasa",
    slug = "nasa",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_nasa_name,
        description_i18n: i18n_key:provider_nasa_description
    },
    presentation = {
        logo_light: logo_brand:nasa_light,
        logo_dark: logo_brand:nasa_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_nasa_tooltip,
        display_order: 6010
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:nasa_documentation,
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

CREATE provider:netlify SET
    name = "netlify",
    slug = "netlify",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_netlify_name,
        description_i18n: i18n_key:provider_netlify_description
    },
    presentation = {
        logo_light: logo_brand:netlify_light,
        logo_dark: logo_brand:netlify_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_netlify_tooltip,
        display_order: 6020
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:netlify_documentation,
            api_base: "https://api.netlify.com",
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

CREATE provider:nextcloud SET
    name = "nextcloud",
    slug = "nextcloud",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_nextcloud_name,
        description_i18n: i18n_key:provider_nextcloud_description
    },
    presentation = {
        logo_light: logo_brand:nextcloud_light,
        logo_dark: logo_brand:nextcloud_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_nextcloud_tooltip,
        display_order: 6030
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:nextcloud_documentation,
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

CREATE provider:nocodb SET
    name = "nocodb",
    slug = "nocodb",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_nocodb_name,
        description_i18n: i18n_key:provider_nocodb_description
    },
    presentation = {
        logo_light: logo_brand:nocodb_light,
        logo_dark: logo_brand:nocodb_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_nocodb_tooltip,
        display_order: 6040
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:nocodb_documentation,
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

CREATE provider:notion SET
    name = "notion",
    slug = "notion",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_notion_name,
        description_i18n: i18n_key:provider_notion_description
    },
    presentation = {
        logo_light: logo_brand:notion_light,
        logo_dark: logo_brand:notion_dark,
        color: "#000000",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_notion_tooltip,
        display_order: 6050
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:notion_documentation,
            api_base: "https://api.notion.com/v1",
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

CREATE provider:npm SET
    name = "npm",
    slug = "npm",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_npm_name,
        description_i18n: i18n_key:provider_npm_description
    },
    presentation = {
        logo_light: logo_brand:npm_light,
        logo_dark: logo_brand:npm_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_npm_tooltip,
        display_order: 6060
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:npm_documentation,
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

CREATE provider:odoo SET
    name = "odoo",
    slug = "odoo",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_odoo_name,
        description_i18n: i18n_key:provider_odoo_description
    },
    presentation = {
        logo_light: logo_brand:odoo_light,
        logo_dark: logo_brand:odoo_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_odoo_tooltip,
        display_order: 6070
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:odoo_documentation,
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

CREATE provider:okta SET
    name = "okta",
    slug = "okta",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_okta_name,
        description_i18n: i18n_key:provider_okta_description
    },
    presentation = {
        logo_light: logo_brand:okta_light,
        logo_dark: logo_brand:okta_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_okta_tooltip,
        display_order: 6080
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:okta_documentation,
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

CREATE provider:onesimpleapi SET
    name = "onesimpleapi",
    slug = "onesimpleapi",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_onesimpleapi_name,
        description_i18n: i18n_key:provider_onesimpleapi_description
    },
    presentation = {
        logo_light: logo_brand:onesimpleapi_light,
        logo_dark: logo_brand:onesimpleapi_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_onesimpleapi_tooltip,
        display_order: 6090
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

CREATE provider:onfleet SET
    name = "onfleet",
    slug = "onfleet",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_onfleet_name,
        description_i18n: i18n_key:provider_onfleet_description
    },
    presentation = {
        logo_light: logo_brand:onfleet_light,
        logo_dark: logo_brand:onfleet_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_onfleet_tooltip,
        display_order: 6100
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:onfleet_documentation,
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

CREATE provider:openai SET
    name = "openai",
    slug = "openai",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_openai_name,
        description_i18n: i18n_key:provider_openai_description
    },
    presentation = {
        logo_light: logo_brand:openai_light,
        logo_dark: logo_brand:openai_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_openai_tooltip,
        display_order: 6110
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:openai_documentation,
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

CREATE provider:opencti SET
    name = "opencti",
    slug = "opencti",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_opencti_name,
        description_i18n: i18n_key:provider_opencti_description
    },
    presentation = {
        logo_light: logo_brand:opencti_light,
        logo_dark: logo_brand:opencti_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_opencti_tooltip,
        display_order: 6120
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:opencti_documentation,
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

CREATE provider:openweathermap SET
    name = "openweathermap",
    slug = "openweathermap",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_openweathermap_name,
        description_i18n: i18n_key:provider_openweathermap_description
    },
    presentation = {
        logo_light: logo_brand:openweathermap_light,
        logo_dark: logo_brand:openweathermap_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_openweathermap_tooltip,
        display_order: 6130
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:openweathermap_documentation,
            api_base: "https://api.openweathermap.org/data/2.5",
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

CREATE provider:oracle SET
    name = "oracle",
    slug = "oracle",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_oracle_name,
        description_i18n: i18n_key:provider_oracle_description
    },
    presentation = {
        logo_light: logo_brand:oracle_light,
        logo_dark: logo_brand:oracle_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_oracle_tooltip,
        display_order: 6140
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

CREATE provider:orbit SET
    name = "orbit",
    slug = "orbit",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_orbit_name,
        description_i18n: i18n_key:provider_orbit_description
    },
    presentation = {
        logo_light: logo_brand:orbit_light,
        logo_dark: logo_brand:orbit_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_orbit_tooltip,
        display_order: 6150
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:orbit_documentation,
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

CREATE provider:oura SET
    name = "oura",
    slug = "oura",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_oura_name,
        description_i18n: i18n_key:provider_oura_description
    },
    presentation = {
        logo_light: logo_brand:oura_light,
        logo_dark: logo_brand:oura_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_oura_tooltip,
        display_order: 6160
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:oura_documentation,
            api_base: "https://api.ouraring.com",
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

CREATE provider:paddle SET
    name = "paddle",
    slug = "paddle",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_paddle_name,
        description_i18n: i18n_key:provider_paddle_description
    },
    presentation = {
        logo_light: logo_brand:paddle_light,
        logo_dark: logo_brand:paddle_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_paddle_tooltip,
        display_order: 6170
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:paddle_documentation,
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

CREATE provider:pagerduty SET
    name = "pagerduty",
    slug = "pagerduty",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_pagerduty_name,
        description_i18n: i18n_key:provider_pagerduty_description
    },
    presentation = {
        logo_light: logo_brand:pagerduty_light,
        logo_dark: logo_brand:pagerduty_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_pagerduty_tooltip,
        display_order: 6180
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:pagerduty_documentation,
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

CREATE provider:paypal SET
    name = "paypal",
    slug = "paypal",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_paypal_name,
        description_i18n: i18n_key:provider_paypal_description
    },
    presentation = {
        logo_light: logo_brand:paypal_light,
        logo_dark: logo_brand:paypal_dark,
        color: "#00457C",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_paypal_tooltip,
        display_order: 6190
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:paypal_documentation,
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

CREATE provider:peekalink SET
    name = "peekalink",
    slug = "peekalink",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_peekalink_name,
        description_i18n: i18n_key:provider_peekalink_description
    },
    presentation = {
        logo_light: logo_brand:peekalink_light,
        logo_dark: logo_brand:peekalink_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_peekalink_tooltip,
        display_order: 6200
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:peekalink_documentation,
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

CREATE provider:perplexity SET
    name = "perplexity",
    slug = "perplexity",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_perplexity_name,
        description_i18n: i18n_key:provider_perplexity_description
    },
    presentation = {
        logo_light: logo_brand:perplexity_light,
        logo_dark: logo_brand:perplexity_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_perplexity_tooltip,
        display_order: 6210
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:perplexity_documentation,
            api_base: "https://api.perplexity.ai",
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

CREATE provider:phantombuster SET
    name = "phantombuster",
    slug = "phantombuster",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_phantombuster_name,
        description_i18n: i18n_key:provider_phantombuster_description
    },
    presentation = {
        logo_light: logo_brand:phantombuster_light,
        logo_dark: logo_brand:phantombuster_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_phantombuster_tooltip,
        display_order: 6220
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:phantombuster_documentation,
            api_base: "https://api.phantombuster.com/api/v2",
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

CREATE provider:philipshue SET
    name = "philipshue",
    slug = "philipshue",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_philipshue_name,
        description_i18n: i18n_key:provider_philipshue_description
    },
    presentation = {
        logo_light: logo_brand:philipshue_light,
        logo_dark: logo_brand:philipshue_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_philipshue_tooltip,
        display_order: 6230
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:philipshue_documentation,
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

CREATE provider:pipedrive SET
    name = "pipedrive",
    slug = "pipedrive",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_pipedrive_name,
        description_i18n: i18n_key:provider_pipedrive_description
    },
    presentation = {
        logo_light: logo_brand:pipedrive_light,
        logo_dark: logo_brand:pipedrive_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_pipedrive_tooltip,
        display_order: 6240
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:pipedrive_documentation,
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

CREATE provider:plivo SET
    name = "plivo",
    slug = "plivo",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_plivo_name,
        description_i18n: i18n_key:provider_plivo_description
    },
    presentation = {
        logo_light: logo_brand:plivo_light,
        logo_dark: logo_brand:plivo_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_plivo_tooltip,
        display_order: 6250
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:plivo_documentation,
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

CREATE provider:postgres SET
    name = "postgres",
    slug = "postgres",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_postgres_name,
        description_i18n: i18n_key:provider_postgres_description
    },
    presentation = {
        logo_light: logo_brand:postgres_light,
        logo_dark: logo_brand:postgres_dark,
        color: "#336791",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_postgres_tooltip,
        display_order: 6260
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:postgres_documentation,
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

CREATE provider:posthog SET
    name = "posthog",
    slug = "posthog",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_posthog_name,
        description_i18n: i18n_key:provider_posthog_description
    },
    presentation = {
        logo_light: logo_brand:posthog_light,
        logo_dark: logo_brand:posthog_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_posthog_tooltip,
        display_order: 6270
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:posthog_documentation,
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

CREATE provider:postmark SET
    name = "postmark",
    slug = "postmark",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_postmark_name,
        description_i18n: i18n_key:provider_postmark_description
    },
    presentation = {
        logo_light: logo_brand:postmark_light,
        logo_dark: logo_brand:postmark_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_postmark_tooltip,
        display_order: 6280
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:postmark_documentation,
            api_base: "https://api.postmarkapp.com",
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

CREATE provider:profitwell SET
    name = "profitwell",
    slug = "profitwell",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_profitwell_name,
        description_i18n: i18n_key:provider_profitwell_description
    },
    presentation = {
        logo_light: logo_brand:profitwell_light,
        logo_dark: logo_brand:profitwell_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_profitwell_tooltip,
        display_order: 6290
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:profitwell_documentation,
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

CREATE provider:pushbullet SET
    name = "pushbullet",
    slug = "pushbullet",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_pushbullet_name,
        description_i18n: i18n_key:provider_pushbullet_description
    },
    presentation = {
        logo_light: logo_brand:pushbullet_light,
        logo_dark: logo_brand:pushbullet_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_pushbullet_tooltip,
        display_order: 6300
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:pushbullet_documentation,
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


