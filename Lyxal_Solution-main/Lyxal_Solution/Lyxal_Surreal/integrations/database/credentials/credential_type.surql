-- =============================================================================================
-- |
-- | Fichier : credential_type.surql
-- | Module : integrations > credentials
-- | Description : Types de credentials pour authentification API.
-- |
-- | Cette table définit les différents types de credentials disponibles pour s'authentifier
-- | auprès des APIs externes (Google Sheets OAuth2, Stripe API Key, etc.).
-- | 
-- | Structure GROUPÉE pour optimiser les cas d'usage :
-- | • UI : Récupération ciblée des données de présentation
-- | • IA : Accès direct aux métadonnées de configuration
-- | • Humain : Structure claire et organisée
-- |
-- | Architecture:
-- | • Champs à PLAT : name, slug, is_active (pour index/recherche/unicité)
-- | • Champs GROUPÉS : identity, presentation, config, documentation
-- |
-- | Tables référencées:
-- | • i18n_key : Clés de traduction pour l'internationalisation
-- | • icon : Icônes normalisées pour l'UI
-- | • auth_type : Type d'authentification (OAuth2, API Key, etc.)
-- | • provider : Fournisseur d'API (Google, Stripe, Slack, etc.)
-- | • url : URLs normalisées pour documentation
-- |
-- | Fonctionnalités temps réel:
-- | • ETag automatique (UUID v7) pour détecter les changements
-- | • Support WebSocket via LIVE SELECT pour mise à jour UI en temps réel
-- |   (voir: integrations/documentation/webhook/WEBSOCKET_CREDENTIALS.md)
-- |
-- =============================================================================================

DEFINE TABLE IF NOT EXISTS credential_type TYPE NORMAL SCHEMAFULL
COMMENT 'Types de credentials pour authentification API (Google Sheets OAuth2, Stripe API Key, etc.).'
PERMISSIONS
FOR SELECT,CREATE FULL
FOR UPDATE,DELETE NONE;

-- =====================================================
-- CHAMPS À PLAT (pour index et recherche)
-- =====================================================

DEFINE FIELD IF NOT EXISTS name ON credential_type 
    TYPE string
    ASSERT $value != NONE AND string::len($value) > 0
    COMMENT 'Nom technique unique (ex: googleSheetsOAuth2Api, stripeApi).';

DEFINE FIELD IF NOT EXISTS slug ON credential_type 
    TYPE string
    ASSERT $value != NONE AND string::len($value) > 0 
        AND string::matches($value, '^[a-z0-9-]+$')
    COMMENT 'Slug unique pour URL et recherche (ex: google-sheets-oauth2, stripe-api).';

DEFINE FIELD IF NOT EXISTS is_active ON credential_type 
    TYPE bool
    DEFAULT true
    COMMENT 'Indique si ce type de credential est actif et utilisable.';

