-- =====================================================
-- SCHÉMA DE BASE DE DONNÉES POUR MODULE D'INTÉGRATION
-- Inspiré de l'architecture n8n
-- =====================================================
-- 
-- STRUCTURE PRINCIPALE:
-- 1. PROVIDER (ex: Google, Facebook, GitHub, Slack)
-- 2. SERVICE (ex: Google Sheets, Google Ads, GitHub Issues)
-- 3. TOOL/OPERATION (ex: Create, Read, Update, Delete, Search)
-- 4. CREDENTIAL_TYPE (Types d'authentification)
-- 5. RESOURCE (Ressources manipulées par les services)
-- 6. PARAMETER (Paramètres des outils)
-- =====================================================


-- =====================================================
-- TABLE: resource
-- Représente les ressources manipulées par un service
-- (ex: Channel, Message, File pour Slack)
-- (ex: Sheet, Spreadsheet pour Google Sheets)
-- =====================================================
DEFINE TABLE resource SCHEMAFULL;

DEFINE FIELD name ON resource TYPE string
    ASSERT $value != NONE;

DEFINE FIELD display_name ON resource TYPE string
    ASSERT $value != NONE;

DEFINE FIELD slug ON resource TYPE string
    ASSERT $value != NONE;

DEFINE FIELD description ON resource TYPE option<string>;

-- Référence au service parent
DEFINE FIELD service_id ON resource TYPE record<service>
    ASSERT $value != NONE;

DEFINE FIELD is_active ON resource TYPE bool DEFAULT true;

DEFINE FIELD metadata ON resource TYPE option<object>;

DEFINE FIELD created_at ON resource TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON resource TYPE datetime DEFAULT time::now();

-- Index
DEFINE INDEX resource_slug_service_idx ON resource FIELDS slug, service_id UNIQUE;
DEFINE INDEX resource_service_idx ON resource FIELDS service_id;

-- =====================================================
-- TABLE: tool (Operation/Action)
-- Représente les actions/outils disponibles sur une ressource
-- (ex: Create, Read, Update, Delete, Search, Upload, etc.)
-- =====================================================
DEFINE TABLE tool SCHEMAFULL;

DEFINE FIELD name ON tool TYPE string
    ASSERT $value != NONE;

DEFINE FIELD display_name ON tool TYPE string
    ASSERT $value != NONE;

DEFINE FIELD slug ON tool TYPE string
    ASSERT $value != NONE;

DEFINE FIELD description ON tool TYPE option<string>;

-- Référence à la ressource parent
DEFINE FIELD resource_id ON tool TYPE record<resource>
    ASSERT $value != NONE;

-- Type d'opération (create, read, update, delete, list, search, etc.)
DEFINE FIELD operation_type ON tool TYPE string
    ASSERT $value IN ["create", "read", "update", "delete", "list", "search", "upload", "download", "execute", "custom"];

-- Méthode HTTP utilisée
DEFINE FIELD http_method ON tool TYPE option<string>
    ASSERT $value == NONE OR $value IN ["GET", "POST", "PUT", "PATCH", "DELETE"];

-- Endpoint API (peut contenir des variables: /api/v1/users/{userId})
DEFINE FIELD api_endpoint ON tool TYPE option<string>;

-- Template du corps de la requête
DEFINE FIELD request_body_template ON tool TYPE option<object>;

DEFINE FIELD is_active ON tool TYPE bool DEFAULT true;

-- Configuration avancée
DEFINE FIELD supports_pagination ON tool TYPE bool DEFAULT false;
DEFINE FIELD supports_filtering ON tool TYPE bool DEFAULT false;
DEFINE FIELD supports_sorting ON tool TYPE bool DEFAULT false;
DEFINE FIELD supports_batch ON tool TYPE bool DEFAULT false;

-- Limites de taux (rate limiting)
DEFINE FIELD rate_limit_requests ON tool TYPE option<int>;
DEFINE FIELD rate_limit_period ON tool TYPE option<string>;

DEFINE FIELD metadata ON tool TYPE option<object>;

DEFINE FIELD created_at ON tool TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON tool TYPE datetime DEFAULT time::now();

-- Index
DEFINE INDEX tool_slug_resource_idx ON tool FIELDS slug, resource_id UNIQUE;
DEFINE INDEX tool_resource_idx ON tool FIELDS resource_id;
DEFINE INDEX tool_operation_idx ON tool FIELDS operation_type;

-- =====================================================
-- TABLE: parameter
-- Représente les paramètres d'entrée/sortie d'un outil
-- =====================================================
DEFINE TABLE parameter SCHEMAFULL;

DEFINE FIELD name ON parameter TYPE string
    ASSERT $value != NONE;

DEFINE FIELD display_name ON parameter TYPE string
    ASSERT $value != NONE;

DEFINE FIELD description ON parameter TYPE option<string>;

-- Référence à l'outil parent
DEFINE FIELD tool_id ON parameter TYPE record<tool>
    ASSERT $value != NONE;

-- Type de paramètre (string, number, boolean, object, array, etc.)
DEFINE FIELD parameter_type ON parameter TYPE string
    ASSERT $value IN ["string", "number", "boolean", "object", "array", "date", "datetime", "file", "options", "multiOptions", "resourceLocator", "json", "hidden"];

-- Sous-type pour les options
DEFINE FIELD sub_type ON parameter TYPE option<string>;

-- Valeur par défaut
DEFINE FIELD default_value ON parameter TYPE option<any>;

-- Est-ce requis ?
DEFINE FIELD is_required ON parameter TYPE bool DEFAULT false;

-- Position/ordre d'affichage
DEFINE FIELD display_order ON parameter TYPE int DEFAULT 0;

-- Options pour les paramètres de type "options"
DEFINE FIELD options ON parameter TYPE option<array<object>>;

-- Validation
DEFINE FIELD validation_rules ON parameter TYPE option<object>;
DEFINE FIELD min_value ON parameter TYPE option<number>;
DEFINE FIELD max_value ON parameter TYPE option<number>;
DEFINE FIELD pattern ON parameter TYPE option<string>;

-- Conditions d'affichage
DEFINE FIELD display_conditions ON parameter TYPE option<object>;

-- Placeholder pour les champs texte
DEFINE FIELD placeholder ON parameter TYPE option<string>;

DEFINE FIELD metadata ON parameter TYPE option<object>;

DEFINE FIELD created_at ON parameter TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON parameter TYPE datetime DEFAULT time::now();

-- Index
DEFINE INDEX parameter_tool_idx ON parameter FIELDS tool_id;
DEFINE INDEX parameter_name_tool_idx ON parameter FIELDS name, tool_id;



-- =====================================================
-- TABLE: response_mapping
-- Définit comment mapper les réponses API
-- =====================================================
DEFINE TABLE response_mapping SCHEMAFULL;

DEFINE FIELD tool_id ON response_mapping TYPE record<tool>
    ASSERT $value != NONE;

DEFINE FIELD name ON response_mapping TYPE string
    ASSERT $value != NONE;

-- Chemin dans la réponse (ex: "data.items", "result.users")
DEFINE FIELD json_path ON response_mapping TYPE string;

-- Type de données attendu
DEFINE FIELD data_type ON response_mapping TYPE string
    ASSERT $value IN ["string", "number", "boolean", "object", "array"];

-- Transformation à appliquer (optionnel)
DEFINE FIELD transform_function ON response_mapping TYPE option<string>;

DEFINE FIELD is_required ON response_mapping TYPE bool DEFAULT false;

DEFINE FIELD metadata ON response_mapping TYPE option<object>;

DEFINE FIELD created_at ON response_mapping TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON response_mapping TYPE datetime DEFAULT time::now();

-- Index
DEFINE INDEX response_mapping_tool_idx ON response_mapping FIELDS tool_id;

-- =====================================================
-- TABLE: error_mapping
-- Définit comment gérer les erreurs API
-- =====================================================
DEFINE TABLE error_mapping SCHEMAFULL;

DEFINE FIELD service_id ON error_mapping TYPE record<service>
    ASSERT $value != NONE;

-- Code d'erreur HTTP
DEFINE FIELD http_status_code ON error_mapping TYPE option<int>;

-- Code d'erreur spécifique de l'API
DEFINE FIELD api_error_code ON error_mapping TYPE option<string>;

-- Message d'erreur normalisé
DEFINE FIELD normalized_message ON error_mapping TYPE string;

-- Niveau de sévérité
DEFINE FIELD severity ON error_mapping TYPE string
    ASSERT $value IN ["info", "warning", "error", "critical"];

-- Action recommandée
DEFINE FIELD recommended_action ON error_mapping TYPE option<string>;

-- Est-ce réessayable ?
DEFINE FIELD is_retryable ON error_mapping TYPE bool DEFAULT false;

DEFINE FIELD metadata ON error_mapping TYPE option<object>;

DEFINE FIELD created_at ON error_mapping TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON error_mapping TYPE datetime DEFAULT time::now();

-- Index
DEFINE INDEX error_mapping_service_idx ON error_mapping FIELDS service_id;
DEFINE INDEX error_mapping_status_idx ON error_mapping FIELDS http_status_code;

-- =====================================================
-- TABLE: webhook_config
-- Configuration des webhooks pour les services
-- =====================================================
DEFINE TABLE webhook_config SCHEMAFULL;

DEFINE FIELD service_id ON webhook_config TYPE record<service>
    ASSERT $value != NONE;

DEFINE FIELD name ON webhook_config TYPE string
    ASSERT $value != NONE;

DEFINE FIELD display_name ON webhook_config TYPE string
    ASSERT $value != NONE;

-- Type d'événement déclenché
DEFINE FIELD event_type ON webhook_config TYPE string;

-- Méthode HTTP acceptée
DEFINE FIELD http_method ON webhook_config TYPE string
    ASSERT $value IN ["GET", "POST", "PUT", "PATCH", "DELETE"];

-- Template pour valider le webhook
DEFINE FIELD validation_config ON webhook_config TYPE option<object>;

-- Headers requis
DEFINE FIELD required_headers ON webhook_config TYPE option<array<string>>;

-- Configuration de signature (pour vérification)
DEFINE FIELD signature_config ON webhook_config TYPE option<object>;

DEFINE FIELD is_active ON webhook_config TYPE bool DEFAULT true;

DEFINE FIELD metadata ON webhook_config TYPE option<object>;

DEFINE FIELD created_at ON webhook_config TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON webhook_config TYPE datetime DEFAULT time::now();

-- Index
DEFINE INDEX webhook_service_idx ON webhook_config FIELDS service_id;

-- =====================================================
-- TABLE: service_version
-- Gestion des versions des services
-- =====================================================
DEFINE TABLE service_version SCHEMAFULL;

DEFINE FIELD service_id ON service_version TYPE record<service>
    ASSERT $value != NONE;

DEFINE FIELD version ON service_version TYPE string
    ASSERT $value != NONE;

DEFINE FIELD is_default ON service_version TYPE bool DEFAULT false;

DEFINE FIELD is_deprecated ON service_version TYPE bool DEFAULT false;

DEFINE FIELD release_date ON service_version TYPE option<datetime>;

DEFINE FIELD deprecation_date ON service_version TYPE option<datetime>;

DEFINE FIELD changelog ON service_version TYPE option<string>;

-- Différences par rapport à la version précédente
DEFINE FIELD breaking_changes ON service_version TYPE array<string> DEFAULT [];

DEFINE FIELD metadata ON service_version TYPE option<object>;

DEFINE FIELD created_at ON service_version TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON service_version TYPE datetime DEFAULT time::now();

-- Index
DEFINE INDEX service_version_idx ON service_version FIELDS service_id, version UNIQUE;

-- =====================================================
-- TABLE: tag
-- Tags pour catégoriser providers, services, etc.
-- =====================================================
DEFINE TABLE tag SCHEMAFULL;

DEFINE FIELD name ON tag TYPE string
    ASSERT $value != NONE;

DEFINE FIELD slug ON tag TYPE string
    ASSERT $value != NONE;

DEFINE FIELD color ON tag TYPE option<string>;

DEFINE FIELD icon ON tag TYPE option<string>;

DEFINE FIELD created_at ON tag TYPE datetime DEFAULT time::now();

-- Index
DEFINE INDEX tag_slug_idx ON tag FIELDS slug UNIQUE;

-- =====================================================
-- RELATIONS
-- =====================================================

-- Relation: service appartient à provider
DEFINE TABLE belongs_to SCHEMAFULL;
DEFINE FIELD in ON belongs_to TYPE record<service>;
DEFINE FIELD out ON belongs_to TYPE record<provider>;
DEFINE FIELD created_at ON belongs_to TYPE datetime DEFAULT time::now();

-- Relation: service utilise credential_type
DEFINE TABLE uses_credential SCHEMAFULL;
DEFINE FIELD in ON uses_credential TYPE record<service>;
DEFINE FIELD out ON uses_credential TYPE record<credential_type>;
DEFINE FIELD is_required ON uses_credential TYPE bool DEFAULT true;
DEFINE FIELD display_conditions ON uses_credential TYPE option<object>;
DEFINE FIELD created_at ON uses_credential TYPE datetime DEFAULT time::now();

-- Relation: resource appartient à service
DEFINE TABLE has_resource SCHEMAFULL;
DEFINE FIELD in ON has_resource TYPE record<service>;
DEFINE FIELD out ON has_resource TYPE record<resource>;
DEFINE FIELD created_at ON has_resource TYPE datetime DEFAULT time::now();

-- Relation: tool appartient à resource
DEFINE TABLE has_tool SCHEMAFULL;
DEFINE FIELD in ON has_tool TYPE record<resource>;
DEFINE FIELD out ON has_tool TYPE record<tool>;
DEFINE FIELD created_at ON has_tool TYPE datetime DEFAULT time::now();

-- Relation: tool a des paramètres
DEFINE TABLE has_parameter SCHEMAFULL;
DEFINE FIELD in ON has_parameter TYPE record<tool>;
DEFINE FIELD out ON has_parameter TYPE record<parameter>;
DEFINE FIELD created_at ON has_parameter TYPE datetime DEFAULT time::now();

-- Relation: provider a des tags
DEFINE TABLE tagged_with SCHEMAFULL;
DEFINE FIELD in ON tagged_with TYPE record;
DEFINE FIELD out ON tagged_with TYPE record<tag>;
DEFINE FIELD created_at ON tagged_with TYPE datetime DEFAULT time::now();

-- =====================================================
-- VUES UTILES
-- =====================================================

-- Vue: Services complets avec leur provider
DEFINE TABLE service_with_provider AS
    SELECT 
        service.*,
        provider.display_name AS provider_name,
        provider.slug AS provider_slug,
        provider.icon_light AS provider_icon_light
    FROM service
    INNER JOIN provider ON service.provider_id = provider.id;

-- =====================================================
-- DONNÉES D'EXEMPLE INSPIRÉES DE N8N
-- =====================================================

-- Provider: Google
LET $google_provider = CREATE provider SET
    name = "Google",
    display_name = "Google",
    slug = "google",
    description = "Services et APIs Google",
    icon_light = "google-icon-light.svg",
    icon_dark = "google-icon-dark.svg",
    website_url = "https://google.com",
    documentation_url = "https://developers.google.com",
    api_base_url = "https://www.googleapis.com",
    support_oauth2 = true,
    support_api_key = true,
    tags = ["productivity", "cloud", "popular"];

-- Service: Google Sheets
LET $google_sheets_service = CREATE service SET
    name = "googleSheets",
    display_name = "Google Sheets",
    slug = "google-sheets",
    description = "Read, update and write data to Google Sheets",
    icon = "googleSheets.svg",
    provider_id = $google_provider.id,
    version = "4.7",
    default_version = "4.7",
    categories = ["Data & Storage", "Productivity"],
    is_active = true,
    documentation_url = "https://docs.n8n.io/integrations/builtin/app-nodes/n8n-nodes-base.googlesheets/",
    aliases = ["CSV", "Sheet", "Spreadsheet", "GS"],
    tags = ["spreadsheet", "data"];

-- Resource: Sheet Within Document
LET $sheet_resource = CREATE resource SET
    name = "sheet",
    display_name = "Sheet Within Document",
    slug = "sheet",
    description = "Operations on sheets within a Google Sheets document",
    service_id = $google_sheets_service.id,
    is_active = true;

-- Tool: Append Row
LET $append_tool = CREATE tool SET
    name = "append",
    display_name = "Append Row",
    slug = "append",
    description = "Create a new row in a sheet",
    resource_id = $sheet_resource.id,
    operation_type = "create",
    http_method = "POST",
    api_endpoint = "/v4/spreadsheets/{spreadsheetId}/values/{range}:append",
    is_active = true,
    supports_batch = true;

-- Tool: Read Rows
LET $read_tool = CREATE tool SET
    name = "read",
    display_name = "Get Row(s)",
    slug = "read",
    description = "Retrieve one or more rows from a sheet",
    resource_id = $sheet_resource.id,
    operation_type = "read",
    http_method = "GET",
    api_endpoint = "/v4/spreadsheets/{spreadsheetId}/values/{range}",
    is_active = true,
    supports_pagination = true,
    supports_filtering = true;

-- Tool: Update Row
LET $update_tool = CREATE tool SET
    name = "update",
    display_name = "Update Row",
    slug = "update",
    description = "Update an existing row in a sheet",
    resource_id = $sheet_resource.id,
    operation_type = "update",
    http_method = "PUT",
    api_endpoint = "/v4/spreadsheets/{spreadsheetId}/values/{range}",
    is_active = true;

-- Credential Type: Google OAuth2
LET $google_oauth2 = CREATE credential_type SET
    name = "googleSheetsOAuth2Api",
    display_name = "Google Sheets OAuth2 API",
    slug = "google-sheets-oauth2",
    auth_type = "oauth2",
    provider_id = $google_provider.id,
    oauth2_config = {
        auth_url: "https://accounts.google.com/o/oauth2/v2/auth",
        token_url: "https://oauth2.googleapis.com/token",
        scope: "https://www.googleapis.com/auth/drive.file https://www.googleapis.com/auth/spreadsheets https://www.googleapis.com/auth/drive.metadata",
        grant_type: "authorization_code"
    },
    required_fields = [
        {name: "client_id", display_name: "Client ID", type: "string", is_secret: false},
        {name: "client_secret", display_name: "Client Secret", type: "string", is_secret: true}
    ],
    is_active = true;

-- Paramètres pour l'outil Append
CREATE parameter SET
    name = "documentId",
    display_name = "Document",
    description = "The Google Sheets document to append to",
    tool_id = $append_tool.id,
    parameter_type = "resourceLocator",
    is_required = true,
    display_order = 1;

CREATE parameter SET
    name = "sheetName",
    display_name = "Sheet",
    description = "The sheet within the document",
    tool_id = $append_tool.id,
    parameter_type = "resourceLocator",
    is_required = true,
    display_order = 2;

CREATE parameter SET
    name = "dataMode",
    display_name = "Data Mode",
    description = "How to send the data",
    tool_id = $append_tool.id,
    parameter_type = "options",
    is_required = true,
    display_order = 3,
    default_value = "autoMapInputData",
    options = [
        {name: "Auto-Map Input Data to Columns", value: "autoMapInputData"},
        {name: "Map Each Column Below", value: "defineBelow"},
        {name: "Nothing", value: "nothing"}
    ];

-- =====================================================
-- Provider: Slack
-- =====================================================

LET $slack_provider = CREATE provider SET
    name = "Slack",
    display_name = "Slack",
    slug = "slack",
    description = "Communication platform for teams",
    icon_light = "slack.svg",
    website_url = "https://slack.com",
    documentation_url = "https://api.slack.com",
    api_base_url = "https://slack.com/api",
    support_oauth2 = true,
    support_api_key = true,
    tags = ["communication", "collaboration", "popular"];

-- Service: Slack
LET $slack_service = CREATE service SET
    name = "slack",
    display_name = "Slack",
    slug = "slack",
    description = "Consume Slack API",
    icon = "slack.svg",
    provider_id = $slack_provider.id,
    version = "2.3",
    categories = ["Communication"],
    is_active = true,
    is_trigger = true,
    is_webhook = true,
    tags = ["messaging", "channels"];

-- Resources pour Slack
LET $channel_resource = CREATE resource SET
    name = "channel",
    display_name = "Channel",
    slug = "channel",
    description = "Operations on Slack channels",
    service_id = $slack_service.id;

LET $message_resource = CREATE resource SET
    name = "message",
    display_name = "Message",
    slug = "message",
    description = "Operations on Slack messages",
    service_id = $slack_service.id;

LET $file_resource = CREATE resource SET
    name = "file",
    display_name = "File",
    slug = "file",
    description = "Operations on Slack files",
    service_id = $slack_service.id;

-- Tools pour Slack Messages
CREATE tool SET
    name = "post",
    display_name = "Post Message",
    slug = "post",
    description = "Post a message to a channel",
    resource_id = $message_resource.id,
    operation_type = "create",
    http_method = "POST",
    api_endpoint = "/chat.postMessage",
    is_active = true;

CREATE tool SET
    name = "update",
    display_name = "Update Message",
    slug = "update",
    description = "Update an existing message",
    resource_id = $message_resource.id,
    operation_type = "update",
    http_method = "POST",
    api_endpoint = "/chat.update",
    is_active = true;

CREATE tool SET
    name = "delete",
    display_name = "Delete Message",
    slug = "delete",
    description = "Delete a message",
    resource_id = $message_resource.id,
    operation_type = "delete",
    http_method = "POST",
    api_endpoint = "/chat.delete",
    is_active = true;

-- =====================================================
-- Provider: GitHub
-- =====================================================

LET $github_provider = CREATE provider SET
    name = "GitHub",
    display_name = "GitHub",
    slug = "github",
    description = "Development platform for code hosting and collaboration",
    icon_light = "github.svg",
    icon_dark = "github.dark.svg",
    website_url = "https://github.com",
    documentation_url = "https://docs.github.com/en/rest",
    api_base_url = "https://api.github.com",
    support_oauth2 = true,
    support_api_key = true,
    tags = ["development", "version-control", "popular"];

-- Service: GitHub
LET $github_service = CREATE service SET
    name = "github",
    display_name = "GitHub",
    slug = "github",
    description = "Consume GitHub API",
    icon = "github.svg",
    provider_id = $github_provider.id,
    version = "1.1",
    categories = ["Development"],
    is_active = true,
    is_trigger = true,
    is_webhook = true,
    tags = ["git", "repository", "issues"];

-- Resources pour GitHub
LET $issue_resource = CREATE resource SET
    name = "issue",
    display_name = "Issue",
    slug = "issue",
    service_id = $github_service.id;

LET $repo_resource = CREATE resource SET
    name = "repository",
    display_name = "Repository",
    slug = "repository",
    service_id = $github_service.id;

LET $file_gh_resource = CREATE resource SET
    name = "file",
    display_name = "File",
    slug = "file",
    service_id = $github_service.id;

-- Tools pour GitHub Issues
CREATE tool SET
    name = "create",
    display_name = "Create Issue",
    slug = "create",
    description = "Create a new issue",
    resource_id = $issue_resource.id,
    operation_type = "create",
    http_method = "POST",
    api_endpoint = "/repos/{owner}/{repo}/issues",
    is_active = true;

CREATE tool SET
    name = "get",
    display_name = "Get Issue",
    slug = "get",
    description = "Get a single issue",
    resource_id = $issue_resource.id,
    operation_type = "read",
    http_method = "GET",
    api_endpoint = "/repos/{owner}/{repo}/issues/{issue_number}",
    is_active = true;

CREATE tool SET
    name = "list",
    display_name = "List Issues",
    slug = "list",
    description = "List all issues",
    resource_id = $issue_resource.id,
    operation_type = "list",
    http_method = "GET",
    api_endpoint = "/repos/{owner}/{repo}/issues",
    is_active = true,
    supports_pagination = true,
    supports_filtering = true;

-- =====================================================
-- FIN DU SCHÉMA
-- =====================================================

