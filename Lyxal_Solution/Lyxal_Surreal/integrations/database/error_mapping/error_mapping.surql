-- ============================================================================
-- TABLE: error_mapping
-- Description: Mapping des codes d'erreur HTTP/API vers des messages utilisateur
-- Version: 1.0.0
-- Auteur: Lyxal Team
-- Date: 2025-01-30
-- ============================================================================

-- ==================================================
-- DÉFINITION DE LA TABLE
-- ==================================================

DEFINE TABLE IF NOT EXISTS error_mapping TYPE NORMAL SCHEMAFULL
COMMENT 'Mappe les codes d\'erreur HTTP/API vers des messages utilisateur internationalisés et actions suggérées.';

-- ==================================================
-- PERMISSIONS
-- ==================================================

PERMISSIONS
    FOR SELECT FULL
    FOR CREATE, UPDATE, DELETE WHERE $auth.permissions = 'lyxal_admin';

-- ==================================================
-- GROUPE: IDENTITY
-- Identification unique et classification de l'erreur
-- ==================================================

DEFINE FIELD IF NOT EXISTS identity ON error_mapping 
    TYPE object
    COMMENT 'Identification et classification de l\'erreur';

DEFINE FIELD IF NOT EXISTS identity.http_code ON error_mapping 
    TYPE int
    ASSERT $value >= 100 AND $value <= 599 
    COMMENT 'Code HTTP (400, 401, 403, 404, 429, 500, etc.)';

DEFINE FIELD IF NOT EXISTS identity.error_code ON error_mapping 
    TYPE option<string>
    COMMENT 'Code d\'erreur spécifique à l\'API (ex: INVALID_TOKEN, RATE_LIMIT_EXCEEDED)';

DEFINE FIELD IF NOT EXISTS identity.error_category ON error_mapping
    TYPE string
    ASSERT $value IN ['auth', 'validation', 'rate_limit', 'not_found', 'server', 'network', 'permission', 'conflict', 'other']
    DEFAULT 'other'
    COMMENT 'Catégorie d\'erreur: auth, validation, rate_limit, not_found, server, network, permission';

DEFINE FIELD IF NOT EXISTS identity.service_id ON error_mapping 
    TYPE option<record<service>>
    REFERENCE ON DELETE REJECT
    VALUE { IF $value != NONE { type::record('service',$value)} ELSE {NONE }}
    COMMENT 'Service spécifique (NONE = erreur générique pour tous les services)';

DEFINE FIELD IF NOT EXISTS identity.tool_id ON error_mapping 
    TYPE option<record<tool>>
    REFERENCE ON DELETE REJECT
    VALUE { IF $value != NONE { type::record('tool',$value)} ELSE {NONE }}
    COMMENT 'Outil spécifique (NONE = erreur pour tout le service)';
-- ==================================================
-- GROUPE: PRESENTATION
-- Messages et présentation UI
-- ==================================================

DEFINE FIELD IF NOT EXISTS presentation ON error_mapping 
    TYPE object
    COMMENT 'Présentation de l\'erreur dans l\'UI';

DEFINE FIELD IF NOT EXISTS presentation.user_message_i18n ON error_mapping 
    TYPE record<i18n_key>
    REFERENCE ON DELETE REJECT
    VALUE {IF $value !=NONE {type::record('i18n_key',$value)} ELSE {NONE }}
    COMMENT 'Message affiché à l\'utilisateur (internationalisé)';

DEFINE FIELD IF NOT EXISTS presentation.technical_message_i18n ON error_mapping 
    TYPE option<record<i18n_key>>
    REFERENCE ON DELETE REJECT
    VALUE {IF $value !=NONE {type::record('i18n_key',$value)} ELSE {NONE }}
    COMMENT 'Message technique pour les développeurs/logs (internationalisé)';

DEFINE FIELD IF NOT EXISTS presentation.severity ON error_mapping 
    TYPE record<error_severity>
    REFERENCE ON DELETE REJECT
    VALUE type::record('error_severity',$value)
    DEFAULT type::record('error_severity',error_severity:error)
    COMMENT 'Niveau de gravité de l\'erreur';

DEFINE FIELD IF NOT EXISTS presentation.icon ON error_mapping 
    TYPE option<record<icon>>
    REFERENCE ON DELETE REJECT
    VALUE {IF $value !=NONE {type::record('icon',$value)} ELSE {NONE }}
    COMMENT 'Icône à afficher (ex: alert-circle, lock, server)';

