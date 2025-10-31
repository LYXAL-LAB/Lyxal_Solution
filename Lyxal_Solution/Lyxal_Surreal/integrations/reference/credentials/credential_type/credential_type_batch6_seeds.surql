-- =============================================================================================
-- |
-- | Fichier : credential_type_batch6_seeds.surql (SEED DATA)
-- | Module : integrations > reference > credentials > credential_type
-- | Description : Seeds pour le Batch 6 des credential types (17 credentials Business/CRM).
-- |
-- | Batch 6 : Top Business/CRM (17 credentials)
-- | Providers : HubSpot, Salesforce, Stripe, Shopify, Pipedrive, Zoho, Copper, ActiveCampaign, Mailchimp
-- |
-- =============================================================================================

-- =====================================================
-- 1. HUBSPOT API (display_order: 500) ✨ TRÈS POPULAIRE
-- =====================================================

CREATE credential_type:hubspot_api SET
    name = "hubspotApi",
    slug = "hubspot-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_hubspot_api_name,
        description_i18n: i18n_key:credential_type_hubspot_api_description
    },
    
    presentation = {
        icon: icon:hubspot,
        color: "#FF7A59",
        color_daisy: "warning",
        tooltip_i18n: i18n_key:credential_type_hubspot_api_tooltip,
        display_order: 500
    },
    
    auth_type = auth_type:api_key,
    provider = provider:hubspot,
    
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
                description: "HubSpot API key (deprecated, use App Token or OAuth2)"
            }
        ],
        metadata: {
            deprecated: true,
            prefer: "hubspotAppToken"
        }
    },
    
    documentation = {
        url: url:hubspot_api_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 2. HUBSPOT APP TOKEN (display_order: 501) ✨ TRÈS POPULAIRE
-- =====================================================

CREATE credential_type:hubspot_app_token SET
    name = "hubspotAppToken",
    slug = "hubspot-app-token",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_hubspot_app_token_name,
        description_i18n: i18n_key:credential_type_hubspot_app_token_description
    },
    
    presentation = {
        icon: icon:hubspot,
        color: "#FF7A59",
        color_daisy: "warning",
        tooltip_i18n: i18n_key:credential_type_hubspot_app_token_tooltip,
        display_order: 501
    },
    
    auth_type = auth_type:bearer_token,
    provider = provider:hubspot,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "appToken",
                display_name: "Private App Token",
                type: "string",
                is_secret: true,
                required: true,
                description: "HubSpot Private App access token"
            }
        ],
        metadata: {
            recommended: true,
            auth_method: "private_app"
        }
    },
    
    documentation = {
        url: url:hubspot_app_token_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 3. HUBSPOT DEVELOPER API (display_order: 502)
-- =====================================================

CREATE credential_type:hubspot_developer_api SET
    name = "hubspotDeveloperApi",
    slug = "hubspot-developer-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_hubspot_developer_api_name,
        description_i18n: i18n_key:credential_type_hubspot_developer_api_description
    },
    
    presentation = {
        icon: icon:hubspot,
        color: "#FF7A59",
        color_daisy: "accent",
        tooltip_i18n: i18n_key:credential_type_hubspot_developer_api_tooltip,
        display_order: 502
    },
    
    auth_type = auth_type:bearer_token,
    provider = provider:hubspot,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "apiKey",
                display_name: "Developer API Key",
                type: "string",
                is_secret: true,
                required: true,
                description: "HubSpot Developer API key"
            }
        ],
        metadata: {
            for_developers: true
        }
    },
    
    documentation = {
        url: url:hubspot_developer_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 4. HUBSPOT OAUTH2 API (display_order: 503)
-- =====================================================

CREATE credential_type:hubspot_oauth2_api SET
    name = "hubspotOAuth2Api",
    slug = "hubspot-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_hubspot_oauth2_api_name,
        description_i18n: i18n_key:credential_type_hubspot_oauth2_api_description
    },
    
    presentation = {
        icon: icon:hubspot,
        color: "#FF7A59",
        color_daisy: "primary",
        tooltip_i18n: i18n_key:credential_type_hubspot_oauth2_api_tooltip,
        display_order: 503
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:hubspot,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://api.hubapi.com/oauth/v1/token",
            authorization_url: "https://app.hubspot.com/oauth/authorize",
            authentication_method: "body",
            scope: "contacts content"
        },
        oauth1: NONE,
        required_fields: [],
        metadata: {
            for_public_apps: true
        }
    },
    
    documentation = {
        url: url:hubspot_oauth2_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 5. SALESFORCE JWT API (display_order: 510)
-- =====================================================

CREATE credential_type:salesforce_jwt_api SET
    name = "salesforceJwtApi",
    slug = "salesforce-jwt-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_salesforce_jwt_api_name,
        description_i18n: i18n_key:credential_type_salesforce_jwt_api_description
    },
    
    presentation = {
        icon: icon:salesforce,
        color: "#00A1E0",
        color_daisy: "info",
        tooltip_i18n: i18n_key:credential_type_salesforce_jwt_api_tooltip,
        display_order: 510
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:salesforce,
    
    config = {
        oauth2: {
            grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
            access_token_url: "={{$parameter[\"environment\"] === \"sandbox\" ? \"https://test.salesforce.com\" : \"https://login.salesforce.com\"}}/services/oauth2/token",
            authentication_method: "body",
            scope: ""
        },
        oauth1: NONE,
        required_fields: [
            {
                name: "clientId",
                display_name: "Client ID",
                type: "string",
                is_secret: false,
                required: true,
                description: "Salesforce Connected App Consumer Key"
            },
            {
                name: "privateKey",
                display_name: "Private Key",
                type: "string",
                is_secret: true,
                required: true,
                description: "Private key for JWT signing"
            },
            {
                name: "username",
                display_name: "Username",
                type: "string",
                is_secret: false,
                required: true,
                description: "Salesforce username"
            }
        ],
        metadata: {
            auth_method: "jwt_bearer",
            server_to_server: true
        }
    },
    
    documentation = {
        url: url:salesforce_jwt_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 6. SALESFORCE OAUTH2 API (display_order: 511) ✨ TRÈS POPULAIRE
-- =====================================================

CREATE credential_type:salesforce_oauth2_api SET
    name = "salesforceOAuth2Api",
    slug = "salesforce-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_salesforce_oauth2_api_name,
        description_i18n: i18n_key:credential_type_salesforce_oauth2_api_description
    },
    
    presentation = {
        icon: icon:salesforce,
        color: "#00A1E0",
        color_daisy: "primary",
        tooltip_i18n: i18n_key:credential_type_salesforce_oauth2_api_tooltip,
        display_order: 511
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:salesforce,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "={{$parameter[\"environment\"] === \"sandbox\" ? \"https://test.salesforce.com\" : \"https://login.salesforce.com\"}}/services/oauth2/token",
            authorization_url: "={{$parameter[\"environment\"] === \"sandbox\" ? \"https://test.salesforce.com\" : \"https://login.salesforce.com\"}}/services/oauth2/authorize",
            authentication_method: "body",
            scope: "full refresh_token"
        },
        oauth1: NONE,
        required_fields: [
            {
                name: "environment",
                display_name: "Environment",
                type: "options",
                is_secret: false,
                required: true,
                description: "Salesforce environment",
                options: [
                    { name: "Production", value: "production" },
                    { name: "Sandbox", value: "sandbox" }
                ],
                default: "production"
            }
        ],
        metadata: {
            supports_sandbox: true
        }
    },
    
    documentation = {
        url: url:salesforce_oauth2_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 7. STRIPE API (display_order: 520) ✨ TRÈS POPULAIRE
-- =====================================================

CREATE credential_type:stripe_api SET
    name = "stripeApi",
    slug = "stripe-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_stripe_api_name,
        description_i18n: i18n_key:credential_type_stripe_api_description
    },
    
    presentation = {
        icon: icon:stripe,
        color: "#635BFF",
        color_daisy: "primary",
        tooltip_i18n: i18n_key:credential_type_stripe_api_tooltip,
        display_order: 520
    },
    
    auth_type = auth_type:bearer_token,
    provider = provider:stripe,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "secretKey",
                display_name: "Secret Key",
                type: "string",
                is_secret: true,
                required: true,
                description: "Stripe secret API key (starts with sk_)"
            }
        ],
        metadata: {
            test_mode_supported: true
        }
    },
    
    documentation = {
        url: url:stripe_api_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 8. SHOPIFY API (display_order: 530) ✨ TRÈS POPULAIRE
-- =====================================================

CREATE credential_type:shopify_api SET
    name = "shopifyApi",
    slug = "shopify-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_shopify_api_name,
        description_i18n: i18n_key:credential_type_shopify_api_description
    },
    
    presentation = {
        icon: icon:shopify,
        color: "#96BF48",
        color_daisy: "success",
        tooltip_i18n: i18n_key:credential_type_shopify_api_tooltip,
        display_order: 530
    },
    
    auth_type = auth_type:basic_auth,
    provider = provider:shopify,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "shopSubdomain",
                display_name: "Shop Subdomain",
                type: "string",
                is_secret: false,
                required: true,
                description: "Shopify shop subdomain (e.g., yourstore)",
                placeholder: "yourstore"
            },
            {
                name: "apiKey",
                display_name: "API Key",
                type: "string",
                is_secret: false,
                required: true,
                description: "Shopify API key"
            },
            {
                name: "password",
                display_name: "API Password",
                type: "string",
                is_secret: true,
                required: true,
                description: "Shopify API password"
            },
            {
                name: "sharedSecret",
                display_name: "Shared Secret",
                type: "string",
                is_secret: true,
                required: true,
                description: "Shopify shared secret"
            }
        ],
        metadata: {
            deprecated: true,
            prefer: "shopifyAccessTokenApi"
        }
    },
    
    documentation = {
        url: url:shopify_api_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 9. SHOPIFY ACCESS TOKEN API (display_order: 531) ✨ TRÈS POPULAIRE
-- =====================================================

CREATE credential_type:shopify_access_token_api SET
    name = "shopifyAccessTokenApi",
    slug = "shopify-access-token-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_shopify_access_token_api_name,
        description_i18n: i18n_key:credential_type_shopify_access_token_api_description
    },
    
    presentation = {
        icon: icon:shopify,
        color: "#96BF48",
        color_daisy: "success",
        tooltip_i18n: i18n_key:credential_type_shopify_access_token_api_tooltip,
        display_order: 531
    },
    
    auth_type = auth_type:bearer_token,
    provider = provider:shopify,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "shopSubdomain",
                display_name: "Shop Subdomain",
                type: "string",
                is_secret: false,
                required: true,
                description: "Shopify shop subdomain",
                placeholder: "yourstore"
            },
            {
                name: "accessToken",
                display_name: "Access Token",
                type: "string",
                is_secret: true,
                required: true,
                description: "Shopify Admin API access token"
            }
        ],
        metadata: {
            recommended: true
        }
    },
    
    documentation = {
        url: url:shopify_access_token_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 10. SHOPIFY OAUTH2 API (display_order: 532)
-- =====================================================

CREATE credential_type:shopify_oauth2_api SET
    name = "shopifyOAuth2Api",
    slug = "shopify-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_shopify_oauth2_api_name,
        description_i18n: i18n_key:credential_type_shopify_oauth2_api_description
    },
    
    presentation = {
        icon: icon:shopify,
        color: "#96BF48",
        color_daisy: "primary",
        tooltip_i18n: i18n_key:credential_type_shopify_oauth2_api_tooltip,
        display_order: 532
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:shopify,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "={{$parameter[\"shopSubdomain\"]}}.myshopify.com/admin/oauth/access_token",
            authorization_url: "={{$parameter[\"shopSubdomain\"]}}.myshopify.com/admin/oauth/authorize",
            authentication_method: "body",
            scope: "read_products write_products"
        },
        oauth1: NONE,
        required_fields: [
            {
                name: "shopSubdomain",
                display_name: "Shop Subdomain",
                type: "string",
                is_secret: false,
                required: true,
                description: "Shopify shop subdomain",
                placeholder: "yourstore"
            }
        ],
        metadata: {
            for_public_apps: true
        }
    },
    
    documentation = {
        url: url:shopify_oauth2_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 11. PIPEDRIVE API (display_order: 540) ✨ POPULAIRE
-- =====================================================

CREATE credential_type:pipedrive_api SET
    name = "pipedriveApi",
    slug = "pipedrive-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_pipedrive_api_name,
        description_i18n: i18n_key:credential_type_pipedrive_api_description
    },
    
    presentation = {
        icon: icon:pipedrive,
        color: "#000000",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:credential_type_pipedrive_api_tooltip,
        display_order: 540
    },
    
    auth_type = auth_type:api_key,
    provider = provider:pipedrive,
    
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
                description: "Pipedrive API token"
            }
        ],
        metadata: {}
    },
    
    documentation = {
        url: url:pipedrive_api_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 12. PIPEDRIVE OAUTH2 API (display_order: 541)
-- =====================================================

CREATE credential_type:pipedrive_oauth2_api SET
    name = "pipedriveOAuth2Api",
    slug = "pipedrive-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_pipedrive_oauth2_api_name,
        description_i18n: i18n_key:credential_type_pipedrive_oauth2_api_description
    },
    
    presentation = {
        icon: icon:pipedrive,
        color: "#000000",
        color_daisy: "primary",
        tooltip_i18n: i18n_key:credential_type_pipedrive_oauth2_api_tooltip,
        display_order: 541
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:pipedrive,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://oauth.pipedrive.com/oauth/token",
            authorization_url: "https://oauth.pipedrive.com/oauth/authorize",
            authentication_method: "body",
            scope: ""
        },
        oauth1: NONE,
        required_fields: [],
        metadata: {}
    },
    
    documentation = {
        url: url:pipedrive_oauth2_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 13. ZOHO OAUTH2 API (display_order: 550)
-- =====================================================

CREATE credential_type:zoho_oauth2_api SET
    name = "zohoOAuth2Api",
    slug = "zoho-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_zoho_oauth2_api_name,
        description_i18n: i18n_key:credential_type_zoho_oauth2_api_description
    },
    
    presentation = {
        icon: icon:zoho,
        color: "#C8252E",
        color_daisy: "error",
        tooltip_i18n: i18n_key:credential_type_zoho_oauth2_api_tooltip,
        display_order: 550
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:zoho,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://accounts.zoho.com/oauth/v2/token",
            authorization_url: "https://accounts.zoho.com/oauth/v2/auth",
            authentication_method: "body",
            scope: "ZohoCRM.modules.ALL"
        },
        oauth1: NONE,
        required_fields: [],
        metadata: {
            multi_region: true
        }
    },
    
    documentation = {
        url: url:zoho_oauth2_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 14. COPPER API (display_order: 560)
-- =====================================================

CREATE credential_type:copper_api SET
    name = "copperApi",
    slug = "copper-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_copper_api_name,
        description_i18n: i18n_key:credential_type_copper_api_description
    },
    
    presentation = {
        icon: icon:copper,
        color: "#EC7357",
        color_daisy: "warning",
        tooltip_i18n: i18n_key:credential_type_copper_api_tooltip,
        display_order: 560
    },
    
    auth_type = auth_type:api_key,
    provider = provider:copper,
    
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
                description: "Copper API key"
            },
            {
                name: "email",
                display_name: "Email",
                type: "string",
                is_secret: false,
                required: true,
                description: "Copper account email"
            }
        ],
        metadata: {
            google_workspace_integration: true
        }
    },
    
    documentation = {
        url: url:copper_api_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 15. ACTIVECAMPAIGN API (display_order: 570)
-- =====================================================

CREATE credential_type:activecampaign_api SET
    name = "activeCampaignApi",
    slug = "activecampaign-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_activecampaign_api_name,
        description_i18n: i18n_key:credential_type_activecampaign_api_description
    },
    
    presentation = {
        icon: icon:activecampaign,
        color: "#356AE6",
        color_daisy: "info",
        tooltip_i18n: i18n_key:credential_type_activecampaign_api_tooltip,
        display_order: 570
    },
    
    auth_type = auth_type:api_key,
    provider = provider:activecampaign,
    
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
                description: "ActiveCampaign API key"
            },
            {
                name: "baseUrl",
                display_name: "Base URL",
                type: "string",
                is_secret: false,
                required: true,
                description: "ActiveCampaign account URL",
                placeholder: "https://youraccou nt.api-us1.com"
            }
        ],
        metadata: {}
    },
    
    documentation = {
        url: url:activecampaign_api_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 16. MAILCHIMP API (display_order: 580) ✨ TRÈS POPULAIRE
-- =====================================================

CREATE credential_type:mailchimp_api SET
    name = "mailchimpApi",
    slug = "mailchimp-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_mailchimp_api_name,
        description_i18n: i18n_key:credential_type_mailchimp_api_description
    },
    
    presentation = {
        icon: icon:mailchimp,
        color: "#FFE01B",
        color_daisy: "warning",
        tooltip_i18n: i18n_key:credential_type_mailchimp_api_tooltip,
        display_order: 580
    },
    
    auth_type = auth_type:api_key,
    provider = provider:mailchimp,
    
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
                description: "Mailchimp API key"
            }
        ],
        metadata: {
            auto_detect_datacenter: true
        }
    },
    
    documentation = {
        url: url:mailchimp_api_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 17. MAILCHIMP OAUTH2 API (display_order: 581)
-- =====================================================

CREATE credential_type:mailchimp_oauth2_api SET
    name = "mailchimpOAuth2Api",
    slug = "mailchimp-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_mailchimp_oauth2_api_name,
        description_i18n: i18n_key:credential_type_mailchimp_oauth2_api_description
    },
    
    presentation = {
        icon: icon:mailchimp,
        color: "#FFE01B",
        color_daisy: "primary",
        tooltip_i18n: i18n_key:credential_type_mailchimp_oauth2_api_tooltip,
        display_order: 581
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:mailchimp,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://login.mailchimp.com/oauth2/token",
            authorization_url: "https://login.mailchimp.com/oauth2/authorize",
            authentication_method: "body",
            scope: ""
        },
        oauth1: NONE,
        required_fields: [],
        metadata: {}
    },
    
    documentation = {
        url: url:mailchimp_oauth2_docs,
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
WHERE presentation.display_order >= 500 AND presentation.display_order < 600
ORDER BY presentation.display_order ASC;
*/

-- =====================================================
-- RÉSUMÉ BATCH 6
-- =====================================================
--
-- ✅ 17 credentials Business/CRM créés :
--
-- HubSpot (4) - display_order: 500-503 ✨ TRÈS POPULAIRE
--  1. hubspot_api (500) - Deprecated
--  2. hubspot_app_token (501) ✨ RECOMMANDÉ
--  3. hubspot_developer_api (502)
--  4. hubspot_oauth2_api (503)
--
-- Salesforce (2) - display_order: 510-511 ✨ TRÈS POPULAIRE
--  5. salesforce_jwt_api (510) - Server-to-server
--  6. salesforce_oauth2_api (511) ✨ TRÈS POPULAIRE
--
-- Stripe (1) - display_order: 520 ✨ TRÈS POPULAIRE
--  7. stripe_api (520) ✨ TRÈS POPULAIRE
--
-- Shopify (3) - display_order: 530-532 ✨ TRÈS POPULAIRE
--  8. shopify_api (530) - Deprecated
--  9. shopify_access_token_api (531) ✨ RECOMMANDÉ
-- 10. shopify_oauth2_api (532)
--
-- Pipedrive (2) - display_order: 540-541
-- 11. pipedrive_api (540)
-- 12. pipedrive_oauth2_api (541)
--
-- Zoho (1) - display_order: 550
-- 13. zoho_oauth2_api (550)
--
-- Copper (1) - display_order: 560
-- 14. copper_api (560) - Google Workspace CRM
--
-- ActiveCampaign (1) - display_order: 570
-- 15. activecampaign_api (570)
--
-- Mailchimp (2) - display_order: 580-581 ✨ TRÈS POPULAIRE
-- 16. mailchimp_api (580) ✨ TRÈS POPULAIRE
-- 17. mailchimp_oauth2_api (581)
--
-- Structure complète : identity, presentation, config, documentation
--
-- =============================================================================================

