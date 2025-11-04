-- =============================================================================================
-- |
-- | Fichier : credential_type_batch12_seeds.surql (SEED DATA)
-- | Module : integrations > reference > credentials > credential_type
-- | Description : Seeds pour le Batch 12 des credential types (11 credentials Forms, Surveys & Scheduling).
-- |
-- | Batch 12 : Forms, Surveys & Scheduling (11 credentials)
-- | Providers : TypeForm, SurveyMonkey, JotForm, Formstack, Calendly, Acuity Scheduling
-- |
-- =============================================================================================

-- =====================================================
-- 1. TYPEFORM API (display_order: 920) ✨ TRÈS POPULAIRE
-- =====================================================

CREATE credential_type:typeform_api SET
    name = "typeformApi",
    slug = "typeform-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_typeform_api_name,
        description_i18n: i18n_key:credential_type_typeform_api_description
    },
    
    presentation = {
        icon: icon:typeform,
        color_type: theme_color_type:neutral,
        tooltip_i18n: i18n_key:credential_type_typeform_api_tooltip,
        display_order: 920
    },
    
    auth_type = auth_type:bearer_token,
    provider = provider:typeform,
    
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
                description: "TypeForm personal access token"
            }
        ],
        metadata: {
            interactive_forms: true
        }
    },
    
    documentation = {
        url: url:typeform_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 2. TYPEFORM OAUTH2 API (display_order: 921)
-- =====================================================

CREATE credential_type:typeform_oauth2_api SET
    name = "typeformOAuth2Api",
    slug = "typeform-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_typeform_oauth2_api_name,
        description_i18n: i18n_key:credential_type_typeform_oauth2_api_description
    },
    
    presentation = {
        icon: icon:typeform,
        color_type: theme_color_type:primary,
        tooltip_i18n: i18n_key:credential_type_typeform_oauth2_api_tooltip,
        display_order: 921
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:typeform,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://api.typeform.com/oauth/token",
            authorization_url: "https://api.typeform.com/oauth/authorize",
            authentication_method: "body",
            scope: "accounts:read forms:read responses:read"
        },
        oauth1: NONE,
        required_fields: [],
        metadata: {}
    },
    
    documentation = {
        url: url:typeform_oauth2_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 3. SURVEYMONKEY API (display_order: 922) ✨ TRÈS POPULAIRE
-- =====================================================

CREATE credential_type:surveymonkey_api SET
    name = "surveyMonkeyApi",
    slug = "surveymonkey-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_surveymonkey_api_name,
        description_i18n: i18n_key:credential_type_surveymonkey_api_description
    },
    
    presentation = {
        icon: icon:surveymonkey,
        color_type: theme_color_type:success,
        tooltip_i18n: i18n_key:credential_type_surveymonkey_api_tooltip,
        display_order: 922
    },
    
    auth_type = auth_type:bearer_token,
    provider = provider:surveymonkey,
    
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
                description: "SurveyMonkey access token"
            }
        ],
        metadata: {
            surveys_leader: true
        }
    },
    
    documentation = {
        url: url:surveymonkey_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 4. SURVEYMONKEY OAUTH2 API (display_order: 923)
-- =====================================================

CREATE credential_type:surveymonkey_oauth2_api SET
    name = "surveyMonkeyOAuth2Api",
    slug = "surveymonkey-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_surveymonkey_oauth2_api_name,
        description_i18n: i18n_key:credential_type_surveymonkey_oauth2_api_description
    },
    
    presentation = {
        icon: icon:surveymonkey,
        color_type: theme_color_type:primary,
        tooltip_i18n: i18n_key:credential_type_surveymonkey_oauth2_api_tooltip,
        display_order: 923
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:surveymonkey,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://api.surveymonkey.com/oauth/token",
            authorization_url: "https://api.surveymonkey.com/oauth/authorize",
            authentication_method: "body",
            scope: "surveys_read responses_read"
        },
        oauth1: NONE,
        required_fields: [],
        metadata: {}
    },
    
    documentation = {
        url: url:surveymonkey_oauth2_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 5. JOTFORM API (display_order: 924) ✨ POPULAIRE
-- =====================================================

CREATE credential_type:jotform_api SET
    name = "jotFormApi",
    slug = "jotform-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_jotform_api_name,
        description_i18n: i18n_key:credential_type_jotform_api_description
    },
    
    presentation = {
        icon: icon:jotform,
        color_type: theme_color_type:warning,
        tooltip_i18n: i18n_key:credential_type_jotform_api_tooltip,
        display_order: 924
    },
    
    auth_type = auth_type:api_key,
    provider = provider:jotform,
    
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
                description: "JotForm API key"
            },
            {
                name: "apiDomain",
                display_name: "API Domain",
                type: "options",
                is_secret: false,
                required: true,
                description: "JotForm API domain",
                options: [
                    { name: "api.jotform.com", value: "api.jotform.com" },
                    { name: "eu-api.jotform.com", value: "eu-api.jotform.com" },
                    { name: "hipaa-api.jotform.com", value: "hipaa-api.jotform.com" }
                ],
                default: "api.jotform.com"
            }
        ],
        metadata: {
            drag_and_drop_builder: true,
            multi_region_support: true
        }
    },
    
    documentation = {
        url: url:jotform_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 6. FORMSTACK API (display_order: 925)
-- =====================================================

CREATE credential_type:formstack_api SET
    name = "formstackApi",
    slug = "formstack-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_formstack_api_name,
        description_i18n: i18n_key:credential_type_formstack_api_description
    },
    
    presentation = {
        icon: icon:formstack,
        color_type: theme_color_type:info,
        tooltip_i18n: i18n_key:credential_type_formstack_api_tooltip,
        display_order: 925
    },
    
    auth_type = auth_type:bearer_token,
    provider = provider:formstack,
    
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
                description: "Formstack access token"
            }
        ],
        metadata: {
            workplace_productivity: true
        }
    },
    
    documentation = {
        url: url:formstack_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 7. FORMSTACK OAUTH2 API (display_order: 926)
-- =====================================================

CREATE credential_type:formstack_oauth2_api SET
    name = "formstackOAuth2Api",
    slug = "formstack-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_formstack_oauth2_api_name,
        description_i18n: i18n_key:credential_type_formstack_oauth2_api_description
    },
    
    presentation = {
        icon: icon:formstack,
        color_type: theme_color_type:primary,
        tooltip_i18n: i18n_key:credential_type_formstack_oauth2_api_tooltip,
        display_order: 926
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:formstack,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://www.formstack.com/api/v2/oauth2/token",
            authorization_url: "https://www.formstack.com/api/v2/oauth2/authorize",
            authentication_method: "body",
            scope: ""
        },
        oauth1: NONE,
        required_fields: [],
        metadata: {}
    },
    
    documentation = {
        url: url:formstack_oauth2_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 8. CALENDLY API (display_order: 930) ✨ TRÈS POPULAIRE
-- =====================================================

CREATE credential_type:calendly_api SET
    name = "calendlyApi",
    slug = "calendly-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_calendly_api_name,
        description_i18n: i18n_key:credential_type_calendly_api_description
    },
    
    presentation = {
        icon: icon:calendly,
        color_type: theme_color_type:info,
        tooltip_i18n: i18n_key:credential_type_calendly_api_tooltip,
        display_order: 930
    },
    
    auth_type = auth_type:bearer_token,
    provider = provider:calendly,
    
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
                description: "Calendly personal access token"
            }
        ],
        metadata: {
            automated_scheduling: true
        }
    },
    
    documentation = {
        url: url:calendly_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 9. CALENDLY OAUTH2 API (display_order: 931)
-- =====================================================

CREATE credential_type:calendly_oauth2_api SET
    name = "calendlyOAuth2Api",
    slug = "calendly-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_calendly_oauth2_api_name,
        description_i18n: i18n_key:credential_type_calendly_oauth2_api_description
    },
    
    presentation = {
        icon: icon:calendly,
        color_type: theme_color_type:primary,
        tooltip_i18n: i18n_key:credential_type_calendly_oauth2_api_tooltip,
        display_order: 931
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:calendly,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://auth.calendly.com/oauth/token",
            authorization_url: "https://auth.calendly.com/oauth/authorize",
            authentication_method: "body",
            scope: ""
        },
        oauth1: NONE,
        required_fields: [],
        metadata: {}
    },
    
    documentation = {
        url: url:calendly_oauth2_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 10. ACUITY SCHEDULING API (display_order: 932)
-- =====================================================

CREATE credential_type:acuity_scheduling_api SET
    name = "acuitySchedulingApi",
    slug = "acuity-scheduling-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_acuity_scheduling_api_name,
        description_i18n: i18n_key:credential_type_acuity_scheduling_api_description
    },
    
    presentation = {
        icon: icon:acuity_scheduling,
        color: "#00C4CC",
        color_daisy: "accent",
        tooltip_i18n: i18n_key:credential_type_acuity_scheduling_api_tooltip,
        display_order: 932
    },
    
    auth_type = auth_type:basic_auth,
    provider = provider:acuity_scheduling,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "userId",
                display_name: "User ID",
                type: "string",
                is_secret: false,
                required: true,
                description: "Acuity Scheduling user ID"
            },
            {
                name: "apiKey",
                display_name: "API Key",
                type: "string",
                is_secret: true,
                required: true,
                description: "Acuity Scheduling API key"
            }
        ],
        metadata: {
            squarespace_product: true,
            client_appointments: true
        }
    },
    
    documentation = {
        url: url:acuity_scheduling_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 11. ACUITY SCHEDULING OAUTH2 API (display_order: 933)
-- =====================================================

CREATE credential_type:acuity_scheduling_oauth2_api SET
    name = "acuitySchedulingOAuth2Api",
    slug = "acuity-scheduling-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_acuity_scheduling_oauth2_api_name,
        description_i18n: i18n_key:credential_type_acuity_scheduling_oauth2_api_description
    },
    
    presentation = {
        icon: icon:acuity_scheduling,
        color_type: theme_color_type:primary,
        tooltip_i18n: i18n_key:credential_type_acuity_scheduling_oauth2_api_tooltip,
        display_order: 933
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:acuity_scheduling,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://acuityscheduling.com/oauth2/token",
            authorization_url: "https://acuityscheduling.com/oauth2/authorize",
            authentication_method: "body",
            scope: ""
        },
        oauth1: NONE,
        required_fields: [],
        metadata: {}
    },
    
    documentation = {
        url: url:acuity_scheduling_oauth2_docs,
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
WHERE presentation.display_order >= 920 AND presentation.display_order < 940
ORDER BY presentation.display_order ASC;
*/

-- =====================================================
-- RÉSUMÉ BATCH 12
-- =====================================================
--
-- ✅ 11 credentials Forms, Surveys & Scheduling créés :
--
-- Forms (7) - display_order: 920-926 ✨ TRÈS POPULAIRE
--  1. typeform_api (920) ✨ TRÈS POPULAIRE - Interactive forms
--  2. typeform_oauth2_api (921)
--  3. surveymonkey_api (922) ✨ TRÈS POPULAIRE - Survey leader
--  4. surveymonkey_oauth2_api (923)
--  5. jotform_api (924) ✨ POPULAIRE - Drag-and-drop builder
--  6. formstack_api (925) - Workplace productivity
--  7. formstack_oauth2_api (926)
--
-- Scheduling (4) - display_order: 930-933 ✨ TRÈS POPULAIRE
--  8. calendly_api (930) ✨ TRÈS POPULAIRE - Automated scheduling
--  9. calendly_oauth2_api (931)
-- 10. acuity_scheduling_api (932) - Squarespace product
-- 11. acuity_scheduling_oauth2_api (933)
--
-- Structure complète : identity, presentation, config, documentation
--
-- =============================================================================================

