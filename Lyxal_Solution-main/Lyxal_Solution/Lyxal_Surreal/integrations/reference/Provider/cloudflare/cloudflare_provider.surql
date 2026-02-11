-- ========================================================================
-- CLOUDFLARE PROVIDER SEEDS
-- ========================================================================
-- Date: 2025-10-29
-- 
--
-- ========================================================================

CREATE provider:cloudflare SET
    name = "cloudflare",
    slug = "cloudflare",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_cloudflare_name,
        description_i18n: i18n_key:provider_cloudflare_description
    },
    presentation = {
        logo_light: logo_brand:cloudflare_light,
        logo_dark: logo_brand:cloudflare_dark,
        color: "#F38020",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_cloudflare_tooltip,
        display_order: 2090
    },
    config = {
        urls: {
            website: NONE,
            documentation: url:cloudflare_documentation,
            api_base: "https://api.cloudflare.com/client/v4/user/tokens/verify",
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