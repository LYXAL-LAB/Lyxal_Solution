

CREATE provider:coda SET
    name = "coda",
    slug = "coda",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_coda_name,
        description_i18n: i18n_key:provider_coda_description
    },
    presentation = {
        logo_light: logo_brand:coda_light,
        logo_dark: logo_brand:coda_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_coda_tooltip,
        display_order: 2110
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:coda_documentation,
            api_base: "https://coda.io/apis/v1/whoami",
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

CREATE provider:contentful SET
    name = "contentful",
    slug = "contentful",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_contentful_name,
        description_i18n: i18n_key:provider_contentful_description
    },
    presentation = {
        logo_light: logo_brand:contentful_light,
        logo_dark: logo_brand:contentful_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_contentful_tooltip,
        display_order: 2120
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:contentful_documentation,
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

CREATE provider:convert SET
    name = "convert",
    slug = "convert",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_convert_name,
        description_i18n: i18n_key:provider_convert_description
    },
    presentation = {
        logo_light: logo_brand:convert_light,
        logo_dark: logo_brand:convert_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_convert_tooltip,
        display_order: 2130
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:convert_documentation,
            api_base: "https://v2.convertapi.com/",
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

CREATE provider:convertkit SET
    name = "convertkit",
    slug = "convertkit",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_convertkit_name,
        description_i18n: i18n_key:provider_convertkit_description
    },
    presentation = {
        logo_light: logo_brand:convertkit_light,
        logo_dark: logo_brand:convertkit_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_convertkit_tooltip,
        display_order: 2140
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:convertkit_documentation,
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

CREATE provider:copper SET
    name = "copper",
    slug = "copper",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_copper_name,
        description_i18n: i18n_key:provider_copper_description
    },
    presentation = {
        logo_light: logo_brand:copper_light,
        logo_dark: logo_brand:copper_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_copper_tooltip,
        display_order: 2150
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:copper_documentation,
            api_base: "https://api.copper.com/developer_api/v1/",
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

CREATE provider:cortex SET
    name = "cortex",
    slug = "cortex",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_cortex_name,
        description_i18n: i18n_key:provider_cortex_description
    },
    presentation = {
        logo_light: logo_brand:cortex_light,
        logo_dark: logo_brand:cortex_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_cortex_tooltip,
        display_order: 2160
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:cortex_documentation,
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

CREATE provider:cratedb SET
    name = "cratedb",
    slug = "cratedb",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_cratedb_name,
        description_i18n: i18n_key:provider_cratedb_description
    },
    presentation = {
        logo_light: logo_brand:cratedb_light,
        logo_dark: logo_brand:cratedb_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_cratedb_tooltip,
        display_order: 2170
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:cratedb_documentation,
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

CREATE provider:crowddev SET
    name = "crowddev",
    slug = "crowddev",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_crowddev_name,
        description_i18n: i18n_key:provider_crowddev_description
    },
    presentation = {
        logo_light: logo_brand:crowddev_light,
        logo_dark: logo_brand:crowddev_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_crowddev_tooltip,
        display_order: 2180
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:crowddev_documentation,
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

CREATE provider:crowdstrike SET
    name = "crowdstrike",
    slug = "crowdstrike",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_crowdstrike_name,
        description_i18n: i18n_key:provider_crowdstrike_description
    },
    presentation = {
        logo_light: logo_brand:crowdstrike_light,
        logo_dark: logo_brand:crowdstrike_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_crowdstrike_tooltip,
        display_order: 2190
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:crowdstrike_documentation,
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

CREATE provider:customer_io SET
    name = "customer_io",
    slug = "customer_io",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_customer_io_name,
        description_i18n: i18n_key:provider_customer_io_description
    },
    presentation = {
        logo_light: logo_brand:customer_io_light,
        logo_dark: logo_brand:customer_io_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_customer_io_tooltip,
        display_order: 2200
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

CREATE provider:datadog SET
    name = "datadog",
    slug = "datadog",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_datadog_name,
        description_i18n: i18n_key:provider_datadog_description
    },
    presentation = {
        logo_light: logo_brand:datadog_light,
        logo_dark: logo_brand:datadog_dark,
        color: "#632CA6",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_datadog_tooltip,
        display_order: 2210
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:datadog_documentation,
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

CREATE provider:deepl SET
    name = "deepl",
    slug = "deepl",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_deepl_name,
        description_i18n: i18n_key:provider_deepl_description
    },
    presentation = {
        logo_light: logo_brand:deepl_light,
        logo_dark: logo_brand:deepl_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_deepl_tooltip,
        display_order: 2220
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:deepl_documentation,
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

CREATE provider:demio SET
    name = "demio",
    slug = "demio",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_demio_name,
        description_i18n: i18n_key:provider_demio_description
    },
    presentation = {
        logo_light: logo_brand:demio_light,
        logo_dark: logo_brand:demio_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_demio_tooltip,
        display_order: 2230
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:demio_documentation,
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

CREATE provider:dfiriris SET
    name = "dfiriris",
    slug = "dfiriris",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_dfiriris_name,
        description_i18n: i18n_key:provider_dfiriris_description
    },
    presentation = {
        logo_light: logo_brand:dfiriris_light,
        logo_dark: logo_brand:dfiriris_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_dfiriris_tooltip,
        display_order: 2240
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:dfiriris_documentation,
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

CREATE provider:dhl SET
    name = "dhl",
    slug = "dhl",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_dhl_name,
        description_i18n: i18n_key:provider_dhl_description
    },
    presentation = {
        logo_light: logo_brand:dhl_light,
        logo_dark: logo_brand:dhl_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_dhl_tooltip,
        display_order: 2250
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:dhl_documentation,
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

CREATE provider:discord SET
    name = "discord",
    slug = "discord",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_discord_name,
        description_i18n: i18n_key:provider_discord_description
    },
    presentation = {
        logo_light: logo_brand:discord_light,
        logo_dark: logo_brand:discord_dark,
        color: "#5865F2",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_discord_tooltip,
        display_order: 2260
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:discord_documentation,
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

CREATE provider:discourse SET
    name = "discourse",
    slug = "discourse",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_discourse_name,
        description_i18n: i18n_key:provider_discourse_description
    },
    presentation = {
        logo_light: logo_brand:discourse_light,
        logo_dark: logo_brand:discourse_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_discourse_tooltip,
        display_order: 2270
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:discourse_documentation,
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

CREATE provider:disqus SET
    name = "disqus",
    slug = "disqus",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_disqus_name,
        description_i18n: i18n_key:provider_disqus_description
    },
    presentation = {
        logo_light: logo_brand:disqus_light,
        logo_dark: logo_brand:disqus_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_disqus_tooltip,
        display_order: 2280
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:disqus_documentation,
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

CREATE provider:drift SET
    name = "drift",
    slug = "drift",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_drift_name,
        description_i18n: i18n_key:provider_drift_description
    },
    presentation = {
        logo_light: logo_brand:drift_light,
        logo_dark: logo_brand:drift_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_drift_tooltip,
        display_order: 2290
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:drift_documentation,
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

CREATE provider:dropbox SET
    name = "dropbox",
    slug = "dropbox",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_dropbox_name,
        description_i18n: i18n_key:provider_dropbox_description
    },
    presentation = {
        logo_light: logo_brand:dropbox_light,
        logo_dark: logo_brand:dropbox_dark,
        color: "#0061FF",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_dropbox_tooltip,
        display_order: 2300
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:dropbox_documentation,
            api_base: "https://api.dropboxapi.com/2",
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


