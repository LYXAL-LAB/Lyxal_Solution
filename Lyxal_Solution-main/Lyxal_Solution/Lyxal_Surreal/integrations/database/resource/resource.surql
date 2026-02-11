-- =============================================================================================
-- |
-- | TABLE: resource
-- | MODULE: integrations
-- | VERSION: 2.0
-- | DATE: 2025-10-29
-- |
-- | DESCRIPTION:
-- | Représente les ressources manipulées par un service.
-- | Une ressource est un objet/entité sur lequel on peut effectuer des opérations.
-- |
-- | EXEMPLES:
-- | - Service "Slack" → Ressources: Channel, Message, File, User, Reaction
-- | - Service "Google Sheets" → Ressources: Spreadsheet, Sheet, Row, Cell, Range
-- | - Service "GitHub" → Ressources: Issue, Repository, Pull Request, Comment
-- |
-- | ARCHITECTURE:
-- | - Structure groupée pour clarté (identity, presentation, config, documentation, metadata)
-- | - i18n_key pour multilinguisme (display_name, description, tooltip)
-- | - icon pour représentation visuelle
-- | - ETag pour optimistic locking et temps réel
-- | - Permissions granulaires pour sécurité
-- |
-- | CONFORMITÉ: 100% Lyxal Standards (Data-First + UI-Driven)
-- |
-- =============================================================================================

-- =====================================================
-- DÉFINITION DE LA TABLE
-- =====================================================

DEFINE TABLE resource SCHEMAFULL
    COMMENT "Ressources manipulées par les services (ex: Channel pour Slack, Sheet pour Google Sheets). Table conforme 100% aux standards Lyxal avec structure groupée, i18n, ETag et permissions."
    PERMISSIONS
        FOR select WHERE is_active = true OR $auth.role IN ["admin", "editor"]
        FOR create WHERE $auth.role IN ["admin"]
        FOR update WHERE $auth.role IN ["admin", "editor"]
        FOR delete WHERE $auth.role = "admin";

-- =====================================================
-- BLOC: IDENTITY (Identité technique et sémantique)
-- =====================================================

DEFINE FIELD identity ON resource TYPE object
    COMMENT "Identité de la ressource : noms techniques et affichables"
    ASSERT $value != NONE;

DEFINE FIELD identity.name ON resource TYPE string
    COMMENT "Nom technique de la ressource (ex: 'channel', 'message', 'spreadsheet')"
    ASSERT $value != NONE AND string::len($value) > 0;

DEFINE FIELD identity.slug ON resource TYPE string
    COMMENT "Slug unique pour URLs et identification (ex: 'slack-channel', 'sheets-spreadsheet')"
    ASSERT $value != NONE AND string::len($value) > 0 AND string::lowercase($value) == $value;

DEFINE FIELD identity.display_name_i18n ON resource TYPE record<i18n_key>
    COMMENT "Clé i18n pour le nom affiché dans l'UI (ex: 'Canal', 'Feuille de calcul')"
    ASSERT $value != NONE;

DEFINE FIELD identity.description_i18n ON resource TYPE option<record<i18n_key>>
    COMMENT "Clé i18n pour la description complète de la ressource";

DEFINE FIELD identity.aliases ON resource TYPE array<string> DEFAULT []
    COMMENT "Alias de recherche (ex: ['chan', 'room'] pour Channel)";

-- =====================================================
-- BLOC: PRESENTATION (Apparence UI)
-- =====================================================

DEFINE FIELD presentation ON resource TYPE object
    COMMENT "Configuration de présentation visuelle dans l'UI"
    ASSERT $value != NONE;

DEFINE FIELD presentation.icon ON resource TYPE option<record<icon>>
    COMMENT "Icône représentant la ressource (ex: 🔔 pour notification, 📄 pour document)";

DEFINE FIELD presentation.color_type ON resource TYPE option<record<theme_color_type>>
    COMMENT "Type de couleur pour les tags/badges dans l'UI (référence vers theme_color_type: primary, error, warning, etc.)"
    REFERENCE ON DELETE REJECT;

DEFINE FIELD presentation.display_order ON resource TYPE int DEFAULT 0
    COMMENT "Ordre d'affichage dans les listes (0 = plus haut)";

DEFINE FIELD presentation.tooltip_i18n ON resource TYPE option<record<i18n_key>>
    COMMENT "Clé i18n pour l'infobulle (conseil rapide affiché au survol)";

