-- =============================================================================================
-- |
-- | Fichier : credential_type_batch17_seeds.surql (SEED DATA)
-- | Module : integrations > reference > credentials > credential_type
-- | Description : Seeds pour le Batch 17 des credential types (11 credentials Monitoring & APIs).
-- |
-- | Batch 17 : Monitoring, Observability, Data Enrichment & Communication (11 credentials)
-- | Providers : Splunk, Sentry.io, PagerDuty, OpenWeatherMap, NASA, Hunter, Clearbit, Raindrop, Telegram, TheHive
-- |
-- =============================================================================================

-- =====================================================
-- 1. SPLUNK API (display_order: 1040) ✨ TRÈS POPULAIRE
-- =====================================================

CREATE credential_type:splunk_api SET
    name = "splunkApi",
    slug = "splunk-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_splunk_api_name,
        description_i18n: i18n_key:credential_type_splunk_api_description
    },
    
    presentation = {
        icon: icon:splunk,
        color_type: theme_color_type:neutral,
        tooltip_i18n: i18n_key:credential_type_splunk_api_tooltip,
        display_order: 1040
    },
    
    auth_type = auth_type:bearer_token,
    provider = provider:splunk,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "authToken",
                display_name: "Auth Token",
                type: "string",
                is_secret: true,
                required: true,
                description: "Splunk authentication token"
            },
            {
                name: "baseUrl",
                display_name: "Base URL",
                type: "string",
                is_secret: false,
                required: true,
                description: "Splunk instance URL (protocol, domain and port)"
            },
            {
                name: "allowUnauthorizedCerts",
                display_name: "Allow Self-Signed Certificates",
                type: "boolean",
                is_secret: false,
                required: false,
                description: "Connect even if SSL certificate validation is not possible",
                default: false
            }
        ],
        metadata: {
            log_management: true,
            siem: true,
            security_analytics: true,
            enterprise: true
        }
    },
    
    documentation = {
        url: url:splunk_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 2. SENTRY.IO API (display_order: 1041) ✨ TRÈS POPULAIRE
-- =====================================================

CREATE credential_type:sentry_io_api SET
    name = "sentryIoApi",
    slug = "sentry-io-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_sentry_io_api_name,
        description_i18n: i18n_key:credential_type_sentry_io_api_description
    }, presentation = { icon: icon:sentry_io_api, color_type: theme_color_type:neutral, tooltip_i18n: i18n_key:credential_type_sentry_io_api_tooltip,
        display_order: 1041
    },
    
    auth_type = auth_type:bearer_token,
    provider = provider:sentry,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "token",
                display_name: "Token",
                type: "string",
                is_secret: true,
                required: true,
                description: "Sentry.io API authentication token"
            }
        ],
        metadata: {
            error_tracking: true,
            application_monitoring: true,
            performance_monitoring: true,
            developer_tool: true
        }
    },
    
    documentation = {
        url: url:sentry_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 3. PAGERDUTY API (display_order: 1042) ✨ TRÈS POPULAIRE
-- =====================================================

CREATE credential_type:pagerduty_api SET
    name = "pagerDutyApi",
    slug = "pagerduty-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_pagerduty_api_name,
        description_i18n: i18n_key:credential_type_pagerduty_api_description
    },
    
    presentation = {
        icon: icon:pagerduty,
        color_type: theme_color_type:success,
        tooltip_i18n: i18n_key:credential_type_pagerduty_api_tooltip,
        display_order: 1042
    },
    
    auth_type = auth_type:bearer_token,
    provider = provider:pagerduty,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "apiToken",
                display_name: "API Token",
                type: "string",
                is_secret: true,
                required: true,
                description: "PagerDuty API token"
            }
        ],
        metadata: {
            incident_management: true,
            on_call_scheduling: true,
            alerting: true,
            devops: true
        }
    },
    
    documentation = {
        url: url:pagerduty_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 4. PAGERDUTY OAUTH2 API (display_order: 1043)
-- =====================================================

CREATE credential_type:pagerduty_oauth2_api SET
    name = "pagerDutyOAuth2Api",
    slug = "pagerduty-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_pagerduty_oauth2_api_name,
        description_i18n: i18n_key:credential_type_pagerduty_oauth2_api_description
    },
    
    presentation = {
        icon: icon:pagerduty,
        color_type: theme_color_type:success,
        tooltip_i18n: i18n_key:credential_type_pagerduty_oauth2_api_tooltip,
        display_order: 1043
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:pagerduty,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://app.pagerduty.com/oauth/token",
            authorization_url: "https://app.pagerduty.com/oauth/authorize",
            authentication_method: "header",
            scope: "write"
        },
        oauth1: NONE,
        required_fields: [],
        metadata: {
            oauth_recommended: true
        }
    },
    
    documentation = {
        url: url:pagerduty_oauth2_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 5. OPENWEATHERMAP API (display_order: 1044) ✨ TRÈS POPULAIRE
-- =====================================================

CREATE credential_type:openweathermap_api SET
    name = "openWeatherMapApi",
    slug = "openweathermap-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_openweathermap_api_name,
        description_i18n: i18n_key:credential_type_openweathermap_api_description
    },
    
    presentation = {
        icon: icon:openweathermap,
        color_type: theme_color_type:warning,
        tooltip_i18n: i18n_key:credential_type_openweathermap_api_tooltip,
        display_order: 1044
    },
    
    auth_type = auth_type:api_key,
    provider = provider:openweathermap,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "accessToken",
                display_name: "Access Token",
                type: "string",
                is_secret: true,
                required: true,
                description: "OpenWeatherMap API key"
            }
        ],
        metadata: {
            weather_data: true,
            free_tier: true,
            popular_api: true
        }
    },
    
    documentation = {
        url: url:openweathermap_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 6. NASA API (display_order: 1045)
-- =====================================================

CREATE credential_type:nasa_api SET
    name = "nasaApi",
    slug = "nasa-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_nasa_api_name,
        description_i18n: i18n_key:credential_type_nasa_api_description
    },
    
    presentation = {
        icon: icon:nasa,
        color_type: theme_color_type:info,
        tooltip_i18n: i18n_key:credential_type_nasa_api_tooltip,
        display_order: 1045
    },
    
    auth_type = auth_type:api_key,
    provider = provider:nasa,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "api_key",
                display_name: "API Key",
                type: "string",
                is_secret: true,
                required: true,
                description: "NASA Open API key"
            }
        ],
        metadata: {
            space_data: true,
            government_api: true,
            open_data: true,
            free: true
        }
    },
    
    documentation = {
        url: url:nasa_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 7. HUNTER API (display_order: 1046) ✨ TRÈS POPULAIRE
-- =====================================================

CREATE credential_type:hunter_api SET
    name = "hunterApi",
    slug = "hunter-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_hunter_api_name,
        description_i18n: i18n_key:credential_type_hunter_api_description
    },
    
    presentation = {
        icon: icon:hunter,
        color_type: theme_color_type:error,
        tooltip_i18n: i18n_key:credential_type_hunter_api_tooltip,
        display_order: 1046
    },
    
    auth_type = auth_type:api_key,
    provider = provider:hunter,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "apiKey",
                display_name: "API Key",
                type: "string",
                is_secret: true,
                required: true,
                description: "Hunter.io API key"
            }
        ],
        metadata: {
            email_finder: true,
            email_verification: true,
            sales_tool: true,
            data_enrichment: true
        }
    },
    
    documentation = {
        url: url:hunter_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 8. CLEARBIT API (display_order: 1047) ✨ TRÈS POPULAIRE
-- =====================================================

CREATE credential_type:clearbit_api SET
    name = "clearbitApi",
    slug = "clearbit-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_clearbit_api_name,
        description_i18n: i18n_key:credential_type_clearbit_api_description
    },
    
    presentation = {
        icon: icon:clearbit,
        color_type: theme_color_type:info,
        tooltip_i18n: i18n_key:credential_type_clearbit_api_tooltip,
        display_order: 1047
    },
    
    auth_type = auth_type:api_key,
    provider = provider:clearbit,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "apiKey",
                display_name: "API Key",
                type: "string",
                is_secret: true,
                required: true,
                description: "Clearbit API key"
            }
        ],
        metadata: {
            business_intelligence: true,
            data_enrichment: true,
            lead_enrichment: true,
            company_data: true
        }
    },
    
    documentation = {
        url: url:clearbit_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 9. RAINDROP OAUTH2 API (display_order: 1048)
-- =====================================================

CREATE credential_type:raindrop_oauth2_api SET
    name = "raindropOAuth2Api",
    slug = "raindrop-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_raindrop_oauth2_api_name,
        description_i18n: i18n_key:credential_type_raindrop_oauth2_api_description
    },
    
    presentation = {
        icon: icon:raindrop,
        color_type: theme_color_type:info,
        tooltip_i18n: i18n_key:credential_type_raindrop_oauth2_api_tooltip,
        display_order: 1048
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:raindrop,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://api.raindrop.io/v1/oauth/access_token",
            authorization_url: "https://raindrop.io/oauth/authorize",
            authentication_method: "body",
            scope: ""
        },
        oauth1: NONE,
        required_fields: [],
        metadata: {
            bookmark_manager: true,
            productivity: true,
            personal_tool: true
        }
    },
    
    documentation = {
        url: url:raindrop_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 10. THEHIVE API (display_order: 1049)
-- =====================================================

CREATE credential_type:thehive_api SET
    name = "theHiveApi",
    slug = "thehive-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_thehive_api_name,
        description_i18n: i18n_key:credential_type_thehive_api_description
    },
    
    presentation = {
        icon: icon:thehive,
        color_type: theme_color_type:warning,
        tooltip_i18n: i18n_key:credential_type_thehive_api_tooltip,
        display_order: 1049
    },
    
    auth_type = auth_type:bearer_token,
    provider = provider:thehive,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "ApiKey",
                display_name: "API Key",
                type: "string",
                is_secret: true,
                required: true,
                description: "TheHive API key"
            },
            {
                name: "url",
                display_name: "URL",
                type: "string",
                is_secret: false,
                required: true,
                description: "TheHive instance URL"
            },
            {
                name: "apiVersion",
                display_name: "API Version",
                type: "options",
                is_secret: false,
                required: true,
                description: "TheHive API version",
                options: [
                    { name: "TheHive 4+ (api v1)", value: "v1" },
                    { name: "TheHive 3 (api v0)", value: "" }
                ],
                default: "v1"
            },
            {
                name: "allowUnauthorizedCerts",
                display_name: "Ignore SSL Issues (Insecure)",
                type: "boolean",
                is_secret: false,
                required: false,
                description: "Connect even if SSL certificate validation is not possible",
                default: false
            }
        ],
        metadata: {
            security_incident_response: true,
            threat_intelligence: true,
            soc_tool: true,
            case_management: true,
            open_source: true
        }
    },
    
    documentation = {
        url: url:thehive_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- VÉRIFICATION
-- =====================================================

/*
SELECT 
    id,
    name,
    slug,
    identity.display_name_i18n AS display_name,
    presentation.color_daisy AS color,
    presentation.display_order AS order,
    auth_type.name AS auth_type_name,
    provider.name AS provider_name
FROM credential_type
WHERE presentation.display_order >= 1040 AND presentation.display_order <= 1050
ORDER BY presentation.display_order ASC;
*/

-- =====================================================
-- RÉSUMÉ BATCH 17
-- =====================================================
--
-- ✅ 10 credentials Monitoring, Observability, Data Enrichment & Productivity créés :
--
-- Monitoring & Observability (4) - display_order: 1040-1043 ✨ TRÈS POPULAIRE
--  1. splunk_api (1040) ✨ TRÈS POPULAIRE - Enterprise log management & SIEM
--  2. sentry_io_api (1041) ✨ TRÈS POPULAIRE - Error tracking & application monitoring
--  3. pagerduty_api (1042) ✨ TRÈS POPULAIRE - Incident management & on-call scheduling
--  4. pagerduty_oauth2_api (1043) - PagerDuty OAuth2 version
--
-- Data & Public APIs (4) - display_order: 1044-1047 ✨ TRÈS POPULAIRE
--  5. openweathermap_api (1044) ✨ TRÈS POPULAIRE - Weather data API (free tier)
--  6. nasa_api (1045) - NASA open data & space information
--  7. hunter_api (1046) ✨ TRÈS POPULAIRE - Email finder & verification
--  8. clearbit_api (1047) ✨ TRÈS POPULAIRE - Business intelligence & lead enrichment
--
-- Productivity & Security (2) - display_order: 1048-1049
--  9. raindrop_oauth2_api (1048) - Bookmark manager OAuth2
-- 10. thehive_api (1049) - Security incident response & threat intelligence (open-source)
--
-- Structure complète : identity, presentation, config, documentation
--
-- =============================================================================================

