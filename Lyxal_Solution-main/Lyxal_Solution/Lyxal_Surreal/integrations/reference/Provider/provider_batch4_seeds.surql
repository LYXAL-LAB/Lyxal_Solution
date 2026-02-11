-- ========================================================================
-- BATCH 4 : PROVIDERS SEEDS (30 providers) - DONNÉES COMPLÈTES N8N
-- ========================================================================
-- Date: 2025-10-29
-- Source:
--    n8n credentials (documentationUrl, baseURL, auth types)
--    Official brand colors (45+ providers)
-- ========================================================================

CREATE provider:grafana SET
    name = "grafana",
    slug = "grafana",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_grafana_name,
        description_i18n: i18n_key:provider_grafana_description
    },
    presentation = {
        logo_light: logo_brand:grafana_light,
        logo_dark: logo_brand:grafana_dark,
        color: "#F46800",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_grafana_tooltip,
        display_order: 4010
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:grafana_documentation,
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

CREATE provider:grist SET
    name = "grist",
    slug = "grist",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_grist_name,
        description_i18n: i18n_key:provider_grist_description
    },
    presentation = {
        logo_light: logo_brand:grist_light,
        logo_dark: logo_brand:grist_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_grist_tooltip,
        display_order: 4020
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:grist_documentation,
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

CREATE provider:gumroad SET
    name = "gumroad",
    slug = "gumroad",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_gumroad_name,
        description_i18n: i18n_key:provider_gumroad_description
    },
    presentation = {
        logo_light: logo_brand:gumroad_light,
        logo_dark: logo_brand:gumroad_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_gumroad_tooltip,
        display_order: 4030
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:gumroad_documentation,
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

CREATE provider:halopsa SET
    name = "halopsa",
    slug = "halopsa",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_halopsa_name,
        description_i18n: i18n_key:provider_halopsa_description
    },
    presentation = {
        logo_light: logo_brand:halopsa_light,
        logo_dark: logo_brand:halopsa_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_halopsa_tooltip,
        display_order: 4040
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:halopsa_documentation,
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

CREATE provider:harvest SET
    name = "harvest",
    slug = "harvest",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_harvest_name,
        description_i18n: i18n_key:provider_harvest_description
    },
    presentation = {
        logo_light: logo_brand:harvest_light,
        logo_dark: logo_brand:harvest_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_harvest_tooltip,
        display_order: 4050
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:harvest_documentation,
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

CREATE provider:helpscout SET
    name = "helpscout",
    slug = "helpscout",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_helpscout_name,
        description_i18n: i18n_key:provider_helpscout_description
    },
    presentation = {
        logo_light: logo_brand:helpscout_light,
        logo_dark: logo_brand:helpscout_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_helpscout_tooltip,
        display_order: 4060
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:helpscout_documentation,
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

CREATE provider:highlevel SET
    name = "highlevel",
    slug = "highlevel",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_highlevel_name,
        description_i18n: i18n_key:provider_highlevel_description
    },
    presentation = {
        logo_light: logo_brand:highlevel_light,
        logo_dark: logo_brand:highlevel_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_highlevel_tooltip,
        display_order: 4070
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:highlevel_documentation,
            api_base: "https://rest.gohighlevel.com/v1",
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

CREATE provider:homeassistant SET
    name = "homeassistant",
    slug = "homeassistant",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_homeassistant_name,
        description_i18n: i18n_key:provider_homeassistant_description
    },
    presentation = {
        logo_light: logo_brand:homeassistant_light,
        logo_dark: logo_brand:homeassistant_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_homeassistant_tooltip,
        display_order: 4080
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:homeassistant_documentation,
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

CREATE provider:hubspot SET
    name = "hubspot",
    slug = "hubspot",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_hubspot_name,
        description_i18n: i18n_key:provider_hubspot_description
    },
    presentation = {
        logo_light: logo_brand:hubspot_light,
        logo_dark: logo_brand:hubspot_dark,
        color: "#FF7A59",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_hubspot_tooltip,
        display_order: 4090
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:hubspot_documentation,
            api_base: "https://api.hubapi.com",
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

CREATE provider:humantic SET
    name = "humantic",
    slug = "humantic",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_humantic_name,
        description_i18n: i18n_key:provider_humantic_description
    },
    presentation = {
        logo_light: logo_brand:humantic_light,
        logo_dark: logo_brand:humantic_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_humantic_tooltip,
        display_order: 4100
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

CREATE provider:hunter SET
    name = "hunter",
    slug = "hunter",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_hunter_name,
        description_i18n: i18n_key:provider_hunter_description
    },
    presentation = {
        logo_light: logo_brand:hunter_light,
        logo_dark: logo_brand:hunter_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_hunter_tooltip,
        display_order: 4110
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:hunter_documentation,
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

CREATE provider:hybridanalysis SET
    name = "hybridanalysis",
    slug = "hybridanalysis",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_hybridanalysis_name,
        description_i18n: i18n_key:provider_hybridanalysis_description
    },
    presentation = {
        logo_light: logo_brand:hybridanalysis_light,
        logo_dark: logo_brand:hybridanalysis_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_hybridanalysis_tooltip,
        display_order: 4120
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:hybridanalysis_documentation,
            api_base: "https://www.hybrid-analysis.com/api/",
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

CREATE provider:ibm SET
    name = "ibm",
    slug = "ibm",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_ibm_name,
        description_i18n: i18n_key:provider_ibm_description
    },
    presentation = {
        logo_light: logo_brand:ibm_light,
        logo_dark: logo_brand:ibm_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_ibm_tooltip,
        display_order: 4130
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

CREATE provider:imperva SET
    name = "imperva",
    slug = "imperva",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_imperva_name,
        description_i18n: i18n_key:provider_imperva_description
    },
    presentation = {
        logo_light: logo_brand:imperva_light,
        logo_dark: logo_brand:imperva_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_imperva_tooltip,
        display_order: 4140
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

CREATE provider:intercom SET
    name = "intercom",
    slug = "intercom",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_intercom_name,
        description_i18n: i18n_key:provider_intercom_description
    },
    presentation = {
        logo_light: logo_brand:intercom_light,
        logo_dark: logo_brand:intercom_dark,
        color: "#1F8DED",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_intercom_tooltip,
        display_order: 4150
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:intercom_documentation,
            api_base: "https://api.intercom.io",
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

CREATE provider:invoice_ninja SET
    name = "invoice_ninja",
    slug = "invoice_ninja",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_invoice_ninja_name,
        description_i18n: i18n_key:provider_invoice_ninja_description
    },
    presentation = {
        logo_light: logo_brand:invoice_ninja_light,
        logo_dark: logo_brand:invoice_ninja_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_invoice_ninja_tooltip,
        display_order: 4160
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

CREATE provider:iterable SET
    name = "iterable",
    slug = "iterable",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_iterable_name,
        description_i18n: i18n_key:provider_iterable_description
    },
    presentation = {
        logo_light: logo_brand:iterable_light,
        logo_dark: logo_brand:iterable_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_iterable_tooltip,
        display_order: 4170
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:iterable_documentation,
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

CREATE provider:jenkins SET
    name = "jenkins",
    slug = "jenkins",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_jenkins_name,
        description_i18n: i18n_key:provider_jenkins_description
    },
    presentation = {
        logo_light: logo_brand:jenkins_light,
        logo_dark: logo_brand:jenkins_dark,
        color: "#D24939",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_jenkins_tooltip,
        display_order: 4180
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:jenkins_documentation,
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

CREATE provider:jina SET
    name = "jina",
    slug = "jina",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_jina_name,
        description_i18n: i18n_key:provider_jina_description
    },
    presentation = {
        logo_light: logo_brand:jina_light,
        logo_dark: logo_brand:jina_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_jina_tooltip,
        display_order: 4190
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

CREATE provider:jira SET
    name = "jira",
    slug = "jira",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_jira_name,
        description_i18n: i18n_key:provider_jira_description
    },
    presentation = {
        logo_light: logo_brand:jira_light,
        logo_dark: logo_brand:jira_dark,
        color: "#0052CC",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_jira_tooltip,
        display_order: 4200
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

CREATE provider:jotform SET
    name = "jotform",
    slug = "jotform",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_jotform_name,
        description_i18n: i18n_key:provider_jotform_description
    },
    presentation = {
        logo_light: logo_brand:jotform_light,
        logo_dark: logo_brand:jotform_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_jotform_tooltip,
        display_order: 4210
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:jotform_documentation,
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

CREATE provider:kafka SET
    name = "kafka",
    slug = "kafka",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_kafka_name,
        description_i18n: i18n_key:provider_kafka_description
    },
    presentation = {
        logo_light: logo_brand:kafka_light,
        logo_dark: logo_brand:kafka_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_kafka_tooltip,
        display_order: 4220
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:kafka_documentation,
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

CREATE provider:keap SET
    name = "keap",
    slug = "keap",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_keap_name,
        description_i18n: i18n_key:provider_keap_description
    },
    presentation = {
        logo_light: logo_brand:keap_light,
        logo_dark: logo_brand:keap_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_keap_tooltip,
        display_order: 4230
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:keap_documentation,
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

CREATE provider:kitemaker SET
    name = "kitemaker",
    slug = "kitemaker",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_kitemaker_name,
        description_i18n: i18n_key:provider_kitemaker_description
    },
    presentation = {
        logo_light: logo_brand:kitemaker_light,
        logo_dark: logo_brand:kitemaker_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_kitemaker_tooltip,
        display_order: 4240
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:kitemaker_documentation,
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

CREATE provider:kobotoolbox SET
    name = "kobotoolbox",
    slug = "kobotoolbox",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_kobotoolbox_name,
        description_i18n: i18n_key:provider_kobotoolbox_description
    },
    presentation = {
        logo_light: logo_brand:kobotoolbox_light,
        logo_dark: logo_brand:kobotoolbox_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_kobotoolbox_tooltip,
        display_order: 4250
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:kobotoolbox_documentation,
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

CREATE provider:ldap SET
    name = "ldap",
    slug = "ldap",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_ldap_name,
        description_i18n: i18n_key:provider_ldap_description
    },
    presentation = {
        logo_light: logo_brand:ldap_light,
        logo_dark: logo_brand:ldap_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_ldap_tooltip,
        display_order: 4260
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:ldap_documentation,
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

CREATE provider:lemlist SET
    name = "lemlist",
    slug = "lemlist",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_lemlist_name,
        description_i18n: i18n_key:provider_lemlist_description
    },
    presentation = {
        logo_light: logo_brand:lemlist_light,
        logo_dark: logo_brand:lemlist_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_lemlist_tooltip,
        display_order: 4270
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:lemlist_documentation,
            api_base: "https://api.lemlist.com/api",
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

CREATE provider:line SET
    name = "line",
    slug = "line",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_line_name,
        description_i18n: i18n_key:provider_line_description
    },
    presentation = {
        logo_light: logo_brand:line_light,
        logo_dark: logo_brand:line_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_line_tooltip,
        display_order: 4280
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

CREATE provider:linear SET
    name = "linear",
    slug = "linear",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_linear_name,
        description_i18n: i18n_key:provider_linear_description
    },
    presentation = {
        logo_light: logo_brand:linear_light,
        logo_dark: logo_brand:linear_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_linear_tooltip,
        display_order: 4290
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:linear_documentation,
            api_base: NONE,
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

CREATE provider:lingvanex SET
    name = "lingvanex",
    slug = "lingvanex",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_lingvanex_name,
        description_i18n: i18n_key:provider_lingvanex_description
    },
    presentation = {
        logo_light: logo_brand:lingvanex_light,
        logo_dark: logo_brand:lingvanex_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_lingvanex_tooltip,
        display_order: 4300
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:lingvanex_documentation,
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


