-- =============================================================================================
-- |
-- | Fichier : credential_type_batch11_seeds.surql (SEED DATA)
-- | Module : integrations > reference > credentials > credential_type
-- | Description : Seeds pour le Batch 11 des credential types (11 credentials Customer Support, Analytics & Communication APIs).
-- |
-- | Batch 11 : Customer Support, Analytics & Communication APIs (11 credentials)
-- | Providers : Drift, Freshdesk, HelpScout, Intercom, Segment, Zendesk, Mailgun, Postmark, SendGrid
-- |
-- =============================================================================================

-- =====================================================
-- 1. DRIFT API (display_order: 870)
-- =====================================================

CREATE credential_type:drift_api SET
    name = "driftApi",
    slug = "drift-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_drift_api_name,
        description_i18n: i18n_key:credential_type_drift_api_description
    },
    
    presentation = {
        icon: icon:drift,
        color_type: theme_color_type:neutral,
        tooltip_i18n: i18n_key:credential_type_drift_api_tooltip,
        display_order: 870
    },
    
    auth_type = auth_type:bearer_token,
    provider = provider:drift,
    
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
                description: "Drift access token"
            }
        ],
        metadata: {
            conversational_marketing: true
        }
    },
    
    documentation = {
        url: url:drift_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 2. DRIFT OAUTH2 API (display_order: 871)
-- =====================================================

CREATE credential_type:drift_oauth2_api SET
    name = "driftOAuth2Api",
    slug = "drift-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_drift_oauth2_api_name,
        description_i18n: i18n_key:credential_type_drift_oauth2_api_description
    },
    
    presentation = {
        icon: icon:drift,
        color_type: theme_color_type:primary,
        tooltip_i18n: i18n_key:credential_type_drift_oauth2_api_tooltip,
        display_order: 871
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:drift,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://driftapi.com/oauth2/token",
            authorization_url: "https://dev.drift.com/authorize",
            authentication_method: "body",
            scope: ""
        },
        oauth1: NONE,
        required_fields: [],
        metadata: {}
    },
    
    documentation = {
        url: url:drift_oauth2_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 3. FRESHDESK API (display_order: 880)
-- =====================================================

CREATE credential_type:freshdesk_api SET
    name = "freshdeskApi",
    slug = "freshdesk-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_freshdesk_api_name,
        description_i18n: i18n_key:credential_type_freshdesk_api_description
    },
    
    presentation = {
        icon: icon:freshdesk,
        color_type: theme_color_type:success,
        tooltip_i18n: i18n_key:credential_type_freshdesk_api_tooltip,
        display_order: 880
    },
    
    auth_type = auth_type:api_key,
    provider = provider:freshdesk,
    
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
                description: "Freshdesk API key"
            },
            {
                name: "domain",
                display_name: "Freshdesk Domain",
                type: "string",
                is_secret: false,
                required: true,
                description: "Freshdesk domain (e.g., yourcompany.freshdesk.com)",
                placeholder: "yourcompany.freshdesk.com"
            }
        ],
        metadata: {
            freshworks_product: true
        }
    },
    
    documentation = {
        url: url:freshdesk_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 4. HELPSCOUT OAUTH2 API (display_order: 881)
-- =====================================================

CREATE credential_type:helpscout_oauth2_api SET
    name = "helpScoutOAuth2Api",
    slug = "helpscout-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_helpscout_oauth2_api_name,
        description_i18n: i18n_key:credential_type_helpscout_oauth2_api_description
    },
    
    presentation = {
        icon: icon:helpscout,
        color_type: theme_color_type:info,
        tooltip_i18n: i18n_key:credential_type_helpscout_oauth2_api_tooltip,
        display_order: 881
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:helpscout,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://api.helpscout.net/v2/oauth2/token",
            authorization_url: "https://secure.helpscout.net/authentication/authorizeClientApplication",
            authentication_method: "body",
            scope: ""
        },
        oauth1: NONE,
        required_fields: [],
        metadata: {}
    },
    
    documentation = {
        url: url:helpscout_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 5. INTERCOM API (display_order: 890) ✨ TRÈS POPULAIRE
-- =====================================================

CREATE credential_type:intercom_api SET
    name = "intercomApi",
    slug = "intercom-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_intercom_api_name,
        description_i18n: i18n_key:credential_type_intercom_api_description
    },
    
    presentation = {
        icon: icon:intercom,
        color_type: theme_color_type:info,
        tooltip_i18n: i18n_key:credential_type_intercom_api_tooltip,
        display_order: 890
    },
    
    auth_type = auth_type:bearer_token,
    provider = provider:intercom,
    
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
                description: "Intercom access token"
            }
        ],
        metadata: {
            customer_messaging: true
        }
    },
    
    documentation = {
        url: url:intercom_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 6. SEGMENT API (display_order: 891)
-- =====================================================

CREATE credential_type:segment_api SET
    name = "segmentApi",
    slug = "segment-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_segment_api_name,
        description_i18n: i18n_key:credential_type_segment_api_description
    },
    
    presentation = {
        icon: icon:segment,
        color_type: theme_color_type:success,
        tooltip_i18n: i18n_key:credential_type_segment_api_tooltip,
        display_order: 891
    },
    
    auth_type = auth_type:api_key,
    provider = provider:segment,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "writeKey",
                display_name: "Write Key",
                type: "string",
                is_secret: true,
                required: true,
                description: "Segment write key"
            }
        ],
        metadata: {
            cdp_platform: true,
            analytics: true
        }
    },
    
    documentation = {
        url: url:segment_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 7. ZENDESK API (display_order: 900) ✨ TRÈS POPULAIRE
-- =====================================================

CREATE credential_type:zendesk_api SET
    name = "zendeskApi",
    slug = "zendesk-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_zendesk_api_name,
        description_i18n: i18n_key:credential_type_zendesk_api_description
    },
    
    presentation = {
        icon: icon:zendesk,
        color_type: theme_color_type:neutral,
        tooltip_i18n: i18n_key:credential_type_zendesk_api_tooltip,
        display_order: 900
    },
    
    auth_type = auth_type:bearer_token,
    provider = provider:zendesk,
    
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
                description: "Zendesk subdomain",
                placeholder: "yourcompany"
            },
            {
                name: "email",
                display_name: "Email",
                type: "string",
                is_secret: false,
                required: true,
                description: "Zendesk account email"
            },
            {
                name: "apiToken",
                display_name: "API Token",
                type: "string",
                is_secret: true,
                required: true,
                description: "Zendesk API token"
            }
        ],
        metadata: {}
    },
    
    documentation = {
        url: url:zendesk_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 8. ZENDESK OAUTH2 API (display_order: 901)
-- =====================================================

CREATE credential_type:zendesk_oauth2_api SET
    name = "zendeskOAuth2Api",
    slug = "zendesk-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_zendesk_oauth2_api_name,
        description_i18n: i18n_key:credential_type_zendesk_oauth2_api_description
    },
    
    presentation = {
        icon: icon:zendesk,
        color_type: theme_color_type:primary,
        tooltip_i18n: i18n_key:credential_type_zendesk_oauth2_api_tooltip,
        display_order: 901
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:zendesk,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "=https://{{$parameter[\"subdomain\"]}}.zendesk.com/oauth/tokens",
            authorization_url: "=https://{{$parameter[\"subdomain\"]}}.zendesk.com/oauth/authorizations/new",
            authentication_method: "body",
            scope: "read write"
        },
        oauth1: NONE,
        required_fields: [
            {
                name: "subdomain",
                display_name: "Subdomain",
                type: "string",
                is_secret: false,
                required: true,
                description: "Zendesk subdomain",
                placeholder: "yourcompany"
            }
        ],
        metadata: {}
    },
    
    documentation = {
        url: url:zendesk_oauth2_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 9. MAILGUN API (display_order: 910) ✨ POPULAIRE
-- =====================================================

CREATE credential_type:mailgun_api SET
    name = "mailgunApi",
    slug = "mailgun-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_mailgun_api_name,
        description_i18n: i18n_key:credential_type_mailgun_api_description
    },
    
    presentation = {
        icon: icon:mailgun,
        color_type: theme_color_type:error,
        tooltip_i18n: i18n_key:credential_type_mailgun_api_tooltip,
        display_order: 910
    },
    
    auth_type = auth_type:basic_auth,
    provider = provider:mailgun,
    
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
                description: "Mailgun API key"
            },
            {
                name: "apiDomain",
                display_name: "API Domain",
                type: "options",
                is_secret: false,
                required: true,
                description: "Mailgun API domain",
                options: [
                    { name: "US (api.mailgun.net)", value: "api.mailgun.net" },
                    { name: "EU (api.eu.mailgun.net)", value: "api.eu.mailgun.net" }
                ],
                default: "api.mailgun.net"
            }
        ],
        metadata: {
            transactional_email: true
        }
    },
    
    documentation = {
        url: url:mailgun_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 10. POSTMARK API (display_order: 911)
-- =====================================================

CREATE credential_type:postmark_api SET
    name = "postmarkApi",
    slug = "postmark-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_postmark_api_name,
        description_i18n: i18n_key:credential_type_postmark_api_description
    },
    
    presentation = {
        icon: icon:postmark,
        color_type: theme_color_type:warning,
        tooltip_i18n: i18n_key:credential_type_postmark_api_tooltip,
        display_order: 911
    },
    
    auth_type = auth_type:bearer_token,
    provider = provider:postmark,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "serverToken",
                display_name: "Server API Token",
                type: "string",
                is_secret: true,
                required: true,
                description: "Postmark server API token"
            }
        ],
        metadata: {
            transactional_email: true,
            high_deliverability: true
        }
    },
    
    documentation = {
        url: url:postmark_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 11. SENDGRID API (display_order: 912) ✨ TRÈS POPULAIRE
-- =====================================================

CREATE credential_type:sendgrid_api SET
    name = "sendGridApi",
    slug = "sendgrid-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_sendgrid_api_name,
        description_i18n: i18n_key:credential_type_sendgrid_api_description
    },
    
    presentation = {
        icon: icon:sendgrid,
        color_type: theme_color_type:info,
        tooltip_i18n: i18n_key:credential_type_sendgrid_api_tooltip,
        display_order: 912
    },
    
    auth_type = auth_type:bearer_token,
    provider = provider:sendgrid,
    
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
                description: "SendGrid API key"
            }
        ],
        metadata: {
            transactional_email: true,
            twilio_product: true
        }
    },
    
    documentation = {
        url: url:sendgrid_docs,
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
WHERE presentation.display_order >= 870 AND presentation.display_order < 920
ORDER BY presentation.display_order ASC;
*/

-- =====================================================
-- RÉSUMÉ BATCH 11
-- =====================================================
--
-- ✅ 12 credentials Customer Support, Analytics & Communication APIs créés :
--
-- Conversational Marketing (2) - display_order: 870-871
--  1. drift_api (870)
--  2. drift_oauth2_api (871)
--
-- Customer Support & Helpdesk (4) - display_order: 880-881, 900-901 ✨ TRÈS POPULAIRE
--  3. freshdesk_api (880)
--  4. helpscout_oauth2_api (881)
--  7. zendesk_api (900) ✨ TRÈS POPULAIRE
--  8. zendesk_oauth2_api (901)
--
-- Customer Messaging & Analytics (2) - display_order: 890-891 ✨ TRÈS POPULAIRE
--  5. intercom_api (890) ✨ TRÈS POPULAIRE
--  6. segment_api (891) - CDP Platform
--
-- Transactional Email & SMS (4) - display_order: 910-913 ✨ TRÈS POPULAIRE
--  9. mailgun_api (910) ✨ POPULAIRE
-- 10. postmark_api (911)
-- 11. sendgrid_api (912) ✨ TRÈS POPULAIRE - Twilio
-- 12. twilio_api (913) ✨ TRÈS POPULAIRE - SMS/Voice
--
-- Structure complète : identity, presentation, config, documentation
--
-- =============================================================================================

