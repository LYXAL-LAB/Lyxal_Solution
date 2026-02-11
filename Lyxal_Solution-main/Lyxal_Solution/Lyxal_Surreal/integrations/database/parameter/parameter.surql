-- =============================================================================================
-- |
-- | TABLE: parameter
-- | MODULE: integrations
-- | VERSION: 2.0
-- | DATE: 2025-10-30
-- |
-- | DESCRIPTION:
-- | Représente les paramètres d'entrée/sortie d'un tool.
-- | Un paramètre est un champ de formulaire que l'utilisateur doit remplir pour exécuter un tool.
-- |
-- | EXEMPLES:
-- | - Tool "Slack → Create Channel" → Paramètres: name (string), is_private (boolean), description (string)
-- | - Tool "Google Sheets → Append Row" → Paramètres: spreadsheet_id (resourceLocator), sheet_name (resourceLocator), row_values (array)
-- | - Tool "GitHub → Create Issue" → Paramètres: title (string), body (string), labels (multiOptions), assignees (multiOptions)
-- |
-- | ARCHITECTURE:
-- | - Structure groupée pour clarté (identity, presentation, config, validation, metadata)
-- | - i18n_key pour multilinguisme (name, desc, placeholder, help, error)
-- | - icon pour représentation visuelle
-- | - ETag pour optimistic locking et temps réel
-- | - Permissions granulaires pour sécurité
-- | - Validation structurée et enrichie
-- | - Métadonnées UX (is_sensitive, help_text, error_message)
-- |
-- | CONFORMITÉ: 100% Lyxal Standards (Data-First + UI-Driven)
-- |
-- =============================================================================================

-- =====================================================
-- DÉFINITION DE LA TABLE
-- =====================================================

DEFINE TABLE parameter SCHEMAFULL
    COMMENT "Paramètres d'entrée/sortie des tools (ex: name, is_private, spreadsheet_id). Table conforme 100% aux standards Lyxal avec structure groupée, i18n, validation enrichie, ETag et permissions."
    PERMISSIONS
        FOR select WHERE is_active = true OR $auth.role IN ["admin", "editor"]
        FOR create WHERE $auth.role IN ["admin"]
        FOR update WHERE $auth.role IN ["admin", "editor"]
        FOR delete WHERE $auth.role = "admin";

-- =====================================================
-- BLOC: IDENTITY (Identité technique et sémantique)
-- =====================================================

DEFINE FIELD identity ON parameter TYPE object
    COMMENT "Identité du paramètre : noms techniques et affichables"
    ASSERT $value != NONE;

DEFINE FIELD identity.name ON parameter TYPE string
    COMMENT "Nom technique du paramètre (ex: 'name', 'is_private', 'spreadsheet_id')"
    ASSERT $value != NONE AND string::len($value) > 0;

DEFINE FIELD identity.parameter_key ON parameter TYPE string
    COMMENT "Clé unique du paramètre dans le tool (ex: 'channel_name', 'is_private_channel')"
    ASSERT $value != NONE AND string::len($value) > 0;

DEFINE FIELD identity.display_name_i18n ON parameter TYPE record<i18n_key>
    COMMENT "Clé i18n pour le nom affiché dans l'UI (ex: 'Nom du canal', 'Canal privé')"
    ASSERT $value != NONE;

DEFINE FIELD identity.description_i18n ON parameter TYPE option<record<i18n_key>>
    COMMENT "Clé i18n pour la description complète du paramètre";

-- =====================================================
-- BLOC: PRESENTATION (Apparence UI)
-- =====================================================

DEFINE FIELD presentation ON parameter TYPE object
    COMMENT "Configuration de présentation visuelle dans l'UI"
    ASSERT $value != NONE;

DEFINE FIELD presentation.icon ON parameter TYPE option<record<icon>>
    COMMENT "Icône représentant le paramètre (ex: 📝 pour name, 🔒 pour is_private)";

DEFINE FIELD presentation.display_order ON parameter TYPE int DEFAULT 0
    COMMENT "Ordre d'affichage dans le formulaire (0 = premier)";

