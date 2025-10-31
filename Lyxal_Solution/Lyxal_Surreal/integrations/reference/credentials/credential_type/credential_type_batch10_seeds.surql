-- =============================================================================================
-- |
-- | Fichier : credential_type_batch10_seeds.surql (SEED DATA)
-- | Module : integrations > reference > credentials > credential_type
-- | Description : Seeds pour le Batch 10 des credential types (14 credentials Productivity & Project Management).
-- |
-- | Batch 10 : Productivity & Project Management (14 credentials)
-- | Providers : Airtable, Asana, ClickUp, Monday.com, Notion, Todoist, Trello
-- |
-- =============================================================================================

-- =====================================================
-- 1. AIRTABLE API (display_order: 800) ✨ TRÈS POPULAIRE
-- =====================================================

CREATE credential_type:airtable_api SET
    name = "airtableApi",
    slug = "airtable-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_airtable_api_name,
        description_i18n: i18n_key:credential_type_airtable_api_description
    },
    
    presentation = {
        icon: icon:airtable,
        color: "#18BFFF",
        color_daisy: "info",
        tooltip_i18n: i18n_key:credential_type_airtable_api_tooltip,
        display_order: 800
    },
    
    auth_type = auth_type:api_key,
    provider = provider:airtable,
    
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
                description: "Airtable API key (deprecated, use Personal Access Token)"
            }
        ],
        metadata: {
            deprecated: true,
            prefer: "airtableTokenApi"
        }
    },
    
    documentation = {
        url: url:airtable_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 2. AIRTABLE OAUTH2 API (display_order: 801)
-- =====================================================

CREATE credential_type:airtable_oauth2_api SET
    name = "airtableOAuth2Api",
    slug = "airtable-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_airtable_oauth2_api_name,
        description_i18n: i18n_key:credential_type_airtable_oauth2_api_description
    },
    
    presentation = {
        icon: icon:airtable,
        color: "#18BFFF",
        color_daisy: "accent",
        tooltip_i18n: i18n_key:credential_type_airtable_oauth2_api_tooltip,
        display_order: 801
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:airtable,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://airtable.com/oauth2/v1/token",
            authorization_url: "https://airtable.com/oauth2/v1/authorize",
            authentication_method: "body",
            scope: "data.records:read data.records:write"
        },
        oauth1: NONE,
        required_fields: [],
        metadata: {}
    },
    
    documentation = {
        url: url:airtable_oauth2_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 3. AIRTABLE TOKEN API (display_order: 802) ✨ TRÈS POPULAIRE
-- =====================================================

CREATE credential_type:airtable_token_api SET
    name = "airtableTokenApi",
    slug = "airtable-token-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_airtable_token_api_name,
        description_i18n: i18n_key:credential_type_airtable_token_api_description
    },
    
    presentation = {
        icon: icon:airtable,
        color: "#18BFFF",
        color_daisy: "primary",
        tooltip_i18n: i18n_key:credential_type_airtable_token_api_tooltip,
        display_order: 802
    },
    
    auth_type = auth_type:bearer_token,
    provider = provider:airtable,
    
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
                description: "Airtable Personal Access Token"
            }
        ],
        metadata: {
            recommended: true,
            granular_scopes: true
        }
    },
    
    documentation = {
        url: url:airtable_token_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 4. ASANA API (display_order: 810) ✨ TRÈS POPULAIRE
-- =====================================================

CREATE credential_type:asana_api SET
    name = "asanaApi",
    slug = "asana-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_asana_api_name,
        description_i18n: i18n_key:credential_type_asana_api_description
    },
    
    presentation = {
        icon: icon:asana,
        color: "#F06A6A",
        color_daisy: "error",
        tooltip_i18n: i18n_key:credential_type_asana_api_tooltip,
        display_order: 810
    },
    
    auth_type = auth_type:bearer_token,
    provider = provider:asana,
    
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
                description: "Asana Personal Access Token"
            }
        ],
        metadata: {}
    },
    
    documentation = {
        url: url:asana_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 5. ASANA OAUTH2 API (display_order: 811)
-- =====================================================

CREATE credential_type:asana_oauth2_api SET
    name = "asanaOAuth2Api",
    slug = "asana-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_asana_oauth2_api_name,
        description_i18n: i18n_key:credential_type_asana_oauth2_api_description
    },
    
    presentation = {
        icon: icon:asana,
        color: "#F06A6A",
        color_daisy: "primary",
        tooltip_i18n: i18n_key:credential_type_asana_oauth2_api_tooltip,
        display_order: 811
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:asana,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://app.asana.com/-/oauth_token",
            authorization_url: "https://app.asana.com/-/oauth_authorize",
            authentication_method: "body",
            scope: "default"
        },
        oauth1: NONE,
        required_fields: [],
        metadata: {}
    },
    
    documentation = {
        url: url:asana_oauth2_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 6. CLICKUP API (display_order: 820) ✨ POPULAIRE
-- =====================================================

CREATE credential_type:clickup_api SET
    name = "clickUpApi",
    slug = "clickup-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_clickup_api_name,
        description_i18n: i18n_key:credential_type_clickup_api_description
    },
    
    presentation = {
        icon: icon:clickup,
        color: "#7B68EE",
        color_daisy: "secondary",
        tooltip_i18n: i18n_key:credential_type_clickup_api_tooltip,
        display_order: 820
    },
    
    auth_type = auth_type:bearer_token,
    provider = provider:clickup,
    
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
                description: "ClickUp API token"
            }
        ],
        metadata: {}
    },
    
    documentation = {
        url: url:clickup_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 7. CLICKUP OAUTH2 API (display_order: 821)
-- =====================================================

CREATE credential_type:clickup_oauth2_api SET
    name = "clickUpOAuth2Api",
    slug = "clickup-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_clickup_oauth2_api_name,
        description_i18n: i18n_key:credential_type_clickup_oauth2_api_description
    },
    
    presentation = {
        icon: icon:clickup,
        color: "#7B68EE",
        color_daisy: "primary",
        tooltip_i18n: i18n_key:credential_type_clickup_oauth2_api_tooltip,
        display_order: 821
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:clickup,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://api.clickup.com/api/v2/oauth/token",
            authorization_url: "https://app.clickup.com/api",
            authentication_method: "body",
            scope: ""
        },
        oauth1: NONE,
        required_fields: [],
        metadata: {}
    },
    
    documentation = {
        url: url:clickup_oauth2_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 8. MONDAY.COM API (display_order: 830) ✨ TRÈS POPULAIRE
-- =====================================================

CREATE credential_type:monday_com_api SET
    name = "mondayComApi",
    slug = "monday-com-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_monday_com_api_name,
        description_i18n: i18n_key:credential_type_monday_com_api_description
    },
    
    presentation = {
        icon: icon:monday,
        color: "#FF3D57",
        color_daisy: "error",
        tooltip_i18n: i18n_key:credential_type_monday_com_api_tooltip,
        display_order: 830
    },
    
    auth_type = auth_type:bearer_token,
    provider = provider:monday,
    
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
                description: "Monday.com API token (v2)"
            }
        ],
        metadata: {
            api_type: "graphql"
        }
    },
    
    documentation = {
        url: url:monday_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 9. MONDAY.COM OAUTH2 API (display_order: 831)
-- =====================================================

CREATE credential_type:monday_com_oauth2_api SET
    name = "mondayComOAuth2Api",
    slug = "monday-com-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_monday_com_oauth2_api_name,
        description_i18n: i18n_key:credential_type_monday_com_oauth2_api_description
    },
    
    presentation = {
        icon: icon:monday,
        color: "#FF3D57",
        color_daisy: "primary",
        tooltip_i18n: i18n_key:credential_type_monday_com_oauth2_api_tooltip,
        display_order: 831
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:monday,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://auth.monday.com/oauth2/token",
            authorization_url: "https://auth.monday.com/oauth2/authorize",
            authentication_method: "body",
            scope: "boards:read boards:write"
        },
        oauth1: NONE,
        required_fields: [],
        metadata: {}
    },
    
    documentation = {
        url: url:monday_oauth2_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 10. NOTION API (display_order: 840) ✨ TRÈS POPULAIRE
-- =====================================================

CREATE credential_type:notion_api SET
    name = "notionApi",
    slug = "notion-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_notion_api_name,
        description_i18n: i18n_key:credential_type_notion_api_description
    },
    
    presentation = {
        icon: icon:notion,
        color: "#000000",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:credential_type_notion_api_tooltip,
        display_order: 840
    },
    
    auth_type = auth_type:bearer_token,
    provider = provider:notion,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "apiKey",
                display_name: "Internal Integration Token",
                type: "string",
                is_secret: true,
                required: true,
                description: "Notion Internal Integration Token"
            }
        ],
        metadata: {
            for_internal_integrations: true
        }
    },
    
    documentation = {
        url: url:notion_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 11. NOTION OAUTH2 API (display_order: 841)
-- =====================================================

CREATE credential_type:notion_oauth2_api SET
    name = "notionOAuth2Api",
    slug = "notion-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_notion_oauth2_api_name,
        description_i18n: i18n_key:credential_type_notion_oauth2_api_description
    },
    
    presentation = {
        icon: icon:notion,
        color: "#000000",
        color_daisy: "primary",
        tooltip_i18n: i18n_key:credential_type_notion_oauth2_api_tooltip,
        display_order: 841
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:notion,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://api.notion.com/v1/oauth/token",
            authorization_url: "https://api.notion.com/v1/oauth/authorize",
            authentication_method: "body",
            scope: ""
        },
        oauth1: NONE,
        required_fields: [],
        metadata: {
            for_public_integrations: true
        }
    },
    
    documentation = {
        url: url:notion_oauth2_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 12. TODOIST API (display_order: 850)
-- =====================================================

CREATE credential_type:todoist_api SET
    name = "todoistApi",
    slug = "todoist-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_todoist_api_name,
        description_i18n: i18n_key:credential_type_todoist_api_description
    },
    
    presentation = {
        icon: icon:todoist,
        color: "#E44332",
        color_daisy: "error",
        tooltip_i18n: i18n_key:credential_type_todoist_api_tooltip,
        display_order: 850
    },
    
    auth_type = auth_type:bearer_token,
    provider = provider:todoist,
    
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
                description: "Todoist API token"
            }
        ],
        metadata: {}
    },
    
    documentation = {
        url: url:todoist_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 13. TODOIST OAUTH2 API (display_order: 851)
-- =====================================================

CREATE credential_type:todoist_oauth2_api SET
    name = "todoistOAuth2Api",
    slug = "todoist-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_todoist_oauth2_api_name,
        description_i18n: i18n_key:credential_type_todoist_oauth2_api_description
    },
    
    presentation = {
        icon: icon:todoist,
        color: "#E44332",
        color_daisy: "primary",
        tooltip_i18n: i18n_key:credential_type_todoist_oauth2_api_tooltip,
        display_order: 851
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:todoist,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://todoist.com/oauth/access_token",
            authorization_url: "https://todoist.com/oauth/authorize",
            authentication_method: "body",
            scope: "data:read data:write"
        },
        oauth1: NONE,
        required_fields: [],
        metadata: {}
    },
    
    documentation = {
        url: url:todoist_oauth2_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 14. TRELLO API (display_order: 860) ✨ TRÈS POPULAIRE
-- =====================================================

CREATE credential_type:trello_api SET
    name = "trelloApi",
    slug = "trello-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_trello_api_name,
        description_i18n: i18n_key:credential_type_trello_api_description
    },
    
    presentation = {
        icon: icon:trello,
        color: "#0079BF",
        color_daisy: "info",
        tooltip_i18n: i18n_key:credential_type_trello_api_tooltip,
        display_order: 860
    },
    
    auth_type = auth_type:api_key,
    provider = provider:trello,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "apiKey",
                display_name: "API Key",
                type: "string",
                is_secret: false,
                required: true,
                description: "Trello API key"
            },
            {
                name: "apiToken",
                display_name: "API Token",
                type: "string",
                is_secret: true,
                required: true,
                description: "Trello API token"
            }
        ],
        metadata: {
            atlassian_product: true
        }
    },
    
    documentation = {
        url: url:trello_docs,
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
WHERE presentation.display_order >= 800 AND presentation.display_order < 870
ORDER BY presentation.display_order ASC;
*/

-- =====================================================
-- RÉSUMÉ BATCH 10
-- =====================================================
--
-- ✅ 14 credentials Productivity & Project Management créés :
--
-- Airtable (3) - display_order: 800-802 ✨ TRÈS POPULAIRE
--  1. airtable_api (800) - Deprecated
--  2. airtable_oauth2_api (801)
--  3. airtable_token_api (802) ✨ TRÈS POPULAIRE - Recommandé
--
-- Asana (2) - display_order: 810-811 ✨ TRÈS POPULAIRE
--  4. asana_api (810) ✨ TRÈS POPULAIRE
--  5. asana_oauth2_api (811)
--
-- ClickUp (2) - display_order: 820-821 ✨ POPULAIRE
--  6. clickup_api (820) ✨ POPULAIRE
--  7. clickup_oauth2_api (821)
--
-- Monday.com (2) - display_order: 830-831 ✨ TRÈS POPULAIRE
--  8. monday_com_api (830) ✨ TRÈS POPULAIRE - GraphQL API
--  9. monday_com_oauth2_api (831)
--
-- Notion (2) - display_order: 840-841 ✨ TRÈS POPULAIRE
-- 10. notion_api (840) ✨ TRÈS POPULAIRE - Internal Integrations
-- 11. notion_oauth2_api (841) - Public Integrations
--
-- Todoist (2) - display_order: 850-851
-- 12. todoist_api (850)
-- 13. todoist_oauth2_api (851)
--
-- Trello (1) - display_order: 860 ✨ TRÈS POPULAIRE
-- 14. trello_api (860) ✨ TRÈS POPULAIRE - Atlassian Kanban
--
-- Structure complète : identity, presentation, config, documentation
--
-- =============================================================================================

