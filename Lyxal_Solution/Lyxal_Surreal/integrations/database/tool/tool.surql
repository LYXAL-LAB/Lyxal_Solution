-- =============================================================================================
-- |
-- | TABLE: tool
-- | MODULE: integrations
-- | VERSION: 2.0
-- | DATE: 2025-10-30
-- |
-- | DESCRIPTION:
-- | Représente les actions/outils disponibles sur une ressource.
-- | Un tool est une opération qu'on peut effectuer (Create, Read, Update, Delete, Search, etc.).
-- |
-- | EXEMPLES:
-- | - Resource "Slack → Channel" → Tools: Create Channel, Get Channel, List Channels, Archive Channel
-- | - Resource "Google Sheets → Sheet" → Tools: Append Row, Get Row(s), Update Row, Delete Row
-- | - Resource "GitHub → Issue" → Tools: Create Issue, Get Issue, List Issues, Update Issue
-- |
-- | ARCHITECTURE:
-- | - Structure groupée pour clarté (identity, presentation, config, documentation, metadata)
-- | - i18n_key pour multilinguisme (name, desc, tooltip, success_msg, error_msg)
-- | - icon pour représentation visuelle
-- | - ETag pour optimistic locking et temps réel
-- | - Permissions granulaires pour sécurité
-- | - Config Request/Response complète pour API
-- | - Métadonnées UX (confirmation, durée, is_destructive)
-- |
-- | CONFORMITÉ: 100% Lyxal Standards (Data-First + UI-Driven)
-- |
-- =============================================================================================

-- =====================================================
-- DÉFINITION DE LA TABLE
-- =====================================================

DEFINE TABLE tool SCHEMAFULL
    COMMENT "Actions/outils disponibles sur les ressources (ex: Create Channel, Append Row, Get Issue). Table conforme 100% aux standards Lyxal avec structure groupée, i18n, config API complète, ETag et permissions."
    PERMISSIONS
        FOR select WHERE is_active = true OR $auth.role IN ["admin", "editor"]
        FOR create WHERE $auth.role IN ["admin"]
        FOR update WHERE $auth.role IN ["admin", "editor"]
        FOR delete WHERE $auth.role = "admin";

-- =====================================================
-- BLOC: IDENTITY (Identité technique et sémantique)
-- =====================================================

DEFINE FIELD identity ON tool TYPE object
    COMMENT "Identité du tool : noms techniques et affichables"
    ASSERT $value != NONE;

DEFINE FIELD identity.name ON tool TYPE string
    COMMENT "Nom technique du tool (ex: 'create', 'get', 'list', 'update')"
    ASSERT $value != NONE AND string::len($value) > 0;

DEFINE FIELD identity.slug ON tool TYPE string
    COMMENT "Slug unique pour URLs et identification (ex: 'slack-channel-create', 'sheets-append-row')"
    ASSERT $value != NONE AND string::len($value) > 0 AND string::lowercase($value) == $value;

DEFINE FIELD identity.display_name_i18n ON tool TYPE record<i18n_key>
    COMMENT "Clé i18n pour le nom affiché dans l'UI (ex: 'Créer un canal', 'Ajouter une ligne')"
    ASSERT $value != NONE;

DEFINE FIELD identity.description_i18n ON tool TYPE option<record<i18n_key>>
    COMMENT "Clé i18n pour la description complète du tool";

DEFINE FIELD identity.operation_type ON tool TYPE string
    COMMENT "Type d'opération effectuée (create, read, update, delete, list, search, upload, download, execute, custom)"
    ASSERT $value IN ["create", "read", "update", "delete", "list", "search", "upload", "download", "execute", "custom"];

DEFINE FIELD identity.aliases ON tool TYPE array<string> DEFAULT []
    COMMENT "Alias de recherche (ex: ['add', 'insert'] pour Create)";

-- =====================================================
-- BLOC: PRESENTATION (Apparence UI)
-- =====================================================

DEFINE FIELD presentation ON tool TYPE object
    COMMENT "Configuration de présentation visuelle dans l'UI"
    ASSERT $value != NONE;

DEFINE FIELD presentation.icon ON tool TYPE option<record<icon>>
    COMMENT "Icône représentant le tool (ex: ➕ pour create, 📄 pour get, 🗑️ pour delete)";