DEFINE FIELD presentation.placeholder_i18n ON parameter TYPE option<record<i18n_key>>
    COMMENT "Clé i18n pour le texte de placeholder (ex: 'Entrez le nom du canal')";

DEFINE FIELD presentation.help_text_i18n ON parameter TYPE option<record<i18n_key>>
    COMMENT "Clé i18n pour le texte d'aide détaillé (ex: 'Le nom doit être unique et contenir...')";

DEFINE FIELD presentation.error_message_i18n ON parameter TYPE option<record<i18n_key>>
    COMMENT "Clé i18n pour le message d'erreur personnalisé (ex: 'Le nom est invalide')";

DEFINE FIELD presentation.is_sensitive ON parameter TYPE bool DEFAULT false
    COMMENT "True si le champ contient des données sensibles (password, token) → masquer dans l'UI";

DEFINE FIELD presentation.display_conditions ON parameter TYPE option<object>
    COMMENT "Conditions d'affichage du paramètre (ex: afficher seulement si is_private = true)";

-- =====================================================
-- BLOC: CONFIG (Configuration technique)
-- =====================================================

DEFINE FIELD config ON parameter TYPE object
    COMMENT "Configuration technique du paramètre"
    ASSERT $value != NONE;

DEFINE FIELD config.parameter_type ON parameter TYPE string
    COMMENT "Type du paramètre (string, number, boolean, object, array, date, datetime, file, options, multiOptions, resourceLocator, json, hidden)"
    ASSERT $value IN ["string", "number", "boolean", "object", "array", "date", "datetime", "file", "options", "multiOptions", "resourceLocator", "json", "hidden"];

DEFINE FIELD config.sub_type ON parameter TYPE option<string>
    COMMENT "Sous-type pour affiner le type (ex: 'email', 'url', 'phone' pour string)";

DEFINE FIELD config.default_value ON parameter TYPE option<any>
    COMMENT "Valeur par défaut du paramètre (NONE si pas de valeur par défaut)";

DEFINE FIELD config.is_required ON parameter TYPE bool DEFAULT false
    COMMENT "True si le paramètre est obligatoire pour exécuter le tool";

DEFINE FIELD config.options ON parameter TYPE option<array<object>>
    COMMENT "Options disponibles pour les paramètres de type 'options' ou 'multiOptions' (ex: [{name: 'Public', value: 'public'}, {name: 'Private', value: 'private'}])";

DEFINE FIELD config.multiple_values ON parameter TYPE bool DEFAULT false
    COMMENT "True si le paramètre accepte plusieurs valeurs (pour multiOptions, array)";

DEFINE FIELD config.auto_complete ON parameter TYPE bool DEFAULT false
    COMMENT "True si l'autocomplétion est disponible pour ce paramètre";

-- =====================================================
-- BLOC: VALIDATION (Règles de validation)
-- =====================================================

DEFINE FIELD validation ON parameter TYPE option<object>
    COMMENT "Règles de validation pour ce paramètre";

DEFINE FIELD validation.rules ON parameter TYPE option<object>
    COMMENT "Règles de validation génériques (object avec clés personnalisées)";

DEFINE FIELD validation.min_value ON parameter TYPE option<number>
    COMMENT "Valeur minimale pour les nombres (ex: 0, 1, 100)"
    ASSERT $value == NONE OR $value >= 0;

DEFINE FIELD validation.max_value ON parameter TYPE option<number>
    COMMENT "Valeur maximale pour les nombres (ex: 100, 1000, 9999)"
    ASSERT $value == NONE OR $value >= 0;

DEFINE FIELD validation.min_length ON parameter TYPE option<int>
    COMMENT "Longueur minimale pour les strings (ex: 3, 5, 10)"
    ASSERT $value == NONE OR $value >= 0;

DEFINE FIELD validation.max_length ON parameter TYPE option<int>
    COMMENT "Longueur maximale pour les strings (ex: 50, 100, 255)"
    ASSERT $value == NONE OR $value >= 0;