DEFINE FIELD presentation.badge_text ON resource TYPE option<string>
    COMMENT "Texte du badge affiché (ex: 'Core', 'Required', 'Advanced')"
    ASSERT $value == NONE OR string::len($value) <= 20;

DEFINE FIELD presentation.badge_color ON resource TYPE option<string>
    COMMENT "Couleur du badge (ex: '#4CAF50' pour 'Core', '#FF9800' pour 'Advanced')"
    ASSERT $value == NONE OR string::starts_with($value, '#');

-- =====================================================
-- BLOC: CONFIG (Configuration technique)
-- =====================================================

DEFINE FIELD config ON resource TYPE object
    COMMENT "Configuration technique et capacités de la ressource"
    ASSERT $value != NONE;

-- Operation Types ────────────────────────────────────

DEFINE FIELD config.operation_types ON resource TYPE object
    COMMENT "Types d'opérations supportées par cette ressource"
    ASSERT $value != NONE;

DEFINE FIELD config.operation_types.supports_create ON resource TYPE bool DEFAULT true
    COMMENT "True si la ressource peut être créée (POST)";

DEFINE FIELD config.operation_types.supports_read ON resource TYPE bool DEFAULT true
    COMMENT "True si la ressource peut être lue (GET)";

DEFINE FIELD config.operation_types.supports_update ON resource TYPE bool DEFAULT true
    COMMENT "True si la ressource peut être modifiée (PUT/PATCH)";

DEFINE FIELD config.operation_types.supports_delete ON resource TYPE bool DEFAULT false
    COMMENT "True si la ressource peut être supprimée (DELETE)";

DEFINE FIELD config.operation_types.supports_list ON resource TYPE bool DEFAULT true
    COMMENT "True si on peut lister les ressources (GET collection)";

DEFINE FIELD config.operation_types.supports_search ON resource TYPE bool DEFAULT false
    COMMENT "True si la ressource supporte la recherche avancée";

-- Capabilities ────────────────────────────────────────

DEFINE FIELD config.capabilities ON resource TYPE object
    COMMENT "Capacités et fonctionnalités avancées"
    ASSERT $value != NONE;

DEFINE FIELD config.capabilities.supports_bulk_operations ON resource TYPE bool DEFAULT false
    COMMENT "True si les opérations par lot sont supportées";

DEFINE FIELD config.capabilities.supports_pagination ON resource TYPE bool DEFAULT true
    COMMENT "True si la pagination est supportée pour les listes";

DEFINE FIELD config.capabilities.supports_filtering ON resource TYPE bool DEFAULT false
    COMMENT "True si le filtrage des résultats est supporté";

DEFINE FIELD config.capabilities.supports_sorting ON resource TYPE bool DEFAULT false
    COMMENT "True si le tri des résultats est supporté";

DEFINE FIELD config.capabilities.requires_authentication ON resource TYPE bool DEFAULT true
    COMMENT "True si l'authentification est requise pour accéder à cette ressource";

DEFINE FIELD config.capabilities.is_real_time ON resource TYPE bool DEFAULT false
    COMMENT "True si la ressource supporte les mises à jour en temps réel (websocket, etc.)";

-- API ──────────────────────────────────────────────────

DEFINE FIELD config.api ON resource TYPE option<object>
    COMMENT "Configuration de l'API pour cette ressource";

DEFINE FIELD config.api.base_path ON resource TYPE option<string>
    COMMENT "Chemin de base de l'API (ex: '/channels', '/spreadsheets')"
    ASSERT $value == NONE OR string::starts_with($value, '/');

DEFINE FIELD config.api.id_field ON resource TYPE option<string>
    COMMENT "Nom du champ identifiant (ex: 'channel_id', 'spreadsheet_id')";

DEFINE FIELD config.api.list_endpoint ON resource TYPE option<string>
    COMMENT "Endpoint pour lister les ressources (ex: '/channels/list')";

-- =====================================================
-- BLOC: DOCUMENTATION (Ressources externes)
-- =====================================================

DEFINE FIELD documentation ON resource TYPE option<object>
    COMMENT "URLs de documentation et ressources d'apprentissage";

DEFINE FIELD documentation.main_url ON resource TYPE option<string>
    COMMENT "URL principale de la documentation de la ressource"
    ASSERT $value == NONE OR (string::starts_with($value, 'http://') OR string::starts_with($value, 'https://'));

DEFINE FIELD documentation.examples_url ON resource TYPE option<string>
    COMMENT "URL vers des exemples d'utilisation"
    ASSERT $value == NONE OR (string::starts_with($value, 'http://') OR string::starts_with($value, 'https://'));