DEFINE FIELD presentation.color_type ON tool TYPE option<record<theme_color_type>>
    COMMENT "Type de couleur pour les tags/badges dans l'UI (référence vers theme_color_type: primary, error, warning, etc.)"
    REFERENCE ON DELETE REJECT;

DEFINE FIELD presentation.display_order ON tool TYPE int DEFAULT 0
    COMMENT "Ordre d'affichage dans les listes (0 = plus haut)";

DEFINE FIELD presentation.tooltip_i18n ON tool TYPE option<record<i18n_key>>
    COMMENT "Clé i18n pour l'infobulle (conseil rapide affiché au survol)";

DEFINE FIELD presentation.badge_text ON tool TYPE option<string>
    COMMENT "Texte du badge affiché (ex: 'Beta', 'Premium', 'Recommended')"
    ASSERT $value == NONE OR string::len($value) <= 20;

DEFINE FIELD presentation.badge_color ON tool TYPE option<string>
    COMMENT "Couleur du badge (ex: '#FF9800' pour Beta, '#9C27B0' pour Premium)"
    ASSERT $value == NONE OR string::starts_with($value, '#');

DEFINE FIELD presentation.success_message_i18n ON tool TYPE option<record<i18n_key>>
    COMMENT "Clé i18n pour le message de succès après exécution (ex: 'Canal créé avec succès')";

DEFINE FIELD presentation.error_message_i18n ON tool TYPE option<record<i18n_key>>
    COMMENT "Clé i18n pour le message d'erreur générique (ex: 'Échec de la création du canal')";

DEFINE FIELD presentation.confirmation_required ON tool TYPE bool DEFAULT false
    COMMENT "True si une confirmation est requise avant exécution (ex: true pour delete, false pour get)";

DEFINE FIELD presentation.confirmation_message_i18n ON tool TYPE option<record<i18n_key>>
    COMMENT "Clé i18n pour le message de confirmation (ex: 'Êtes-vous sûr de vouloir supprimer ?')";

DEFINE FIELD presentation.estimated_duration ON tool TYPE option<int>
    COMMENT "Durée estimée d'exécution en secondes (ex: 2, 5, 30)"
    ASSERT $value == NONE OR $value > 0;

DEFINE FIELD presentation.is_destructive ON tool TYPE bool DEFAULT false
    COMMENT "True si l'action est destructive et irréversible (ex: true pour delete, false pour get)";

-- =====================================================
-- BLOC: CONFIG (Configuration technique)
-- =====================================================

DEFINE FIELD config ON tool TYPE object
    COMMENT "Configuration technique de l'API et du comportement du tool"
    ASSERT $value != NONE;

-- Request Configuration ────────────────────────────────────

DEFINE FIELD config.request ON tool TYPE object
    COMMENT "Configuration de la requête HTTP vers l'API"
    ASSERT $value != NONE;

DEFINE FIELD config.request.method ON tool TYPE string
    COMMENT "Méthode HTTP utilisée (GET, POST, PUT, PATCH, DELETE)"
    ASSERT $value IN ["GET", "POST", "PUT", "PATCH", "DELETE"];

DEFINE FIELD config.request.endpoint ON tool TYPE string
    COMMENT "Endpoint de l'API (peut contenir des variables: /api/v1/users/{userId}/posts/{postId})"
    ASSERT $value != NONE AND string::len($value) > 0;

DEFINE FIELD config.request.body_template ON tool TYPE option<object>
    COMMENT "Template du corps de la requête (variables: {field_name})";

DEFINE FIELD config.request.headers_template ON tool TYPE option<object>
    COMMENT "Template des headers HTTP personnalisés (ex: {\"X-Custom-Header\": \"{value}\"})";

DEFINE FIELD config.request.query_params_template ON tool TYPE option<object>
    COMMENT "Template des paramètres query (ex: {\"page\": \"{page}\", \"limit\": \"{limit}\"})";

DEFINE FIELD config.request.path_params ON tool TYPE array<string> DEFAULT []
    COMMENT "Liste des paramètres de chemin à remplacer dans l'endpoint (ex: ['userId', 'postId'])";

DEFINE FIELD config.request.authentication_required ON tool TYPE bool DEFAULT true
    COMMENT "True si l'authentification est requise pour ce tool";

