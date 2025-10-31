-- =============================================================================================
-- |
-- | Fichier : credential_type_batch19_seeds.surql (SEED DATA)
-- | Module : integrations > reference > credentials > credential_type
-- | Description : Seeds pour le Batch 19 des credential types (11 credentials Diverse APIs).
-- |
-- | Batch 19 : Diverse APIs & Tools (11 credentials)
-- | Providers : Airtop, AlienVault, APITemplate.io, Azure Storage, Bannerbear, Beeminder, Bitly, Bitwarden
-- |
-- =============================================================================================

-- =====================================================
-- 1. AIRTOP API (display_order: 1080)
-- =====================================================

CREATE credential_type:airtop_api SET
    name = "airtopApi",
    slug = "airtop-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_airtop_api_name,
        description_i18n: i18n_key:credential_type_airtop_api_description
    },
    
    presentation = {
        icon: icon:airtop,
        color: "#4A90E2",
        color_daisy: "info",
        tooltip_i18n: i18n_key:credential_type_airtop_api_tooltip,
        display_order: 1080
    },
    
    auth_type = auth_type:bearer_token,
    provider = provider:airtop,
    
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
                description: "Airtop API key"
            }
        ],
        metadata: {
            ai_browser_automation: true,
            web_scraping: true,
            custom_header: "api-key"
        }
    },
    
    documentation = {
        url: url:airtop_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 2. ALIENVAULT API (display_order: 1081)
-- =====================================================

CREATE credential_type:alien_vault_api SET
    name = "alienVaultApi",
    slug = "alien-vault-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_alien_vault_api_name,
        description_i18n: i18n_key:credential_type_alien_vault_api_description
    },
    
    presentation = {
        icon: icon:alienvault,
        color: "#FF6B35",
        color_daisy: "error",
        tooltip_i18n: i18n_key:credential_type_alien_vault_api_tooltip,
        display_order: 1081
    },
    
    auth_type = auth_type:custom,
    provider = provider:alienvault,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "accessToken",
                display_name: "OTX Key",
                type: "string",
                is_secret: true,
                required: true,
                description: "AlienVault OTX API key"
            }
        ],
        metadata: {
            threat_intelligence: true,
            security: true,
            otx_platform: true,
            custom_header: "X-OTX-API-KEY"
        }
    },
    
    documentation = {
        url: url:alienvault_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 3. APITEMPLATE.IO API (display_order: 1082)
-- =====================================================

CREATE credential_type:api_template_io_api SET
    name = "apiTemplateIoApi",
    slug = "api-template-io-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_api_template_io_api_name,
        description_i18n: i18n_key:credential_type_api_template_io_api_description
    },
    
    presentation = {
        icon: icon:apitemplateio,
        color: "#6C63FF",
        color_daisy: "secondary",
        tooltip_i18n: i18n_key:credential_type_api_template_io_api_tooltip,
        display_order: 1082
    },
    
    auth_type = auth_type:api_key,
    provider = provider:apitemplateio,
    
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
                description: "APITemplate.io API key"
            }
        ],
        metadata: {
            template_generation: true,
            pdf_generation: true,
            image_generation: true,
            custom_header: "X-API-KEY"
        }
    },
    
    documentation = {
        url: url:apitemplateio_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 4. AZURE STORAGE SHARED KEY API (display_order: 1083)
-- =====================================================

CREATE credential_type:azure_storage_shared_key_api SET
    name = "azureStorageSharedKeyApi",
    slug = "azure-storage-shared-key-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_azure_storage_shared_key_api_name,
        description_i18n: i18n_key:credential_type_azure_storage_shared_key_api_description
    },
    
    presentation = {
        icon: icon:azure,
        color: "#0078D4",
        color_daisy: "info",
        tooltip_i18n: i18n_key:credential_type_azure_storage_shared_key_api_tooltip,
        display_order: 1083
    },
    
    auth_type = auth_type:custom,
    provider = provider:azure,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "account",
                display_name: "Account",
                type: "string",
                is_secret: false,
                required: true,
                description: "Azure storage account name"
            },
            {
                name: "key",
                display_name: "Key",
                type: "string",
                is_secret: true,
                required: true,
                description: "Azure storage account key"
            }
        ],
        metadata: {
            cloud_storage: true,
            microsoft_azure: true,
            blob_storage: true
        }
    },
    
    documentation = {
        url: url:azure_storage_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 5. AZURE STORAGE OAUTH2 API (display_order: 1084)
-- =====================================================

CREATE credential_type:azure_storage_oauth2_api SET
    name = "azureStorageOAuth2Api",
    slug = "azure-storage-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_azure_storage_oauth2_api_name,
        description_i18n: i18n_key:credential_type_azure_storage_oauth2_api_description
    },
    
    presentation = {
        icon: icon:azure,
        color: "#0078D4",
        color_daisy: "accent",
        tooltip_i18n: i18n_key:credential_type_azure_storage_oauth2_api_tooltip,
        display_order: 1084
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:azure,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://login.microsoftonline.com/common/oauth2/v2.0/token",
            authorization_url: "https://login.microsoftonline.com/common/oauth2/v2.0/authorize",
            authentication_method: "header",
            scope: "https://storage.azure.com/.default offline_access"
        },
        oauth1: NONE,
        required_fields: [],
        metadata: {
            oauth_recommended: true
        }
    },
    
    documentation = {
        url: url:azure_storage_oauth2_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 6. BANNERBEAR API (display_order: 1085)
-- =====================================================

CREATE credential_type:bannerbear_api SET
    name = "bannerbearApi",
    slug = "bannerbear-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_bannerbear_api_name,
        description_i18n: i18n_key:credential_type_bannerbear_api_description
    },
    
    presentation = {
        icon: icon:bannerbear,
        color: "#FF6B6B",
        color_daisy: "error",
        tooltip_i18n: i18n_key:credential_type_bannerbear_api_tooltip,
        display_order: 1085
    },
    
    auth_type = auth_type:bearer_token,
    provider = provider:bannerbear,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "apiKey",
                display_name: "Project API Key",
                type: "string",
                is_secret: true,
                required: true,
                description: "Bannerbear project API key"
            }
        ],
        metadata: {
            image_generation: true,
            video_generation: true,
            automation: true
        }
    },
    
    documentation = {
        url: url:bannerbear_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 7. BEEMINDER API (display_order: 1086)
-- =====================================================

CREATE credential_type:beeminder_api SET
    name = "beeminderApi",
    slug = "beeminder-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_beeminder_api_name,
        description_i18n: i18n_key:credential_type_beeminder_api_description
    },
    
    presentation = {
        icon: icon:beeminder,
        color: "#FFA500",
        color_daisy: "warning",
        tooltip_i18n: i18n_key:credential_type_beeminder_api_tooltip,
        display_order: 1086
    },
    
    auth_type = auth_type:custom,
    provider = provider:beeminder,
    
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
                description: "Beeminder authentication token"
            }
        ],
        metadata: {
            goal_tracking: true,
            productivity: true,
            quantified_self: true
        }
    },
    
    documentation = {
        url: url:beeminder_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 8. BEEMINDER OAUTH2 API (display_order: 1087)
-- =====================================================

CREATE credential_type:beeminder_oauth2_api SET
    name = "beeminderOAuth2Api",
    slug = "beeminder-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_beeminder_oauth2_api_name,
        description_i18n: i18n_key:credential_type_beeminder_oauth2_api_description
    },
    
    presentation = {
        icon: icon:beeminder,
        color: "#FFA500",
        color_daisy: "accent",
        tooltip_i18n: i18n_key:credential_type_beeminder_oauth2_api_tooltip,
        display_order: 1087
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:beeminder,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://www.beeminder.com/apps/authorize",
            authorization_url: "https://www.beeminder.com/apps/authorize",
            authentication_method: "body",
            scope: ""
        },
        oauth1: NONE,
        required_fields: [],
        metadata: {
            oauth_recommended: true
        }
    },
    
    documentation = {
        url: url:beeminder_oauth2_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 9. BITLY API (display_order: 1088)
-- =====================================================

CREATE credential_type:bitly_api SET
    name = "bitlyApi",
    slug = "bitly-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_bitly_api_name,
        description_i18n: i18n_key:credential_type_bitly_api_description
    },
    
    presentation = {
        icon: icon:bitly,
        color: "#EE6123",
        color_daisy: "error",
        tooltip_i18n: i18n_key:credential_type_bitly_api_tooltip,
        display_order: 1088
    },
    
    auth_type = auth_type:bearer_token,
    provider = provider:bitly,
    
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
                description: "Bitly access token"
            }
        ],
        metadata: {
            url_shortener: true,
            link_management: true,
            very_popular: true
        }
    },
    
    documentation = {
        url: url:bitly_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 10. BITLY OAUTH2 API (display_order: 1089)
-- =====================================================

CREATE credential_type:bitly_oauth2_api SET
    name = "bitlyOAuth2Api",
    slug = "bitly-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_bitly_oauth2_api_name,
        description_i18n: i18n_key:credential_type_bitly_oauth2_api_description
    },
    
    presentation = {
        icon: icon:bitly,
        color: "#EE6123",
        color_daisy: "accent",
        tooltip_i18n: i18n_key:credential_type_bitly_oauth2_api_tooltip,
        display_order: 1089
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:bitly,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://api-ssl.bitly.com/oauth/access_token",
            authorization_url: "https://bitly.com/oauth/authorize",
            authentication_method: "body",
            scope: ""
        },
        oauth1: NONE,
        required_fields: [],
        metadata: {
            oauth_recommended: true
        }
    },
    
    documentation = {
        url: url:bitly_oauth2_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 11. BITWARDEN API (display_order: 1090)
-- =====================================================

CREATE credential_type:bitwarden_api SET
    name = "bitwardenApi",
    slug = "bitwarden-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_bitwarden_api_name,
        description_i18n: i18n_key:credential_type_bitwarden_api_description
    },
    
    presentation = {
        icon: icon:bitwarden,
        color: "#175DDC",
        color_daisy: "info",
        tooltip_i18n: i18n_key:credential_type_bitwarden_api_tooltip,
        display_order: 1090
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:bitwarden,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "clientId",
                display_name: "Client ID",
                type: "string",
                is_secret: false,
                required: true,
                description: "Bitwarden client ID"
            },
            {
                name: "clientSecret",
                display_name: "Client Secret",
                type: "string",
                is_secret: true,
                required: true,
                description: "Bitwarden client secret"
            },
            {
                name: "environment",
                display_name: "Environment",
                type: "options",
                is_secret: false,
                required: true,
                description: "Bitwarden environment",
                options: [
                    { name: "Cloud-Hosted", value: "cloudHosted" },
                    { name: "Self-Hosted", value: "selfHosted" }
                ],
                default: "cloudHosted"
            },
            {
                name: "domain",
                display_name: "Self-Hosted Domain",
                type: "string",
                is_secret: false,
                required: false,
                description: "Self-hosted Bitwarden domain"
            }
        ],
        metadata: {
            password_manager: true,
            security: true,
            self_hosted_option: true
        }
    },
    
    documentation = {
        url: url:bitwarden_docs,
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
WHERE presentation.display_order >= 1080 AND presentation.display_order <= 1090
ORDER BY presentation.display_order ASC;
*/

-- =====================================================
-- RÉSUMÉ BATCH 19
-- =====================================================
--
-- ✅ 11 credentials Diverse APIs & Tools créés :
--
-- AI & Automation (1) - display_order: 1080
--  1. airtop_api (1080) - AI browser automation & web scraping
--
-- Security & Threat Intelligence (1) - display_order: 1081
--  2. alien_vault_api (1081) - Threat intelligence OTX platform
--
-- Template & Content Generation (2) - display_order: 1082-1085
--  3. api_template_io_api (1082) - PDF/image template generation
--  6. bannerbear_api (1085) - Image/video generation automation
--
-- Cloud Storage (2) - display_order: 1083-1084
--  4. azure_storage_shared_key_api (1083) - Azure blob storage (shared key)
--  5. azure_storage_oauth2_api (1084) - Azure blob storage (OAuth2)
--
-- Productivity & Goal Tracking (2) - display_order: 1086-1087
--  7. beeminder_api (1086) - Goal tracking & quantified self
--  8. beeminder_oauth2_api (1087) - Beeminder OAuth2 version
--
-- URL Management & Security (3) - display_order: 1088-1090
--  9. bitly_api (1088) ✨ TRÈS POPULAIRE - URL shortener
-- 10. bitly_oauth2_api (1089) - Bitly OAuth2 version
-- 11. bitwarden_api (1090) - Password manager (cloud/self-hosted)
--
-- Structure complète : identity, presentation, config, documentation
--
-- =============================================================================================