DEFINE FIELD documentation.video_tutorial_url ON resource TYPE option<string>
    COMMENT "URL d'une vidéo de démonstration"
    ASSERT $value == NONE OR (string::starts_with($value, 'http://') OR string::starts_with($value, 'https://'));

DEFINE FIELD documentation.common_use_cases ON resource TYPE array<string> DEFAULT []
    COMMENT "Liste des cas d'usage courants (ex: ['Créer un canal', 'Archiver un canal'])";

-- =====================================================
-- BLOC: METADATA (Données supplémentaires)
-- =====================================================

DEFINE FIELD metadata ON resource TYPE option<object>
    COMMENT "Métadonnées additionnelles pour analytics et extensions";

DEFINE FIELD metadata.common_fields ON resource TYPE option<array<object>>
    COMMENT "Champs fréquemment utilisés de cette ressource (ex: [{name: 'name', type: 'string', required: true}])";

DEFINE FIELD metadata.relationships ON resource TYPE array<string> DEFAULT []
    COMMENT "Relations avec d'autres ressources (ex: ['channel has many messages'])";

DEFINE FIELD metadata.popularity_score ON resource TYPE option<int>
    COMMENT "Score de popularité d'utilisation"
    ASSERT $value == NONE OR ($value >= 0 AND $value <= 100);

DEFINE FIELD metadata.custom_data ON resource TYPE option<object>
    COMMENT "Données personnalisées spécifiques à l'application";

-- =====================================================
-- BLOC: RELATIONS (Liaisons vers autres tables)
-- =====================================================

DEFINE FIELD service_id ON resource TYPE record<service>
    COMMENT "Service parent de cette ressource (ex: resource 'Channel' → service 'Slack')"
    ASSERT $value != NONE;

-- =====================================================
-- BLOC: ÉTAT (Status et synchronisation)
-- =====================================================

DEFINE FIELD is_active ON resource TYPE bool DEFAULT true
    COMMENT "True si la ressource est activée et disponible dans l'UI";

DEFINE FIELD ETag ON resource TYPE uuid DEFAULT rand::uuid::v4()
    COMMENT "ETag pour optimistic locking et Live Queries. Change à chaque modification."
    READONLY;

-- =====================================================
-- BLOC: TIMESTAMPS (Audit trail)
-- =====================================================

DEFINE FIELD created_at ON resource TYPE datetime
    COMMENT "Date de création de l'enregistrement (immuable)"
    VALUE $before OR time::now()
    READONLY;

DEFINE FIELD updated_at ON resource TYPE datetime
    COMMENT "Date de dernière modification (auto-mise à jour)"
    DEFAULT ALWAYS time::now()
    READONLY;

-- =====================================================
-- INDEX (Performance et contraintes)
-- =====================================================

DEFINE INDEX resource_slug_service_idx ON resource FIELDS identity.slug, service_id UNIQUE
    COMMENT "Index unique sur le slug par service pour garantir l'unicité";

DEFINE INDEX resource_name_idx ON resource FIELDS identity.name
    COMMENT "Index sur le nom technique pour recherches rapides";

DEFINE INDEX resource_service_idx ON resource FIELDS service_id
    COMMENT "Index sur service_id pour requêtes de type 'toutes les ressources d'un service'";

DEFINE INDEX resource_active_idx ON resource FIELDS is_active
    COMMENT "Index sur is_active pour filtrer rapidement les ressources actives";

-- =====================================================
-- EXEMPLES D'UTILISATION
-- =====================================================

-- Exemple 1: Créer une ressource "Channel" pour Slack
/*
CREATE resource:slack_channel SET
    identity = {
        name: "channel",
        slug: "slack-channel",
        display_name_i18n: i18n_key:resource_slack_channel_name,
        description_i18n: i18n_key:resource_slack_channel_desc,
        aliases: ["chan", "room", "canal"]
    },
    presentation = {
        icon: icon:channel,
        color: "#4A154B",
        display_order: 1,
        tooltip_i18n: i18n_key:resource_slack_channel_tooltip,
        badge_text: "Core",
        badge_color: "#4CAF50"
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: true
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: true,
            supports_sorting: true,
            requires_authentication: true,
            is_real_time: true
        },
        api: {
            base_path: "/conversations",
            id_field: "channel_id",
            list_endpoint: "/conversations.list"
        }
    },
    documentation = {
        main_url: "https://api.slack.com/methods#conversations",
        examples_url: "https://api.slack.com/methods/conversations.create",
        video_tutorial_url: NONE,
        common_use_cases: ["Créer un canal", "Lister les canaux", "Archiver un canal"]
    },
    metadata = {
        common_fields: [
            {name: "id", type: "string", required: true},
            {name: "name", type: "string", required: true},
            {name: "is_private", type: "boolean", required: false}
        ],
        relationships: ["channel has many messages", "channel has many members"],
        popularity_score: 95,
        custom_data: NONE
    },
    service_id: service:slack,
    is_active: true;
*/

