-- =============================================================================================
-- |
-- | Fichier : credential_type_batch20_seeds.surql (SEED DATA)
-- | Module : integrations > reference > credentials > credential_type
-- | Description : Seeds pour le Batch 20 des credential types (11 credentials CRM & No-Code).
-- |
-- | Batch 20 : CRM, Marketing Automation & No-Code Platforms (11 credentials)
-- | Providers : Action Network, Adalo, Affinity, AgileCRM, Autopilot, BambooHR, Brandfetch, Bubble, Cal, Carbon Black, Chargebee
-- |
-- =============================================================================================

-- =====================================================
-- 1. ACTION NETWORK API (display_order: 1100)
-- =====================================================

CREATE credential_type:action_network_api SET
    name = "actionNetworkApi",
    slug = "action-network-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_action_network_api_name,
        description_i18n: i18n_key:credential_type_action_network_api_description
    },
    
    presentation = {
        icon: icon:actionnetwork,
        color_type: theme_color_type:info,
        tooltip_i18n: i18n_key:credential_type_action_network_api_tooltip,
        display_order: 1100
    },
    
    auth_type = auth_type:custom,
    provider = provider:actionnetwork,
    
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
                description: "Action Network API key"
            }
        ],
        metadata: {
            activism: true,
            advocacy: true,
            organizing: true,
            custom_header: "OSDI-API-Token"
        }
    },
    
    documentation = {
        url: url:actionnetwork_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 2. ADALO API (display_order: 1101)
-- =====================================================

CREATE credential_type:adalo_api SET
    name = "adaloApi",
    slug = "adalo-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_adalo_api_name,
        description_i18n: i18n_key:credential_type_adalo_api_description
    }, presentation = { icon: icon:adalo_api, color_type: theme_color_type:neutral, tooltip_i18n: i18n_key:credential_type_adalo_api_tooltip,
        display_order: 1101
    },
    
    auth_type = auth_type:bearer_token,
    provider = provider:adalo,
    
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
                description: "Adalo API key (paid plans only)"
            },
            {
                name: "appId",
                display_name: "App ID",
                type: "string",
                is_secret: false,
                required: true,
                description: "App ID from Adalo URL"
            }
        ],
        metadata: {
            no_code: true,
            app_builder: true,
            mobile_apps: true
        }
    },
    
    documentation = {
        url: url:adalo_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 3. AFFINITY API (display_order: 1102)
-- =====================================================

CREATE credential_type:affinity_api SET
    name = "affinityApi",
    slug = "affinity-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_affinity_api_name,
        description_i18n: i18n_key:credential_type_affinity_api_description
    },
    
    presentation = {
        icon: icon:affinity,
        color_type: theme_color_type:primary,
        tooltip_i18n: i18n_key:credential_type_affinity_api_tooltip,
        display_order: 1102
    },
    
    auth_type = auth_type:basic,
    provider = provider:affinity,
    
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
                description: "Affinity API key"
            }
        ],
        metadata: {
            crm: true,
            relationship_intelligence: true,
            venture_capital: true
        }
    },
    
    documentation = {
        url: url:affinity_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 4. AGILE CRM API (display_order: 1103)
-- =====================================================

CREATE credential_type:agile_crm_api SET
    name = "agileCrmApi",
    slug = "agile-crm-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_agile_crm_api_name,
        description_i18n: i18n_key:credential_type_agile_crm_api_description
    },
    
    presentation = {
        icon: icon:agilecrm,
        color_type: theme_color_type:success,
        tooltip_i18n: i18n_key:credential_type_agile_crm_api_tooltip,
        display_order: 1103
    },
    
    auth_type = auth_type:basic,
    provider = provider:agilecrm,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "email",
                display_name: "Email",
                type: "string",
                is_secret: false,
                required: true,
                description: "Agile CRM account email"
            },
            {
                name: "apiKey",
                display_name: "API Key",
                type: "string",
                is_secret: true,
                required: true,
                description: "Agile CRM API key"
            },
            {
                name: "subdomain",
                display_name: "Subdomain",
                type: "string",
                is_secret: false,
                required: true,
                description: "Subdomain from Agile CRM URL"
            }
        ],
        metadata: {
            crm: true,
            sales: true,
            marketing: true,
            helpdesk: true
        }
    },
    
    documentation = {
        url: url:agilecrm_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 5. AUTOPILOT API (display_order: 1104)
-- =====================================================

CREATE credential_type:autopilot_api SET
    name = "autopilotApi",
    slug = "autopilot-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_autopilot_api_name,
        description_i18n: i18n_key:credential_type_autopilot_api_description
    },
    
    presentation = {
        icon: icon:autopilot,
        color_type: theme_color_type:warning,
        tooltip_i18n: i18n_key:credential_type_autopilot_api_tooltip,
        display_order: 1104
    },
    
    auth_type = auth_type:api_key,
    provider = provider:autopilot,
    
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
                description: "Autopilot API key (autopilotapikey header)"
            }
        ],
        metadata: {
            marketing_automation: true,
            customer_journey: true,
            visual_builder: true
        }
    },
    
    documentation = {
        url: url:autopilot_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 6. BAMBOOHR API - DOUBLON SUPPRIMÉ (déjà défini ailleurs avec name = "bambooHrApi")
-- =====================================================

-- =====================================================
-- 7. BRANDFETCH API (display_order: 1106)
-- =====================================================

CREATE credential_type:brandfetch_api SET
    name = "brandfetchApi",
    slug = "brandfetch-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_brandfetch_api_name,
        description_i18n: i18n_key:credential_type_brandfetch_api_description
    }, presentation = { icon: icon:brandfetch_api, color_type: theme_color_type:neutral, tooltip_i18n: i18n_key:credential_type_brandfetch_api_tooltip,
        display_order: 1106
    },
    
    auth_type = auth_type:bearer_token,
    provider = provider:brandfetch,
    
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
                description: "Brandfetch API key"
            }
        ],
        metadata: {
            brand_data: true,
            logo_api: true,
            company_information: true
        }
    },
    
    documentation = {
        url: url:brandfetch_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 8. BUBBLE API (display_order: 1107)
-- =====================================================

CREATE credential_type:bubble_api SET
    name = "bubbleApi",
    slug = "bubble-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_bubble_api_name,
        description_i18n: i18n_key:credential_type_bubble_api_description
    },
    
    presentation = {
        icon: icon:bubble,
        color_type: theme_color_type:info,
        tooltip_i18n: i18n_key:credential_type_bubble_api_tooltip,
        display_order: 1107
    },
    
    auth_type = auth_type:bearer_token,
    provider = provider:bubble,
    
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
                description: "Bubble API token"
            },
            {
                name: "appName",
                display_name: "App Name",
                type: "string",
                is_secret: false,
                required: true,
                description: "Bubble app name"
            },
            {
                name: "environment",
                display_name: "Environment",
                type: "options",
                is_secret: false,
                required: true,
                description: "Development or Live environment",
                options: [
                    { name: "Development", value: "development" },
                    { name: "Live", value: "live" }
                ],
                default: "live"
            },
            {
                name: "hosting",
                display_name: "Hosting",
                type: "options",
                is_secret: false,
                required: true,
                description: "Bubble-hosted or self-hosted",
                options: [
                    { name: "Bubble-Hosted", value: "bubbleHosted" },
                    { name: "Self-Hosted", value: "selfHosted" }
                ],
                default: "bubbleHosted"
            },
            {
                name: "domain",
                display_name: "Domain",
                type: "string",
                is_secret: false,
                required: false,
                description: "Custom domain (self-hosted only)"
            }
        ],
        metadata: {
            no_code: true,
            web_app_builder: true,
            very_popular: true
        }
    },
    
    documentation = {
        url: url:bubble_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 9. CAL API (display_order: 1108)
-- =====================================================

CREATE credential_type:cal_api SET
    name = "calApi",
    slug = "cal-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_cal_api_name,
        description_i18n: i18n_key:credential_type_cal_api_description
    },
    
    presentation = {
        icon: icon:cal,
        color_type: theme_color_type:neutral,
        tooltip_i18n: i18n_key:credential_type_cal_api_tooltip,
        display_order: 1108
    },
    
    auth_type = auth_type:api_key,
    provider = provider:cal,
    
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
                description: "Cal.com API key"
            },
            {
                name: "host",
                display_name: "Host",
                type: "string",
                is_secret: false,
                required: false,
                description: "Cal.com host URL",
                default: "https://api.cal.com"
            }
        ],
        metadata: {
            scheduling: true,
            calendar: true,
            open_source: true
        }
    },
    
    documentation = {
        url: url:cal_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 10. CARBON BLACK API (display_order: 1109)
-- =====================================================

CREATE credential_type:carbon_black_api SET
    name = "carbonBlackApi",
    slug = "carbon-black-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_carbon_black_api_name,
        description_i18n: i18n_key:credential_type_carbon_black_api_description
    },
    
    presentation = {
        icon: icon:vmware,
        color_type: theme_color_type:neutral,
        tooltip_i18n: i18n_key:credential_type_carbon_black_api_tooltip,
        display_order: 1109
    },
    
    auth_type = auth_type:custom,
    provider = provider:carbonblack,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "apiUrl",
                display_name: "URL",
                type: "string",
                is_secret: false,
                required: true,
                description: "Carbon Black API URL"
            },
            {
                name: "accessToken",
                display_name: "Access Token",
                type: "string",
                is_secret: true,
                required: true,
                description: "Carbon Black access token"
            }
        ],
        metadata: {
            cybersecurity: true,
            endpoint_protection: true,
            vmware: true,
            custom_header: "X-Auth-Token"
        }
    },
    
    documentation = {
        url: url:carbonblack_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 11. CHARGEBEE API (display_order: 1110)
-- =====================================================

CREATE credential_type:chargebee_api SET
    name = "chargebeeApi",
    slug = "chargebee-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_chargebee_api_name,
        description_i18n: i18n_key:credential_type_chargebee_api_description
    },
    
    presentation = {
        icon: icon:chargebee,
        color_type: theme_color_type:warning,
        tooltip_i18n: i18n_key:credential_type_chargebee_api_tooltip,
        display_order: 1110
    },
    
    auth_type = auth_type:basic,
    provider = provider:chargebee,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "accountName",
                display_name: "Account Name",
                type: "string",
                is_secret: false,
                required: true,
                description: "Chargebee account name"
            },
            {
                name: "apiKey",
                display_name: "API Key",
                type: "string",
                is_secret: true,
                required: true,
                description: "Chargebee API key"
            }
        ],
        metadata: {
            subscription_management: true,
            billing: true,
            recurring_payments: true,
            very_popular: true
        }
    },
    
    documentation = {
        url: url:chargebee_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- RÉSUMÉ BATCH 20
-- =====================================================
--
-- ✅ 11 credentials CRM, Marketing Automation & No-Code créés :
--
-- Activism & Advocacy (1) - display_order: 1100
--  1. action_network_api (1100) - Activism & organizing platform
--
-- No-Code Platforms (2) - display_order: 1101, 1107
--  2. adalo_api (1101) - No-code mobile app builder
--  8. bubble_api (1107) ✨ TRÈS POPULAIRE - No-code web app builder
--
-- CRM & Sales (2) - display_order: 1102-1103
--  3. affinity_api (1102) - Relationship intelligence CRM
--  4. agile_crm_api (1103) - All-in-one CRM with helpdesk
--
-- Marketing Automation (1) - display_order: 1104
--  5. autopilot_api (1104) - Marketing automation & customer journeys
--
-- HR Management (1) - display_order: 1105
--  6. bamboo_hr_api (1105) ✨ TRÈS POPULAIRE - HR & employee management
--
-- Brand & Data (1) - display_order: 1106
--  7. brandfetch_api (1106) - Brand data & logo API
--
-- Scheduling (1) - display_order: 1108
--  9. cal_api (1108) - Open-source scheduling (Cal.com)
--
-- Cybersecurity (1) - display_order: 1109
-- 10. carbon_black_api (1109) - VMware endpoint protection
--
-- Billing & Subscriptions (1) - display_order: 1110
-- 11. chargebee_api (1110) ✨ TRÈS POPULAIRE - Subscription billing
--
-- Structure complète : identity, presentation, config, documentation
--
-- =============================================================================================