DEFINE FIELD IF NOT EXISTS presentation.color_type ON error_mapping 
    TYPE option<record<theme_color_type>>
    REFERENCE ON DELETE REJECT
    COMMENT 'Type de couleur pour les tags/badges dans l\'UI (référence vers theme_color_type: primary, error, warning, etc.).';

-- ==================================================
-- GROUPE: CONFIG
-- Configuration du comportement
-- ==================================================

DEFINE FIELD config ON error_mapping 
    TYPE object
    COMMENT 'Configuration du traitement de l\'erreur';

DEFINE FIELD config.is_retryable ON error_mapping 
    TYPE bool
    DEFAULT false
    COMMENT 'Si l\'opération peut être réessayée automatiquement';

DEFINE FIELD IF NOT EXISTS config.retry_after_seconds ON error_mapping 
    TYPE option<int>
    ASSERT $value == NONE OR $value > 0
    COMMENT 'Délai en secondes avant de réessayer (pour 429 Rate Limit)';

DEFINE FIELD IF NOT EXISTS config.max_retries ON error_mapping 
    TYPE int
    ASSERT $value >= 0
    DEFAULT 0
    COMMENT 'Nombre maximum de tentatives automatiques';

DEFINE FIELD IF NOT EXISTS config.backoff_strategy ON error_mapping 
    TYPE option<string>
    ASSERT $value == NONE OR $value IN ['none', 'linear', 'exponential']
    COMMENT 'Stratégie de backoff: none, linear, exponential';

DEFINE FIELD IF NOT EXISTS config.should_log ON error_mapping 
    TYPE bool
    DEFAULT true
    COMMENT 'Si l\'erreur doit être loggée côté serveur';

DEFINE FIELD IF NOT EXISTS config.should_notify_admin ON error_mapping 
    TYPE bool
    DEFAULT false
    COMMENT 'Si l\'erreur nécessite une notification admin';

-- ==================================================
-- GROUPE: SUGGESTED_ACTION
-- Actions suggérées à l'utilisateur
-- ==================================================

DEFINE FIELD IF NOT EXISTS suggested_action ON error_mapping 
    TYPE object
    COMMENT 'Actions suggérées pour résoudre l\'erreur';

DEFINE FIELD IF NOT EXISTS suggested_action.action_message_i18n ON error_mapping 
    TYPE option<record<i18n_key>>
    REFERENCE ON DELETE REJECT
    VALUE {IF $value !=NONE {type::record('i18n_key',$value)} ELSE {NONE }}
    COMMENT 'Message décrivant l\'action à faire 
    (ex: "Veuillez vérifier vos identifiants")';

DEFINE FIELD IF NOT EXISTS suggested_action.action_type ON error_mapping 
    TYPE option<string>
    ASSERT $value == NONE OR $value IN ['refresh_token', 'check_credentials', 'contact_support', 'retry_later', 'check_input', 'upgrade_plan', 'check_permissions']
    COMMENT 'Type d\'action: refresh_token, check_credentials, contact_support, retry_later, check_input, upgrade_plan, check_permissions';

DEFINE FIELD IF NOT EXISTS suggested_action.help_url ON error_mapping 
    TYPE option<record<url>>
    REFERENCE ON DELETE REJECT
    VALUE {IF $value !=NONE {type::record('url',$value)} ELSE {NONE }}
    COMMENT 'URL vers la documentation d\'aide';

DEFINE FIELD IF NOT EXISTS suggested_action.support_contact ON error_mapping 
    TYPE option<record<email>>
    REFERENCE ON DELETE REJECT
    VALUE {IF $value !=NONE {type::record('email',$value)} ELSE {NONE }}
    COMMENT 'Contact du support (email ou URL)';

-- ==================================================
-- GROUPE: DOCUMENTATION
-- Documentation et exemples
-- ==================================================

DEFINE FIELD IF NOT EXISTS documentation ON error_mapping 
    TYPE option<object>
    COMMENT 'Documentation sur l\'erreur';

DEFINE FIELD IF NOT EXISTS documentation.description_i18n ON error_mapping.documentation 
    TYPE option<record<i18n_key>>
    REFERENCE ON DELETE REJECT
    VALUE {IF $value !=NONE {type::record('i18n_key',$value)} ELSE {NONE }}
    COMMENT 'Description détaillée de l\'erreur';

DEFINE FIELD IF NOT EXISTS documentation.common_causes ON error_mapping.documentation 
    TYPE option<array<string>>
    COMMENT 'Causes communes de cette erreur';

DEFINE FIELD IF NOT EXISTS documentation.example_request ON error_mapping.documentation 
    TYPE option<string>
    COMMENT 'Exemple de requête qui a provoqué l\'erreur';

