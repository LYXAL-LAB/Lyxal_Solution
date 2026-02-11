-- ========================================================================
-- BATCH 5 : PROVIDERS SEEDS (30 providers) - DONNÉES COMPLÈTES N8N
-- ========================================================================
-- Date: 2025-10-29
-- Source:
--    n8n credentials (documentationUrl, baseURL, auth types)
--    Official brand colors (45+ providers)
-- ========================================================================

CREATE provider:linkedin SET
    name = "linkedin",
    slug = "linkedin",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_linkedin_name,
        description_i18n: i18n_key:provider_linkedin_description
    },
    presentation = {
        logo_light: logo_brand:linkedin_light,
        logo_dark: logo_brand:linkedin_dark,
        color: "#0A66C2",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_linkedin_tooltip,
        display_order: 5010
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:linkedin_documentation,
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

CREATE provider:lonescale SET
    name = "lonescale",
    slug = "lonescale",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_lonescale_name,
        description_i18n: i18n_key:provider_lonescale_description
    },
    presentation = {
        logo_light: logo_brand:lonescale_light,
        logo_dark: logo_brand:lonescale_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_lonescale_tooltip,
        display_order: 5020
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:lonescale_documentation,
            api_base: "https://public-api.lonescale.com",
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

CREATE provider:magento SET
    name = "magento",
    slug = "magento",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_magento_name,
        description_i18n: i18n_key:provider_magento_description
    },
    presentation = {
        logo_light: logo_brand:magento_light,
        logo_dark: logo_brand:magento_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_magento_tooltip,
        display_order: 5030
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

CREATE provider:mailcheck SET
    name = "mailcheck",
    slug = "mailcheck",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_mailcheck_name,
        description_i18n: i18n_key:provider_mailcheck_description
    },
    presentation = {
        logo_light: logo_brand:mailcheck_light,
        logo_dark: logo_brand:mailcheck_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_mailcheck_tooltip,
        display_order: 5040
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:mailcheck_documentation,
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

CREATE provider:mailchimp SET
    name = "mailchimp",
    slug = "mailchimp",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_mailchimp_name,
        description_i18n: i18n_key:provider_mailchimp_description
    },
    presentation = {
        logo_light: logo_brand:mailchimp_light,
        logo_dark: logo_brand:mailchimp_dark,
        color: "#FFE01B",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_mailchimp_tooltip,
        display_order: 5050
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:mailchimp_documentation,
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

CREATE provider:mailerlite SET
    name = "mailerlite",
    slug = "mailerlite",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_mailerlite_name,
        description_i18n: i18n_key:provider_mailerlite_description
    },
    presentation = {
        logo_light: logo_brand:mailerlite_light,
        logo_dark: logo_brand:mailerlite_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_mailerlite_tooltip,
        display_order: 5060
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:mailerlite_documentation,
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

CREATE provider:mailgun SET
    name = "mailgun",
    slug = "mailgun",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_mailgun_name,
        description_i18n: i18n_key:provider_mailgun_description
    },
    presentation = {
        logo_light: logo_brand:mailgun_light,
        logo_dark: logo_brand:mailgun_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_mailgun_tooltip,
        display_order: 5070
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:mailgun_documentation,
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

CREATE provider:mailjet SET
    name = "mailjet",
    slug = "mailjet",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_mailjet_name,
        description_i18n: i18n_key:provider_mailjet_description
    },
    presentation = {
        logo_light: logo_brand:mailjet_light,
        logo_dark: logo_brand:mailjet_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_mailjet_tooltip,
        display_order: 5080
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

CREATE provider:malcore SET
    name = "malcore",
    slug = "malcore",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_malcore_name,
        description_i18n: i18n_key:provider_malcore_description
    },
    presentation = {
        logo_light: logo_brand:malcore_light,
        logo_dark: logo_brand:malcore_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_malcore_tooltip,
        display_order: 5090
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:malcore_documentation,
            api_base: "https://api.malcore.io/api",
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

CREATE provider:mandrill SET
    name = "mandrill",
    slug = "mandrill",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_mandrill_name,
        description_i18n: i18n_key:provider_mandrill_description
    },
    presentation = {
        logo_light: logo_brand:mandrill_light,
        logo_dark: logo_brand:mandrill_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_mandrill_tooltip,
        display_order: 5100
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:mandrill_documentation,
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

CREATE provider:marketstack SET
    name = "marketstack",
    slug = "marketstack",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_marketstack_name,
        description_i18n: i18n_key:provider_marketstack_description
    },
    presentation = {
        logo_light: logo_brand:marketstack_light,
        logo_dark: logo_brand:marketstack_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_marketstack_tooltip,
        display_order: 5110
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:marketstack_documentation,
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

CREATE provider:matrix SET
    name = "matrix",
    slug = "matrix",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_matrix_name,
        description_i18n: i18n_key:provider_matrix_description
    },
    presentation = {
        logo_light: logo_brand:matrix_light,
        logo_dark: logo_brand:matrix_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_matrix_tooltip,
        display_order: 5120
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:matrix_documentation,
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

CREATE provider:mattermost SET
    name = "mattermost",
    slug = "mattermost",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_mattermost_name,
        description_i18n: i18n_key:provider_mattermost_description
    },
    presentation = {
        logo_light: logo_brand:mattermost_light,
        logo_dark: logo_brand:mattermost_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_mattermost_tooltip,
        display_order: 5130
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:mattermost_documentation,
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

CREATE provider:mautic SET
    name = "mautic",
    slug = "mautic",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_mautic_name,
        description_i18n: i18n_key:provider_mautic_description
    },
    presentation = {
        logo_light: logo_brand:mautic_light,
        logo_dark: logo_brand:mautic_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_mautic_tooltip,
        display_order: 5140
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:mautic_documentation,
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

CREATE provider:medium SET
    name = "medium",
    slug = "medium",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_medium_name,
        description_i18n: i18n_key:provider_medium_description
    },
    presentation = {
        logo_light: logo_brand:medium_light,
        logo_dark: logo_brand:medium_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_medium_tooltip,
        display_order: 5150
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:medium_documentation,
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

CREATE provider:messagebird SET
    name = "messagebird",
    slug = "messagebird",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_messagebird_name,
        description_i18n: i18n_key:provider_messagebird_description
    },
    presentation = {
        logo_light: logo_brand:messagebird_light,
        logo_dark: logo_brand:messagebird_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_messagebird_tooltip,
        display_order: 5160
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:messagebird_documentation,
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

CREATE provider:metabase SET
    name = "metabase",
    slug = "metabase",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_metabase_name,
        description_i18n: i18n_key:provider_metabase_description
    },
    presentation = {
        logo_light: logo_brand:metabase_light,
        logo_dark: logo_brand:metabase_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_metabase_tooltip,
        display_order: 5170
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:metabase_documentation,
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

CREATE provider:microsoft SET
    name = "microsoft",
    slug = "microsoft",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_microsoft_name,
        description_i18n: i18n_key:provider_microsoft_description
    },
    presentation = {
        logo_light: logo_brand:microsoft_light,
        logo_dark: logo_brand:microsoft_dark,
        color: "#00A4EF",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_microsoft_tooltip,
        display_order: 5180
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:microsoft_documentation,
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

CREATE provider:mindee SET
    name = "mindee",
    slug = "mindee",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_mindee_name,
        description_i18n: i18n_key:provider_mindee_description
    },
    presentation = {
        logo_light: logo_brand:mindee_light,
        logo_dark: logo_brand:mindee_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_mindee_tooltip,
        display_order: 5190
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

CREATE provider:miro SET
    name = "miro",
    slug = "miro",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_miro_name,
        description_i18n: i18n_key:provider_miro_description
    },
    presentation = {
        logo_light: logo_brand:miro_light,
        logo_dark: logo_brand:miro_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_miro_tooltip,
        display_order: 5200
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:miro_documentation,
            api_base: "https://api.miro.com/v2/",
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

CREATE provider:misp SET
    name = "misp",
    slug = "misp",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_misp_name,
        description_i18n: i18n_key:provider_misp_description
    },
    presentation = {
        logo_light: logo_brand:misp_light,
        logo_dark: logo_brand:misp_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_misp_tooltip,
        display_order: 5210
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:misp_documentation,
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

CREATE provider:mist SET
    name = "mist",
    slug = "mist",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_mist_name,
        description_i18n: i18n_key:provider_mist_description
    },
    presentation = {
        logo_light: logo_brand:mist_light,
        logo_dark: logo_brand:mist_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_mist_tooltip,
        display_order: 5220
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:mist_documentation,
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

CREATE provider:mocean SET
    name = "mocean",
    slug = "mocean",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_mocean_name,
        description_i18n: i18n_key:provider_mocean_description
    },
    presentation = {
        logo_light: logo_brand:mocean_light,
        logo_dark: logo_brand:mocean_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_mocean_tooltip,
        display_order: 5230
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:mocean_documentation,
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

CREATE provider:monday SET
    name = "monday",
    slug = "monday",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_monday_name,
        description_i18n: i18n_key:provider_monday_description
    },
    presentation = {
        logo_light: logo_brand:monday_light,
        logo_dark: logo_brand:monday_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_monday_tooltip,
        display_order: 5240
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

CREATE provider:mongodb SET
    name = "mongodb",
    slug = "mongodb",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_mongodb_name,
        description_i18n: i18n_key:provider_mongodb_description
    },
    presentation = {
        logo_light: logo_brand:mongodb_light,
        logo_dark: logo_brand:mongodb_dark,
        color: "#47A248",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_mongodb_tooltip,
        display_order: 5250
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:mongodb_documentation,
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

CREATE provider:monica SET
    name = "monica",
    slug = "monica",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_monica_name,
        description_i18n: i18n_key:provider_monica_description
    },
    presentation = {
        logo_light: logo_brand:monica_light,
        logo_dark: logo_brand:monica_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_monica_tooltip,
        display_order: 5260
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

CREATE provider:mqtt SET
    name = "mqtt",
    slug = "mqtt",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_mqtt_name,
        description_i18n: i18n_key:provider_mqtt_description
    },
    presentation = {
        logo_light: logo_brand:mqtt_light,
        logo_dark: logo_brand:mqtt_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_mqtt_tooltip,
        display_order: 5270
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:mqtt_documentation,
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

CREATE provider:msg91 SET
    name = "msg91",
    slug = "msg91",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_msg91_name,
        description_i18n: i18n_key:provider_msg91_description
    },
    presentation = {
        logo_light: logo_brand:msg91_light,
        logo_dark: logo_brand:msg91_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_msg91_tooltip,
        display_order: 5280
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:msg91_documentation,
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

CREATE provider:mysql SET
    name = "mysql",
    slug = "mysql",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_mysql_name,
        description_i18n: i18n_key:provider_mysql_description
    },
    presentation = {
        logo_light: logo_brand:mysql_light,
        logo_dark: logo_brand:mysql_dark,
        color: "#4479A1",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_mysql_tooltip,
        display_order: 5290
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:mysql_documentation,
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

CREATE provider:n8n SET
    name = "n8n",
    slug = "n8n",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_n8n_name,
        description_i18n: i18n_key:provider_n8n_description
    },
    presentation = {
        logo_light: logo_brand:n8n_light,
        logo_dark: logo_brand:n8n_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_n8n_tooltip,
        display_order: 5300
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:n8n_documentation,
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


