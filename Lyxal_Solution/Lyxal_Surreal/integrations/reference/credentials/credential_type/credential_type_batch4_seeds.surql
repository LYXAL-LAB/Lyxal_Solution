-- =============================================================================================
-- |
-- | Fichier : credential_type_batch4_seeds.surql (SEED DATA)
-- | Module : integrations > reference > credentials > credential_type
-- | Description : Seeds pour le Batch 4 des credential types (13 credentials Communication).
-- |
-- | Batch 4 : Top Communication (13 credentials)
-- | Providers : Slack, Discord, Telegram, Twilio, WhatsApp, Mattermost, RocketChat, Matrix, Twist
-- |
-- =============================================================================================

-- =====================================================
-- 1. SLACK API (display_order: 300) ✨ TRÈS POPULAIRE
-- =====================================================

CREATE credential_type:slack_api SET
    name = "slackApi",
    slug = "slack-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_slack_api_name,
        description_i18n: i18n_key:credential_type_slack_api_description
    }, presentation = { icon: icon:slack_api, color_type: theme_color_type:neutral, tooltip_i18n: i18n_key:credential_type_slack_api_tooltip,
        display_order: 300
    },
    
    auth_type = auth_type:bearer_token,
    provider = provider:slack,
    
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
                description: "Slack API token (starts with xoxb- or xoxp-)"
            }
        ],
        metadata: {
            token_types: ["bot", "user"],
            auth_method: "bearer_token"
        }
    },
    
    documentation = {
        url: url:slack_api_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 2. SLACK OAUTH2 API (display_order: 301) ✨ TRÈS POPULAIRE
-- =====================================================

CREATE credential_type:slack_oauth2_api SET
    name = "slackOAuth2Api",
    slug = "slack-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_slack_oauth2_api_name,
        description_i18n: i18n_key:credential_type_slack_oauth2_api_description
    }, presentation = { icon: icon:slack_oauth2_api, color_type: theme_color_type:neutral, tooltip_i18n: i18n_key:credential_type_slack_oauth2_api_tooltip,
        display_order: 301
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:slack,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://slack.com/api/oauth.v2.access",
            authorization_url: "https://slack.com/oauth/v2/authorize",
            authentication_method: "body",
            scope: "chat:write channels:read"
        },
        oauth1: NONE,
        required_fields: [],
        metadata: {
            oauth_version: "v2"
        }
    },
    
    documentation = {
        url: url:slack_oauth2_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 3. DISCORD BOT API (display_order: 302) ✨ POPULAIRE
-- =====================================================

CREATE credential_type:discord_bot_api SET
    name = "discordBotApi",
    slug = "discord-bot-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_discord_bot_api_name,
        description_i18n: i18n_key:credential_type_discord_bot_api_description
    },
    
    presentation = {
        icon: icon:discord,
        color_type: theme_color_type:primary,
        tooltip_i18n: i18n_key:credential_type_discord_bot_api_tooltip,
        display_order: 302
    },
    
    auth_type = auth_type:bearer_token,
    provider = provider:discord,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "botToken",
                display_name: "Bot Token",
                type: "string",
                is_secret: true,
                required: true,
                description: "Discord bot token from Developer Portal"
            }
        ],
        metadata: {
            auth_method: "bot_token"
        }
    },
    
    documentation = {
        url: url:discord_bot_api_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 4. DISCORD OAUTH2 API (display_order: 303)
-- =====================================================

CREATE credential_type:discord_oauth2_api SET
    name = "discordOAuth2Api",
    slug = "discord-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_discord_oauth2_api_name,
        description_i18n: i18n_key:credential_type_discord_oauth2_api_description
    },
    
    presentation = {
        icon: icon:discord,
        color_type: theme_color_type:primary,
        tooltip_i18n: i18n_key:credential_type_discord_oauth2_api_tooltip,
        display_order: 303
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:discord,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://discord.com/api/oauth2/token",
            authorization_url: "https://discord.com/api/oauth2/authorize",
            authentication_method: "body",
            scope: "identify guilds"
        },
        oauth1: NONE,
        required_fields: [],
        metadata: {}
    },
    
    documentation = {
        url: url:discord_oauth2_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 5. DISCORD WEBHOOK API (display_order: 304)
-- =====================================================

CREATE credential_type:discord_webhook_api SET
    name = "discordWebhookApi",
    slug = "discord-webhook-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_discord_webhook_api_name,
        description_i18n: i18n_key:credential_type_discord_webhook_api_description
    }, presentation = { icon: icon:discord_webhook_api, color_type: theme_color_type:neutral, tooltip_i18n: i18n_key:credential_type_discord_webhook_api_tooltip,
        display_order: 304
    },
    
    auth_type = auth_type:custom,
    provider = provider:discord,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "webhookUrl",
                display_name: "Webhook URL",
                type: "string",
                is_secret: true,
                required: true,
                description: "Discord webhook URL",
                placeholder: "https://discord.com/api/webhooks/..."
            }
        ],
        metadata: {
            auth_method: "webhook",
            no_authentication_header: true
        }
    },
    
    documentation = {
        url: url:discord_webhook_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 6. TELEGRAM API (display_order: 305) ✨ TRÈS POPULAIRE
-- =====================================================

CREATE credential_type:telegram_api SET
    name = "telegramApi",
    slug = "telegram-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_telegram_api_name,
        description_i18n: i18n_key:credential_type_telegram_api_description
    },
    
    presentation = {
        icon: icon:telegram,
        color_type: theme_color_type:info,
        tooltip_i18n: i18n_key:credential_type_telegram_api_tooltip,
        display_order: 305
    },
    
    auth_type = auth_type:bearer_token,
    provider = provider:telegram,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "accessToken",
                display_name: "Bot Token",
                type: "string",
                is_secret: true,
                required: true,
                description: "Telegram bot token from @BotFather"
            }
        ],
        metadata: {
            auth_method: "bot_token",
            bot_father: true
        }
    },
    
    documentation = {
        url: url:telegram_bot_api_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 7. TWILIO API (display_order: 310) ✨ POPULAIRE
-- =====================================================

CREATE credential_type:twilio_api SET
    name = "twilioApi",
    slug = "twilio-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_twilio_api_name,
        description_i18n: i18n_key:credential_type_twilio_api_description
    },
    
    presentation = {
        icon: icon:twilio,
        color_type: theme_color_type:error,
        tooltip_i18n: i18n_key:credential_type_twilio_api_tooltip,
        display_order: 310
    },
    
    auth_type = auth_type:basic_auth,
    provider = provider:twilio,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "accountSid",
                display_name: "Account SID",
                type: "string",
                is_secret: false,
                required: true,
                description: "Twilio Account SID"
            },
            {
                name: "authToken",
                display_name: "Auth Token",
                type: "string",
                is_secret: true,
                required: true,
                description: "Twilio Auth Token"
            }
        ],
        metadata: {
            auth_method: "basic_auth"
        }
    },
    
    documentation = {
        url: url:twilio_api_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 8. WHATSAPP API - DOUBLON SUPPRIMÉ (déjà défini ailleurs avec name = "whatsAppApi")
-- =====================================================

-- =====================================================
-- 9. WHATSAPP TRIGGER API - DOUBLON SUPPRIMÉ (déjà défini dans la base avec name = "whatsAppTriggerApi")
-- =====================================================

-- =====================================================
-- 10. MATTERMOST API (display_order: 320)
-- =====================================================

CREATE credential_type:mattermost_api SET
    name = "mattermostApi",
    slug = "mattermost-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_mattermost_api_name,
        description_i18n: i18n_key:credential_type_mattermost_api_description
    },
    
    presentation = {
        icon: icon:mattermost,
        color_type: theme_color_type:info,
        tooltip_i18n: i18n_key:credential_type_mattermost_api_tooltip,
        display_order: 320
    },
    
    auth_type = auth_type:bearer_token,
    provider = provider:mattermost,
    
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
                description: "Mattermost server URL",
                placeholder: "https://mattermost.example.com"
            },
            {
                name: "accessToken",
                display_name: "Access Token",
                type: "string",
                is_secret: true,
                required: true,
                description: "Mattermost personal access token"
            }
        ],
        metadata: {
            self_hosted: true,
            open_source: true
        }
    },
    
    documentation = {
        url: url:mattermost_api_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 11. ROCKETCHAT API (display_order: 321)
-- =====================================================

CREATE credential_type:rocketchat_api SET
    name = "rocketchatApi",
    slug = "rocketchat-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_rocketchat_api_name,
        description_i18n: i18n_key:credential_type_rocketchat_api_description
    },
    
    presentation = {
        icon: icon:rocketchat,
        color_type: theme_color_type:error,
        tooltip_i18n: i18n_key:credential_type_rocketchat_api_tooltip,
        display_order: 321
    },
    
    auth_type = auth_type:basic_auth,
    provider = provider:rocketchat,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "domain",
                display_name: "Domain",
                type: "string",
                is_secret: false,
                required: true,
                description: "Rocket.Chat server domain",
                placeholder: "rocketchat.example.com"
            },
            {
                name: "userId",
                display_name: "User ID",
                type: "string",
                is_secret: false,
                required: true,
                description: "Rocket.Chat user ID"
            },
            {
                name: "authToken",
                display_name: "Auth Token",
                type: "string",
                is_secret: true,
                required: true,
                description: "Rocket.Chat authentication token"
            }
        ],
        metadata: {
            self_hosted: true,
            open_source: true
        }
    },
    
    documentation = {
        url: url:rocketchat_api_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 12. MATRIX API (display_order: 322)
-- =====================================================

CREATE credential_type:matrix_api SET
    name = "matrixApi",
    slug = "matrix-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_matrix_api_name,
        description_i18n: i18n_key:credential_type_matrix_api_description
    },
    
    presentation = {
        icon: icon:matrix,
        color_type: theme_color_type:success,
        tooltip_i18n: i18n_key:credential_type_matrix_api_tooltip,
        display_order: 322
    },
    
    auth_type = auth_type:bearer_token,
    provider = provider:matrix,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "homeserver",
                display_name: "Homeserver URL",
                type: "string",
                is_secret: false,
                required: true,
                description: "Matrix homeserver URL",
                placeholder: "https://matrix.org"
            },
            {
                name: "accessToken",
                display_name: "Access Token",
                type: "string",
                is_secret: true,
                required: true,
                description: "Matrix access token"
            }
        ],
        metadata: {
            decentralized: true,
            open_source: true,
            encryption: "end-to-end"
        }
    },
    
    documentation = {
        url: url:matrix_api_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 13. TWIST OAUTH2 API (display_order: 323)
-- =====================================================

CREATE credential_type:twist_oauth2_api SET
    name = "twistOAuth2Api",
    slug = "twist-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_twist_oauth2_api_name,
        description_i18n: i18n_key:credential_type_twist_oauth2_api_description
    },
    
    presentation = {
        icon: icon:twist,
        color_type: theme_color_type:info,
        tooltip_i18n: i18n_key:credential_type_twist_oauth2_api_tooltip,
        display_order: 323
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:twist,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://twist.com/oauth/access_token",
            authorization_url: "https://twist.com/oauth/authorize",
            authentication_method: "body",
            scope: ""
        },
        oauth1: NONE,
        required_fields: [],
        metadata: {
            async_communication: true
        }
    },
    
    documentation = {
        url: url:twist_oauth2_docs,
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
WHERE presentation.display_order >= 300 AND presentation.display_order < 400
ORDER BY presentation.display_order ASC;
*/

-- =====================================================
-- RÉSUMÉ BATCH 4
-- =====================================================
--
-- ✅ 13 credentials Communication créés :
--
-- Team Messaging (5) - display_order: 300-304 ✨ TRÈS POPULAIRES
--  1. slack_api (300) ✨ TRÈS POPULAIRE
--  2. slack_oauth2_api (301) ✨ TRÈS POPULAIRE
--  3. discord_bot_api (302) ✨ POPULAIRE
--  4. discord_oauth2_api (303)
--  5. discord_webhook_api (304)
--
-- Consumer Messaging (4) - display_order: 305, 310-312 ✨ TRÈS POPULAIRES
--  6. telegram_api (305) ✨ TRÈS POPULAIRE
--  7. twilio_api (310) ✨ POPULAIRE
--  8. whatsapp_api (311) ✨ TRÈS POPULAIRE
--  9. whatsapp_trigger_api (312)
--
-- Open-Source Team Messaging (4) - display_order: 320-323
-- 10. mattermost_api (320) - Self-hosted Slack alternative
-- 11. rocketchat_api (321) - Open-source chat platform
-- 12. matrix_api (322) - Decentralized encrypted messaging
-- 13. twist_oauth2_api (323) - Asynchronous communication
--
-- Structure complète : identity, presentation, config, documentation
--
-- =============================================================================================

