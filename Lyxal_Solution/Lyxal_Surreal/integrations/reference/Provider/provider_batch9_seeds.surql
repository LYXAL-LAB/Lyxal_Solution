-- ========================================================================
-- BATCH 9 : PROVIDERS SEEDS (26 providers) - DONNÉES COMPLÈTES N8N
-- ========================================================================
-- Date: 2025-10-29
-- Source:
--    n8n credentials (documentationUrl, baseURL, auth types)
--    Official brand colors (45+ providers)
-- ========================================================================

CREATE provider:uplead SET
    name = "uplead",
    slug = "uplead",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_uplead_name,
        description_i18n: i18n_key:provider_uplead_description
    },
    presentation = {
        logo_light: logo_brand:uplead_light,
        logo_dark: logo_brand:uplead_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_uplead_tooltip,
        display_order: 9010
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:uplead_documentation,
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

CREATE provider:uproc SET
    name = "uproc",
    slug = "uproc",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_uproc_name,
        description_i18n: i18n_key:provider_uproc_description
    },
    presentation = {
        logo_light: logo_brand:uproc_light,
        logo_dark: logo_brand:uproc_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_uproc_tooltip,
        display_order: 9020
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:uproc_documentation,
            api_base: "https://api.uproc.io/api/v2",
            status_page: NONE
        },
        capabilities: {
            supports_oauth2: false,
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

CREATE provider:uptimerobot SET
    name = "uptimerobot",
    slug = "uptimerobot",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_uptimerobot_name,
        description_i18n: i18n_key:provider_uptimerobot_description
    },
    presentation = {
        logo_light: logo_brand:uptimerobot_light,
        logo_dark: logo_brand:uptimerobot_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_uptimerobot_tooltip,
        display_order: 9030
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:uptimerobot_documentation,
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

CREATE provider:urlscan SET
    name = "urlscan",
    slug = "urlscan",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_urlscan_name,
        description_i18n: i18n_key:provider_urlscan_description
    },
    presentation = {
        logo_light: logo_brand:urlscan_light,
        logo_dark: logo_brand:urlscan_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_urlscan_tooltip,
        display_order: 9040
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

CREATE provider:venafi SET
    name = "venafi",
    slug = "venafi",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_venafi_name,
        description_i18n: i18n_key:provider_venafi_description
    },
    presentation = {
        logo_light: logo_brand:venafi_light,
        logo_dark: logo_brand:venafi_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_venafi_tooltip,
        display_order: 9050
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

CREATE provider:vero SET
    name = "vero",
    slug = "vero",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_vero_name,
        description_i18n: i18n_key:provider_vero_description
    },
    presentation = {
        logo_light: logo_brand:vero_light,
        logo_dark: logo_brand:vero_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_vero_tooltip,
        display_order: 9060
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:vero_documentation,
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

CREATE provider:vertica SET
    name = "vertica",
    slug = "vertica",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_vertica_name,
        description_i18n: i18n_key:provider_vertica_description
    },
    presentation = {
        logo_light: logo_brand:vertica_light,
        logo_dark: logo_brand:vertica_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_vertica_tooltip,
        display_order: 9070
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:vertica_documentation,
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

CREATE provider:virustotal SET
    name = "virustotal",
    slug = "virustotal",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_virustotal_name,
        description_i18n: i18n_key:provider_virustotal_description
    },
    presentation = {
        logo_light: logo_brand:virustotal_light,
        logo_dark: logo_brand:virustotal_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_virustotal_tooltip,
        display_order: 9080
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:virustotal_documentation,
            api_base: "https://www.virustotal.com/api/v3/",
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

CREATE provider:vonage SET
    name = "vonage",
    slug = "vonage",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_vonage_name,
        description_i18n: i18n_key:provider_vonage_description
    },
    presentation = {
        logo_light: logo_brand:vonage_light,
        logo_dark: logo_brand:vonage_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_vonage_tooltip,
        display_order: 9090
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:vonage_documentation,
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

CREATE provider:webflow SET
    name = "webflow",
    slug = "webflow",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_webflow_name,
        description_i18n: i18n_key:provider_webflow_description
    },
    presentation = {
        logo_light: logo_brand:webflow_light,
        logo_dark: logo_brand:webflow_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_webflow_tooltip,
        display_order: 9100
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:webflow_documentation,
            api_base: "https://api.webflow.com",
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

CREATE provider:wekan SET
    name = "wekan",
    slug = "wekan",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_wekan_name,
        description_i18n: i18n_key:provider_wekan_description
    },
    presentation = {
        logo_light: logo_brand:wekan_light,
        logo_dark: logo_brand:wekan_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_wekan_tooltip,
        display_order: 9110
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:wekan_documentation,
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

CREATE provider:whatsapp SET
    name = "whatsapp",
    slug = "whatsapp",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_whatsapp_name,
        description_i18n: i18n_key:provider_whatsapp_description
    },
    presentation = {
        logo_light: logo_brand:whatsapp_light,
        logo_dark: logo_brand:whatsapp_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_whatsapp_tooltip,
        display_order: 9120
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:whatsapp_documentation,
            api_base: "https://graph.facebook.com/v13.0",
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

CREATE provider:wise SET
    name = "wise",
    slug = "wise",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_wise_name,
        description_i18n: i18n_key:provider_wise_description
    },
    presentation = {
        logo_light: logo_brand:wise_light,
        logo_dark: logo_brand:wise_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_wise_tooltip,
        display_order: 9130
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:wise_documentation,
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

CREATE provider:woocommerce SET
    name = "woocommerce",
    slug = "woocommerce",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_woocommerce_name,
        description_i18n: i18n_key:provider_woocommerce_description
    },
    presentation = {
        logo_light: logo_brand:woocommerce_light,
        logo_dark: logo_brand:woocommerce_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_woocommerce_tooltip,
        display_order: 9140
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:woocommerce_documentation,
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

CREATE provider:wordpress SET
    name = "wordpress",
    slug = "wordpress",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_wordpress_name,
        description_i18n: i18n_key:provider_wordpress_description
    },
    presentation = {
        logo_light: logo_brand:wordpress_light,
        logo_dark: logo_brand:wordpress_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_wordpress_tooltip,
        display_order: 9150
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:wordpress_documentation,
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

CREATE provider:workable SET
    name = "workable",
    slug = "workable",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_workable_name,
        description_i18n: i18n_key:provider_workable_description
    },
    presentation = {
        logo_light: logo_brand:workable_light,
        logo_dark: logo_brand:workable_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_workable_tooltip,
        display_order: 9160
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:workable_documentation,
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

CREATE provider:wufoo SET
    name = "wufoo",
    slug = "wufoo",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_wufoo_name,
        description_i18n: i18n_key:provider_wufoo_description
    },
    presentation = {
        logo_light: logo_brand:wufoo_light,
        logo_dark: logo_brand:wufoo_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_wufoo_tooltip,
        display_order: 9170
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:wufoo_documentation,
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

CREATE provider:xero SET
    name = "xero",
    slug = "xero",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_xero_name,
        description_i18n: i18n_key:provider_xero_description
    },
    presentation = {
        logo_light: logo_brand:xero_light,
        logo_dark: logo_brand:xero_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_xero_tooltip,
        display_order: 9180
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:xero_documentation,
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

CREATE provider:yourls SET
    name = "yourls",
    slug = "yourls",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_yourls_name,
        description_i18n: i18n_key:provider_yourls_description
    },
    presentation = {
        logo_light: logo_brand:yourls_light,
        logo_dark: logo_brand:yourls_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_yourls_tooltip,
        display_order: 9190
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:yourls_documentation,
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

CREATE provider:zabbix SET
    name = "zabbix",
    slug = "zabbix",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_zabbix_name,
        description_i18n: i18n_key:provider_zabbix_description
    },
    presentation = {
        logo_light: logo_brand:zabbix_light,
        logo_dark: logo_brand:zabbix_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_zabbix_tooltip,
        display_order: 9200
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:zabbix_documentation,
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

CREATE provider:zammad SET
    name = "zammad",
    slug = "zammad",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_zammad_name,
        description_i18n: i18n_key:provider_zammad_description
    },
    presentation = {
        logo_light: logo_brand:zammad_light,
        logo_dark: logo_brand:zammad_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_zammad_tooltip,
        display_order: 9210
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

CREATE provider:zendesk SET
    name = "zendesk",
    slug = "zendesk",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_zendesk_name,
        description_i18n: i18n_key:provider_zendesk_description
    },
    presentation = {
        logo_light: logo_brand:zendesk_light,
        logo_dark: logo_brand:zendesk_dark,
        color: "#03363D",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_zendesk_tooltip,
        display_order: 9220
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:zendesk_documentation,
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

CREATE provider:zoho SET
    name = "zoho",
    slug = "zoho",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_zoho_name,
        description_i18n: i18n_key:provider_zoho_description
    },
    presentation = {
        logo_light: logo_brand:zoho_light,
        logo_dark: logo_brand:zoho_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_zoho_tooltip,
        display_order: 9230
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:zoho_documentation,
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

CREATE provider:zoom SET
    name = "zoom",
    slug = "zoom",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_zoom_name,
        description_i18n: i18n_key:provider_zoom_description
    },
    presentation = {
        logo_light: logo_brand:zoom_light,
        logo_dark: logo_brand:zoom_dark,
        color: "#2D8CFF",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_zoom_tooltip,
        display_order: 9240
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:zoom_documentation,
            api_base: "https://api.zoom.us/v2",
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

CREATE provider:zscaler SET
    name = "zscaler",
    slug = "zscaler",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_zscaler_name,
        description_i18n: i18n_key:provider_zscaler_description
    },
    presentation = {
        logo_light: logo_brand:zscaler_light,
        logo_dark: logo_brand:zscaler_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_zscaler_tooltip,
        display_order: 9250
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

CREATE provider:zulip SET
    name = "zulip",
    slug = "zulip",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_zulip_name,
        description_i18n: i18n_key:provider_zulip_description
    },
    presentation = {
        logo_light: logo_brand:zulip_light,
        logo_dark: logo_brand:zulip_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_zulip_tooltip,
        display_order: 9260
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:zulip_documentation,
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


