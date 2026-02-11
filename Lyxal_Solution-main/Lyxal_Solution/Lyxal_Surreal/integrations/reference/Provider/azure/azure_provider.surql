-- ========================================================================
-- AZURE PROVIDER SEEDS
-- ========================================================================
-- Date: 2025-10-29
-- 
--
-- ========================================================================

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