-- Exemple 2: Créer une ressource "Sheet" pour Google Sheets
/*
CREATE resource:google_sheets_sheet SET
    identity = {
        name: "sheet",
        slug: "google-sheets-sheet",
        display_name_i18n: i18n_key:resource_google_sheets_sheet_name,
        description_i18n: i18n_key:resource_google_sheets_sheet_desc,
        aliases: ["worksheet", "tab", "feuille"]
    },
    presentation = {
        icon: icon:spreadsheet,
        color: "#34A853",
        display_order: 2,
        tooltip_i18n: i18n_key:resource_google_sheets_sheet_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: true,
            supports_list: true,
            supports_search: false
        },
        capabilities: {
            supports_bulk_operations: true,
            supports_pagination: false,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: "/v4/spreadsheets",
            id_field: "sheet_id",
            list_endpoint: NONE
        }
    },
    documentation = {
        main_url: "https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/sheets",
        examples_url: "https://developers.google.com/sheets/api/guides/create",
        video_tutorial_url: NONE,
        common_use_cases: ["Ajouter une feuille", "Lire les données", "Mettre à jour des cellules"]
    },
    metadata = {
        common_fields: [
            {name: "sheetId", type: "number", required: true},
            {name: "title", type: "string", required: true},
            {name: "index", type: "number", required: false}
        ],
        relationships: ["sheet belongs to spreadsheet", "sheet has many rows"],
        popularity_score: 90,
        custom_data: NONE
    },
    service_id: service:google_sheets,
    is_active: true;
*/

-- Exemple 3: Query pour obtenir toutes les ressources d'un service
/*
SELECT * FROM resource
WHERE service_id = service:slack AND is_active = true
ORDER BY presentation.display_order ASC;
*/

-- Exemple 4: Query avec JOIN pour obtenir resource + service + i18n
/*
SELECT
    identity.name,
    identity.slug,
    identity.display_name_i18n.* AS display_name,
    service_id.identity.display_name_i18n.* AS service_name,
    config.operation_types.*,
    config.capabilities.*
FROM resource
WHERE is_active = true;
*/

-- =====================================================
-- NOTES TECHNIQUES
-- =====================================================

-- 1. STRUCTURE GROUPÉE:
--    Tous les champs sont organisés en blocs logiques (identity, presentation, config, etc.)
--    pour une meilleure lisibilité et maintenabilité.
--
-- 2. I18N OBLIGATOIRE:
--    display_name_i18n et description_i18n utilisent i18n_key pour supporter
--    le multilinguisme (FR, EN, IT, DE, ES).
--
-- 3. ICON:
--    presentation.icon utilise record<icon> pour centraliser la gestion
--    des icônes.
--
-- 4. ETAG:
--    Change automatiquement à chaque UPDATE grâce à SurrealDB.
--    Utilisé pour optimistic locking et Live Queries.
--
-- 5. TIMESTAMPS:
--    - created_at : READONLY, défini uniquement à la création
--    - updated_at : READONLY, mis à jour automatiquement à chaque modification
--
-- 6. PERMISSIONS:
--    - SELECT: Tous peuvent voir les ressources actives, admins/editors voient tout
--    - CREATE: Réservé aux admins
--    - UPDATE: Admins et editors
--    - DELETE: Réservé aux admins
--
-- 7. CONFIG.OPERATION_TYPES:
--    Définit quelles opérations CRUD sont possibles sur cette ressource.
--    Utilisé par l'UI pour afficher/masquer les actions correspondantes.
--
-- 8. CONFIG.CAPABILITIES:
--    Définit les capacités avancées (bulk, pagination, filtering, etc.).
--    Permet à l'UI de s'adapter dynamiquement aux possibilités de la ressource.
--
-- 9. SLUG UNIQUE PAR SERVICE:
--    Le slug doit être unique au sein d'un service, mais peut être dupliqué
--    entre services différents (ex: "message" pour Slack ET Discord).

-- =====================================================
-- FIN DE LA DÉFINITION
-- =====================================================