DEFINE FIELD IF NOT EXISTS documentation.example_response ON error_mapping.documentation 
    TYPE option<string>
    COMMENT 'Exemple de réponse d\'erreur de l\'API';

-- ==================================================
-- GROUPE: METADATA
-- Métadonnées système
-- ==================================================

DEFINE FIELD IF NOT EXISTS metadata ON error_mapping 
    TYPE object
    COMMENT 'Métadonnées système et versioning';

DEFINE FIELD IF NOT EXISTS metadata.created_at ON error_mapping 
    TYPE datetime
    READONLY
    DEFAULT time::now()
    COMMENT 'Date de création';

DEFINE FIELD IF NOT EXISTS metadata.updated_at ON error_mapping 
    TYPE datetime
    READONLY
    DEFAULT ALWAYS time::now()
    COMMENT 'Date de dernière modification';

DEFINE FIELD IF NOT EXISTS metadata.created_by ON error_mapping 
    TYPE option<record<user>>
    REFERENCE ON DELETE REJECT
    VALUE {IF $value !=NONE {type::record('user',$value)} ELSE {NONE }}
    COMMENT 'Utilisateur ayant créé l\'enregistrement';

DEFINE FIELD IF NOT EXISTS metadata.updated_by ON error_mapping 
    TYPE option<record<user>>
    REFERENCE ON DELETE REJECT
    VALUE {IF $value !=NONE {type::record('user',$value)} ELSE {NONE }}
    COMMENT 'Utilisateur ayant modifié l\'enregistrement';

DEFINE FIELD IF NOT EXISTS metadata.version ON error_mapping 
    TYPE int
    ASSERT $value > 0
    DEFAULT 1
    COMMENT 'Version de l\'enregistrement';

-- ==================================================
-- CHAMPS: ACTIVATION
-- ==================================================

DEFINE FIELD IF NOT EXISTS is_active ON error_mapping 
    TYPE bool
    DEFAULT true
    COMMENT 'Si le mapping est actif';

-- ==================================================
-- INDEX
-- ==================================================

DEFINE INDEX IF NOT EXISTS idx_error_mapping_http_code ON error_mapping 
    FIELDS identity.http_code UNIQUE
    COMMENT 'Index unique sur code HTTP';

DEFINE INDEX IF NOT EXISTS idx_error_mapping_category ON error_mapping 
    FIELDS identity.error_category
    COMMENT 'Index sur catégorie d\'erreur';

DEFINE INDEX IF NOT EXISTS idx_error_mapping_service ON error_mapping 
    FIELDS identity.service_id
    COMMENT 'Index sur service';

DEFINE INDEX IF NOT EXISTS idx_error_mapping_tool ON error_mapping 
    FIELDS identity.tool_id
    COMMENT 'Index sur outil';

DEFINE INDEX IF NOT EXISTS idx_error_mapping_active ON error_mapping 
    FIELDS is_active
    COMMENT 'Index sur statut actif/inactif';

-- Recherche par service ET code HTTP
DEFINE INDEX IF NOT EXISTS idx_error_mapping_service_code ON error_mapping 
    FIELDS identity.service_id, identity.http_code
    COMMENT 'Index sur service et code HTTP';

-- ==================================================
-- COMMENTAIRES FINAUX
-- ==================================================

-- Relations:
-- • error_mapping → service (N:1 optionnel, pour erreurs spécifiques à un service)
-- • error_mapping → tool (N:1 optionnel, pour erreurs spécifiques à un outil)
-- • error_mapping → i18n_key (N:1, pour messages utilisateur/technique/actions)

-- Exemples d'utilisation:
-- 1. Erreur générique 401:
--    { http_code: 401, service_id: NONE, tool_id: NONE, ... }
-- 2. Erreur spécifique Slack rate limit:
--    { http_code: 429, service_id: service:slack, error_code: 'rate_limited', ... }
-- 3. Erreur spécifique outil:
--    { http_code: 400, tool_id: tool:slack_channel_create, error_code: 'INVALID_CHANNEL_NAME', ... }

-- Catégories d'erreurs:
-- • auth: Erreurs d'authentification/autorisation (401, 403)
-- • validation: Erreurs de validation d'entrée (400)
-- • rate_limit: Dépassement de limite de taux (429)
-- • not_found: Ressource introuvable (404)
-- • server: Erreurs serveur (500, 502, 503)
-- • network: Erreurs réseau (timeout, connection refused)
-- • permission: Permissions insuffisantes (403 avec contexte)
-- • conflict: Conflit de données (409)
-- • other: Autres erreurs

-- ============================================================================
-- FIN DU FICHIER error_mapping.surql
-- ============================================================================

