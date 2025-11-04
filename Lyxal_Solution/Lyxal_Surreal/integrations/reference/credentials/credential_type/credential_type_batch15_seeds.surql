-- =============================================================================================
-- |
-- | Fichier : credential_type_batch15_seeds.surql (SEED DATA)
-- | Module : integrations > reference > credentials > credential_type
-- | Description : Seeds pour le Batch 15 des credential types (11 credentials CMS, ERP & Database).
-- |
-- | Batch 15 : CMS, ERP & Database Management (11 credentials)
-- | Providers : Contentful, Strapi, Storyblok, Odoo, ERPNext, Grist, SeaTable, QuickBase, Stackby
-- |
-- =============================================================================================

-- =====================================================
-- 1. CONTENTFUL API (display_order: 1000) ✨ TRÈS POPULAIRE
-- =====================================================

CREATE credential_type:contentful_api SET
    name = "contentfulApi",
    slug = "contentful-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_contentful_api_name,
        description_i18n: i18n_key:credential_type_contentful_api_description
    },
    
    presentation = {
        icon: icon:contentful,
        color_type: theme_color_type:info,
        tooltip_i18n: i18n_key:credential_type_contentful_api_tooltip,
        display_order: 1000
    },
    
    auth_type = auth_type:custom,
    provider = provider:contentful,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "spaceId",
                display_name: "Space ID",
                type: "string",
                is_secret: false,
                required: true,
                description: "Contentful space ID"
            },
            {
                name: "ContentDeliveryaccessToken",
                display_name: "Content Delivery API Access Token",
                type: "string",
                is_secret: true,
                required: false,
                description: "Access token for Content Delivery API"
            },
            {
                name: "ContentPreviewaccessToken",
                display_name: "Content Preview API Access Token",
                type: "string",
                is_secret: true,
                required: false,
                description: "Access token for Content Preview API"
            }
        ],
        metadata: {
            headless_cms: true,
            enterprise_cms: true,
            api_first: true
        }
    },
    
    documentation = {
        url: url:contentful_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 2. STRAPI API (display_order: 1001) ✨ TRÈS POPULAIRE
-- =====================================================

CREATE credential_type:strapi_api SET
    name = "strapiApi",
    slug = "strapi-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_strapi_api_name,
        description_i18n: i18n_key:credential_type_strapi_api_description
    },
    
    presentation = {
        icon: icon:strapi,
        color_type: theme_color_type:primary,
        tooltip_i18n: i18n_key:credential_type_strapi_api_tooltip,
        display_order: 1001
    },
    
    auth_type = auth_type:custom,
    provider = provider:strapi,
    
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
                description: "Strapi instance URL",
                placeholder: "https://api.example.com"
            },
            {
                name: "email",
                display_name: "Email",
                type: "string",
                is_secret: false,
                required: true,
                description: "User account email (not admin)",
                placeholder: "name@email.com"
            },
            {
                name: "password",
                display_name: "Password",
                type: "string",
                is_secret: true,
                required: true,
                description: "User account password"
            },
            {
                name: "apiVersion",
                display_name: "API Version",
                type: "options",
                is_secret: false,
                required: true,
                description: "Strapi API version",
                options: [
                    { name: "Version 4", value: "v4" },
                    { name: "Version 3", value: "v3" }
                ],
                default: "v3"
            }
        ],
        metadata: {
            headless_cms: true,
            open_source: true,
            self_hosted: true
        }
    },
    
    documentation = {
        url: url:strapi_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 3. STRAPI TOKEN API (display_order: 1002)
-- =====================================================

CREATE credential_type:strapi_token_api SET
    name = "strapiTokenApi",
    slug = "strapi-token-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_strapi_token_api_name,
        description_i18n: i18n_key:credential_type_strapi_token_api_description
    },
    
    presentation = {
        icon: icon:strapi,
        color: "#4945FF",
        color_daisy: "secondary",
        tooltip_i18n: i18n_key:credential_type_strapi_token_api_tooltip,
        display_order: 1002
    },
    
    auth_type = auth_type:bearer_token,
    provider = provider:strapi,
    
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
                description: "Strapi instance URL",
                placeholder: "https://api.example.com"
            },
            {
                name: "apiToken",
                display_name: "API Token",
                type: "string",
                is_secret: true,
                required: true,
                description: "Strapi API token"
            },
            {
                name: "apiVersion",
                display_name: "API Version",
                type: "options",
                is_secret: false,
                required: true,
                description: "Strapi API version",
                options: [
                    { name: "Version 4", value: "v4" },
                    { name: "Version 3", value: "v3" }
                ],
                default: "v3"
            }
        ],
        metadata: {
            token_auth: true,
            recommended: true
        }
    },
    
    documentation = {
        url: url:strapi_token_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 4. STORYBLOK CONTENT API (display_order: 1003) ✨ TRÈS POPULAIRE
-- =====================================================

CREATE credential_type:storyblok_content_api SET
    name = "storyblokContentApi",
    slug = "storyblok-content-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_storyblok_content_api_name,
        description_i18n: i18n_key:credential_type_storyblok_content_api_description
    },
    
    presentation = {
        icon: icon:storyblok,
        color_type: theme_color_type:info,
        tooltip_i18n: i18n_key:credential_type_storyblok_content_api_tooltip,
        display_order: 1003
    },
    
    auth_type = auth_type:api_key,
    provider = provider:storyblok,
    
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
                description: "Storyblok Content API key (public access token)"
            }
        ],
        metadata: {
            headless_cms: true,
            visual_editor: true,
            read_only: true
        }
    },
    
    documentation = {
        url: url:storyblok_content_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 5. STORYBLOK MANAGEMENT API (display_order: 1004)
-- =====================================================

CREATE credential_type:storyblok_management_api SET
    name = "storyblokManagementApi",
    slug = "storyblok-management-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_storyblok_management_api_name,
        description_i18n: i18n_key:credential_type_storyblok_management_api_description
    },
    
    presentation = {
        icon: icon:storyblok,
        color_type: theme_color_type:success,
        tooltip_i18n: i18n_key:credential_type_storyblok_management_api_tooltip,
        display_order: 1004
    },
    
    auth_type = auth_type:bearer_token,
    provider = provider:storyblok,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "accessToken",
                display_name: "Personal Access Token",
                type: "string",
                is_secret: true,
                required: true,
                description: "Storyblok Management API personal access token"
            }
        ],
        metadata: {
            full_access: true,
            write_access: true
        }
    },
    
    documentation = {
        url: url:storyblok_management_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 6. ODOO API (display_order: 1005) ✨ TRÈS POPULAIRE
-- =====================================================

CREATE credential_type:odoo_api SET
    name = "odooApi",
    slug = "odoo-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_odoo_api_name,
        description_i18n: i18n_key:credential_type_odoo_api_description
    },
    
    presentation = {
        icon: icon:odoo,
        color: "#714B67",
        color_daisy: "secondary",
        tooltip_i18n: i18n_key:credential_type_odoo_api_tooltip,
        display_order: 1005
    },
    
    auth_type = auth_type:custom,
    provider = provider:odoo,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "url",
                display_name: "Site URL",
                type: "string",
                is_secret: false,
                required: true,
                description: "Odoo instance URL",
                placeholder: "https://my-organization.odoo.com"
            },
            {
                name: "username",
                display_name: "Username",
                type: "string",
                is_secret: false,
                required: true,
                description: "Odoo username/email",
                placeholder: "user@email.com"
            },
            {
                name: "password",
                display_name: "Password or API Key",
                type: "string",
                is_secret: true,
                required: true,
                description: "Odoo password or API key"
            },
            {
                name: "db",
                display_name: "Database Name",
                type: "string",
                is_secret: false,
                required: false,
                description: "Odoo database name (optional)"
            }
        ],
        metadata: {
            erp_system: true,
            open_source: true,
            all_in_one: true
        }
    },
    
    documentation = {
        url: url:odoo_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 7. ERPNEXT API (display_order: 1006) ✨ TRÈS POPULAIRE
-- =====================================================

CREATE credential_type:erpnext_api SET
    name = "erpNextApi",
    slug = "erpnext-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_erpnext_api_name,
        description_i18n: i18n_key:credential_type_erpnext_api_description
    },
    
    presentation = {
        icon: icon:erpnext,
        color_type: theme_color_type:info,
        tooltip_i18n: i18n_key:credential_type_erpnext_api_tooltip,
        display_order: 1006
    },
    
    auth_type = auth_type:custom,
    provider = provider:erpnext,
    
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
                description: "ERPNext API key"
            },
            {
                name: "apiSecret",
                display_name: "API Secret",
                type: "string",
                is_secret: true,
                required: true,
                description: "ERPNext API secret"
            },
            {
                name: "environment",
                display_name: "Environment",
                type: "options",
                is_secret: false,
                required: true,
                description: "ERPNext environment type",
                options: [
                    { name: "Cloud-Hosted", value: "cloudHosted" },
                    { name: "Self-Hosted", value: "selfHosted" }
                ],
                default: "cloudHosted"
            },
            {
                name: "subdomain",
                display_name: "Subdomain",
                type: "string",
                is_secret: false,
                required: false,
                description: "Cloud-hosted ERPNext subdomain",
                placeholder: "n8n"
            },
            {
                name: "domain",
                display_name: "Domain",
                type: "string",
                is_secret: false,
                required: false,
                description: "ERPNext domain",
                default: "erpnext.com"
            }
        ],
        metadata: {
            erp_system: true,
            open_source: true,
            frappe_framework: true
        }
    },
    
    documentation = {
        url: url:erpnext_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 8. GRIST API (display_order: 1007)
-- =====================================================

CREATE credential_type:grist_api SET
    name = "gristApi",
    slug = "grist-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_grist_api_name,
        description_i18n: i18n_key:credential_type_grist_api_description
    },
    
    presentation = {
        icon: icon:grist,
        color_type: theme_color_type:success,
        tooltip_i18n: i18n_key:credential_type_grist_api_tooltip,
        display_order: 1007
    },
    
    auth_type = auth_type:api_key,
    provider = provider:grist,
    
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
                description: "Grist API key"
            },
            {
                name: "planType",
                display_name: "Plan Type",
                type: "options",
                is_secret: false,
                required: true,
                description: "Grist plan type",
                options: [
                    { name: "Free", value: "free" },
                    { name: "Paid", value: "paid" },
                    { name: "Self-Hosted", value: "selfHosted" }
                ],
                default: "free"
            },
            {
                name: "customSubdomain",
                display_name: "Custom Subdomain",
                type: "string",
                is_secret: false,
                required: false,
                description: "Custom subdomain for paid plans"
            },
            {
                name: "selfHostedUrl",
                display_name: "Self-Hosted URL",
                type: "string",
                is_secret: false,
                required: false,
                description: "Self-hosted Grist instance URL",
                placeholder: "http://localhost:8484"
            }
        ],
        metadata: {
            spreadsheet_database: true,
            open_source: true
        }
    },
    
    documentation = {
        url: url:grist_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 9. SEATABLE API (display_order: 1008)
-- =====================================================

CREATE credential_type:seatable_api SET
    name = "seaTableApi",
    slug = "seatable-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_seatable_api_name,
        description_i18n: i18n_key:credential_type_seatable_api_description
    },
    
    presentation = {
        icon: icon:seatable,
        color_type: theme_color_type:warning,
        tooltip_i18n: i18n_key:credential_type_seatable_api_tooltip,
        display_order: 1008
    },
    
    auth_type = auth_type:bearer_token,
    provider = provider:seatable,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "environment",
                display_name: "Environment",
                type: "options",
                is_secret: false,
                required: true,
                description: "SeaTable environment",
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
                description: "Self-hosted SeaTable domain",
                placeholder: "https://seatable.example.com"
            },
            {
                name: "token",
                display_name: "API Token (of a Base)",
                type: "string",
                is_secret: true,
                required: true,
                description: "SeaTable base API token"
            },
            {
                name: "timezone",
                display_name: "Timezone",
                type: "string",
                is_secret: false,
                required: false,
                description: "SeaTable server timezone",
                default: "UTC"
            }
        ],
        metadata: {
            spreadsheet_database: true,
            collaborative: true
        }
    },
    
    documentation = {
        url: url:seatable_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 10. QUICKBASE API (display_order: 1009)
-- =====================================================

CREATE credential_type:quickbase_api SET
    name = "quickbaseApi",
    slug = "quickbase-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_quickbase_api_name,
        description_i18n: i18n_key:credential_type_quickbase_api_description
    },
    
    presentation = {
        icon: icon:quickbase,
        color_type: theme_color_type:info,
        tooltip_i18n: i18n_key:credential_type_quickbase_api_tooltip,
        display_order: 1009
    },
    
    auth_type = auth_type:bearer_token,
    provider = provider:quickbase,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "hostname",
                display_name: "Hostname",
                type: "string",
                is_secret: false,
                required: true,
                description: "QuickBase hostname",
                placeholder: "demo.quickbase.com"
            },
            {
                name: "userToken",
                display_name: "User Token",
                type: "string",
                is_secret: true,
                required: true,
                description: "QuickBase user token"
            }
        ],
        metadata: {
            no_code_database: true,
            enterprise_platform: true
        }
    },
    
    documentation = {
        url: url:quickbase_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 11. STACKBY API (display_order: 1010)
-- =====================================================

CREATE credential_type:stackby_api SET
    name = "stackbyApi",
    slug = "stackby-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_stackby_api_name,
        description_i18n: i18n_key:credential_type_stackby_api_description
    },
    
    presentation = {
        icon: icon:stackby,
        color_type: theme_color_type:error,
        tooltip_i18n: i18n_key:credential_type_stackby_api_tooltip,
        display_order: 1010
    },
    
    auth_type = auth_type:api_key,
    provider = provider:stackby,
    
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
                description: "Stackby API key"
            }
        ],
        metadata: {
            spreadsheet_database: true,
            workflow_automation: true
        }
    },
    
    documentation = {
        url: url:stackby_docs,
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
WHERE presentation.display_order >= 1000 AND presentation.display_order <= 1010
ORDER BY presentation.display_order ASC;
*/

-- =====================================================
-- RÉSUMÉ BATCH 15
-- =====================================================
--
-- ✅ 11 credentials CMS, ERP & Database Management créés :
--
-- Headless CMS Platforms (5) - display_order: 1000-1004 ✨ TRÈS POPULAIRE
--  1. contentful_api (1000) ✨ TRÈS POPULAIRE - Enterprise headless CMS
--  2. strapi_api (1001) ✨ TRÈS POPULAIRE - Open-source headless CMS
--  3. strapi_token_api (1002) - Strapi token authentication
--  4. storyblok_content_api (1003) ✨ TRÈS POPULAIRE - Visual editor CMS
--  5. storyblok_management_api (1004) - Full management access
--
-- ERP Systems (2) - display_order: 1005-1006 ✨ TRÈS POPULAIRE
--  6. odoo_api (1005) ✨ TRÈS POPULAIRE - Open-source all-in-one ERP
--  7. erpnext_api (1006) ✨ TRÈS POPULAIRE - Frappe-based open-source ERP
--
-- Spreadsheet & Database Platforms (4) - display_order: 1007-1010
--  8. grist_api (1007) - Open-source spreadsheet database
--  9. seatable_api (1008) - Collaborative spreadsheet database
-- 10. quickbase_api (1009) - Enterprise no-code database
-- 11. stackby_api (1010) - Spreadsheet database with automation
--
-- Structure complète : identity, presentation, config, documentation
--
-- =============================================================================================

