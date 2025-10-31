-- ========================================================================
-- BATCH 3 : PROVIDERS SEEDS (30 providers) - DONNÉES COMPLÈTES N8N
-- ========================================================================
-- Date: 2025-10-29
-- Source:
--    n8n credentials (documentationUrl, baseURL, auth types)
--    Official brand colors (45+ providers)
-- ========================================================================

CREATE provider:dropcontact SET
    name = "dropcontact",
    slug = "dropcontact",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_dropcontact_name,
        description_i18n: i18n_key:provider_dropcontact_description
    },
    presentation = {
        logo_light: logo_brand:dropcontact_light,
        logo_dark: logo_brand:dropcontact_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_dropcontact_tooltip,
        display_order: 3010
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:dropcontact_documentation,
            api_base: "https://api.dropcontact.io",
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

CREATE provider:dynatrace SET
    name = "dynatrace",
    slug = "dynatrace",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_dynatrace_name,
        description_i18n: i18n_key:provider_dynatrace_description
    },
    presentation = {
        logo_light: logo_brand:dynatrace_light,
        logo_dark: logo_brand:dynatrace_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_dynatrace_tooltip,
        display_order: 3020
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:dynatrace_documentation,
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

CREATE provider:egoi SET
    name = "egoi",
    slug = "egoi",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_egoi_name,
        description_i18n: i18n_key:provider_egoi_description
    },
    presentation = {
        logo_light: logo_brand:egoi_light,
        logo_dark: logo_brand:egoi_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_egoi_tooltip,
        display_order: 3030
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:egoi_documentation,
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

CREATE provider:elastic SET
    name = "elastic",
    slug = "elastic",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_elastic_name,
        description_i18n: i18n_key:provider_elastic_description
    },
    presentation = {
        logo_light: logo_brand:elastic_light,
        logo_dark: logo_brand:elastic_dark,
        color: "#005571",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_elastic_tooltip,
        display_order: 3040
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

CREATE provider:elasticsearch SET
    name = "elasticsearch",
    slug = "elasticsearch",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_elasticsearch_name,
        description_i18n: i18n_key:provider_elasticsearch_description
    },
    presentation = {
        logo_light: logo_brand:elasticsearch_light,
        logo_dark: logo_brand:elasticsearch_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_elasticsearch_tooltip,
        display_order: 3050
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:elasticsearch_documentation,
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

CREATE provider:email SET
    name = "email",
    slug = "email",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_email_name,
        description_i18n: i18n_key:provider_email_description
    },
    presentation = {
        logo_light: logo_brand:email_light,
        logo_dark: logo_brand:email_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_email_tooltip,
        display_order: 3060
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

CREATE provider:emelia SET
    name = "emelia",
    slug = "emelia",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_emelia_name,
        description_i18n: i18n_key:provider_emelia_description
    },
    presentation = {
        logo_light: logo_brand:emelia_light,
        logo_dark: logo_brand:emelia_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_emelia_tooltip,
        display_order: 3070
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:emelia_documentation,
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

CREATE provider:erpnext SET
    name = "erpnext",
    slug = "erpnext",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_erpnext_name,
        description_i18n: i18n_key:provider_erpnext_description
    },
    presentation = {
        logo_light: logo_brand:erpnext_light,
        logo_dark: logo_brand:erpnext_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_erpnext_tooltip,
        display_order: 3080
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:erpnext_documentation,
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

CREATE provider:eventbrite SET
    name = "eventbrite",
    slug = "eventbrite",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_eventbrite_name,
        description_i18n: i18n_key:provider_eventbrite_description
    },
    presentation = {
        logo_light: logo_brand:eventbrite_light,
        logo_dark: logo_brand:eventbrite_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_eventbrite_tooltip,
        display_order: 3090
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:eventbrite_documentation,
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

CREATE provider:f5 SET
    name = "f5",
    slug = "f5",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_f5_name,
        description_i18n: i18n_key:provider_f5_description
    },
    presentation = {
        logo_light: logo_brand:f5_light,
        logo_dark: logo_brand:f5_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_f5_tooltip,
        display_order: 3100
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

CREATE provider:facebook SET
    name = "facebook",
    slug = "facebook",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_facebook_name,
        description_i18n: i18n_key:provider_facebook_description
    },
    presentation = {
        logo_light: logo_brand:facebook_light,
        logo_dark: logo_brand:facebook_dark,
        color: "#1877F2",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_facebook_tooltip,
        display_order: 3110
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

CREATE provider:figma SET
    name = "figma",
    slug = "figma",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_figma_name,
        description_i18n: i18n_key:provider_figma_description
    },
    presentation = {
        logo_light: logo_brand:figma_light,
        logo_dark: logo_brand:figma_dark,
        color: "#F24E1E",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_figma_tooltip,
        display_order: 3120
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:figma_documentation,
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

CREATE provider:filemaker SET
    name = "filemaker",
    slug = "filemaker",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_filemaker_name,
        description_i18n: i18n_key:provider_filemaker_description
    },
    presentation = {
        logo_light: logo_brand:filemaker_light,
        logo_dark: logo_brand:filemaker_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_filemaker_tooltip,
        display_order: 3130
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:filemaker_documentation,
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

CREATE provider:filescan SET
    name = "filescan",
    slug = "filescan",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_filescan_name,
        description_i18n: i18n_key:provider_filescan_description
    },
    presentation = {
        logo_light: logo_brand:filescan_light,
        logo_dark: logo_brand:filescan_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_filescan_tooltip,
        display_order: 3140
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:filescan_documentation,
            api_base: "https://www.filescan.io/api",
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

CREATE provider:flow SET
    name = "flow",
    slug = "flow",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_flow_name,
        description_i18n: i18n_key:provider_flow_description
    },
    presentation = {
        logo_light: logo_brand:flow_light,
        logo_dark: logo_brand:flow_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_flow_tooltip,
        display_order: 3150
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:flow_documentation,
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

CREATE provider:formio SET
    name = "formio",
    slug = "formio",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_formio_name,
        description_i18n: i18n_key:provider_formio_description
    },
    presentation = {
        logo_light: logo_brand:formio_light,
        logo_dark: logo_brand:formio_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_formio_tooltip,
        display_order: 3160
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:formio_documentation,
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

CREATE provider:formstack SET
    name = "formstack",
    slug = "formstack",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_formstack_name,
        description_i18n: i18n_key:provider_formstack_description
    },
    presentation = {
        logo_light: logo_brand:formstack_light,
        logo_dark: logo_brand:formstack_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_formstack_tooltip,
        display_order: 3170
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:formstack_documentation,
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

CREATE provider:fortinet SET
    name = "fortinet",
    slug = "fortinet",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_fortinet_name,
        description_i18n: i18n_key:provider_fortinet_description
    },
    presentation = {
        logo_light: logo_brand:fortinet_light,
        logo_dark: logo_brand:fortinet_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_fortinet_tooltip,
        display_order: 3180
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

CREATE provider:freshdesk SET
    name = "freshdesk",
    slug = "freshdesk",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_freshdesk_name,
        description_i18n: i18n_key:provider_freshdesk_description
    },
    presentation = {
        logo_light: logo_brand:freshdesk_light,
        logo_dark: logo_brand:freshdesk_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_freshdesk_tooltip,
        display_order: 3190
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:freshdesk_documentation,
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

CREATE provider:freshworks SET
    name = "freshworks",
    slug = "freshworks",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_freshworks_name,
        description_i18n: i18n_key:provider_freshworks_description
    },
    presentation = {
        logo_light: logo_brand:freshworks_light,
        logo_dark: logo_brand:freshworks_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_freshworks_tooltip,
        display_order: 3200
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

CREATE provider:generic SET
    name = "generic",
    slug = "generic",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_generic_name,
        description_i18n: i18n_key:provider_generic_description
    },
    presentation = {
        logo_light: logo_brand:generic_light,
        logo_dark: logo_brand:generic_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_generic_tooltip,
        display_order: 3210
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

CREATE provider:getresponse SET
    name = "getresponse",
    slug = "getresponse",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_getresponse_name,
        description_i18n: i18n_key:provider_getresponse_description
    },
    presentation = {
        logo_light: logo_brand:getresponse_light,
        logo_dark: logo_brand:getresponse_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_getresponse_tooltip,
        display_order: 3220
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:getresponse_documentation,
            api_base: "https://api.getresponse.com/v3",
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

CREATE provider:ghost SET
    name = "ghost",
    slug = "ghost",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_ghost_name,
        description_i18n: i18n_key:provider_ghost_description
    },
    presentation = {
        logo_light: logo_brand:ghost_light,
        logo_dark: logo_brand:ghost_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_ghost_tooltip,
        display_order: 3230
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

CREATE provider:git SET
    name = "git",
    slug = "git",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_git_name,
        description_i18n: i18n_key:provider_git_description
    },
    presentation = {
        logo_light: logo_brand:git_light,
        logo_dark: logo_brand:git_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_git_tooltip,
        display_order: 3240
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

CREATE provider:github SET
    name = "github",
    slug = "github",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_github_name,
        description_i18n: i18n_key:provider_github_description
    },
    presentation = {
        logo_light: logo_brand:github_light,
        logo_dark: logo_brand:github_dark,
        color: "#181717",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_github_tooltip,
        display_order: 3250
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:github_documentation,
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

CREATE provider:gitlab SET
    name = "gitlab",
    slug = "gitlab",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_gitlab_name,
        description_i18n: i18n_key:provider_gitlab_description
    },
    presentation = {
        logo_light: logo_brand:gitlab_light,
        logo_dark: logo_brand:gitlab_dark,
        color: "#FC6D26",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_gitlab_tooltip,
        display_order: 3260
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:gitlab_documentation,
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

CREATE provider:gong SET
    name = "gong",
    slug = "gong",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_gong_name,
        description_i18n: i18n_key:provider_gong_description
    },
    presentation = {
        logo_light: logo_brand:gong_light,
        logo_dark: logo_brand:gong_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_gong_tooltip,
        display_order: 3270
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:gong_documentation,
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

CREATE provider:google SET
    name = "google",
    slug = "google",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_google_name,
        description_i18n: i18n_key:provider_google_description
    },
    presentation = {
        logo_light: logo_brand:google_light,
        logo_dark: logo_brand:google_dark,
        color: "#4285F4",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_google_tooltip,
        display_order: 3280
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:google_documentation,
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

CREATE provider:gotify SET
    name = "gotify",
    slug = "gotify",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_gotify_name,
        description_i18n: i18n_key:provider_gotify_description
    },
    presentation = {
        logo_light: logo_brand:gotify_light,
        logo_dark: logo_brand:gotify_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_gotify_tooltip,
        display_order: 3290
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:gotify_documentation,
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

CREATE provider:gotowebinar SET
    name = "gotowebinar",
    slug = "gotowebinar",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_gotowebinar_name,
        description_i18n: i18n_key:provider_gotowebinar_description
    },
    presentation = {
        logo_light: logo_brand:gotowebinar_light,
        logo_dark: logo_brand:gotowebinar_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_gotowebinar_tooltip,
        display_order: 3300
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:gotowebinar_documentation,
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


