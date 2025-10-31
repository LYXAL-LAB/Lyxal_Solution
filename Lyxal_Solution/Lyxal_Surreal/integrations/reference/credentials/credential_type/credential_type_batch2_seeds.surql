-- =============================================================================================
-- |
-- | Fichier : credential_type_batch2_seeds.surql (SEED DATA)
-- | Module : integrations > reference > credentials > credential_type
-- | Description : Seeds pour le Batch 2 des credential types (22 credentials Google).
-- |
-- | Batch 2 : Google Ecosystem (22 credentials)
-- | Provider : Google (provider:google)
-- |
-- | Note : Tous héritent de la base OAuth2 Google avec des scopes spécifiques par service.
-- |
-- =============================================================================================

-- =====================================================
-- 1. GOOGLE SHEETS OAUTH2 API (display_order: 100) ✨ TRÈS POPULAIRE
-- =====================================================

CREATE credential_type:google_sheets_oauth2_api SET
    name = "googleSheetsOAuth2Api",
    slug = "google-sheets-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_google_sheets_oauth2_api_name,
        description_i18n: i18n_key:credential_type_google_sheets_oauth2_api_description
    },
    
    presentation = {
        icon: icon:google_sheets,
        color: "#34A853",
        color_daisy: "success",
        tooltip_i18n: i18n_key:credential_type_google_sheets_oauth2_api_tooltip,
        display_order: 100
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:google,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://oauth2.googleapis.com/token",
            authorization_url: "https://accounts.google.com/o/oauth2/v2/auth",
            authentication_method: "body",
            scope: "https://www.googleapis.com/auth/drive.file https://www.googleapis.com/auth/spreadsheets https://www.googleapis.com/auth/drive.metadata"
        },
        oauth1: NONE,
        required_fields: [],
        metadata: {
            extends: "googleOAuth2Api",
            apis_required: ["Google Drive API", "Google Sheets API"]
        }
    },
    
    documentation = {
        url: url:google_sheets_api_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 2. GOOGLE DRIVE OAUTH2 API (display_order: 101) ✨ TRÈS POPULAIRE
-- =====================================================

CREATE credential_type:google_drive_oauth2_api SET
    name = "googleDriveOAuth2Api",
    slug = "google-drive-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_google_drive_oauth2_api_name,
        description_i18n: i18n_key:credential_type_google_drive_oauth2_api_description
    },
    
    presentation = {
        icon: icon:google_drive,
        color: "#4285F4",
        color_daisy: "info",
        tooltip_i18n: i18n_key:credential_type_google_drive_oauth2_api_tooltip,
        display_order: 101
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:google,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://oauth2.googleapis.com/token",
            authorization_url: "https://accounts.google.com/o/oauth2/v2/auth",
            authentication_method: "body",
            scope: "https://www.googleapis.com/auth/drive.file https://www.googleapis.com/auth/drive.metadata"
        },
        oauth1: NONE,
        required_fields: [],
        metadata: {
            extends: "googleOAuth2Api",
            apis_required: ["Google Drive API"]
        }
    },
    
    documentation = {
        url: url:google_drive_api_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 3. GOOGLE CALENDAR OAUTH2 API (display_order: 102) ✨ TRÈS POPULAIRE
-- =====================================================

CREATE credential_type:google_calendar_oauth2_api SET
    name = "googleCalendarOAuth2Api",
    slug = "google-calendar-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_google_calendar_oauth2_api_name,
        description_i18n: i18n_key:credential_type_google_calendar_oauth2_api_description
    },
    
    presentation = {
        icon: icon:google_calendar,
        color: "#EA4335",
        color_daisy: "error",
        tooltip_i18n: i18n_key:credential_type_google_calendar_oauth2_api_tooltip,
        display_order: 102
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:google,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://oauth2.googleapis.com/token",
            authorization_url: "https://accounts.google.com/o/oauth2/v2/auth",
            authentication_method: "body",
            scope: "https://www.googleapis.com/auth/calendar https://www.googleapis.com/auth/calendar.events"
        },
        oauth1: NONE,
        required_fields: [],
        metadata: {
            extends: "googleOAuth2Api",
            apis_required: ["Google Calendar API"]
        }
    },
    
    documentation = {
        url: url:google_calendar_api_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 4. GOOGLE DOCS OAUTH2 API (display_order: 103)
-- =====================================================

CREATE credential_type:google_docs_oauth2_api SET
    name = "googleDocsOAuth2Api",
    slug = "google-docs-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_google_docs_oauth2_api_name,
        description_i18n: i18n_key:credential_type_google_docs_oauth2_api_description
    },
    
    presentation = {
        icon: icon:google_docs,
        color: "#4285F4",
        color_daisy: "info",
        tooltip_i18n: i18n_key:credential_type_google_docs_oauth2_api_tooltip,
        display_order: 103
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:google,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://oauth2.googleapis.com/token",
            authorization_url: "https://accounts.google.com/o/oauth2/v2/auth",
            authentication_method: "body",
            scope: "https://www.googleapis.com/auth/documents https://www.googleapis.com/auth/drive.file"
        },
        oauth1: NONE,
        required_fields: [],
        metadata: {
            extends: "googleOAuth2Api",
            apis_required: ["Google Docs API", "Google Drive API"]
        }
    },
    
    documentation = {
        url: url:google_docs_api_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 5. GOOGLE SLIDES OAUTH2 API (display_order: 104)
-- =====================================================

CREATE credential_type:google_slides_oauth2_api SET
    name = "googleSlidesOAuth2Api",
    slug = "google-slides-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_google_slides_oauth2_api_name,
        description_i18n: i18n_key:credential_type_google_slides_oauth2_api_description
    },
    
    presentation = {
        icon: icon:google_slides,
        color: "#F4B400",
        color_daisy: "warning",
        tooltip_i18n: i18n_key:credential_type_google_slides_oauth2_api_tooltip,
        display_order: 104
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:google,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://oauth2.googleapis.com/token",
            authorization_url: "https://accounts.google.com/o/oauth2/v2/auth",
            authentication_method: "body",
            scope: "https://www.googleapis.com/auth/presentations https://www.googleapis.com/auth/drive.file"
        },
        oauth1: NONE,
        required_fields: [],
        metadata: {
            extends: "googleOAuth2Api",
            apis_required: ["Google Slides API", "Google Drive API"]
        }
    },
    
    documentation = {
        url: url:google_slides_api_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 6. GOOGLE CONTACTS OAUTH2 API (display_order: 105)
-- =====================================================

CREATE credential_type:google_contacts_oauth2_api SET
    name = "googleContactsOAuth2Api",
    slug = "google-contacts-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_google_contacts_oauth2_api_name,
        description_i18n: i18n_key:credential_type_google_contacts_oauth2_api_description
    },
    
    presentation = {
        icon: icon:google_contacts,
        color: "#34A853",
        color_daisy: "success",
        tooltip_i18n: i18n_key:credential_type_google_contacts_oauth2_api_tooltip,
        display_order: 105
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:google,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://oauth2.googleapis.com/token",
            authorization_url: "https://accounts.google.com/o/oauth2/v2/auth",
            authentication_method: "body",
            scope: "https://www.googleapis.com/auth/contacts https://www.googleapis.com/auth/contacts.readonly"
        },
        oauth1: NONE,
        required_fields: [],
        metadata: {
            extends: "googleOAuth2Api",
            apis_required: ["People API"]
        }
    },
    
    documentation = {
        url: url:google_contacts_api_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 7. GOOGLE TASKS OAUTH2 API (display_order: 106)
-- =====================================================

CREATE credential_type:google_tasks_oauth2_api SET
    name = "googleTasksOAuth2Api",
    slug = "google-tasks-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_google_tasks_oauth2_api_name,
        description_i18n: i18n_key:credential_type_google_tasks_oauth2_api_description
    },
    
    presentation = {
        icon: icon:google_tasks,
        color: "#4285F4",
        color_daisy: "info",
        tooltip_i18n: i18n_key:credential_type_google_tasks_oauth2_api_tooltip,
        display_order: 106
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:google,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://oauth2.googleapis.com/token",
            authorization_url: "https://accounts.google.com/o/oauth2/v2/auth",
            authentication_method: "body",
            scope: "https://www.googleapis.com/auth/tasks"
        },
        oauth1: NONE,
        required_fields: [],
        metadata: {
            extends: "googleOAuth2Api",
            apis_required: ["Google Tasks API"]
        }
    },
    
    documentation = {
        url: url:google_tasks_api_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 8. GOOGLE OAUTH2 API (GÉNÉRIQUE) (display_order: 107)
-- =====================================================

CREATE credential_type:google_oauth2_api SET
    name = "googleOAuth2Api",
    slug = "google-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_google_oauth2_api_name,
        description_i18n: i18n_key:credential_type_google_oauth2_api_description
    },
    
    presentation = {
        icon: icon:google,
        color: "#4285F4",
        color_daisy: "primary",
        tooltip_i18n: i18n_key:credential_type_google_oauth2_api_tooltip,
        display_order: 107
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:google,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://oauth2.googleapis.com/token",
            authorization_url: "https://accounts.google.com/o/oauth2/v2/auth",
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
                description: "OAuth 2.0 Client ID from Google Cloud Console"
            },
            {
                name: "clientSecret",
                display_name: "Client Secret",
                type: "string",
                is_secret: true,
                required: true,
                description: "OAuth 2.0 Client Secret from Google Cloud Console"
            },
            {
                name: "scope",
                display_name: "Scope",
                type: "string",
                is_secret: false,
                required: false,
                description: "Space-separated OAuth scopes"
            }
        ],
        metadata: {
            is_base_credential: true,
            inherited_by: ["googleSheetsOAuth2Api", "googleDriveOAuth2Api", "googleCalendarOAuth2Api"]
        }
    },
    
    documentation = {
        url: url:google_oauth2_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 9. GOOGLE API (SERVICE ACCOUNT) (display_order: 108)
-- =====================================================

CREATE credential_type:google_api SET
    name = "googleApi",
    slug = "google-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_google_api_name,
        description_i18n: i18n_key:credential_type_google_api_description
    },
    
    presentation = {
        icon: icon:google_cloud,
        color: "#4285F4",
        color_daisy: "info",
        tooltip_i18n: i18n_key:credential_type_google_api_tooltip,
        display_order: 108
    },
    
    auth_type = auth_type:api_key,
    provider = provider:google,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "email",
                display_name: "Service Account Email",
                type: "string",
                is_secret: false,
                required: true,
                description: "Service account email from Google Cloud Console",
                placeholder: "your-service-account@project-id.iam.gserviceaccount.com"
            },
            {
                name: "privateKey",
                display_name: "Private Key (JSON)",
                type: "string",
                is_secret: true,
                required: true,
                description: "Full JSON key file content from Google Cloud Console"
            }
        ],
        metadata: {
            auth_method: "service_account",
            no_user_interaction: true
        }
    },
    
    documentation = {
        url: url:google_service_account_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 10. GOOGLE ANALYTICS OAUTH2 API (display_order: 110)
-- =====================================================

CREATE credential_type:google_analytics_oauth2_api SET
    name = "googleAnalyticsOAuth2Api",
    slug = "google-analytics-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_google_analytics_oauth2_api_name,
        description_i18n: i18n_key:credential_type_google_analytics_oauth2_api_description
    },
    
    presentation = {
        icon: icon:google_analytics,
        color: "#F4B400",
        color_daisy: "warning",
        tooltip_i18n: i18n_key:credential_type_google_analytics_oauth2_api_tooltip,
        display_order: 110
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:google,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://oauth2.googleapis.com/token",
            authorization_url: "https://accounts.google.com/o/oauth2/v2/auth",
            authentication_method: "body",
            scope: "https://www.googleapis.com/auth/analytics https://www.googleapis.com/auth/analytics.readonly"
        },
        oauth1: NONE,
        required_fields: [],
        metadata: {
            extends: "googleOAuth2Api",
            apis_required: ["Google Analytics API"]
        }
    },
    
    documentation = {
        url: url:google_analytics_api_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 11. GOOGLE ADS OAUTH2 API (display_order: 111)
-- =====================================================

CREATE credential_type:google_ads_oauth2_api SET
    name = "googleAdsOAuth2Api",
    slug = "google-ads-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_google_ads_oauth2_api_name,
        description_i18n: i18n_key:credential_type_google_ads_oauth2_api_description
    },
    
    presentation = {
        icon: icon:google_ads,
        color: "#34A853",
        color_daisy: "success",
        tooltip_i18n: i18n_key:credential_type_google_ads_oauth2_api_tooltip,
        display_order: 111
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:google,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://oauth2.googleapis.com/token",
            authorization_url: "https://accounts.google.com/o/oauth2/v2/auth",
            authentication_method: "body",
            scope: "https://www.googleapis.com/auth/adwords"
        },
        oauth1: NONE,
        required_fields: [],
        metadata: {
            extends: "googleOAuth2Api",
            apis_required: ["Google Ads API"]
        }
    },
    
    documentation = {
        url: url:google_ads_api_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 12. GOOGLE CHAT OAUTH2 API (display_order: 112)
-- =====================================================

CREATE credential_type:google_chat_oauth2_api SET
    name = "googleChatOAuth2Api",
    slug = "google-chat-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_google_chat_oauth2_api_name,
        description_i18n: i18n_key:credential_type_google_chat_oauth2_api_description
    },
    
    presentation = {
        icon: icon:google_chat,
        color: "#34A853",
        color_daisy: "success",
        tooltip_i18n: i18n_key:credential_type_google_chat_oauth2_api_tooltip,
        display_order: 112
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:google,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://oauth2.googleapis.com/token",
            authorization_url: "https://accounts.google.com/o/oauth2/v2/auth",
            authentication_method: "body",
            scope: "https://www.googleapis.com/auth/chat.spaces https://www.googleapis.com/auth/chat.messages"
        },
        oauth1: NONE,
        required_fields: [],
        metadata: {
            extends: "googleOAuth2Api",
            apis_required: ["Google Chat API"],
            workspace_only: true
        }
    },
    
    documentation = {
        url: url:google_chat_api_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 13. GOOGLE TRANSLATE OAUTH2 API (display_order: 113)
-- =====================================================

CREATE credential_type:google_translate_oauth2_api SET
    name = "googleTranslateOAuth2Api",
    slug = "google-translate-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_google_translate_oauth2_api_name,
        description_i18n: i18n_key:credential_type_google_translate_oauth2_api_description
    },
    
    presentation = {
        icon: icon:google_translate,
        color: "#4285F4",
        color_daisy: "info",
        tooltip_i18n: i18n_key:credential_type_google_translate_oauth2_api_tooltip,
        display_order: 113
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:google,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://oauth2.googleapis.com/token",
            authorization_url: "https://accounts.google.com/o/oauth2/v2/auth",
            authentication_method: "body",
            scope: "https://www.googleapis.com/auth/cloud-translation"
        },
        oauth1: NONE,
        required_fields: [],
        metadata: {
            extends: "googleOAuth2Api",
            apis_required: ["Cloud Translation API"]
        }
    },
    
    documentation = {
        url: url:google_translate_api_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 14. GOOGLE BUSINESS PROFILE OAUTH2 API (display_order: 114)
-- =====================================================

CREATE credential_type:google_business_profile_oauth2_api SET
    name = "googleBusinessProfileOAuth2Api",
    slug = "google-business-profile-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_google_business_profile_oauth2_api_name,
        description_i18n: i18n_key:credential_type_google_business_profile_oauth2_api_description
    },
    
    presentation = {
        icon: icon:google_business,
        color: "#EA4335",
        color_daisy: "error",
        tooltip_i18n: i18n_key:credential_type_google_business_profile_oauth2_api_tooltip,
        display_order: 114
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:google,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://oauth2.googleapis.com/token",
            authorization_url: "https://accounts.google.com/o/oauth2/v2/auth",
            authentication_method: "body",
            scope: "https://www.googleapis.com/auth/business.manage"
        },
        oauth1: NONE,
        required_fields: [],
        metadata: {
            extends: "googleOAuth2Api",
            apis_required: ["Business Profile API"],
            formerly: "Google My Business"
        }
    },
    
    documentation = {
        url: url:google_business_profile_api_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 15. GOOGLE SHEETS TRIGGER OAUTH2 API (display_order: 115)
-- =====================================================

CREATE credential_type:google_sheets_trigger_oauth2_api SET
    name = "googleSheetsTriggerOAuth2Api",
    slug = "google-sheets-trigger-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_google_sheets_trigger_oauth2_api_name,
        description_i18n: i18n_key:credential_type_google_sheets_trigger_oauth2_api_description
    },
    
    presentation = {
        icon: icon:google_sheets,
        color: "#34A853",
        color_daisy: "success",
        tooltip_i18n: i18n_key:credential_type_google_sheets_trigger_oauth2_api_tooltip,
        display_order: 115
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:google,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://oauth2.googleapis.com/token",
            authorization_url: "https://accounts.google.com/o/oauth2/v2/auth",
            authentication_method: "body",
            scope: "https://www.googleapis.com/auth/drive.file https://www.googleapis.com/auth/spreadsheets https://www.googleapis.com/auth/drive.metadata https://www.googleapis.com/auth/script.projects"
        },
        oauth1: NONE,
        required_fields: [],
        metadata: {
            extends: "googleOAuth2Api",
            apis_required: ["Google Drive API", "Google Sheets API", "Apps Script API"],
            supports_webhooks: true
        }
    },
    
    documentation = {
        url: url:google_sheets_trigger_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 16. GOOGLE BIGQUERY OAUTH2 API (display_order: 120)
-- =====================================================

CREATE credential_type:google_bigquery_oauth2_api SET
    name = "googleBigQueryOAuth2Api",
    slug = "google-bigquery-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_google_bigquery_oauth2_api_name,
        description_i18n: i18n_key:credential_type_google_bigquery_oauth2_api_description
    },
    
    presentation = {
        icon: icon:google_bigquery,
        color: "#4285F4",
        color_daisy: "info",
        tooltip_i18n: i18n_key:credential_type_google_bigquery_oauth2_api_tooltip,
        display_order: 120
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:google,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://oauth2.googleapis.com/token",
            authorization_url: "https://accounts.google.com/o/oauth2/v2/auth",
            authentication_method: "body",
            scope: "https://www.googleapis.com/auth/bigquery"
        },
        oauth1: NONE,
        required_fields: [],
        metadata: {
            extends: "googleOAuth2Api",
            apis_required: ["BigQuery API"],
            category: "data_warehouse"
        }
    },
    
    documentation = {
        url: url:google_bigquery_api_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 17. GOOGLE CLOUD STORAGE OAUTH2 API (display_order: 121)
-- =====================================================

CREATE credential_type:google_cloud_storage_oauth2_api SET
    name = "googleCloudStorageOAuth2Api",
    slug = "google-cloud-storage-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_google_cloud_storage_oauth2_api_name,
        description_i18n: i18n_key:credential_type_google_cloud_storage_oauth2_api_description
    },
    
    presentation = {
        icon: icon:google_cloud_storage,
        color: "#34A853",
        color_daisy: "success",
        tooltip_i18n: i18n_key:credential_type_google_cloud_storage_oauth2_api_tooltip,
        display_order: 121
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:google,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://oauth2.googleapis.com/token",
            authorization_url: "https://accounts.google.com/o/oauth2/v2/auth",
            authentication_method: "body",
            scope: "https://www.googleapis.com/auth/devstorage.full_control"
        },
        oauth1: NONE,
        required_fields: [],
        metadata: {
            extends: "googleOAuth2Api",
            apis_required: ["Cloud Storage API"],
            category: "cloud_storage"
        }
    },
    
    documentation = {
        url: url:google_cloud_storage_api_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 18. GOOGLE CLOUD NATURAL LANGUAGE OAUTH2 API (display_order: 122)
-- =====================================================

CREATE credential_type:google_cloud_natural_language_oauth2_api SET
    name = "googleCloudNaturalLanguageOAuth2Api",
    slug = "google-cloud-natural-language-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_google_cloud_natural_language_oauth2_api_name,
        description_i18n: i18n_key:credential_type_google_cloud_natural_language_oauth2_api_description
    },
    
    presentation = {
        icon: icon:google_cloud,
        color: "#4285F4",
        color_daisy: "info",
        tooltip_i18n: i18n_key:credential_type_google_cloud_natural_language_oauth2_api_tooltip,
        display_order: 122
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:google,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://oauth2.googleapis.com/token",
            authorization_url: "https://accounts.google.com/o/oauth2/v2/auth",
            authentication_method: "body",
            scope: "https://www.googleapis.com/auth/cloud-platform"
        },
        oauth1: NONE,
        required_fields: [],
        metadata: {
            extends: "googleOAuth2Api",
            apis_required: ["Cloud Natural Language API"],
            category: "ai_ml"
        }
    },
    
    documentation = {
        url: url:google_cloud_nlp_api_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 19. GOOGLE PERSPECTIVE OAUTH2 API (display_order: 123)
-- =====================================================

CREATE credential_type:google_perspective_oauth2_api SET
    name = "googlePerspectiveOAuth2Api",
    slug = "google-perspective-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_google_perspective_oauth2_api_name,
        description_i18n: i18n_key:credential_type_google_perspective_oauth2_api_description
    },
    
    presentation = {
        icon: icon:google_perspective,
        color: "#EA4335",
        color_daisy: "error",
        tooltip_i18n: i18n_key:credential_type_google_perspective_oauth2_api_tooltip,
        display_order: 123
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:google,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://oauth2.googleapis.com/token",
            authorization_url: "https://accounts.google.com/o/oauth2/v2/auth",
            authentication_method: "body",
            scope: "https://www.googleapis.com/auth/userinfo.email"
        },
        oauth1: NONE,
        required_fields: [],
        metadata: {
            extends: "googleOAuth2Api",
            apis_required: ["Perspective Comment Analyzer API"],
            category: "ai_ml"
        }
    },
    
    documentation = {
        url: url:google_perspective_api_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 20. GOOGLE FIREBASE CLOUD FIRESTORE OAUTH2 API (display_order: 130)
-- =====================================================

CREATE credential_type:google_firebase_cloud_firestore_oauth2_api SET
    name = "googleFirebaseCloudFirestoreOAuth2Api",
    slug = "google-firebase-cloud-firestore-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_google_firebase_cloud_firestore_oauth2_api_name,
        description_i18n: i18n_key:credential_type_google_firebase_cloud_firestore_oauth2_api_description
    },
    
    presentation = {
        icon: icon:firebase,
        color: "#F4B400",
        color_daisy: "warning",
        tooltip_i18n: i18n_key:credential_type_google_firebase_cloud_firestore_oauth2_api_tooltip,
        display_order: 130
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:google,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://oauth2.googleapis.com/token",
            authorization_url: "https://accounts.google.com/o/oauth2/v2/auth",
            authentication_method: "body",
            scope: "https://www.googleapis.com/auth/cloud-platform https://www.googleapis.com/auth/datastore"
        },
        oauth1: NONE,
        required_fields: [],
        metadata: {
            extends: "googleOAuth2Api",
            apis_required: ["Cloud Firestore API"],
            category: "database"
        }
    },
    
    documentation = {
        url: url:firebase_firestore_api_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 21. GOOGLE FIREBASE REALTIME DATABASE OAUTH2 API (display_order: 131)
-- =====================================================

CREATE credential_type:google_firebase_realtime_database_oauth2_api SET
    name = "googleFirebaseRealtimeDatabaseOAuth2Api",
    slug = "google-firebase-realtime-database-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_google_firebase_realtime_database_oauth2_api_name,
        description_i18n: i18n_key:credential_type_google_firebase_realtime_database_oauth2_api_description
    },
    
    presentation = {
        icon: icon:firebase,
        color: "#F4B400",
        color_daisy: "warning",
        tooltip_i18n: i18n_key:credential_type_google_firebase_realtime_database_oauth2_api_tooltip,
        display_order: 131
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:google,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://oauth2.googleapis.com/token",
            authorization_url: "https://accounts.google.com/o/oauth2/v2/auth",
            authentication_method: "body",
            scope: "https://www.googleapis.com/auth/firebase.database https://www.googleapis.com/auth/userinfo.email"
        },
        oauth1: NONE,
        required_fields: [],
        metadata: {
            extends: "googleOAuth2Api",
            apis_required: ["Firebase Realtime Database API"],
            category: "database"
        }
    },
    
    documentation = {
        url: url:firebase_realtime_db_api_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 22. GOOGLE BOOKS OAUTH2 API (display_order: 140)
-- =====================================================

CREATE credential_type:google_books_oauth2_api SET
    name = "googleBooksOAuth2Api",
    slug = "google-books-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_google_books_oauth2_api_name,
        description_i18n: i18n_key:credential_type_google_books_oauth2_api_description
    },
    
    presentation = {
        icon: icon:google_books,
        color: "#4285F4",
        color_daisy: "info",
        tooltip_i18n: i18n_key:credential_type_google_books_oauth2_api_tooltip,
        display_order: 140
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:google,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://oauth2.googleapis.com/token",
            authorization_url: "https://accounts.google.com/o/oauth2/v2/auth",
            authentication_method: "body",
            scope: "https://www.googleapis.com/auth/books"
        },
        oauth1: NONE,
        required_fields: [],
        metadata: {
            extends: "googleOAuth2Api",
            apis_required: ["Books API"],
            category: "content"
        }
    },
    
    documentation = {
        url: url:google_books_api_docs,
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
WHERE provider = provider:google
ORDER BY presentation.display_order ASC;
*/

-- =====================================================
-- RÉSUMÉ BATCH 2
-- =====================================================
--
-- ✅ 22 credentials Google créés :
--
-- Google Workspace (7) - display_order: 100-106
--  1. google_sheets_oauth2_api (100) ✨ TRÈS POPULAIRE
--  2. google_drive_oauth2_api (101) ✨ TRÈS POPULAIRE
--  3. google_calendar_oauth2_api (102) ✨ TRÈS POPULAIRE
--  4. google_docs_oauth2_api (103)
--  5. google_slides_oauth2_api (104)
--  6. google_contacts_oauth2_api (105)
--  7. google_tasks_oauth2_api (106)
--
-- Google Generic (2) - display_order: 107-108
--  8. google_oauth2_api (107) - Base pour tous les autres
--  9. google_api (108) - Service Account
--
-- Google Marketing & Analytics (3) - display_order: 110-112
-- 10. google_analytics_oauth2_api (110)
-- 11. google_ads_oauth2_api (111)
-- 12. google_chat_oauth2_api (112)
--
-- Google Services (4) - display_order: 113-115
-- 13. google_translate_oauth2_api (113)
-- 14. google_business_profile_oauth2_api (114)
-- 15. google_sheets_trigger_oauth2_api (115)
--
-- Google Cloud (4) - display_order: 120-123
-- 16. google_bigquery_oauth2_api (120)
-- 17. google_cloud_storage_oauth2_api (121)
-- 18. google_cloud_natural_language_oauth2_api (122)
-- 19. google_perspective_oauth2_api (123)
--
-- Firebase (2) - display_order: 130-131
-- 20. google_firebase_cloud_firestore_oauth2_api (130)
-- 21. google_firebase_realtime_database_oauth2_api (131)
--
-- Google Content (1) - display_order: 140
-- 22. google_books_oauth2_api (140)
--
-- Tous avec provider = provider:google
-- Structure complète : identity, presentation, config, documentation
--
-- =============================================================================================