DEFINE FIELD validation.pattern ON parameter TYPE option<string>
    COMMENT "Expression régulière pour valider le format (ex: '^[a-z0-9-]+$' pour un slug)";

DEFINE FIELD validation.required_format ON parameter TYPE option<string>
    COMMENT "Format requis prédéfini (email, url, phone, ip, uuid, etc.)"
    ASSERT $value == NONE OR $value IN ["email", "url", "phone", "ip", "ipv4", "ipv6", "uuid", "slug", "hex", "base64", "jwt"];

DEFINE FIELD validation.custom_validator ON parameter TYPE option<string>
    COMMENT "Fonction JavaScript de validation personnalisée (ex: 'function(value) { return value > 0; }')";

-- =====================================================
-- BLOC: METADATA (Données supplémentaires)
-- =====================================================

DEFINE FIELD metadata ON parameter TYPE option<object>
    COMMENT "Métadonnées additionnelles pour analytics et extensions";

DEFINE FIELD metadata.usage_frequency ON parameter TYPE option<int>
    COMMENT "Fréquence d'utilisation de ce paramètre (nombre de fois utilisé)"
    ASSERT $value == NONE OR $value >= 0;

DEFINE FIELD metadata.common_values ON parameter TYPE option<array<any>>
    COMMENT "Valeurs courantes utilisées pour ce paramètre (pour suggestions)";

DEFINE FIELD metadata.custom_data ON parameter TYPE option<object>
    COMMENT "Données personnalisées spécifiques à l'application";

-- =====================================================
-- BLOC: RELATIONS (Liaisons vers autres tables)
-- =====================================================

DEFINE FIELD tool_id ON parameter TYPE record<tool>
    COMMENT "Tool parent de ce paramètre (ex: parameter 'name' → tool 'Slack Create Channel')"
    ASSERT $value != NONE;

-- =====================================================
-- BLOC: ÉTAT (Status et synchronisation)
-- =====================================================

DEFINE FIELD is_active ON parameter TYPE bool DEFAULT true
    COMMENT "True si le paramètre est activé et affiché dans l'UI";

DEFINE FIELD ETag ON parameter TYPE uuid DEFAULT rand::uuid::v4()
    COMMENT "ETag pour optimistic locking et Live Queries. Change à chaque modification."
    READONLY;

-- =====================================================
-- BLOC: TIMESTAMPS (Audit trail)
-- =====================================================

DEFINE FIELD created_at ON parameter TYPE datetime
    COMMENT "Date de création de l'enregistrement (immuable)"
    VALUE $before OR time::now()
    READONLY;

DEFINE FIELD updated_at ON parameter TYPE datetime
    COMMENT "Date de dernière modification (auto-mise à jour)"
    DEFAULT ALWAYS time::now()
    READONLY;

-- =====================================================
-- INDEX (Performance et contraintes)
-- =====================================================

DEFINE INDEX parameter_key_tool_idx ON parameter FIELDS identity.parameter_key, tool_id UNIQUE
    COMMENT "Index unique sur parameter_key par tool pour garantir l'unicité";

DEFINE INDEX parameter_name_idx ON parameter FIELDS identity.name
    COMMENT "Index sur le nom technique pour recherches rapides";

DEFINE INDEX parameter_tool_idx ON parameter FIELDS tool_id
    COMMENT "Index sur tool_id pour requêtes de type 'tous les paramètres d'un tool'";

DEFINE INDEX parameter_type_idx ON parameter FIELDS config.parameter_type
    COMMENT "Index sur parameter_type pour filtrer par type";

DEFINE INDEX parameter_required_idx ON parameter FIELDS config.is_required
    COMMENT "Index sur is_required pour filtrer les paramètres obligatoires";

DEFINE INDEX parameter_active_idx ON parameter FIELDS is_active
    COMMENT "Index sur is_active pour filtrer rapidement les paramètres actifs";

-- =====================================================
-- EXEMPLES D'UTILISATION
-- =====================================================

