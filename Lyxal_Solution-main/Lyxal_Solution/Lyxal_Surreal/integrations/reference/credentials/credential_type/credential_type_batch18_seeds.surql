-- =============================================================================================
-- |
-- | Fichier : credential_type_batch18_seeds.surql (SEED DATA)
-- | Module : integrations > reference > credentials > credential_type
-- | Description : Seeds pour le Batch 18 des credential types (11 credentials Email Marketing).
-- |
-- | Batch 18 : Email Marketing & Communication (11 credentials)
-- | Providers : Brevo, GetResponse, MailerLite, ConvertKit, Automizy, Customer.io, E-goi, Sendy, Lemlist, SMTP
-- |
-- =============================================================================================

-- =====================================================
-- 1. BREVO API (display_order: 1060) ✨ TRÈS POPULAIRE (formerly SendInBlue)
-- =====================================================

CREATE credential_type:brevo_api SET
    name = "sendInBlueApi",
    slug = "brevo-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_brevo_api_name,
        description_i18n: i18n_key:credential_type_brevo_api_description
    },
    
    presentation = {
        icon: icon:brevo,
        color_type: theme_color_type:info,
        tooltip_i18n: i18n_key:credential_type_brevo_api_tooltip,
        display_order: 1060
    },
    
    auth_type = auth_type:api_key,
    provider = provider:brevo,
    
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
                description: "Brevo API key"
            }
        ],
        metadata: {
            email_marketing: true,
            transactional_email: true,
            formerly_sendinblue: true,
            very_popular: true,
            custom_header: "api-key"
        }
    },
    
    documentation = {
        url: url:brevo_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 2. GETRESPONSE API (display_order: 1061)
-- =====================================================

CREATE credential_type:getresponse_api SET
    name = "getResponseApi",
    slug = "getresponse-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_getresponse_api_name,
        description_i18n: i18n_key:credential_type_getresponse_api_description
    },
    
    presentation = {
        icon: icon:getresponse,
        color_type: theme_color_type:info,
        tooltip_i18n: i18n_key:credential_type_getresponse_api_tooltip,
        display_order: 1061
    },
    
    auth_type = auth_type:custom,
    provider = provider:getresponse,
    
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
                description: "GetResponse API key"
            }
        ],
        metadata: {
            email_marketing: true,
            marketing_automation: true,
            custom_header: "X-Auth-Token: api-key"
        }
    },
    
    documentation = {
        url: url:getresponse_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 3. GETRESPONSE OAUTH2 API (display_order: 1062)
-- =====================================================

CREATE credential_type:getresponse_oauth2_api SET
    name = "getResponseOAuth2Api",
    slug = "getresponse-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_getresponse_oauth2_api_name,
        description_i18n: i18n_key:credential_type_getresponse_oauth2_api_description
    }, presentation = { icon: icon:getresponse_oauth2_api, color_type: theme_color_type:neutral, tooltip_i18n: i18n_key:credential_type_getresponse_oauth2_api_tooltip,
        display_order: 1062
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:getresponse,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://api.getresponse.com/v3/token",
            authorization_url: "https://app.getresponse.com/oauth2_authorize.html",
            authentication_method: "header",
            scope: ""
        },
        oauth1: NONE,
        required_fields: [],
        metadata: {
            oauth_recommended: true
        }
    },
    
    documentation = {
        url: url:getresponse_oauth2_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 4. MAILERLITE API (display_order: 1063)
-- =====================================================

CREATE credential_type:mailerlite_api SET
    name = "mailerLiteApi",
    slug = "mailerlite-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_mailerlite_api_name,
        description_i18n: i18n_key:credential_type_mailerlite_api_description
    },
    
    presentation = {
        icon: icon:mailerlite,
        color_type: theme_color_type:success,
        tooltip_i18n: i18n_key:credential_type_mailerlite_api_tooltip,
        display_order: 1063
    },
    
    auth_type = auth_type:bearer_token,
    provider = provider:mailerlite,
    
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
                description: "MailerLite API key"
            },
            {
                name: "classicApi",
                display_name: "Classic API",
                type: "boolean",
                is_secret: false,
                required: false,
                description: "Use Classic API (v2) instead of new API",
                default: true
            }
        ],
        metadata: {
            email_marketing: true,
            landing_pages: true,
            supports_legacy_api: true
        }
    },
    
    documentation = {
        url: url:mailerlite_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 5. CONVERTKIT API (display_order: 1064)
-- =====================================================

CREATE credential_type:convertkit_api SET
    name = "convertKitApi",
    slug = "convertkit-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_convertkit_api_name,
        description_i18n: i18n_key:credential_type_convertkit_api_description
    },
    
    presentation = {
        icon: icon:convertkit,
        color_type: theme_color_type:error,
        tooltip_i18n: i18n_key:credential_type_convertkit_api_tooltip,
        display_order: 1064
    },
    
    auth_type = auth_type:api_key,
    provider = provider:convertkit,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "apiSecret",
                display_name: "API Secret",
                type: "string",
                is_secret: true,
                required: true,
                description: "ConvertKit API secret"
            }
        ],
        metadata: {
            email_marketing: true,
            creator_economy: true,
            newsletter_tool: true
        }
    },
    
    documentation = {
        url: url:convertkit_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 6. AUTOMIZY API (display_order: 1065) [DEPRECATED]
-- =====================================================

CREATE credential_type:automizy_api SET
    name = "automizyApi",
    slug = "automizy-api",
    is_active = false,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_automizy_api_name,
        description_i18n: i18n_key:credential_type_automizy_api_description
    },
    
    presentation = {
        icon: icon:automizy,
        color_type: theme_color_type:warning,
        tooltip_i18n: i18n_key:credential_type_automizy_api_tooltip,
        display_order: 1065
    },
    
    auth_type = auth_type:bearer_token,
    provider = provider:automizy,
    
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
                description: "Automizy API token"
            }
        ],
        metadata: {
            deprecated: true,
            service_discontinued: true,
            email_marketing: true
        }
    },
    
    documentation = {
        url: url:automizy_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 7. CUSTOMER.IO API (display_order: 1066)
-- =====================================================

CREATE credential_type:customer_io_api SET
    name = "customerIoApi",
    slug = "customer-io-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_customer_io_api_name,
        description_i18n: i18n_key:credential_type_customer_io_api_description
    },
    
    presentation = {
        icon: icon:customer_io,
        color_type: theme_color_type:info,
        tooltip_i18n: i18n_key:credential_type_customer_io_api_tooltip,
        display_order: 1066
    },
    
    auth_type = auth_type:custom,
    provider = provider:customer_io,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "trackingApiKey",
                display_name: "Tracking API Key",
                type: "string",
                is_secret: true,
                required: true,
                description: "Customer.io tracking API key"
            },
            {
                name: "trackingSiteId",
                display_name: "Tracking Site ID",
                type: "string",
                is_secret: false,
                required: true,
                description: "Customer.io site ID"
            },
            {
                name: "region",
                display_name: "Region",
                type: "options",
                is_secret: false,
                required: true,
                description: "Customer.io region",
                options: [
                    { name: "Global region", value: "track.customer.io" },
                    { name: "EU region", value: "track-eu.customer.io" }
                ],
                default: "track.customer.io"
            },
            {
                name: "appApiKey",
                display_name: "App API Key",
                type: "string",
                is_secret: true,
                required: false,
                description: "Customer.io App API key (optional)"
            }
        ],
        metadata: {
            marketing_automation: true,
            customer_messaging: true,
            multi_region: true
        }
    },
    
    documentation = {
        url: url:customer_io_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 8. E-GOI API (display_order: 1067)
-- =====================================================

CREATE credential_type:egoi_api SET
    name = "egoiApi",
    slug = "egoi-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_egoi_api_name,
        description_i18n: i18n_key:credential_type_egoi_api_description
    },
    
    presentation = {
        icon: icon:egoi,
        color_type: theme_color_type:error,
        tooltip_i18n: i18n_key:credential_type_egoi_api_tooltip,
        display_order: 1067
    },
    
    auth_type = auth_type:api_key,
    provider = provider:egoi,
    
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
                description: "E-goi API key"
            }
        ],
        metadata: {
            email_marketing: true,
            multi_channel: true,
            sms_marketing: true
        }
    },
    
    documentation = {
        url: url:egoi_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 9. SENDY API (display_order: 1068)
-- =====================================================

CREATE credential_type:sendy_api SET
    name = "sendyApi",
    slug = "sendy-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_sendy_api_name,
        description_i18n: i18n_key:credential_type_sendy_api_description
    },
    
    presentation = {
        icon: icon:sendy,
        color_type: theme_color_type:info,
        tooltip_i18n: i18n_key:credential_type_sendy_api_tooltip,
        display_order: 1068
    },
    
    auth_type = auth_type:api_key,
    provider = provider:sendy,
    
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
                description: "Sendy installation URL"
            },
            {
                name: "apiKey",
                display_name: "API Key",
                type: "string",
                is_secret: true,
                required: true,
                description: "Sendy API key"
            }
        ],
        metadata: {
            email_marketing: true,
            self_hosted: true,
            amazon_ses: true,
            cost_effective: true
        }
    },
    
    documentation = {
        url: url:sendy_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 10. LEMLIST API (display_order: 1069)
-- =====================================================

CREATE credential_type:lemlist_api SET
    name = "lemlistApi",
    slug = "lemlist-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_lemlist_api_name,
        description_i18n: i18n_key:credential_type_lemlist_api_description
    },
    
    presentation = {
        icon: icon:lemlist,
        color_type: theme_color_type:error,
        tooltip_i18n: i18n_key:credential_type_lemlist_api_tooltip,
        display_order: 1069
    },
    
    auth_type = auth_type:basic_auth,
    provider = provider:lemlist,
    
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
                description: "Lemlist API key"
            }
        ],
        metadata: {
            cold_outreach: true,
            email_personalization: true,
            sales_automation: true
        }
    },
    
    documentation = {
        url: url:lemlist_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 11. SMTP (display_order: 1070) ✨ TRÈS POPULAIRE
-- =====================================================

CREATE credential_type:smtp SET
    name = "smtp",
    slug = "smtp",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_smtp_name,
        description_i18n: i18n_key:credential_type_smtp_description
    },
    
    presentation = {
        icon: icon:smtp,
        color_type: theme_color_type:success,
        tooltip_i18n: i18n_key:credential_type_smtp_tooltip,
        display_order: 1070
    },
    
    auth_type = auth_type:basic_auth,
    provider = provider:smtp,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "user",
                display_name: "User",
                type: "string",
                is_secret: false,
                required: true,
                description: "SMTP username"
            },
            {
                name: "password",
                display_name: "Password",
                type: "string",
                is_secret: true,
                required: true,
                description: "SMTP password"
            },
            {
                name: "host",
                display_name: "Host",
                type: "string",
                is_secret: false,
                required: true,
                description: "SMTP server hostname"
            },
            {
                name: "port",
                display_name: "Port",
                type: "number",
                is_secret: false,
                required: true,
                description: "SMTP server port",
                default: 465
            },
            {
                name: "secure",
                display_name: "SSL/TLS",
                type: "boolean",
                is_secret: false,
                required: false,
                description: "Use SSL/TLS encryption",
                default: true
            },
            {
                name: "disableStartTls",
                display_name: "Disable STARTTLS",
                type: "boolean",
                is_secret: false,
                required: false,
                description: "Disable STARTTLS when SSL/TLS is off",
                default: false
            },
            {
                name: "hostName",
                display_name: "Client Host Name",
                type: "string",
                is_secret: false,
                required: false,
                description: "Hostname of the client for server identification"
            }
        ],
        metadata: {
            email_sending: true,
            standard_protocol: true,
            universal: true,
            very_popular: true
        }
    },
    
    documentation = {
        url: url:smtp_docs,
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
WHERE presentation.display_order >= 1060 AND presentation.display_order <= 1070
ORDER BY presentation.display_order ASC;
*/

-- =====================================================
-- RÉSUMÉ BATCH 18
-- =====================================================
--
-- ✅ 11 credentials Email Marketing & Communication créés :
--
-- Email Marketing Platforms (5) - display_order: 1060-1064
--  1. brevo_api (1060) ✨ TRÈS POPULAIRE - Email marketing (formerly SendInBlue)
--  2. getresponse_api (1061) - Marketing automation platform
--  3. getresponse_oauth2_api (1062) - GetResponse OAuth2 version
--  4. mailerlite_api (1063) - Email marketing with landing pages
--  5. convertkit_api (1064) - Creator-focused newsletter tool
--
-- Email Automation & Outreach (4) - display_order: 1065-1068
--  6. automizy_api (1065) [DEPRECATED] - Marketing automation (service discontinued)
--  7. customer_io_api (1066) - Customer messaging & automation (EU/Global regions)
--  8. egoi_api (1067) - Multi-channel marketing (Email/SMS)
--  9. sendy_api (1068) - Self-hosted email marketing (Amazon SES)
--
-- Cold Outreach & SMTP (2) - display_order: 1069-1070
-- 10. lemlist_api (1069) - Cold email outreach & personalization
-- 11. smtp (1070) ✨ TRÈS POPULAIRE - Standard SMTP protocol (universal)
--
-- Structure complète : identity, presentation, config, documentation
--
-- =============================================================================================