-- Response Configuration ────────────────────────────────────

DEFINE FIELD config.response ON tool TYPE object
    COMMENT "Configuration de la réponse API"
    ASSERT $value != NONE;

DEFINE FIELD config.response.success_codes ON tool TYPE array<int> DEFAULT [200]
    COMMENT "Codes HTTP considérés comme succès (ex: [200, 201, 204])"
    ASSERT array::len($value) > 0;

DEFINE FIELD config.response.data_path ON tool TYPE option<string>
    COMMENT "Chemin JSON vers les données dans la réponse (ex: 'data.items', 'result.users')";

DEFINE FIELD config.response.pagination_path ON tool TYPE option<string>
    COMMENT "Chemin JSON vers les métadonnées de pagination (ex: 'data.pagination', 'meta.page')";

DEFINE FIELD config.response.transform ON tool TYPE option<object>
    COMMENT "Transformation à appliquer sur la réponse (mapping de champs, etc.)";

-- Capabilities ──────────────────────────────────────────────

DEFINE FIELD config.capabilities ON tool TYPE object
    COMMENT "Capacités et fonctionnalités avancées du tool"
    ASSERT $value != NONE;

DEFINE FIELD config.capabilities.supports_pagination ON tool TYPE bool DEFAULT false
    COMMENT "True si le tool supporte la pagination (généralement pour list)";

DEFINE FIELD config.capabilities.supports_filtering ON tool TYPE bool DEFAULT false
    COMMENT "True si le tool supporte le filtrage des résultats";

DEFINE FIELD config.capabilities.supports_sorting ON tool TYPE bool DEFAULT false
    COMMENT "True si le tool supporte le tri des résultats";

DEFINE FIELD config.capabilities.supports_batch ON tool TYPE bool DEFAULT false
    COMMENT "True si le tool supporte les opérations par lot (créer/modifier plusieurs à la fois)";

DEFINE FIELD config.capabilities.is_idempotent ON tool TYPE bool DEFAULT false
    COMMENT "True si le tool est idempotent (même résultat si exécuté plusieurs fois)";

DEFINE FIELD config.capabilities.requires_confirmation ON tool TYPE bool DEFAULT false
    COMMENT "True si une confirmation utilisateur est requise avant exécution";

-- Rate Limiting ─────────────────────────────────────────────

DEFINE FIELD config.rate_limiting ON tool TYPE option<object>
    COMMENT "Configuration des limites de taux (rate limiting)";

DEFINE FIELD config.rate_limiting.max_requests ON tool TYPE option<int>
    COMMENT "Nombre maximum de requêtes autorisées dans la période"
    ASSERT $value == NONE OR $value > 0;

DEFINE FIELD config.rate_limiting.period ON tool TYPE option<string>
    COMMENT "Période de temps pour le rate limiting (minute, hour, day)"
    ASSERT $value == NONE OR $value IN ["second", "minute", "hour", "day"];

DEFINE FIELD config.rate_limiting.burst_allowed ON tool TYPE bool DEFAULT false
    COMMENT "True si les rafales (burst) sont autorisées";

-- =====================================================
-- BLOC: DOCUMENTATION (Ressources externes)
-- =====================================================

DEFINE FIELD documentation ON tool TYPE option<object>
    COMMENT "URLs de documentation et ressources d'apprentissage";

DEFINE FIELD documentation.main_url ON tool TYPE option<string>
    COMMENT "URL principale de la documentation du tool"
    ASSERT $value == NONE OR (string::starts_with($value, 'http://') OR string::starts_with($value, 'https://'));

DEFINE FIELD documentation.examples_url ON tool TYPE option<string>
    COMMENT "URL vers des exemples d'utilisation"
    ASSERT $value == NONE OR (string::starts_with($value, 'http://') OR string::starts_with($value, 'https://'));

DEFINE FIELD documentation.video_tutorial_url ON tool TYPE option<string>
    COMMENT "URL d'une vidéo de démonstration"
    ASSERT $value == NONE OR (string::starts_with($value, 'http://') OR string::starts_with($value, 'https://'));

