-- =============================================================================================
-- |
-- | Fichier : uses_credential.surql
-- | Module : integrations > database > credentials
-- | Description : Relation entre service et credential_type.
-- |
-- | Cette relation (edge) définit quels types de credentials un service peut utiliser
-- | pour s'authentifier auprès de son API.
-- |
-- | Exemples de relations:
-- | • service:google_sheets → credential_type:google_sheets_oauth2 (recommandé)
-- | • service:google_sheets → credential_type:google_service_account (avancé)
-- | • service:slack → credential_type:slack_oauth2
-- | • service:stripe → credential_type:stripe_api
-- |
-- | Architecture:
-- | • Champs de RELATION : in (service), out (credential_type), is_required
-- | • Champs GROUPÉS : presentation, config, documentation
-- |
-- | Tables référencées:
-- | • service : Services des providers (ex: Google Sheets, Slack Messages)
-- | • credential_type : Types d'authentification disponibles
-- | • i18n_key : Clés de traduction pour l'internationalisation
-- | • url : URLs normalisées pour la documentation
-- |
-- | Fonctionnalités temps réel:
-- | • ETag automatique (UUID v7) pour détecter les changements
-- | • Support WebSocket via LIVE SELECT pour mise à jour UI en temps réel
-- |   (voir: integrations/documentation/webhook/WEBSOCKET_CREDENTIALS.md)
-- |
-- =============================================================================================

DEFINE TABLE IF NOT EXISTS uses_credential TYPE RELATION SCHEMAFULL
COMMENT 'Relation entre service et credential_type - Gère les authentifications disponibles par service.'
PERMISSIONS
    FOR SELECT FULL
    FOR CREATE, UPDATE, DELETE WHERE $auth.permissions = 'lyxal_admin';

-- =====================================================
-- CHAMPS DE RELATION (structure de base)
-- =====================================================

DEFINE FIELD IF NOT EXISTS in ON uses_credential 
    TYPE record<service>
    REFERENCE ON DELETE REJECT
    COMMENT 'Service source (ex: service:google_sheets, service:slack).';

DEFINE FIELD IF NOT EXISTS out ON uses_credential 
    TYPE record<credential_type>
    REFERENCE ON DELETE REJECT
    COMMENT 'Type de credential cible (ex: credential_type:google_sheets_oauth2).';

DEFINE FIELD IF NOT EXISTS is_required ON uses_credential 
    TYPE bool
    DEFAULT true
    COMMENT 'Indique si ce credential est obligatoire pour utiliser le service (true = obligatoire, false = optionnel).';

