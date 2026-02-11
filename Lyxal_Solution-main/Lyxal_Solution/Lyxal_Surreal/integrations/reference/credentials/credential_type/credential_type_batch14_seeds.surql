-- =============================================================================================
-- |
-- | Fichier : credential_type_batch14_seeds.surql (SEED DATA)
-- | Module : integrations > reference > credentials > credential_type
-- | Description : Seeds pour le Batch 14 des credential types (11 credentials No-Code, Analytics & Security).
-- |
-- | Batch 14 : No-Code, Analytics & Security Tools (11 credentials)
-- | Providers : Baserow, NocoDB, Grafana, Metabase, PostHog, Coda, Gong, Okta, Auth0
-- |
-- =============================================================================================

-- =====================================================
-- 1. BASEROW API (display_order: 980) ✨ TRÈS POPULAIRE
-- =====================================================

CREATE credential_type:baserow_api SET
    name = "baserowApi",
    slug = "baserow-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_baserow_api_name,
        description_i18n: i18n_key:credential_type_baserow_api_description
    },
    
    presentation = {
        icon: icon:baserow,
        color_type: theme_color_type:info,
        tooltip_i18n: i18n_key:credential_type_baserow_api_tooltip,
        display_order: 980
    },
    
    auth_type = auth_type:basic_auth,
    provider = provider:baserow,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "host",
                display_name: "Host URL",
                type: "string",
                is_secret: false,
                required: true,
                description: "Baserow instance URL",
                default: "https://api.baserow.io"
            },
            {
                name: "username",
                display_name: "Username",
                type: "string",
                is_secret: false,
                required: true,
                description: "Baserow account username/email"
            },
            {
                name: "password",
                display_name: "Password",
                type: "string",
                is_secret: true,
                required: true,
                description: "Baserow account password"
            }
        ],
        metadata: {
            no_code_database: true,
            open_source: true,
            airtable_alternative: true
        }
    },
    
    documentation = {
        url: url:baserow_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 2. NOCODB (display_order: 981) ✨ TRÈS POPULAIRE
-- =====================================================

CREATE credential_type:nocodb SET
    name = "nocoDb",
    slug = "nocodb",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_nocodb_name,
        description_i18n: i18n_key:credential_type_nocodb_description
    },
    
    presentation = {
        icon: icon:nocodb,
        color_type: theme_color_type:warning,
        tooltip_i18n: i18n_key:credential_type_nocodb_tooltip,
        display_order: 981
    },
    
    auth_type = auth_type:custom,
    provider = provider:nocodb,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "host",
                display_name: "Host URL",
                type: "string",
                is_secret: false,
                required: true,
                description: "NocoDB instance URL",
                placeholder: "http(s)://localhost:8080"
            },
            {
                name: "apiToken",
                display_name: "User Token",
                type: "string",
                is_secret: true,
                required: true,
                description: "NocoDB user authentication token"
            }
        ],
        metadata: {
            no_code_database: true,
            open_source: true,
            airtable_alternative: true,
            header_auth: "xc-auth"
        }
    },
    
    documentation = {
        url: url:nocodb_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 3. NOCODB API TOKEN (display_order: 982)
-- =====================================================

CREATE credential_type:nocodb_api_token SET
    name = "nocoDbApiToken",
    slug = "nocodb-api-token",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_nocodb_api_token_name,
        description_i18n: i18n_key:credential_type_nocodb_api_token_description
    },
    
    presentation = {
        icon: icon:nocodb,
        color_type: theme_color_type:error,
        tooltip_i18n: i18n_key:credential_type_nocodb_api_token_tooltip,
        display_order: 982
    },
    
    auth_type = auth_type:custom,
    provider = provider:nocodb,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "host",
                display_name: "Host URL",
                type: "string",
                is_secret: false,
                required: true,
                description: "NocoDB instance URL",
                placeholder: "http(s)://localhost:8080"
            },
            {
                name: "apiToken",
                display_name: "API Token",
                type: "string",
                is_secret: true,
                required: true,
                description: "NocoDB API token (project-specific)"
            }
        ],
        metadata: {
            token_based: true,
            project_scoped: true,
            header_auth: "xc-token"
        }
    },
    
    documentation = {
        url: url:nocodb_api_token_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 4. GRAFANA API (display_order: 983) ✨ TRÈS POPULAIRE
-- =====================================================

CREATE credential_type:grafana_api SET
    name = "grafanaApi",
    slug = "grafana-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_grafana_api_name,
        description_i18n: i18n_key:credential_type_grafana_api_description
    },
    
    presentation = {
        icon: icon:grafana,
        color_type: theme_color_type:warning,
        tooltip_i18n: i18n_key:credential_type_grafana_api_tooltip,
        display_order: 983
    },
    
    auth_type = auth_type:bearer_token,
    provider = provider:grafana,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "baseUrl",
                display_name: "Base URL",
                type: "string",
                is_secret: false,
                required: true,
                description: "Grafana instance base URL",
                placeholder: "https://n8n.grafana.net/"
            },
            {
                name: "apiKey",
                display_name: "API Key",
                type: "string",
                is_secret: true,
                required: true,
                description: "Grafana API key"
            }
        ],
        metadata: {
            monitoring_platform: true,
            dashboards_and_metrics: true,
            observability: true
        }
    },
    
    documentation = {
        url: url:grafana_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 5. METABASE API (display_order: 984) ✨ TRÈS POPULAIRE
-- =====================================================

CREATE credential_type:metabase_api SET
    name = "metabaseApi",
    slug = "metabase-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_metabase_api_name,
        description_i18n: i18n_key:credential_type_metabase_api_description
    },
    
    presentation = {
        icon: icon:metabase,
        color_type: theme_color_type:info,
        tooltip_i18n: i18n_key:credential_type_metabase_api_tooltip,
        display_order: 984
    },
    
    auth_type = auth_type:custom,
    provider = provider:metabase,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "url",
                display_name: "Metabase URL",
                type: "string",
                is_secret: false,
                required: true,
                description: "Metabase instance URL"
            },
            {
                name: "username",
                display_name: "Username",
                type: "string",
                is_secret: false,
                required: true,
                description: "Metabase account username"
            },
            {
                name: "password",
                display_name: "Password",
                type: "string",
                is_secret: true,
                required: true,
                description: "Metabase account password"
            }
        ],
        metadata: {
            business_intelligence: true,
            analytics_platform: true,
            session_based_auth: true,
            open_source: true
        }
    },
    
    documentation = {
        url: url:metabase_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 6. POSTHOG API (display_order: 985) ✨ TRÈS POPULAIRE
-- =====================================================

CREATE credential_type:posthog_api SET
    name = "postHogApi",
    slug = "posthog-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_posthog_api_name,
        description_i18n: i18n_key:credential_type_posthog_api_description
    },
    
    presentation = {
        icon: icon:posthog,
        color_type: theme_color_type:primary,
        tooltip_i18n: i18n_key:credential_type_posthog_api_tooltip,
        display_order: 985
    },
    
    auth_type = auth_type:api_key,
    provider = provider:posthog,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "url",
                display_name: "PostHog URL",
                type: "string",
                is_secret: false,
                required: true,
                description: "PostHog instance URL",
                default: "https://app.posthog.com"
            },
            {
                name: "apiKey",
                display_name: "API Key",
                type: "string",
                is_secret: true,
                required: true,
                description: "PostHog personal API key"
            }
        ],
        metadata: {
            product_analytics: true,
            feature_flags: true,
            session_recording: true,
            open_source: true
        }
    },
    
    documentation = {
        url: url:posthog_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 7. CODA API (display_order: 986) ✨ TRÈS POPULAIRE
-- =====================================================

CREATE credential_type:coda_api SET
    name = "codaApi",
    slug = "coda-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_coda_api_name,
        description_i18n: i18n_key:credential_type_coda_api_description
    },
    
    presentation = {
        icon: icon:coda,
        color_type: theme_color_type:error,
        tooltip_i18n: i18n_key:credential_type_coda_api_tooltip,
        display_order: 986
    },
    
    auth_type = auth_type:bearer_token,
    provider = provider:coda,
    
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
                description: "Coda API access token"
            }
        ],
        metadata: {
            document_automation: true,
            collaborative_docs: true,
            all_in_one_platform: true
        }
    },
    
    documentation = {
        url: url:coda_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 8. GONG API (display_order: 987)
-- =====================================================

CREATE credential_type:gong_api SET
    name = "gongApi",
    slug = "gong-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_gong_api_name,
        description_i18n: i18n_key:credential_type_gong_api_description
    },
    
    presentation = {
        icon: icon:gong,
        color_type: theme_color_type:error,
        tooltip_i18n: i18n_key:credential_type_gong_api_tooltip,
        display_order: 987
    },
    
    auth_type = auth_type:basic_auth,
    provider = provider:gong,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "baseUrl",
                display_name: "Base URL",
                type: "string",
                is_secret: false,
                required: true,
                description: "Gong API base URL",
                default: "https://api.gong.io"
            },
            {
                name: "accessKey",
                display_name: "Access Key",
                type: "string",
                is_secret: true,
                required: true,
                description: "Gong API access key"
            },
            {
                name: "accessKeySecret",
                display_name: "Access Key Secret",
                type: "string",
                is_secret: true,
                required: true,
                description: "Gong API access key secret"
            }
        ],
        metadata: {
            revenue_intelligence: true,
            conversation_analytics: true,
            sales_platform: true
        }
    },
    
    documentation = {
        url: url:gong_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 9. GONG OAUTH2 API (display_order: 988)
-- =====================================================

CREATE credential_type:gong_oauth2_api SET
    name = "gongOAuth2Api",
    slug = "gong-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_gong_oauth2_api_name,
        description_i18n: i18n_key:credential_type_gong_oauth2_api_description
    },
    
    presentation = {
        icon: icon:gong,
        color_type: theme_color_type:warning,
        tooltip_i18n: i18n_key:credential_type_gong_oauth2_api_tooltip,
        display_order: 988
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:gong,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://app.gong.io/oauth2/generate-customer-token",
            authorization_url: "https://app.gong.io/oauth2/authorize",
            authentication_method: "header",
            scope: "api:calls:read:transcript api:calls:read:basic api:users:read api:meetings:user:create"
        },
        oauth1: NONE,
        required_fields: [
            {
                name: "baseUrl",
                display_name: "Base URL",
                type: "string",
                is_secret: false,
                required: false,
                description: "Gong API base URL",
                default: "https://api.gong.io"
            }
        ],
        metadata: {
            oauth_recommended: true
        }
    },
    
    documentation = {
        url: url:gong_oauth2_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 10. OKTA API (display_order: 989) ✨ TRÈS POPULAIRE
-- =====================================================

CREATE credential_type:okta_api SET
    name = "oktaApi",
    slug = "okta-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_okta_api_name,
        description_i18n: i18n_key:credential_type_okta_api_description
    },
    
    presentation = {
        icon: icon:okta,
        color_type: theme_color_type:info,
        tooltip_i18n: i18n_key:credential_type_okta_api_tooltip,
        display_order: 989
    },
    
    auth_type = auth_type:custom,
    provider = provider:okta,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "url",
                display_name: "Okta Domain URL",
                type: "string",
                is_secret: false,
                required: true,
                description: "Okta domain URL",
                placeholder: "https://dev-123456.okta.com"
            },
            {
                name: "accessToken",
                display_name: "Access Token",
                type: "string",
                is_secret: true,
                required: true,
                description: "Okta SSWS (Secure Single Web Service) access token"
            }
        ],
        metadata: {
            identity_management: true,
            sso_provider: true,
            enterprise_security: true,
            custom_header: "SSWS"
        }
    },
    
    documentation = {
        url: url:okta_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 11. AUTH0 MANAGEMENT API (display_order: 990) ✨ TRÈS POPULAIRE
-- =====================================================

CREATE credential_type:auth0_management_api SET
    name = "auth0ManagementApi",
    slug = "auth0-management-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_auth0_management_api_name,
        description_i18n: i18n_key:credential_type_auth0_management_api_description
    },
    
    presentation = {
        icon: icon:auth0,
        color_type: theme_color_type:error,
        tooltip_i18n: i18n_key:credential_type_auth0_management_api_tooltip,
        display_order: 990
    },
    
    auth_type = auth_type:custom,
    provider = provider:auth0,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "domain",
                display_name: "Auth0 Domain",
                type: "string",
                is_secret: false,
                required: true,
                description: "Auth0 tenant domain",
                placeholder: "your-domain.eu.auth0.com"
            },
            {
                name: "clientId",
                display_name: "Client ID",
                type: "string",
                is_secret: false,
                required: true,
                description: "Auth0 application client ID"
            },
            {
                name: "clientSecret",
                display_name: "Client Secret",
                type: "string",
                is_secret: true,
                required: true,
                description: "Auth0 application client secret"
            }
        ],
        metadata: {
            identity_management: true,
            authentication_platform: true,
            oauth2_provider: true,
            session_token_auth: true
        }
    },
    
    documentation = {
        url: url:auth0_management_docs,
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
WHERE presentation.display_order >= 980 AND presentation.display_order <= 990
ORDER BY presentation.display_order ASC;
*/

-- =====================================================
-- RÉSUMÉ BATCH 14
-- =====================================================
--
-- ✅ 11 credentials No-Code, Analytics & Security créés :
--
-- No-Code Database Platforms (3) - display_order: 980-982 ✨ TRÈS POPULAIRE
--  1. baserow_api (980) ✨ TRÈS POPULAIRE - Open-source Airtable alternative
--  2. nocodb (981) ✨ TRÈS POPULAIRE - No-code database (user token auth)
--  3. nocodb_api_token (982) - NocoDB API token (project-scoped)
--
-- Analytics & BI Platforms (3) - display_order: 983-985 ✨ TRÈS POPULAIRE
--  4. grafana_api (983) ✨ TRÈS POPULAIRE - Monitoring & dashboards
--  5. metabase_api (984) ✨ TRÈS POPULAIRE - Open-source BI platform
--  6. posthog_api (985) ✨ TRÈS POPULAIRE - Product analytics & feature flags
--
-- Productivity & Collaboration (1) - display_order: 986 ✨ TRÈS POPULAIRE
--  7. coda_api (986) ✨ TRÈS POPULAIRE - All-in-one collaborative workspace
--
-- Revenue Intelligence (2) - display_order: 987-988
--  8. gong_api (987) - Conversation analytics (basic auth)
--  9. gong_oauth2_api (988) - Gong OAuth2 version
--
-- Identity & Security (2) - display_order: 989-990 ✨ TRÈS POPULAIRE
-- 10. okta_api (989) ✨ TRÈS POPULAIRE - Enterprise identity management & SSO
-- 11. auth0_management_api (990) ✨ TRÈS POPULAIRE - Authentication & identity platform
--
-- Structure complète : identity, presentation, config, documentation
--
-- =============================================================================================

