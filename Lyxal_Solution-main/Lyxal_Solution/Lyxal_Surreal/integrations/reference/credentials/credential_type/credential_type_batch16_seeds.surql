-- =============================================================================================
-- |
-- | Fichier : credential_type_batch16_seeds.surql (SEED DATA)
-- | Module : integrations > reference > credentials > credential_type
-- | Description : Seeds pour le Batch 16 des credential types (11 credentials Accounting, Finance, Time & HR).
-- |
-- | Batch 16 : Accounting, Finance, Time Tracking & HR (11 credentials)
-- | Providers : Xero, QuickBooks, Invoice Ninja, ProfitWell, Wise, Harvest, Clockify, Toggl, BambooHR, Workable
-- |
-- =============================================================================================

-- =====================================================
-- 1. XERO OAUTH2 API (display_order: 1020) ✨ TRÈS POPULAIRE
-- =====================================================

CREATE credential_type:xero_oauth2_api SET
    name = "xeroOAuth2Api",
    slug = "xero-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_xero_oauth2_api_name,
        description_i18n: i18n_key:credential_type_xero_oauth2_api_description
    },
    
    presentation = {
        icon: icon:xero,
        color_type: theme_color_type:info,
        tooltip_i18n: i18n_key:credential_type_xero_oauth2_api_tooltip,
        display_order: 1020
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:xero,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://identity.xero.com/connect/token",
            authorization_url: "https://login.xero.com/identity/connect/authorize",
            authentication_method: "header",
            scope: "offline_access accounting.transactions accounting.settings accounting.contacts"
        },
        oauth1: NONE,
        required_fields: [],
        metadata: {
            accounting_platform: true,
            cloud_accounting: true
        }
    },
    
    documentation = {
        url: url:xero_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 2. QUICKBOOKS OAUTH2 API (display_order: 1021) ✨ TRÈS POPULAIRE
-- =====================================================

CREATE credential_type:quickbooks_oauth2_api SET
    name = "quickBooksOAuth2Api",
    slug = "quickbooks-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_quickbooks_oauth2_api_name,
        description_i18n: i18n_key:credential_type_quickbooks_oauth2_api_description
    },
    
    presentation = {
        icon: icon:quickbooks,
        color_type: theme_color_type:success,
        tooltip_i18n: i18n_key:credential_type_quickbooks_oauth2_api_tooltip,
        display_order: 1021
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:quickbooks,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://oauth.platform.intuit.com/oauth2/v1/tokens/bearer",
            authorization_url: "https://appcenter.intuit.com/connect/oauth2",
            authentication_method: "header",
            scope: "com.intuit.quickbooks.accounting"
        },
        oauth1: NONE,
        required_fields: [
            {
                name: "environment",
                display_name: "Environment",
                type: "options",
                is_secret: false,
                required: true,
                description: "QuickBooks environment",
                options: [
                    { name: "Production", value: "production" },
                    { name: "Sandbox", value: "sandbox" }
                ],
                default: "production"
            }
        ],
        metadata: {
            accounting_platform: true,
            intuit_product: true
        }
    },
    
    documentation = {
        url: url:quickbooks_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 3. INVOICE NINJA API (display_order: 1022)
-- =====================================================

CREATE credential_type:invoice_ninja_api SET
    name = "invoiceNinjaApi",
    slug = "invoice-ninja-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_invoice_ninja_api_name,
        description_i18n: i18n_key:credential_type_invoice_ninja_api_description
    },
    
    presentation = {
        icon: icon:invoice_ninja,
        color_type: theme_color_type:info,
        tooltip_i18n: i18n_key:credential_type_invoice_ninja_api_tooltip,
        display_order: 1022
    },
    
    auth_type = auth_type:custom,
    provider = provider:invoice_ninja,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "url",
                display_name: "URL",
                type: "string",
                is_secret: false,
                required: true,
                description: "Invoice Ninja instance URL (v4: app.invoiceninja.com, v5: invoicing.co)"
            },
            {
                name: "apiToken",
                display_name: "API Token",
                type: "string",
                is_secret: true,
                required: true,
                description: "Invoice Ninja API token"
            },
            {
                name: "secret",
                display_name: "Secret",
                type: "string",
                is_secret: true,
                required: false,
                description: "Optional secret (only for v5 if configured)"
            }
        ],
        metadata: {
            invoicing_platform: true,
            open_source: true,
            supports_v4_v5: true
        }
    },
    
    documentation = {
        url: url:invoice_ninja_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 4. PROFITWELL API (display_order: 1023)
-- =====================================================

CREATE credential_type:profitwell_api SET
    name = "profitWellApi",
    slug = "profitwell-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_profitwell_api_name,
        description_i18n: i18n_key:credential_type_profitwell_api_description
    },
    
    presentation = {
        icon: icon:profitwell,
        color_type: theme_color_type:error,
        tooltip_i18n: i18n_key:credential_type_profitwell_api_tooltip,
        display_order: 1023
    },
    
    auth_type = auth_type:bearer_token,
    provider = provider:profitwell,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "accessToken",
                display_name: "API Token",
                type: "string",
                is_secret: true,
                required: true,
                description: "ProfitWell private API token"
            }
        ],
        metadata: {
            revenue_analytics: true,
            subscription_metrics: true
        }
    },
    
    documentation = {
        url: url:profitwell_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 5. WISE API (display_order: 1024) ✨ TRÈS POPULAIRE
-- =====================================================

CREATE credential_type:wise_api SET
    name = "wiseApi",
    slug = "wise-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_wise_api_name,
        description_i18n: i18n_key:credential_type_wise_api_description
    },
    
    presentation = {
        icon: icon:wise,
        color_type: theme_color_type:success,
        tooltip_i18n: i18n_key:credential_type_wise_api_tooltip,
        display_order: 1024
    },
    
    auth_type = auth_type:bearer_token,
    provider = provider:wise,
    
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
                description: "Wise API token"
            },
            {
                name: "environment",
                display_name: "Environment",
                type: "options",
                is_secret: false,
                required: true,
                description: "Wise environment",
                options: [
                    { name: "Live", value: "live" },
                    { name: "Test", value: "test" }
                ],
                default: "live"
            },
            {
                name: "privateKey",
                display_name: "Private Key (Optional)",
                type: "string",
                is_secret: true,
                required: false,
                description: "Optional private key for SCA (Strong Customer Authentication)"
            }
        ],
        metadata: {
            money_transfer: true,
            international_payments: true,
            formerly_transferwise: true
        }
    },
    
    documentation = {
        url: url:wise_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 6. HARVEST API (display_order: 1025) ✨ TRÈS POPULAIRE
-- =====================================================

CREATE credential_type:harvest_api SET
    name = "harvestApi",
    slug = "harvest-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_harvest_api_name,
        description_i18n: i18n_key:credential_type_harvest_api_description
    },
    
    presentation = {
        icon: icon:harvest,
        color_type: theme_color_type:warning,
        tooltip_i18n: i18n_key:credential_type_harvest_api_tooltip,
        display_order: 1025
    },
    
    auth_type = auth_type:bearer_token,
    provider = provider:harvest,
    
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
                description: "Harvest personal access token"
            }
        ],
        metadata: {
            time_tracking: true,
            invoicing: true,
            expense_tracking: true
        }
    },
    
    documentation = {
        url: url:harvest_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 7. HARVEST OAUTH2 API (display_order: 1026)
-- =====================================================

CREATE credential_type:harvest_oauth2_api SET
    name = "harvestOAuth2Api",
    slug = "harvest-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_harvest_oauth2_api_name,
        description_i18n: i18n_key:credential_type_harvest_oauth2_api_description
    },
    
    presentation = {
        icon: icon:harvest,
        color_type: theme_color_type:error,
        tooltip_i18n: i18n_key:credential_type_harvest_oauth2_api_tooltip,
        display_order: 1026
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:harvest,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://id.getharvest.com/api/v2/oauth2/token",
            authorization_url: "https://id.getharvest.com/oauth2/authorize",
            authentication_method: "body",
            scope: "all"
        },
        oauth1: NONE,
        required_fields: [],
        metadata: {
            oauth_recommended: true
        }
    },
    
    documentation = {
        url: url:harvest_oauth2_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 8. CLOCKIFY API (display_order: 1027) ✨ TRÈS POPULAIRE
-- =====================================================

CREATE credential_type:clockify_api SET
    name = "clockifyApi",
    slug = "clockify-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_clockify_api_name,
        description_i18n: i18n_key:credential_type_clockify_api_description
    },
    
    presentation = {
        icon: icon:clockify,
        color_type: theme_color_type:info,
        tooltip_i18n: i18n_key:credential_type_clockify_api_tooltip,
        display_order: 1027
    },
    
    auth_type = auth_type:custom,
    provider = provider:clockify,
    
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
                description: "Clockify API key"
            }
        ],
        metadata: {
            time_tracking: true,
            free_tier: true,
            custom_header: "X-Api-Key"
        }
    },
    
    documentation = {
        url: url:clockify_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 9. TOGGL API (display_order: 1028) ✨ TRÈS POPULAIRE
-- =====================================================

CREATE credential_type:toggl_api SET
    name = "togglApi",
    slug = "toggl-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_toggl_api_name,
        description_i18n: i18n_key:credential_type_toggl_api_description
    },
    
    presentation = {
        icon: icon:toggl,
        color_type: theme_color_type:error,
        tooltip_i18n: i18n_key:credential_type_toggl_api_tooltip,
        display_order: 1028
    },
    
    auth_type = auth_type:basic_auth,
    provider = provider:toggl,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "username",
                display_name: "Email Address",
                type: "string",
                is_secret: false,
                required: true,
                description: "Toggl account email"
            },
            {
                name: "password",
                display_name: "Password",
                type: "string",
                is_secret: true,
                required: true,
                description: "Toggl account password"
            }
        ],
        metadata: {
            time_tracking: true,
            simple_time_tracker: true
        }
    },
    
    documentation = {
        url: url:toggl_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 10. BAMBOOHR API (display_order: 1029) ✨ TRÈS POPULAIRE
-- =====================================================

CREATE credential_type:bamboohr_api SET
    name = "bambooHrApi",
    slug = "bamboohr-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_bamboohr_api_name,
        description_i18n: i18n_key:credential_type_bamboohr_api_description
    },
    
    presentation = {
        icon: icon:bamboohr,
        color_type: theme_color_type:success,
        tooltip_i18n: i18n_key:credential_type_bamboohr_api_tooltip,
        display_order: 1029
    },
    
    auth_type = auth_type:api_key,
    provider = provider:bamboohr,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "subdomain",
                display_name: "Subdomain",
                type: "string",
                is_secret: false,
                required: true,
                description: "BambooHR account subdomain"
            },
            {
                name: "apiKey",
                display_name: "API Key",
                type: "string",
                is_secret: true,
                required: true,
                description: "BambooHR API key"
            }
        ],
        metadata: {
            hr_management: true,
            employee_database: true
        }
    },
    
    documentation = {
        url: url:bamboohr_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 11. WORKABLE API (display_order: 1030)
-- =====================================================

CREATE credential_type:workable_api SET
    name = "workableApi",
    slug = "workable-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_workable_api_name,
        description_i18n: i18n_key:credential_type_workable_api_description
    },
    
    presentation = {
        icon: icon:workable,
        color_type: theme_color_type:info,
        tooltip_i18n: i18n_key:credential_type_workable_api_tooltip,
        display_order: 1030
    },
    
    auth_type = auth_type:bearer_token,
    provider = provider:workable,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "subdomain",
                display_name: "Subdomain",
                type: "string",
                is_secret: false,
                required: true,
                description: "Workable account subdomain"
            },
            {
                name: "accessToken",
                display_name: "Access Token",
                type: "string",
                is_secret: true,
                required: true,
                description: "Workable access token"
            }
        ],
        metadata: {
            recruiting_platform: true,
            applicant_tracking: true
        }
    },
    
    documentation = {
        url: url:workable_docs,
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
WHERE presentation.display_order >= 1020 AND presentation.display_order <= 1030
ORDER BY presentation.display_order ASC;
*/

-- =====================================================
-- RÉSUMÉ BATCH 16
-- =====================================================
--
-- ✅ 11 credentials Accounting, Finance, Time Tracking & HR créés :
--
-- Accounting & Finance (5) - display_order: 1020-1024 ✨ TRÈS POPULAIRE
--  1. xero_oauth2_api (1020) ✨ TRÈS POPULAIRE - Cloud accounting platform
--  2. quickbooks_oauth2_api (1021) ✨ TRÈS POPULAIRE - Intuit accounting (production/sandbox)
--  3. invoice_ninja_api (1022) - Open-source invoicing (v4/v5 support)
--  4. profitwell_api (1023) - Revenue analytics & subscription metrics
--  5. wise_api (1024) ✨ TRÈS POPULAIRE - International money transfers (formerly TransferWise)
--
-- Time Tracking (4) - display_order: 1025-1028 ✨ TRÈS POPULAIRE
--  6. harvest_api (1025) ✨ TRÈS POPULAIRE - Time tracking, invoicing & expenses
--  7. harvest_oauth2_api (1026) - Harvest OAuth2 version
--  8. clockify_api (1027) ✨ TRÈS POPULAIRE - Free time tracker
--  9. toggl_api (1028) ✨ TRÈS POPULAIRE - Simple time tracking
--
-- HR & Recruiting (2) - display_order: 1029-1030 ✨ TRÈS POPULAIRE
-- 10. bamboohr_api (1029) ✨ TRÈS POPULAIRE - HR management & employee database
-- 11. workable_api (1030) - Recruiting & applicant tracking system
--
-- Structure complète : identity, presentation, config, documentation
--
-- =============================================================================================