-- Exemple 1: Créer un paramètre "name" pour "Slack Create Channel"
/*
CREATE parameter:slack_channel_create_name SET
    identity = {
        name: "name",
        parameter_key: "channel_name",
        display_name_i18n: i18n_key:param_slack_channel_create_name_label,
        description_i18n: i18n_key:param_slack_channel_create_name_desc
    },
    presentation = {
        icon: icon:text,
        display_order: 1,
        placeholder_i18n: i18n_key:param_slack_channel_create_name_placeholder,
        help_text_i18n: i18n_key:param_slack_channel_create_name_help,
        error_message_i18n: i18n_key:param_slack_channel_create_name_error,
        is_sensitive: false,
        display_conditions: NONE
    },
    config = {
        parameter_type: "string",
        sub_type: "slug",
        default_value: NONE,
        is_required: true,
        options: NONE,
        multiple_values: false,
        auto_complete: false
    },
    validation = {
        rules: NONE,
        min_value: NONE,
        max_value: NONE,
        min_length: 1,
        max_length: 80,
        pattern: "^[a-z0-9-_]+$",
        required_format: "slug",
        custom_validator: NONE
    },
    metadata = {
        usage_frequency: 0,
        common_values: ["general", "random", "support"],
        custom_data: NONE
    },
    tool_id: tool:slack_channel_create,
    is_active: true;
*/

-- Exemple 2: Créer un paramètre "is_private" (boolean) pour "Slack Create Channel"
/*
CREATE parameter:slack_channel_create_is_private SET
    identity = {
        name: "is_private",
        parameter_key: "is_private_channel",
        display_name_i18n: i18n_key:param_slack_channel_create_is_private_label,
        description_i18n: i18n_key:param_slack_channel_create_is_private_desc
    },
    presentation = {
        icon: icon:lock,
        display_order: 2,
        placeholder_i18n: NONE,
        help_text_i18n: i18n_key:param_slack_channel_create_is_private_help,
        error_message_i18n: NONE,
        is_sensitive: false,
        display_conditions: NONE
    },
    config = {
        parameter_type: "boolean",
        sub_type: NONE,
        default_value: false,
        is_required: false,
        options: NONE,
        multiple_values: false,
        auto_complete: false
    },
    validation = NONE,
    metadata = {
        usage_frequency: 0,
        common_values: [false, true],
        custom_data: NONE
    },
    tool_id: tool:slack_channel_create,
    is_active: true;
*/

-- Exemple 3: Créer un paramètre "api_key" (string sensible)
/*
CREATE parameter:some_tool_api_key SET
    identity = {
        name: "api_key",
        parameter_key: "user_api_key",
        display_name_i18n: i18n_key:param_api_key_label,
        description_i18n: i18n_key:param_api_key_desc
    },
    presentation = {
        icon: icon:key,
        display_order: 1,
        placeholder_i18n: i18n_key:param_api_key_placeholder,
        help_text_i18n: i18n_key:param_api_key_help,
        error_message_i18n: i18n_key:param_api_key_error,
        is_sensitive: true,
        display_conditions: NONE
    },
    config = {
        parameter_type: "string",
        sub_type: "password",
        default_value: NONE,
        is_required: true,
        options: NONE,
        multiple_values: false,
        auto_complete: false
    },
    validation = {
        rules: NONE,
        min_value: NONE,
        max_value: NONE,
        min_length: 32,
        max_length: 128,
        pattern: NONE,
        required_format: NONE,
        custom_validator: NONE
    },
    metadata = {
        usage_frequency: 0,
        common_values: NONE,
        custom_data: NONE
    },
    tool_id: tool:some_api_tool,
    is_active: true;
*/

-- Exemple 4: Créer un paramètre "status" (options) pour "GitHub Create Issue"
/*
CREATE parameter:github_issue_create_status SET
    identity = {
        name: "status",
        parameter_key: "issue_status",
        display_name_i18n: i18n_key:param_github_issue_create_status_label,
        description_i18n: i18n_key:param_github_issue_create_status_desc
    },
    presentation = {
        icon: icon:status,
        display_order: 5,
        placeholder_i18n: i18n_key:param_github_issue_create_status_placeholder,
        help_text_i18n: NONE,
        error_message_i18n: NONE,
        is_sensitive: false,
        display_conditions: NONE
    },
    config = {
        parameter_type: "options",
        sub_type: NONE,
        default_value: "open",
        is_required: true,
        options: [
            {name: "Open", value: "open"},
            {name: "Closed", value: "closed"},
            {name: "In Progress", value: "in_progress"}
        ],
        multiple_values: false,
        auto_complete: false
    },
    validation = NONE,
    metadata = {
        usage_frequency: 0,
        common_values: ["open", "in_progress"],
        custom_data: NONE
    },
    tool_id: tool:github_issue_create,
    is_active: true;
*/