-- =====================================================
-- OBJET: presentation (Éléments pour l'UI)
-- =====================================================

DEFINE FIELD IF NOT EXISTS presentation ON uses_credential 
    TYPE object
    COMMENT 'Éléments de présentation pour l\'interface utilisateur.';

DEFINE FIELD IF NOT EXISTS presentation.display_order ON uses_credential 
    TYPE int
    DEFAULT 0
    COMMENT 'Ordre d\'affichage dans l\'UI (plus petit = plus haut). Utile quand un service a plusieurs credentials.';

DEFINE FIELD IF NOT EXISTS presentation.custom_label_i18n ON uses_credential 
    TYPE option<record<i18n_key>>
    REFERENCE ON DELETE REJECT
    COMMENT 'Label personnalisé multilingue pour ce credential dans ce service (override du display_name du credential_type).';

DEFINE FIELD IF NOT EXISTS presentation.tooltip_i18n ON uses_credential 
    TYPE option<record<i18n_key>>
    REFERENCE ON DELETE REJECT
    COMMENT 'Tooltip explicatif multilingue pour aider l\'utilisateur dans ce contexte.';

DEFINE FIELD IF NOT EXISTS presentation.is_recommended ON uses_credential 
    TYPE bool
    DEFAULT false
    COMMENT 'Indique si ce credential est recommandé pour ce service (affichage en premier, badge "Recommandé").';

DEFINE FIELD IF NOT EXISTS presentation.badge_color_type ON uses_credential 
    TYPE record<theme_color_type>
    REFERENCE ON DELETE REJECT
    COMMENT 'Type de couleur pour le badge dans l\'UI (référence vers theme_color_type: primary, error, warning, etc.).';

DEFINE FIELD IF NOT EXISTS presentation.display_conditions ON uses_credential 
    FLEXIBLE
    TYPE option<object>
    COMMENT 'Conditions d\'affichage dynamiques. Format JSON: { show: { field: [values] }, hide: { field: [values] } }. Ex: { show: { authentication_mode: ["oauth2"] }, hide: { plan: ["free"] } }';

-- =====================================================
-- OBJET: config (Configuration technique)
-- =====================================================

DEFINE FIELD IF NOT EXISTS config ON uses_credential 
    TYPE object
    COMMENT 'Configuration technique et exigences spécifiques à ce contexte.';

DEFINE FIELD IF NOT EXISTS config.custom_description_i18n ON uses_credential 
    TYPE option<record<i18n_key>>
    REFERENCE ON DELETE REJECT
    COMMENT 'Description personnalisée multilingue pour ce credential dans ce service (ex: "OAuth2 is recommended for most users").';

DEFINE FIELD IF NOT EXISTS config.scopes_required ON uses_credential 
    TYPE array<string>
    DEFAULT []
    COMMENT 'Scopes OAuth2 spécifiques requis pour ce service (ex: ["https://www.googleapis.com/auth/spreadsheets", "https://www.googleapis.com/auth/drive.file"]).';

DEFINE FIELD IF NOT EXISTS config.permissions_needed ON uses_credential 
    TYPE array<string>
    DEFAULT []
    COMMENT 'Permissions nécessaires pour ce service (ex: ["read:channels", "write:messages", "users:read"]).';

DEFINE FIELD IF NOT EXISTS config.setup_complexity ON uses_credential 
    TYPE string
    ASSERT $value IN ['easy', 'medium', 'hard']
    DEFAULT 'medium'
    COMMENT 'Complexité de configuration pour l\'utilisateur (easy = simple, medium = intermédiaire, hard = expert).';

DEFINE FIELD IF NOT EXISTS config.estimated_setup_time ON uses_credential 
    TYPE option<int>
    ASSERT $value == NONE OR $value > 0
    COMMENT 'Temps estimé de configuration en minutes (ex: 5, 15, 30).';

DEFINE FIELD IF NOT EXISTS config.use_case ON uses_credential 
    TYPE option<string>
    ASSERT $value == NONE OR $value IN ['standard', 'automation', 'serverless', 'development', 'production']
    COMMENT 'Cas d\'usage principal (ex: "automation" pour Service Account, "standard" pour OAuth2).';

-- =====================================================
-- OBJET: documentation (Ressources d'aide)
-- =====================================================

DEFINE FIELD IF NOT EXISTS documentation ON uses_credential 
    TYPE object
    COMMENT 'Ressources de documentation spécifiques à ce contexte.';

DEFINE FIELD IF NOT EXISTS documentation.setup_instructions_i18n ON uses_credential 
    TYPE option<record<i18n_key>>
    REFERENCE ON DELETE REJECT
    COMMENT 'Instructions de configuration détaillées multilingues (étape par étape).';

DEFINE FIELD IF NOT EXISTS documentation.video_tutorial_url ON uses_credential 
    TYPE option<record<url>>
    REFERENCE ON DELETE REJECT
    COMMENT 'URL d\'une vidéo tutoriel pour configurer ce credential dans ce service.';

DEFINE FIELD IF NOT EXISTS documentation.troubleshooting_url ON uses_credential 
    TYPE option<record<url>>
    REFERENCE ON DELETE REJECT
    COMMENT 'URL de la page de dépannage pour résoudre les problèmes courants.';

DEFINE FIELD IF NOT EXISTS documentation.best_practices_i18n ON uses_credential 
    TYPE option<record<i18n_key>>
    REFERENCE ON DELETE REJECT
    COMMENT 'Bonnes pratiques pour utiliser ce credential dans ce service.';

-- =====================================================
-- CHAMPS SYSTÈME
-- =====================================================

DEFINE FIELD IF NOT EXISTS etag ON uses_credential 
    TYPE uuid
    READONLY
    DEFAULT ALWAYS rand::uuid::v7()
    COMMENT 'ETag pour détection de changements et synchronisation temps réel via WebSocket.';

DEFINE FIELD IF NOT EXISTS created_at ON uses_credential 
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT 'Date de création de la relation.';

DEFINE FIELD IF NOT EXISTS updated_at ON uses_credential 
    TYPE datetime
    READONLY
    DEFAULT ALWAYS time::now()
    COMMENT 'Date de dernière mise à jour (auto-updated à chaque modification).';

-- =====================================================
-- INDEX (pour performance)
-- =====================================================

DEFINE INDEX IF NOT EXISTS uses_credential_in_idx ON uses_credential FIELDS in
    COMMENT 'Récupération rapide de tous les credentials d\'un service.';

DEFINE INDEX IF NOT EXISTS uses_credential_out_idx ON uses_credential FIELDS out
    COMMENT 'Récupération de tous les services utilisant un credential_type donné.';

DEFINE INDEX IF NOT EXISTS uses_credential_unique_idx ON uses_credential FIELDS in, out UNIQUE
    COMMENT 'Prévention des doublons - Un service ne peut avoir qu\'une seule relation vers un credential_type.';

DEFINE INDEX IF NOT EXISTS uses_credential_required_idx ON uses_credential FIELDS is_required
    COMMENT 'Filtrage rapide des credentials obligatoires vs optionnels.';

DEFINE INDEX IF NOT EXISTS uses_credential_recommended_idx ON uses_credential FIELDS presentation.is_recommended
    COMMENT 'Filtrage des credentials recommandés pour affichage prioritaire.';

DEFINE INDEX IF NOT EXISTS uses_credential_complexity_idx ON uses_credential FIELDS config.setup_complexity
    COMMENT 'Filtrage par complexité de configuration.';

-- =============================================================================================
