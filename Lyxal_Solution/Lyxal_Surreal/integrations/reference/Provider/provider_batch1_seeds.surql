-- ========================================================================
-- BATCH 1 : PROVIDERS SEEDS (30 providers) - DONNÉES COMPLÈTES N8N
-- ========================================================================
-- Date: 2025-10-29
-- Source:
--    n8n credentials (documentationUrl, baseURL, auth types)
--    Official brand colors (45+ providers)
-- ========================================================================

CREATE provider:actionnetwork SET
    name = "actionnetwork",
    slug = "actionnetwork",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_actionnetwork_name,
        description_i18n: i18n_key:provider_actionnetwork_description
    },
    presentation = {
        logo_light: logo_brand:actionnetwork_light,
        logo_dark: logo_brand:actionnetwork_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_actionnetwork_tooltip,
        display_order: 1010
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:actionnetwork_documentation,
            api_base: "https://actionnetwork.org/api/v2",
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

CREATE provider:activecampaign SET
    name = "activecampaign",
    slug = "activecampaign",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_activecampaign_name,
        description_i18n: i18n_key:provider_activecampaign_description
    },
    presentation = {
        logo_light: logo_brand:activecampaign_light,
        logo_dark: logo_brand:activecampaign_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_activecampaign_tooltip,
        display_order: 1020
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:activecampaign_documentation,
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

CREATE provider:acuity_scheduling SET
    name = "acuity_scheduling",
    slug = "acuity_scheduling",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_acuity_scheduling_name,
        description_i18n: i18n_key:provider_acuity_scheduling_description
    },
    presentation = {
        logo_light: logo_brand:acuity_scheduling_light,
        logo_dark: logo_brand:acuity_scheduling_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_acuity_scheduling_tooltip,
        display_order: 1030
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

CREATE provider:adalo SET
    name = "adalo",
    slug = "adalo",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_adalo_name,
        description_i18n: i18n_key:provider_adalo_description
    },
    presentation = {
        logo_light: logo_brand:adalo_light,
        logo_dark: logo_brand:adalo_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_adalo_tooltip,
        display_order: 1040
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:adalo_documentation,
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

CREATE provider:affinity SET
    name = "affinity",
    slug = "affinity",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_affinity_name,
        description_i18n: i18n_key:provider_affinity_description
    },
    presentation = {
        logo_light: logo_brand:affinity_light,
        logo_dark: logo_brand:affinity_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_affinity_tooltip,
        display_order: 1050
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:affinity_documentation,
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

CREATE provider:agilecrm SET
    name = "agilecrm",
    slug = "agilecrm",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_agilecrm_name,
        description_i18n: i18n_key:provider_agilecrm_description
    },
    presentation = {
        logo_light: logo_brand:agilecrm_light,
        logo_dark: logo_brand:agilecrm_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_agilecrm_tooltip,
        display_order: 1060
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:agilecrm_documentation,
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

CREATE provider:airtable SET
    name = "airtable",
    slug = "airtable",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_airtable_name,
        description_i18n: i18n_key:provider_airtable_description
    },
    presentation = {
        logo_light: logo_brand:airtable_light,
        logo_dark: logo_brand:airtable_dark,
        color: "#18BFFF",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_airtable_tooltip,
        display_order: 1070
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:airtable_documentation,
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

CREATE provider:airtop SET
    name = "airtop",
    slug = "airtop",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_airtop_name,
        description_i18n: i18n_key:provider_airtop_description
    },
    presentation = {
        logo_light: logo_brand:airtop_light,
        logo_dark: logo_brand:airtop_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_airtop_tooltip,
        display_order: 1080
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:airtop_documentation,
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

CREATE provider:alienvault SET
    name = "alienvault",
    slug = "alienvault",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_alienvault_name,
        description_i18n: i18n_key:provider_alienvault_description
    },
    presentation = {
        logo_light: logo_brand:alienvault_light,
        logo_dark: logo_brand:alienvault_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_alienvault_tooltip,
        display_order: 1090
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:alienvault_documentation,
            api_base: "https://otx.alienvault.com/api/v1/",
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

CREATE provider:amqp SET
    name = "amqp",
    slug = "amqp",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_amqp_name,
        description_i18n: i18n_key:provider_amqp_description
    },
    presentation = {
        logo_light: logo_brand:amqp_light,
        logo_dark: logo_brand:amqp_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_amqp_tooltip,
        display_order: 1100
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:amqp_documentation,
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

CREATE provider:apitemplateio SET
    name = "apitemplateio",
    slug = "apitemplateio",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_apitemplateio_name,
        description_i18n: i18n_key:provider_apitemplateio_description
    },
    presentation = {
        logo_light: logo_brand:apitemplateio_light,
        logo_dark: logo_brand:apitemplateio_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_apitemplateio_tooltip,
        display_order: 1110
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:apitemplateio_documentation,
            api_base: "https://api.apitemplate.io/v1",
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

CREATE provider:asana SET
    name = "asana",
    slug = "asana",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_asana_name,
        description_i18n: i18n_key:provider_asana_description
    },
    presentation = {
        logo_light: logo_brand:asana_light,
        logo_dark: logo_brand:asana_dark,
        color: "#F06A6A",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_asana_tooltip,
        display_order: 1120
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:asana_documentation,
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

CREATE provider:auth0 SET
    name = "auth0",
    slug = "auth0",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_auth0_name,
        description_i18n: i18n_key:provider_auth0_description
    },
    presentation = {
        logo_light: logo_brand:auth0_light,
        logo_dark: logo_brand:auth0_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_auth0_tooltip,
        display_order: 1130
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

CREATE provider:automizy SET
    name = "automizy",
    slug = "automizy",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_automizy_name,
        description_i18n: i18n_key:provider_automizy_description
    },
    presentation = {
        logo_light: logo_brand:automizy_light,
        logo_dark: logo_brand:automizy_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_automizy_tooltip,
        display_order: 1140
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:automizy_documentation,
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

CREATE provider:autopilot SET
    name = "autopilot",
    slug = "autopilot",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_autopilot_name,
        description_i18n: i18n_key:provider_autopilot_description
    },
    presentation = {
        logo_light: logo_brand:autopilot_light,
        logo_dark: logo_brand:autopilot_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_autopilot_tooltip,
        display_order: 1150
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:autopilot_documentation,
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

CREATE provider:aws SET
    name = "aws",
    slug = "aws",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_aws_name,
        description_i18n: i18n_key:provider_aws_description
    },
    presentation = {
        logo_light: logo_brand:aws_light,
        logo_dark: logo_brand:aws_dark,
        color: "#FF9900",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_aws_tooltip,
        display_order: 1160
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:aws_documentation,
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

CREATE provider:azure SET
    name = "azure",
    slug = "azure",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_azure_name,
        description_i18n: i18n_key:provider_azure_description
    },
    presentation = {
        logo_light: logo_brand:azure_light,
        logo_dark: logo_brand:azure_dark,
        color: "#0078D4",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_azure_tooltip,
        display_order: 1170
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

CREATE provider:bamboohr SET
    name = "bamboohr",
    slug = "bamboohr",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_bamboohr_name,
        description_i18n: i18n_key:provider_bamboohr_description
    },
    presentation = {
        logo_light: logo_brand:bamboohr_light,
        logo_dark: logo_brand:bamboohr_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_bamboohr_tooltip,
        display_order: 1180
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:bamboohr_documentation,
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

CREATE provider:bannerbear SET
    name = "bannerbear",
    slug = "bannerbear",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_bannerbear_name,
        description_i18n: i18n_key:provider_bannerbear_description
    },
    presentation = {
        logo_light: logo_brand:bannerbear_light,
        logo_dark: logo_brand:bannerbear_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_bannerbear_tooltip,
        display_order: 1190
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:bannerbear_documentation,
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

CREATE provider:baserow SET
    name = "baserow",
    slug = "baserow",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_baserow_name,
        description_i18n: i18n_key:provider_baserow_description
    },
    presentation = {
        logo_light: logo_brand:baserow_light,
        logo_dark: logo_brand:baserow_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_baserow_tooltip,
        display_order: 1200
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:baserow_documentation,
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

CREATE provider:beeminder SET
    name = "beeminder",
    slug = "beeminder",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_beeminder_name,
        description_i18n: i18n_key:provider_beeminder_description
    },
    presentation = {
        logo_light: logo_brand:beeminder_light,
        logo_dark: logo_brand:beeminder_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_beeminder_tooltip,
        display_order: 1210
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:beeminder_documentation,
            api_base: "https://www.beeminder.com/api/v1",
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

CREATE provider:bitbucket SET
    name = "bitbucket",
    slug = "bitbucket",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_bitbucket_name,
        description_i18n: i18n_key:provider_bitbucket_description
    },
    presentation = {
        logo_light: logo_brand:bitbucket_light,
        logo_dark: logo_brand:bitbucket_dark,
        color: "#0052CC",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_bitbucket_tooltip,
        display_order: 1220
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:bitbucket_documentation,
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

CREATE provider:bitly SET
    name = "bitly",
    slug = "bitly",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_bitly_name,
        description_i18n: i18n_key:provider_bitly_description
    },
    presentation = {
        logo_light: logo_brand:bitly_light,
        logo_dark: logo_brand:bitly_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_bitly_tooltip,
        display_order: 1230
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:bitly_documentation,
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

CREATE provider:bitwarden SET
    name = "bitwarden",
    slug = "bitwarden",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_bitwarden_name,
        description_i18n: i18n_key:provider_bitwarden_description
    },
    presentation = {
        logo_light: logo_brand:bitwarden_light,
        logo_dark: logo_brand:bitwarden_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_bitwarden_tooltip,
        display_order: 1240
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:bitwarden_documentation,
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

CREATE provider:box SET
    name = "box",
    slug = "box",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_box_name,
        description_i18n: i18n_key:provider_box_description
    },
    presentation = {
        logo_light: logo_brand:box_light,
        logo_dark: logo_brand:box_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_box_tooltip,
        display_order: 1250
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:box_documentation,
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

CREATE provider:brandfetch SET
    name = "brandfetch",
    slug = "brandfetch",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_brandfetch_name,
        description_i18n: i18n_key:provider_brandfetch_description
    },
    presentation = {
        logo_light: logo_brand:brandfetch_light,
        logo_dark: logo_brand:brandfetch_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_brandfetch_tooltip,
        display_order: 1260
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:brandfetch_documentation,
            api_base: "https://api.brandfetch.io",
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

CREATE provider:brevo SET
    name = "brevo",
    slug = "brevo",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_brevo_name,
        description_i18n: i18n_key:provider_brevo_description
    },
    presentation = {
        logo_light: logo_brand:brevo_light,
        logo_dark: logo_brand:brevo_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_brevo_tooltip,
        display_order: 1270
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

CREATE provider:bubble SET
    name = "bubble",
    slug = "bubble",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_bubble_name,
        description_i18n: i18n_key:provider_bubble_description
    },
    presentation = {
        logo_light: logo_brand:bubble_light,
        logo_dark: logo_brand:bubble_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_bubble_tooltip,
        display_order: 1280
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:bubble_documentation,
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

CREATE provider:cal SET
    name = "cal",
    slug = "cal",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_cal_name,
        description_i18n: i18n_key:provider_cal_description
    },
    presentation = {
        logo_light: logo_brand:cal_light,
        logo_dark: logo_brand:cal_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_cal_tooltip,
        display_order: 1290
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:cal_documentation,
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

CREATE provider:calendly SET
    name = "calendly",
    slug = "calendly",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_calendly_name,
        description_i18n: i18n_key:provider_calendly_description
    },
    presentation = {
        logo_light: logo_brand:calendly_light,
        logo_dark: logo_brand:calendly_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_calendly_tooltip,
        display_order: 1300
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:calendly_documentation,
            api_base: "https://calendly.com",
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