-- Exemple 5: Query pour obtenir tous les paramètres d'un tool
/*
SELECT * FROM parameter
WHERE tool_id = tool:slack_channel_create AND is_active = true
ORDER BY presentation.display_order ASC;
*/

-- Exemple 6: Query pour obtenir tous les paramètres obligatoires
/*
SELECT
    identity.name,
    identity.parameter_key,
    identity.display_name_i18n.* AS display_name,
    config.parameter_type,
    tool_id.identity.name AS tool_name
FROM parameter
WHERE config.is_required = true AND is_active = true;
*/

-- Exemple 7: Query pour obtenir tous les paramètres sensibles
/*
SELECT
    identity.name,
    tool_id.identity.name AS tool_name,
    presentation.is_sensitive
FROM parameter
WHERE presentation.is_sensitive = true;
*/

-- =====================================================
-- NOTES TECHNIQUES
-- =====================================================

-- 1. STRUCTURE GROUPÉE:
--    Tous les champs sont organisés en blocs logiques (identity, presentation, config, etc.)
--    pour une meilleure lisibilité et maintenabilité.
--
-- 2. I18N OBLIGATOIRE:
--    4 clés i18n par parameter : display_name, description, placeholder, help_text, error_message
--    Permet de supporter le multilinguisme (FR, EN, IT, DE, ES).
--
-- 3. PARAMETER_TYPE:
--    Types supportés : string, number, boolean, object, array, date, datetime, file,
--    options, multiOptions, resourceLocator, json, hidden.
--
-- 4. IS_SENSITIVE:
--    Pour les champs sensibles (passwords, tokens), l'UI masque automatiquement la valeur.
--
-- 5. VALIDATION ENRICHIE:
--    - min_value / max_value : Pour les nombres
--    - min_length / max_length : Pour les strings
--    - pattern : Regex pour format personnalisé
--    - required_format : Formats prédéfinis (email, url, phone, etc.)
--    - custom_validator : Fonction JS pour validation complexe
--
-- 6. OPTIONS:
--    Pour les paramètres de type "options" ou "multiOptions", définir les choix disponibles
--    dans config.options : [{name: "Option 1", value: "option1"}, ...]
--
-- 7. DISPLAY_CONDITIONS:
--    Permet d'afficher conditionnellement un paramètre (ex: afficher seulement si un autre paramètre = valeur)
--    Format : {field: "is_private", operator: "equals", value: true}
--
-- 8. ETAG:
--    Change automatiquement à chaque UPDATE grâce à SurrealDB.
--    Utilisé pour optimistic locking et Live Queries.
--
-- 9. TIMESTAMPS:
--    - created_at : READONLY, défini uniquement à la création
--    - updated_at : READONLY, mis à jour automatiquement à chaque modification
--
-- 10. PERMISSIONS:
--     - SELECT: Tous peuvent voir les paramètres actifs, admins/editors voient tout
--     - CREATE: Réservé aux admins
--     - UPDATE: Admins et editors
--     - DELETE: Réservé aux admins
--
-- 11. AUTO_COMPLETE:
--     Si true, l'UI peut proposer des suggestions basées sur metadata.common_values
--     ou des valeurs précédemment utilisées.
--
-- 12. USAGE_FREQUENCY:
--     Métrique analytics pour identifier les paramètres les plus utilisés.
--     Peut être utilisé pour optimiser l'UX (afficher en premier les plus utilisés).

-- =====================================================
-- FIN DE LA DÉFINITION
-- =====================================================