DEFINE FIELD documentation.common_use_cases ON tool TYPE array<string> DEFAULT []
    COMMENT "Liste des cas d'usage courants (ex: ['Créer un canal public', 'Créer un canal privé'])";

DEFINE FIELD documentation.prerequisites ON tool TYPE array<string> DEFAULT []
    COMMENT "Prérequis pour utiliser ce tool (ex: ['Permissions admin requises', 'Service activé'])";

-- =====================================================
-- BLOC: METADATA (Données supplémentaires)
-- =====================================================

DEFINE FIELD metadata ON tool TYPE option<object>
    COMMENT "Métadonnées additionnelles pour analytics et extensions";

DEFINE FIELD metadata.usage_count ON tool TYPE option<int>
    COMMENT "Nombre d'utilisations de ce tool"
    ASSERT $value == NONE OR $value >= 0;

DEFINE FIELD metadata.average_duration ON tool TYPE option<int>
    COMMENT "Durée moyenne d'exécution en millisecondes"
    ASSERT $value == NONE OR $value > 0;

DEFINE FIELD metadata.success_rate ON tool TYPE option<float>
    COMMENT "Taux de succès (0.0 à 1.0, ex: 0.98 = 98%)"
    ASSERT $value == NONE OR ($value >= 0.0 AND $value <= 1.0);

DEFINE FIELD metadata.custom_data ON tool TYPE option<object>
    COMMENT "Données personnalisées spécifiques à l'application";

-- =====================================================
-- BLOC: RELATIONS (Liaisons vers autres tables)
-- =====================================================

DEFINE FIELD resource_id ON tool TYPE record<resource>
    COMMENT "Resource parent de ce tool (ex: tool 'Create Channel' → resource 'Slack Channel')"
    ASSERT $value != NONE;

-- =====================================================
-- BLOC: ÉTAT (Status et synchronisation)
-- =====================================================

DEFINE FIELD is_active ON tool TYPE bool DEFAULT true
    COMMENT "True si le tool est activé et disponible dans l'UI";

DEFINE FIELD ETag ON tool TYPE uuid DEFAULT rand::uuid::v4()
    COMMENT "ETag pour optimistic locking et Live Queries. Change à chaque modification."
    READONLY;

-- =====================================================
-- BLOC: TIMESTAMPS (Audit trail)
-- =====================================================

DEFINE FIELD created_at ON tool TYPE datetime
    COMMENT "Date de création de l'enregistrement (immuable)"
    VALUE $before OR time::now()
    READONLY;

DEFINE FIELD updated_at ON tool TYPE datetime
    COMMENT "Date de dernière modification (auto-mise à jour)"
    DEFAULT ALWAYS time::now()
    READONLY;

-- =====================================================
-- INDEX (Performance et contraintes)
-- =====================================================

DEFINE INDEX tool_slug_resource_idx ON tool FIELDS identity.slug, resource_id UNIQUE
    COMMENT "Index unique sur le slug par resource pour garantir l'unicité";

DEFINE INDEX tool_name_idx ON tool FIELDS identity.name
    COMMENT "Index sur le nom technique pour recherches rapides";

DEFINE INDEX tool_resource_idx ON tool FIELDS resource_id
    COMMENT "Index sur resource_id pour requêtes de type 'tous les tools d'une resource'";

DEFINE INDEX tool_operation_idx ON tool FIELDS identity.operation_type
    COMMENT "Index sur operation_type pour filtrer par type (ex: tous les 'create')";

DEFINE INDEX tool_active_idx ON tool FIELDS is_active
    COMMENT "Index sur is_active pour filtrer rapidement les tools actifs";

-- =====================================================
-- EXEMPLES D'UTILISATION
-- =====================================================