-- =====================================================
-- OBJET: identity (Informations d'identification)
-- =====================================================

DEFINE FIELD IF NOT EXISTS identity ON credential_type 
    TYPE object
    COMMENT 'Informations d\'identification et description du credential type.';

DEFINE FIELD IF NOT EXISTS identity.display_name_i18n ON credential_type 
    TYPE record<i18n_key>
    REFERENCE ON DELETE REJECT
    COMMENT 'Nom affiché multilingue dans l\'UI (ex: Google Sheets OAuth2 API).';

DEFINE FIELD IF NOT EXISTS identity.description_i18n ON credential_type 
    TYPE record<i18n_key>
    REFERENCE ON DELETE REJECT
    COMMENT 'Description détaillée multilingue du credential type.';

-- =====================================================
-- OBJET: presentation (Éléments visuels pour UI)
-- =====================================================

DEFINE FIELD IF NOT EXISTS presentation ON credential_type 
    TYPE object
    COMMENT 'Éléments de présentation pour l\'interface utilisateur.';

DEFINE FIELD IF NOT EXISTS presentation.icon ON credential_type 
    TYPE record<icon>
    REFERENCE ON DELETE REJECT
    COMMENT 'Icône représentative du credential type.';

DEFINE FIELD IF NOT EXISTS presentation.color_type ON credential_type 
    TYPE record<theme_color_type>
    REFERENCE ON DELETE REJECT
    COMMENT 'Type de couleur pour les tags/badges dans l\'UI (référence vers theme_color_type: primary, error, warning, etc.).';

DEFINE FIELD IF NOT EXISTS presentation.tooltip_i18n ON credential_type 
    TYPE record<i18n_key>
    REFERENCE ON DELETE REJECT
    COMMENT 'Tooltip contextuel affiché dans l\'UI.';

DEFINE FIELD IF NOT EXISTS presentation.display_order ON credential_type 
    TYPE int
    DEFAULT 999
    COMMENT 'Ordre d\'affichage dans l\'UI (plus petit = plus haut).';

-- =====================================================
-- RELATIONS (Provider et Auth Type)
-- =====================================================

DEFINE FIELD IF NOT EXISTS auth_type ON credential_type 
    TYPE record<auth_type>
    REFERENCE ON DELETE REJECT
    COMMENT 'Type d\'authentification utilisé (OAuth2, API Key, Basic Auth, etc.).';

DEFINE FIELD IF NOT EXISTS provider ON credential_type 
    TYPE option<record<provider>>
    REFERENCE ON DELETE REJECT
    COMMENT 'Fournisseur d\'API (Google, Stripe, Slack, etc.). NULL pour credentials génériques.';

-- =====================================================
-- OBJET: config (Configuration technique)
-- =====================================================

DEFINE FIELD IF NOT EXISTS config ON credential_type 
    TYPE object
    COMMENT 'Configuration technique du credential type.';

DEFINE FIELD IF NOT EXISTS config.oauth2 ON credential_type 
    TYPE option<object>
    COMMENT 'Configuration OAuth2 (auth_url, token_url, scope, grant_type, etc.).';

DEFINE FIELD IF NOT EXISTS config.oauth1 ON credential_type 
    TYPE option<object>
    COMMENT 'Configuration OAuth1 (request_token_url, authorize_url, access_token_url).';

DEFINE FIELD IF NOT EXISTS config.required_fields ON credential_type 
    TYPE array<object>
    DEFAULT []
    COMMENT 'Champs requis pour ce credential type (name, display_name, type, is_secret, etc.).';

DEFINE FIELD IF NOT EXISTS config.metadata ON credential_type 
    TYPE option<object>
    COMMENT 'Métadonnées additionnelles (test_endpoint, token_expiry, custom_headers, etc.).';

-- =====================================================
-- OBJET: documentation (Documentation et ressources)
-- =====================================================

DEFINE FIELD IF NOT EXISTS documentation ON credential_type 
    TYPE object
    COMMENT 'Documentation et ressources pour obtenir les credentials.';

DEFINE FIELD IF NOT EXISTS documentation.url ON credential_type 
    TYPE option<record<url>>
    REFERENCE ON DELETE REJECT
    COMMENT 'URL de documentation pour obtenir les credentials.';

DEFINE FIELD IF NOT EXISTS documentation.use_cases_i18n ON credential_type 
    TYPE option<array<record<i18n_key>>>
    REFERENCE ON DELETE REJECT
    COMMENT 'Cas d\'usage recommandés multilingues.';

-- =====================================================
-- CHAMPS SYSTÈME
-- =====================================================

DEFINE FIELD IF NOT EXISTS etag ON credential_type 
    TYPE uuid
    READONLY
    DEFAULT ALWAYS rand::uuid::v7()
    COMMENT 'ETag pour la détection de changements et synchronisation temps réel.';

DEFINE FIELD IF NOT EXISTS created_at ON credential_type 
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT 'Date de création.';

DEFINE FIELD IF NOT EXISTS updated_at ON credential_type 
    TYPE datetime
    READONLY
    DEFAULT ALWAYS time::now()
    COMMENT 'Date de dernière mise à jour (auto-updated).';

-- =====================================================
-- INDEX (uniquement sur champs à plat)
-- =====================================================

DEFINE INDEX IF NOT EXISTS credential_type_name_idx ON credential_type FIELDS name UNIQUE
    COMMENT 'Unicité du nom technique.';

DEFINE INDEX IF NOT EXISTS credential_type_slug_idx ON credential_type FIELDS slug UNIQUE
    COMMENT 'Unicité du slug.';

DEFINE INDEX IF NOT EXISTS credential_type_active_idx ON credential_type FIELDS is_active
    COMMENT 'Filtrage rapide des credentials actifs.';

DEFINE INDEX IF NOT EXISTS credential_type_auth_type_idx ON credential_type FIELDS auth_type
    COMMENT 'Filtrage par type d\'authentification.';

DEFINE INDEX IF NOT EXISTS credential_type_provider_idx ON credential_type FIELDS provider
    COMMENT 'Filtrage par provider.';

-- =============================================================================================
