-- =============================================================================================
-- |
-- | Fichier : credential_type_batch13_seeds.surql (SEED DATA)
-- | Module : integrations > reference > credentials > credential_type
-- | Description : Seeds pour le Batch 13 des credential types (11 credentials AI, Analytics & Developer Tools).
-- |
-- | Batch 13 : AI, Analytics & Developer Tools (11 credentials)
-- | Providers : OpenAI, Perplexity, DeepL, Datadog, Linear, Figma, Miro, N8n, Ghost
-- |
-- =============================================================================================

-- =====================================================
-- 1. OPENAI API (display_order: 960) ✨ TRÈS POPULAIRE
-- =====================================================

CREATE credential_type:openai_api SET
    name = "openAiApi",
    slug = "openai-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_openai_api_name,
        description_i18n: i18n_key:credential_type_openai_api_description
    },
    
    presentation = {
        icon: icon:openai,
        color_type: theme_color_type:success,
        tooltip_i18n: i18n_key:credential_type_openai_api_tooltip,
        display_order: 960
    },
    
    auth_type = auth_type:bearer_token,
    provider = provider:openai,
    
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
                description: "OpenAI API key"
            },
            {
                name: "organizationId",
                display_name: "Organization ID",
                type: "string",
                is_secret: false,
                required: false,
                description: "Optional: Organization ID for multi-org users"
            },
            {
                name: "url",
                display_name: "Base URL",
                type: "string",
                is_secret: false,
                required: false,
                description: "Override default API base URL",
                default: "https://api.openai.com/v1"
            }
        ],
        metadata: {
            ai_leader: true,
            supports_gpt: true,
            supports_dall_e: true,
            supports_whisper: true
        }
    },
    
    documentation = {
        url: url:openai_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 2. PERPLEXITY API (display_order: 961)
-- =====================================================

CREATE credential_type:perplexity_api SET
    name = "perplexityApi",
    slug = "perplexity-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_perplexity_api_name,
        description_i18n: i18n_key:credential_type_perplexity_api_description
    },
    
    presentation = {
        icon: icon:perplexity,
        color_type: theme_color_type:info,
        tooltip_i18n: i18n_key:credential_type_perplexity_api_tooltip,
        display_order: 961
    },
    
    auth_type = auth_type:bearer_token,
    provider = provider:perplexity,
    
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
                description: "Perplexity API key"
            }
        ],
        metadata: {
            ai_search: true,
            real_time_search: true
        }
    },
    
    documentation = {
        url: url:perplexity_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 3. DEEPL API (display_order: 962) ✨ TRÈS POPULAIRE
-- =====================================================

CREATE credential_type:deepl_api SET
    name = "deepLApi",
    slug = "deepl-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_deepl_api_name,
        description_i18n: i18n_key:credential_type_deepl_api_description
    },
    
    presentation = {
        icon: icon:deepl,
        color_type: theme_color_type:neutral,
        tooltip_i18n: i18n_key:credential_type_deepl_api_tooltip,
        display_order: 962
    },
    
    auth_type = auth_type:api_key,
    provider = provider:deepl,
    
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
                description: "DeepL API key"
            },
            {
                name: "apiPlan",
                display_name: "API Plan",
                type: "options",
                is_secret: false,
                required: true,
                description: "DeepL API plan type",
                options: [
                    { name: "Pro Plan", value: "pro" },
                    { name: "Free Plan", value: "free" }
                ],
                default: "pro"
            }
        ],
        metadata: {
            translation_leader: true,
            supports_29_languages: true
        }
    },
    
    documentation = {
        url: url:deepl_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 4. DATADOG API (display_order: 963) ✨ TRÈS POPULAIRE
-- =====================================================

CREATE credential_type:datadog_api SET
    name = "datadogApi",
    slug = "datadog-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_datadog_api_name,
        description_i18n: i18n_key:credential_type_datadog_api_description
    },
    
    presentation = {
        icon: icon:datadog,
        color: "#632CA6",
        color_daisy: "secondary",
        tooltip_i18n: i18n_key:credential_type_datadog_api_tooltip,
        display_order: 963
    },
    
    auth_type = auth_type:custom,
    provider = provider:datadog,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "url",
                display_name: "API URL",
                type: "string",
                is_secret: false,
                required: true,
                description: "Datadog API URL",
                default: "https://api.datadoghq.com"
            },
            {
                name: "apiKey",
                display_name: "API Key",
                type: "string",
                is_secret: true,
                required: true,
                description: "Datadog API key"
            },
            {
                name: "appKey",
                display_name: "Application Key",
                type: "string",
                is_secret: true,
                required: false,
                description: "Datadog application key (required for some endpoints)"
            }
        ],
        metadata: {
            monitoring_leader: true,
            observability_platform: true
        }
    },
    
    documentation = {
        url: url:datadog_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 5. LINEAR API (display_order: 964) ✨ TRÈS POPULAIRE
-- =====================================================

CREATE credential_type:linear_api SET
    name = "linearApi",
    slug = "linear-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_linear_api_name,
        description_i18n: i18n_key:credential_type_linear_api_description
    },
    
    presentation = {
        icon: icon:linear,
        color_type: theme_color_type:primary,
        tooltip_i18n: i18n_key:credential_type_linear_api_tooltip,
        display_order: 964
    },
    
    auth_type = auth_type:api_key,
    provider = provider:linear,
    
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
                description: "Linear API key (personal access token)"
            }
        ],
        metadata: {
            issue_tracking: true,
            project_management: true,
            modern_tool: true
        }
    },
    
    documentation = {
        url: url:linear_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 6. LINEAR OAUTH2 API (display_order: 965)
-- =====================================================

CREATE credential_type:linear_oauth2_api SET
    name = "linearOAuth2Api",
    slug = "linear-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_linear_oauth2_api_name,
        description_i18n: i18n_key:credential_type_linear_oauth2_api_description
    },
    
    presentation = {
        icon: icon:linear,
        color_type: theme_color_type:info,
        tooltip_i18n: i18n_key:credential_type_linear_oauth2_api_tooltip,
        display_order: 965
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:linear,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://api.linear.app/oauth/token",
            authorization_url: "https://linear.app/oauth/authorize",
            authentication_method: "body",
            scope: "read,write"
        },
        oauth1: NONE,
        required_fields: [],
        metadata: {
            oauth_preferred: true
        }
    },
    
    documentation = {
        url: url:linear_oauth2_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 7. FIGMA API (display_order: 966) ✨ TRÈS POPULAIRE
-- =====================================================

CREATE credential_type:figma_api SET
    name = "figmaApi",
    slug = "figma-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_figma_api_name,
        description_i18n: i18n_key:credential_type_figma_api_description
    },
    
    presentation = {
        icon: icon:figma,
        color_type: theme_color_type:error,
        tooltip_i18n: i18n_key:credential_type_figma_api_tooltip,
        display_order: 966
    },
    
    auth_type = auth_type:bearer_token,
    provider = provider:figma,
    
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
                description: "Figma personal access token"
            }
        ],
        metadata: {
            design_tool: true,
            collaboration_platform: true,
            industry_standard: true
        }
    },
    
    documentation = {
        url: url:figma_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 8. MIRO OAUTH2 API (display_order: 967) ✨ TRÈS POPULAIRE
-- =====================================================

CREATE credential_type:miro_oauth2_api SET
    name = "miroOAuth2Api",
    slug = "miro-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_miro_oauth2_api_name,
        description_i18n: i18n_key:credential_type_miro_oauth2_api_description
    },
    
    presentation = {
        icon: icon:miro,
        color_type: theme_color_type:warning,
        tooltip_i18n: i18n_key:credential_type_miro_oauth2_api_tooltip,
        display_order: 967
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:miro,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://api.miro.com/v1/oauth/token",
            authorization_url: "https://miro.com/oauth/authorize",
            authentication_method: "body",
            scope: ""
        },
        oauth1: NONE,
        required_fields: [],
        metadata: {
            visual_collaboration: true,
            whiteboard_platform: true
        }
    },
    
    documentation = {
        url: url:miro_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 9. N8N API (display_order: 968)
-- =====================================================

CREATE credential_type:n8n_api SET
    name = "n8nApi",
    slug = "n8n-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_n8n_api_name,
        description_i18n: i18n_key:credential_type_n8n_api_description
    },
    
    presentation = {
        icon: icon:n8n,
        color_type: theme_color_type:error,
        tooltip_i18n: i18n_key:credential_type_n8n_api_tooltip,
        display_order: 968
    },
    
    auth_type = auth_type:custom,
    provider = provider:n8n,
    
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
                description: "n8n instance base URL",
                placeholder: "https://<name>.app.n8n.cloud/api/v1"
            },
            {
                name: "apiKey",
                display_name: "API Key",
                type: "string",
                is_secret: true,
                required: true,
                description: "n8n API key"
            }
        ],
        metadata: {
            automation_platform: true,
            workflow_automation: true
        }
    },
    
    documentation = {
        url: url:n8n_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 10. GHOST ADMIN API (display_order: 969)
-- =====================================================

CREATE credential_type:ghost_admin_api SET
    name = "ghostAdminApi",
    slug = "ghost-admin-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_ghost_admin_api_name,
        description_i18n: i18n_key:credential_type_ghost_admin_api_description
    },
    
    presentation = {
        icon: icon:ghost,
        color_type: theme_color_type:neutral,
        tooltip_i18n: i18n_key:credential_type_ghost_admin_api_tooltip,
        display_order: 969
    },
    
    auth_type = auth_type:custom,
    provider = provider:ghost,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "url",
                display_name: "Ghost URL",
                type: "string",
                is_secret: false,
                required: true,
                description: "Ghost instance URL",
                placeholder: "https://your-blog.ghost.io"
            },
            {
                name: "apiKey",
                display_name: "Admin API Key",
                type: "string",
                is_secret: true,
                required: true,
                description: "Ghost Admin API key (format: id:secret)"
            }
        ],
        metadata: {
            cms_platform: true,
            admin_access: true,
            jwt_based: true
        }
    },
    
    documentation = {
        url: url:ghost_admin_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 11. GHOST CONTENT API (display_order: 970)
-- =====================================================

CREATE credential_type:ghost_content_api SET
    name = "ghostContentApi",
    slug = "ghost-content-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_ghost_content_api_name,
        description_i18n: i18n_key:credential_type_ghost_content_api_description
    },
    
    presentation = {
        icon: icon:ghost,
        color_type: theme_color_type:info,
        tooltip_i18n: i18n_key:credential_type_ghost_content_api_tooltip,
        display_order: 970
    },
    
    auth_type = auth_type:api_key,
    provider = provider:ghost,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "url",
                display_name: "Ghost URL",
                type: "string",
                is_secret: false,
                required: true,
                description: "Ghost instance URL",
                placeholder: "https://your-blog.ghost.io"
            },
            {
                name: "apiKey",
                display_name: "Content API Key",
                type: "string",
                is_secret: true,
                required: true,
                description: "Ghost Content API key (public API key)"
            }
        ],
        metadata: {
            cms_platform: true,
            read_only: true,
            public_api: true
        }
    },
    
    documentation = {
        url: url:ghost_content_docs,
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
WHERE presentation.display_order >= 960 AND presentation.display_order <= 970
ORDER BY presentation.display_order ASC;
*/

-- =====================================================
-- RÉSUMÉ BATCH 13
-- =====================================================
--
-- ✅ 11 credentials AI, Analytics & Developer Tools créés :
--
-- AI & Translation Services (3) - display_order: 960-962 ✨ TRÈS POPULAIRE
--  1. openai_api (960) ✨ TRÈS POPULAIRE - AI leader (GPT, DALL-E, Whisper)
--  2. perplexity_api (961) - AI search with real-time web access
--  3. deepl_api (962) ✨ TRÈS POPULAIRE - Translation leader (29 languages)
--
-- Analytics & Monitoring (1) - display_order: 963 ✨ TRÈS POPULAIRE
--  4. datadog_api (963) ✨ TRÈS POPULAIRE - Monitoring & observability platform
--
-- Developer & Project Management Tools (4) - display_order: 964-967 ✨ TRÈS POPULAIRE
--  5. linear_api (964) ✨ TRÈS POPULAIRE - Modern issue tracking
--  6. linear_oauth2_api (965) - Linear OAuth2 version
--  7. figma_api (966) ✨ TRÈS POPULAIRE - Design collaboration platform
--  8. miro_oauth2_api (967) ✨ TRÈS POPULAIRE - Visual collaboration & whiteboard
--
-- Automation & CMS (3) - display_order: 968-970
--  9. n8n_api (968) - Workflow automation platform
-- 10. ghost_admin_api (969) - Ghost CMS (admin access with JWT)
-- 11. ghost_content_api (970) - Ghost CMS (read-only public content)
--
-- Structure complète : identity, presentation, config, documentation
--
-- =============================================================================================