-- Exemple 1: Créer un tool "Create Channel" pour Slack
/*
CREATE tool:slack_channel_create SET
    identity = {
        name: "create",
        slug: "slack-channel-create",
        display_name_i18n: i18n_key:tool_slack_channel_create_name,
        description_i18n: i18n_key:tool_slack_channel_create_desc,
        operation_type: "create",
        aliases: ["add", "new"]
    },
    presentation = {
        icon: icon:plus,
        color: "#4CAF50",
        display_order: 1,
        tooltip_i18n: i18n_key:tool_slack_channel_create_tooltip,
        badge_text: NONE,
        badge_color: NONE,
        success_message_i18n: i18n_key:tool_slack_channel_create_success,
        error_message_i18n: i18n_key:tool_slack_channel_create_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 2,
        is_destructive: false
    },
    config = {
        request: {
            method: "POST",
            endpoint: "/conversations.create",
            body_template: {
                name: "{channel_name}",
                is_private: "{is_private}"
            },
            headers_template: NONE,
            query_params_template: NONE,
            path_params: [],
            authentication_required: true
        },
        response: {
            success_codes: [200, 201],
            data_path: "channel",
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 20,
            period: "minute",
            burst_allowed: false
        }
    },
    documentation = {
        main_url: "https://api.slack.com/methods/conversations.create",
        examples_url: "https://api.slack.com/methods/conversations.create#examples",
        video_tutorial_url: NONE,
        common_use_cases: ["Créer un canal public", "Créer un canal privé"],
        prerequisites: ["Permissions de création de canal"]
    },
    metadata = {
        usage_count: 0,
        average_duration: 1500,
        success_rate: 0.98,
        custom_data: NONE
    },
    resource_id: resource:slack_channel,
    is_active: true;
*/

-- Exemple 2: Créer un tool "Append Row" pour Google Sheets
/*
CREATE tool:google_sheets_append_row SET
    identity = {
        name: "append",
        slug: "google-sheets-append-row",
        display_name_i18n: i18n_key:tool_google_sheets_append_row_name,
        description_i18n: i18n_key:tool_google_sheets_append_row_desc,
        operation_type: "create",
        aliases: ["add", "insert"]
    },
    presentation = {
        icon: icon:plus,
        color: "#34A853",
        display_order: 1,
        tooltip_i18n: i18n_key:tool_google_sheets_append_row_tooltip,
        badge_text: "Popular",
        badge_color: "#4CAF50",
        success_message_i18n: i18n_key:tool_google_sheets_append_row_success,
        error_message_i18n: i18n_key:tool_google_sheets_append_row_error,
        confirmation_required: false,
        confirmation_message_i18n: NONE,
        estimated_duration: 1,
        is_destructive: false
    },
    config = {
        request: {
            method: "POST",
            endpoint: "/v4/spreadsheets/{spreadsheetId}/values/{range}:append",
            body_template: {
                values: "{row_values}"
            },
            headers_template: NONE,
            query_params_template: {
                valueInputOption: "USER_ENTERED"
            },
            path_params: ["spreadsheetId", "range"],
            authentication_required: true
        },
        response: {
            success_codes: [200],
            data_path: "updates",
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: true,
            is_idempotent: false,
            requires_confirmation: false
        },
        rate_limiting: {
            max_requests: 100,
            period: "minute",
            burst_allowed: true
        }
    },
    documentation = {
        main_url: "https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets.values/append",
        examples_url: "https://developers.google.com/sheets/api/guides/values#appending_values",
        video_tutorial_url: NONE,
        common_use_cases: ["Ajouter une ligne de données", "Importer des données"],
        prerequisites: ["Accès en écriture au spreadsheet"]
    },
    metadata = {
        usage_count: 0,
        average_duration: 800,
        success_rate: 0.99,
        custom_data: NONE
    },
    resource_id: resource:google_sheets_sheet,
    is_active: true;
*/

