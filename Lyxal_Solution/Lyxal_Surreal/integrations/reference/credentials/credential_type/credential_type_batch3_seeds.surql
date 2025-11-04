-- =============================================================================================
-- |
-- | Fichier : credential_type_batch3_seeds.surql (SEED DATA)
-- | Module : integrations > reference > credentials > credential_type
-- | Description : Seeds pour le Batch 3 des credential types (13 credentials Microsoft).
-- |
-- | Batch 3 : Microsoft Ecosystem (13 credentials)
-- | Provider : Microsoft (provider:microsoft)
-- |
-- | Note : La plupart héritent de la base OAuth2 Microsoft avec Microsoft Graph API.
-- |
-- =============================================================================================

-- =====================================================
-- 1. MICROSOFT EXCEL OAUTH2 API (display_order: 200) ✨ TRÈS POPULAIRE
-- =====================================================

CREATE credential_type:microsoft_excel_oauth2_api SET
    name = "microsoftExcelOAuth2Api",
    slug = "microsoft-excel-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_microsoft_excel_oauth2_api_name,
        description_i18n: i18n_key:credential_type_microsoft_excel_oauth2_api_description
    },
    
    presentation = {
        icon: icon:microsoft_excel,
        color_type: theme_color_type:success,
        tooltip_i18n: i18n_key:credential_type_microsoft_excel_oauth2_api_tooltip,
        display_order: 200
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:microsoft,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://login.microsoftonline.com/common/oauth2/v2.0/token",
            authorization_url: "https://login.microsoftonline.com/common/oauth2/v2.0/authorize",
            authentication_method: "body",
            scope: "Files.ReadWrite offline_access"
        },
        oauth1: NONE,
        required_fields: [],
        metadata: {
            extends: "microsoftOAuth2Api",
            graph_api: true,
            apis_required: ["Microsoft Graph API"]
        }
    },
    
    documentation = {
        url: url:microsoft_excel_api_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 2. MICROSOFT TEAMS OAUTH2 API (display_order: 201) ✨ TRÈS POPULAIRE
-- =====================================================

CREATE credential_type:microsoft_teams_oauth2_api SET
    name = "microsoftTeamsOAuth2Api",
    slug = "microsoft-teams-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_microsoft_teams_oauth2_api_name,
        description_i18n: i18n_key:credential_type_microsoft_teams_oauth2_api_description
    },
    
    presentation = {
        icon: icon:microsoft_teams,
        color_type: theme_color_type:primary,
        tooltip_i18n: i18n_key:credential_type_microsoft_teams_oauth2_api_tooltip,
        display_order: 201
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:microsoft,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://login.microsoftonline.com/common/oauth2/v2.0/token",
            authorization_url: "https://login.microsoftonline.com/common/oauth2/v2.0/authorize",
            authentication_method: "body",
            scope: "Channel.ReadBasic.All ChannelMessage.Send Group.ReadWrite.All offline_access"
        },
        oauth1: NONE,
        required_fields: [],
        metadata: {
            extends: "microsoftOAuth2Api",
            graph_api: true,
            apis_required: ["Microsoft Graph API"]
        }
    },
    
    documentation = {
        url: url:microsoft_teams_api_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 3. MICROSOFT OUTLOOK OAUTH2 API (display_order: 202) ✨ TRÈS POPULAIRE
-- =====================================================

CREATE credential_type:microsoft_outlook_oauth2_api SET
    name = "microsoftOutlookOAuth2Api",
    slug = "microsoft-outlook-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_microsoft_outlook_oauth2_api_name,
        description_i18n: i18n_key:credential_type_microsoft_outlook_oauth2_api_description
    },
    
    presentation = {
        icon: icon:microsoft_outlook,
        color_type: theme_color_type:info,
        tooltip_i18n: i18n_key:credential_type_microsoft_outlook_oauth2_api_tooltip,
        display_order: 202
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:microsoft,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://login.microsoftonline.com/common/oauth2/v2.0/token",
            authorization_url: "https://login.microsoftonline.com/common/oauth2/v2.0/authorize",
            authentication_method: "body",
            scope: "Mail.ReadWrite Mail.Send Calendars.ReadWrite Contacts.ReadWrite offline_access"
        },
        oauth1: NONE,
        required_fields: [],
        metadata: {
            extends: "microsoftOAuth2Api",
            graph_api: true,
            apis_required: ["Microsoft Graph API"]
        }
    },
    
    documentation = {
        url: url:microsoft_outlook_api_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 4. MICROSOFT ONEDRIVE OAUTH2 API (display_order: 203) ✨ TRÈS POPULAIRE
-- =====================================================

CREATE credential_type:microsoft_onedrive_oauth2_api SET
    name = "microsoftOneDriveOAuth2Api",
    slug = "microsoft-onedrive-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_microsoft_onedrive_oauth2_api_name,
        description_i18n: i18n_key:credential_type_microsoft_onedrive_oauth2_api_description
    },
    
    presentation = {
        icon: icon:microsoft_onedrive,
        color_type: theme_color_type:info,
        tooltip_i18n: i18n_key:credential_type_microsoft_onedrive_oauth2_api_tooltip,
        display_order: 203
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:microsoft,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://login.microsoftonline.com/common/oauth2/v2.0/token",
            authorization_url: "https://login.microsoftonline.com/common/oauth2/v2.0/authorize",
            authentication_method: "body",
            scope: "Files.ReadWrite.All offline_access"
        },
        oauth1: NONE,
        required_fields: [],
        metadata: {
            extends: "microsoftOAuth2Api",
            graph_api: true,
            apis_required: ["Microsoft Graph API"]
        }
    },
    
    documentation = {
        url: url:microsoft_onedrive_api_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 5. MICROSOFT SHAREPOINT OAUTH2 API (display_order: 204)
-- =====================================================

CREATE credential_type:microsoft_sharepoint_oauth2_api SET
    name = "microsoftSharePointOAuth2Api",
    slug = "microsoft-sharepoint-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_microsoft_sharepoint_oauth2_api_name,
        description_i18n: i18n_key:credential_type_microsoft_sharepoint_oauth2_api_description
    },
    
    presentation = {
        icon: icon:microsoft_sharepoint,
        color_type: theme_color_type:info,
        tooltip_i18n: i18n_key:credential_type_microsoft_sharepoint_oauth2_api_tooltip,
        display_order: 204
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:microsoft,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://login.microsoftonline.com/common/oauth2/v2.0/token",
            authorization_url: "https://login.microsoftonline.com/common/oauth2/v2.0/authorize",
            authentication_method: "body",
            scope: "Sites.ReadWrite.All offline_access"
        },
        oauth1: NONE,
        required_fields: [],
        metadata: {
            extends: "microsoftOAuth2Api",
            graph_api: true,
            apis_required: ["Microsoft Graph API"]
        }
    },
    
    documentation = {
        url: url:microsoft_sharepoint_api_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 6. MICROSOFT TODO OAUTH2 API (display_order: 205)
-- =====================================================

CREATE credential_type:microsoft_todo_oauth2_api SET
    name = "microsoftToDoOAuth2Api",
    slug = "microsoft-todo-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_microsoft_todo_oauth2_api_name,
        description_i18n: i18n_key:credential_type_microsoft_todo_oauth2_api_description
    },
    
    presentation = {
        icon: icon:microsoft_todo,
        color_type: theme_color_type:primary,
        tooltip_i18n: i18n_key:credential_type_microsoft_todo_oauth2_api_tooltip,
        display_order: 205
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:microsoft,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://login.microsoftonline.com/common/oauth2/v2.0/token",
            authorization_url: "https://login.microsoftonline.com/common/oauth2/v2.0/authorize",
            authentication_method: "body",
            scope: "Tasks.ReadWrite offline_access"
        },
        oauth1: NONE,
        required_fields: [],
        metadata: {
            extends: "microsoftOAuth2Api",
            graph_api: true,
            apis_required: ["Microsoft Graph API"]
        }
    },
    
    documentation = {
        url: url:microsoft_todo_api_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 7. MICROSOFT OAUTH2 API (GÉNÉRIQUE) (display_order: 206)
-- =====================================================

CREATE credential_type:microsoft_oauth2_api SET
    name = "microsoftOAuth2Api",
    slug = "microsoft-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_microsoft_oauth2_api_name,
        description_i18n: i18n_key:credential_type_microsoft_oauth2_api_description
    },
    
    presentation = {
        icon: icon:microsoft,
        color_type: theme_color_type:primary,
        tooltip_i18n: i18n_key:credential_type_microsoft_oauth2_api_tooltip,
        display_order: 206
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:microsoft,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://login.microsoftonline.com/common/oauth2/v2.0/token",
            authorization_url: "https://login.microsoftonline.com/common/oauth2/v2.0/authorize",
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
                description: "Application (client) ID from Azure App Registration"
            },
            {
                name: "clientSecret",
                display_name: "Client Secret",
                type: "string",
                is_secret: true,
                required: true,
                description: "Client secret from Azure App Registration"
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
            graph_api: true,
            inherited_by: ["microsoftExcelOAuth2Api", "microsoftTeamsOAuth2Api", "microsoftOutlookOAuth2Api"]
        }
    },
    
    documentation = {
        url: url:microsoft_graph_api_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 8. MICROSOFT DYNAMICS OAUTH2 API (display_order: 210)
-- =====================================================

CREATE credential_type:microsoft_dynamics_oauth2_api SET
    name = "microsoftDynamicsOAuth2Api",
    slug = "microsoft-dynamics-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_microsoft_dynamics_oauth2_api_name,
        description_i18n: i18n_key:credential_type_microsoft_dynamics_oauth2_api_description
    },
    
    presentation = {
        icon: icon:microsoft_dynamics,
        color: "#002050",
        color_daisy: "accent",
        tooltip_i18n: i18n_key:credential_type_microsoft_dynamics_oauth2_api_tooltip,
        display_order: 210
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:microsoft,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "={{$parameter[\"subdomain\"]}}/oauth2/v2.0/token",
            authorization_url: "={{$parameter[\"subdomain\"]}}/oauth2/v2.0/authorize",
            authentication_method: "body",
            scope: "={{$parameter[\"resource\"]}}/.default offline_access"
        },
        oauth1: NONE,
        required_fields: [
            {
                name: "subdomain",
                display_name: "Subdomain",
                type: "string",
                is_secret: false,
                required: true,
                description: "Dynamics 365 instance URL (e.g., https://contoso.crm.dynamics.com)",
                placeholder: "https://yourorg.crm.dynamics.com"
            },
            {
                name: "resource",
                display_name: "Resource",
                type: "string",
                is_secret: false,
                required: true,
                description: "Dynamics 365 resource URL",
                placeholder: "https://yourorg.crm.dynamics.com"
            }
        ],
        metadata: {
            extends: "microsoftOAuth2Api",
            crm_erp: true
        }
    },
    
    documentation = {
        url: url:microsoft_dynamics_api_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 9. MICROSOFT ENTRA OAUTH2 API (display_order: 211)
-- =====================================================

CREATE credential_type:microsoft_entra_oauth2_api SET
    name = "microsoftEntraOAuth2Api",
    slug = "microsoft-entra-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_microsoft_entra_oauth2_api_name,
        description_i18n: i18n_key:credential_type_microsoft_entra_oauth2_api_description
    },
    
    presentation = {
        icon: icon:microsoft_entra,
        color_type: theme_color_type:info,
        tooltip_i18n: i18n_key:credential_type_microsoft_entra_oauth2_api_tooltip,
        display_order: 211
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:microsoft,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://login.microsoftonline.com/common/oauth2/v2.0/token",
            authorization_url: "https://login.microsoftonline.com/common/oauth2/v2.0/authorize",
            authentication_method: "body",
            scope: "User.Read.All Group.Read.All Directory.Read.All offline_access"
        },
        oauth1: NONE,
        required_fields: [],
        metadata: {
            extends: "microsoftOAuth2Api",
            graph_api: true,
            formerly: "Azure Active Directory",
            apis_required: ["Microsoft Graph API"]
        }
    },
    
    documentation = {
        url: url:microsoft_entra_api_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 10. MICROSOFT GRAPH SECURITY OAUTH2 API (display_order: 212)
-- =====================================================

CREATE credential_type:microsoft_graph_security_oauth2_api SET
    name = "microsoftGraphSecurityOAuth2Api",
    slug = "microsoft-graph-security-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_microsoft_graph_security_oauth2_api_name,
        description_i18n: i18n_key:credential_type_microsoft_graph_security_oauth2_api_description
    },
    
    presentation = {
        icon: icon:microsoft_security,
        color_type: theme_color_type:error,
        tooltip_i18n: i18n_key:credential_type_microsoft_graph_security_oauth2_api_tooltip,
        display_order: 212
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:microsoft,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://login.microsoftonline.com/common/oauth2/v2.0/token",
            authorization_url: "https://login.microsoftonline.com/common/oauth2/v2.0/authorize",
            authentication_method: "body",
            scope: "SecurityEvents.Read.All SecurityEvents.ReadWrite.All offline_access"
        },
        oauth1: NONE,
        required_fields: [],
        metadata: {
            extends: "microsoftOAuth2Api",
            graph_api: true,
            apis_required: ["Microsoft Graph API"],
            category: "security"
        }
    },
    
    documentation = {
        url: url:microsoft_graph_security_api_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 11. MICROSOFT AZURE MONITOR OAUTH2 API (display_order: 220)
-- =====================================================

CREATE credential_type:microsoft_azure_monitor_oauth2_api SET
    name = "microsoftAzureMonitorOAuth2Api",
    slug = "microsoft-azure-monitor-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_microsoft_azure_monitor_oauth2_api_name,
        description_i18n: i18n_key:credential_type_microsoft_azure_monitor_oauth2_api_description
    },
    
    presentation = {
        icon: icon:azure_monitor,
        color_type: theme_color_type:info,
        tooltip_i18n: i18n_key:credential_type_microsoft_azure_monitor_oauth2_api_tooltip,
        display_order: 220
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:microsoft,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://login.microsoftonline.com/common/oauth2/v2.0/token",
            authorization_url: "https://login.microsoftonline.com/common/oauth2/v2.0/authorize",
            authentication_method: "body",
            scope: "https://management.azure.com/.default offline_access"
        },
        oauth1: NONE,
        required_fields: [],
        metadata: {
            azure_service: true,
            apis_required: ["Azure Monitor API"],
            category: "monitoring"
        }
    },
    
    documentation = {
        url: url:azure_monitor_api_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 12. MICROSOFT AZURE COSMOS DB SHARED KEY API (display_order: 221)
-- =====================================================

CREATE credential_type:microsoft_azure_cosmos_db_shared_key_api SET
    name = "microsoftAzureCosmosDbSharedKeyApi",
    slug = "microsoft-azure-cosmos-db-shared-key-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_microsoft_azure_cosmos_db_shared_key_api_name,
        description_i18n: i18n_key:credential_type_microsoft_azure_cosmos_db_shared_key_api_description
    },
    
    presentation = {
        icon: icon:azure_cosmos_db,
        color_type: theme_color_type:info,
        tooltip_i18n: i18n_key:credential_type_microsoft_azure_cosmos_db_shared_key_api_tooltip,
        display_order: 221
    },
    
    auth_type = auth_type:api_key,
    provider = provider:microsoft,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "endpoint",
                display_name: "Endpoint",
                type: "string",
                is_secret: false,
                required: true,
                description: "Azure Cosmos DB account endpoint URI",
                placeholder: "https://yourdb.documents.azure.com:443/"
            },
            {
                name: "primaryKey",
                display_name: "Primary Key",
                type: "string",
                is_secret: true,
                required: true,
                description: "Primary master key for authentication"
            }
        ],
        metadata: {
            azure_service: true,
            auth_method: "shared_key",
            category: "database"
        }
    },
    
    documentation = {
        url: url:azure_cosmos_db_api_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 13. MICROSOFT SQL (display_order: 222)
-- =====================================================

CREATE credential_type:microsoft_sql SET
    name = "microsoftSql",
    slug = "microsoft-sql",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_microsoft_sql_name,
        description_i18n: i18n_key:credential_type_microsoft_sql_description
    },
    
    presentation = {
        icon: icon:microsoft_sql_server,
        color_type: theme_color_type:error,
        tooltip_i18n: i18n_key:credential_type_microsoft_sql_tooltip,
        display_order: 222
    },
    
    auth_type = auth_type:basic_auth,
    provider = provider:microsoft,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "server",
                display_name: "Server",
                type: "string",
                is_secret: false,
                required: true,
                description: "SQL Server hostname or IP address",
                placeholder: "localhost"
            },
            {
                name: "port",
                display_name: "Port",
                type: "number",
                is_secret: false,
                required: false,
                description: "SQL Server port (default: 1433)",
                default: 1433
            },
            {
                name: "database",
                display_name: "Database",
                type: "string",
                is_secret: false,
                required: true,
                description: "Database name"
            },
            {
                name: "user",
                display_name: "User",
                type: "string",
                is_secret: false,
                required: true,
                description: "SQL Server username"
            },
            {
                name: "password",
                display_name: "Password",
                type: "string",
                is_secret: true,
                required: true,
                description: "SQL Server password"
            }
        ],
        metadata: {
            protocol: "TDS",
            supports_azure_sql: true,
            category: "database"
        }
    },
    
    documentation = {
        url: url:microsoft_sql_server_docs,
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
WHERE provider = provider:microsoft
ORDER BY presentation.display_order ASC;
*/

-- =====================================================
-- RÉSUMÉ BATCH 3
-- =====================================================
--
-- ✅ 13 credentials Microsoft créés :
--
-- Microsoft 365 Workspace (6) - display_order: 200-205 ✨ TRÈS POPULAIRES
--  1. microsoft_excel_oauth2_api (200)
--  2. microsoft_teams_oauth2_api (201)
--  3. microsoft_outlook_oauth2_api (202)
--  4. microsoft_onedrive_oauth2_api (203)
--  5. microsoft_sharepoint_oauth2_api (204)
--  6. microsoft_todo_oauth2_api (205)
--
-- Microsoft Generic (1) - display_order: 206
--  7. microsoft_oauth2_api (206) - Base pour tous les autres
--
-- Microsoft Enterprise (3) - display_order: 210-212
--  8. microsoft_dynamics_oauth2_api (210) - CRM/ERP
--  9. microsoft_entra_oauth2_api (211) - Identity (ex-Azure AD)
-- 10. microsoft_graph_security_oauth2_api (212) - Security
--
-- Microsoft Azure (3) - display_order: 220-222
-- 11. microsoft_azure_monitor_oauth2_api (220) - Monitoring
-- 12. microsoft_azure_cosmos_db_shared_key_api (221) - NoSQL DB
-- 13. microsoft_sql (222) - SQL Server / Azure SQL
--
-- Tous avec provider = provider:microsoft
-- Structure complète : identity, presentation, config, documentation
--
-- =============================================================================================

