-- ========================================================================
-- CLICKUP PROVIDER SEEDS
-- ========================================================================
-- Date: 2025-10-29
-- 
--
-- ========================================================================

CREATE provider:clickup SET
    name = "clickup",
    slug = "clickup",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_clickup_name,
        description_i18n: i18n_key:provider_clickup_description
    },
    presentation = {
        logo_light: logo_brand:clickup_light,
        logo_dark: logo_brand:clickup_dark,
        color: "#6B7280",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_clickup_tooltip,
        display_order: 2070
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:clickup_documentation,
            api_base: "https://api.clickup.com/api/v2",
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