-- Exemple 3: Créer un tool "Delete Issue" pour GitHub (destructive)
/*
CREATE tool:github_issue_delete SET
    identity = {
        name: "delete",
        slug: "github-issue-delete",
        display_name_i18n: i18n_key:tool_github_issue_delete_name,
        description_i18n: i18n_key:tool_github_issue_delete_desc,
        operation_type: "delete",
        aliases: ["remove"]
    },
    presentation = {
        icon: icon:trash,
        color: "#F44336",
        display_order: 99,
        tooltip_i18n: i18n_key:tool_github_issue_delete_tooltip,
        badge_text: "Destructive",
        badge_color: "#F44336",
        success_message_i18n: i18n_key:tool_github_issue_delete_success,
        error_message_i18n: i18n_key:tool_github_issue_delete_error,
        confirmation_required: true,
        confirmation_message_i18n: i18n_key:tool_github_issue_delete_confirm,
        estimated_duration: 1,
        is_destructive: true
    },
    config = {
        request: {
            method: "DELETE",
            endpoint: "/repos/{owner}/{repo}/issues/{issue_number}",
            body_template: NONE,
            headers_template: NONE,
            query_params_template: NONE,
            path_params: ["owner", "repo", "issue_number"],
            authentication_required: true
        },
        response: {
            success_codes: [204],
            data_path: NONE,
            pagination_path: NONE,
            transform: NONE
        },
        capabilities: {
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            supports_batch: false,
            is_idempotent: true,
            requires_confirmation: true
        },
        rate_limiting: {
            max_requests: 60,
            period: "hour",
            burst_allowed: false
        }
    },
    documentation = {
        main_url: "https://docs.github.com/en/rest/issues/issues#delete-an-issue",
        examples_url: NONE,
        video_tutorial_url: NONE,
        common_use_cases: ["Supprimer une issue obsolète"],
        prerequisites: ["Permissions write sur le repository"]
    },
    metadata = {
        usage_count: 0,
        average_duration: 500,
        success_rate: 1.0,
        custom_data: NONE
    },
    resource_id: resource:github_issue,
    is_active: true;
*/

-- Exemple 4: Query pour obtenir tous les tools d'une resource
/*
SELECT * FROM tool
WHERE resource_id = resource:slack_channel AND is_active = true
ORDER BY presentation.display_order ASC;
*/

-- Exemple 5: Query pour obtenir tous les tools de type "create"
/*
SELECT
    identity.name,
    identity.slug,
    identity.display_name_i18n.* AS display_name,
    resource_id.*,
    presentation.color_type,
    config.request.method,
    config.request.endpoint
FROM tool
WHERE identity.operation_type = "create" AND is_active = true;
*/

-- Exemple 6: Query pour obtenir tous les tools destructifs
/*
SELECT
    identity.name,
    resource_id.identity.name AS resource_name,
    presentation.is_destructive,
    presentation.confirmation_required
FROM tool
WHERE presentation.is_destructive = true;
*/

-- =====================================================
-- NOTES TECHNIQUES
-- =====================================================

-- 1. STRUCTURE GROUPÉE:
--    Tous les champs sont organisés en blocs logiques (identity, presentation, config, etc.)
--    pour une meilleure lisibilité et maintenabilité.
--
-- 2. I18N OBLIGATOIRE:
--    5 clés i18n par tool : display_name, description, tooltip, success_message, error_message
--    Permet de supporter le multilinguisme (FR, EN, IT, DE, ES).
--
-- 3. CONFIG.REQUEST:
--    Configuration complète de la requête API avec method, endpoint, body, headers, params.
--    Les variables dans l'endpoint/body sont remplacées dynamiquement par l'UI.
--
-- 4. CONFIG.RESPONSE:
--    Configuration de la réponse API avec success_codes, data_path, pagination_path.
--    Permet à l'UI de parser correctement les réponses.
--
-- 5. CONFIRMATION & IS_DESTRUCTIVE:
--    Les actions destructives (delete, clear, etc.) nécessitent une confirmation utilisateur.
--    L'UI affiche un dialogue de confirmation avant exécution.
--
-- 6. ETAG:
--    Change automatiquement à chaque UPDATE grâce à SurrealDB.
--    Utilisé pour optimistic locking et Live Queries.
--
-- 7. TIMESTAMPS:
--    - created_at : READONLY, défini uniquement à la création
--    - updated_at : READONLY, mis à jour automatiquement à chaque modification
--
-- 8. PERMISSIONS:
--    - SELECT: Tous peuvent voir les tools actifs, admins/editors voient tout
--    - CREATE: Réservé aux admins
--    - UPDATE: Admins et editors
--    - DELETE: Réservé aux admins
--
-- 9. RATE_LIMITING:
--    Limites de taux configurables par tool pour respecter les quotas API.
--    L'UI peut afficher des avertissements si l'utilisateur approche des limites.
--
-- 10. METADATA.USAGE_COUNT / AVERAGE_DURATION / SUCCESS_RATE:
--     Métriques analytics pour suivre l'utilisation et la performance des tools.
--     Mises à jour dynamiquement par le système.

-- =====================================================
-- FIN DE LA DÉFINITION
-- =====================================================
