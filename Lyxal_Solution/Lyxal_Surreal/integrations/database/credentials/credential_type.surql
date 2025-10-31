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

DEFINE FIELD IF NOT EXISTS presentation.color ON credential_type 
    TYPE string
    ASSERT string::starts_with($value, '#') AND string::len($value) = 7
    COMMENT 'Couleur hexadécimale (ex: #4285F4 pour Google).';

DEFINE FIELD IF NOT EXISTS presentation.color_daisy ON credential_type 
    TYPE string
    ASSERT $value IN ['primary', 'secondary', 'accent', 'neutral', 'info', 'success', 'warning', 'error']
    DEFAULT 'neutral'
    COMMENT 'Classe de couleur DaisyUI pour l\'UI.';

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
    TYPE string
    DEFAULT rand::uuid::v7()
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

-- =====================================================
-- EXEMPLES D'UTILISATION
-- =====================================================

-- EXEMPLE 1: Insertion - Google Sheets OAuth2
/*
CREATE credential_type:google_sheets_oauth2 SET
    name = "googleSheetsOAuth2Api",
    slug = "google-sheets-oauth2",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_google_sheets_oauth2_name,
        description_i18n: i18n_key:credential_type_google_sheets_oauth2_description
    },
    
    presentation = {
        icon: icon:google_sheets,
        color: "#34A853",
        color_daisy: "success",
        tooltip_i18n: i18n_key:credential_type_google_sheets_oauth2_tooltip,
        display_order: 1
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:google,
    
    config = {
        oauth2: {
            auth_url: "https://accounts.google.com/o/oauth2/v2/auth",
            token_url: "https://oauth2.googleapis.com/token",
            scope: "https://www.googleapis.com/auth/drive.file https://www.googleapis.com/auth/spreadsheets",
            grant_type: "authorization_code"
        },
        required_fields: [
            {
                name: "client_id",
                display_name: "Client ID",
                type: "string",
                is_secret: false,
                required: true,
                description: "OAuth2 Client ID from Google Cloud Console"
            },
            {
                name: "client_secret",
                display_name: "Client Secret",
                type: "string",
                is_secret: true,
                required: true,
                description: "OAuth2 Client Secret from Google Cloud Console"
            }
        ],
        metadata: {
            test_endpoint: "/v4/spreadsheets",
            token_expiry: 3600
        }
    },
    
    documentation = {
        url: url:google_oauth2_docs,
        use_cases_i18n: [
            i18n_key:credential_type_google_sheets_usecase_automation,
            i18n_key:credential_type_google_sheets_usecase_reporting
        ]
    };
*/

-- EXEMPLE 2: Insertion - Stripe API Key
/*
CREATE credential_type:stripe_api SET
    name = "stripeApi",
    slug = "stripe-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_stripe_api_name,
        description_i18n: i18n_key:credential_type_stripe_api_description
    },
    
    presentation = {
        icon: icon:stripe,
        color: "#635BFF",
        color_daisy: "primary",
        tooltip_i18n: i18n_key:credential_type_stripe_api_tooltip,
        display_order: 2
    },
    
    auth_type = auth_type:api_key,
    provider = provider:stripe,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "api_key",
                display_name: "API Key",
                type: "string",
                is_secret: true,
                required: true,
                description: "Your Stripe secret API key (starts with sk_)",
                placeholder: "sk_live_..."
            }
        ],
        metadata: {
            test_endpoint: "/v1/customers",
            header_name: "Authorization",
            header_prefix: "Bearer "
        }
    },
    
    documentation = {
        url: url:stripe_api_docs,
        use_cases_i18n: [
            i18n_key:credential_type_stripe_usecase_payments,
            i18n_key:credential_type_stripe_usecase_subscriptions
        ]
    };
*/

-- EXEMPLE 3: Insertion - HTTP Basic Auth (générique, sans provider)
/*
CREATE credential_type:http_basic_auth SET
    name = "httpBasicAuth",
    slug = "http-basic-auth",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_http_basic_auth_name,
        description_i18n: i18n_key:credential_type_http_basic_auth_description
    },
    
    presentation = {
        icon: icon:lock_open,
        color: "#9AA0A6",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:credential_type_http_basic_auth_tooltip,
        display_order: 20
    },
    
    auth_type = auth_type:basic_auth,
    provider = NONE,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "username",
                display_name: "Username",
                type: "string",
                is_secret: false,
                required: true
            },
            {
                name: "password",
                display_name: "Password",
                type: "string",
                is_secret: true,
                required: true
            }
        ],
        metadata: NONE
    },
    
    documentation = {
        url: url:basic_auth_rfc7617,
        use_cases_i18n: [
            i18n_key:credential_type_basic_auth_usecase_internal_apis,
            i18n_key:credential_type_basic_auth_usecase_legacy_systems
        ]
    };
*/

-- =====================================================
-- REQUÊTES UTILES
-- =====================================================

-- Requête UI : Liste des credentials actifs avec traductions
/*
SELECT 
    id,
    name,
    slug,
    identity.display_name_i18n.*,
    identity.description_i18n.*,
    presentation,
    auth_type.identity.display_name_i18n.* AS auth_type_name,
    provider.name AS provider_name
FROM credential_type
WHERE is_active = true
ORDER BY presentation.display_order ASC;
*/

-- Requête IA : Credentials par type d'authentification avec métadonnées
/*
SELECT 
    credential_type.*,
    auth_type.quality.security_level,
    auth_type.quality.popularity_score,
    auth_type.quality.implementation_complexity
FROM credential_type
WHERE auth_type = auth_type:oauth2
ORDER BY auth_type.quality.security_level DESC;
*/

-- Requête développeur : Credentials d'un provider avec configuration
/*
SELECT 
    name,
    slug,
    identity.display_name_i18n.*,
    auth_type.*,
    config,
    documentation.url.*
FROM credential_type
WHERE provider = provider:google
ORDER BY presentation.display_order ASC;
*/

-- Requête : Credentials génériques (sans provider)
/*
SELECT 
    name,
    identity.display_name_i18n.*,
    auth_type.name AS auth_type_name
FROM credential_type
WHERE provider IS NONE;
*/

-- Requête : Credentials les plus sécurisés
/*
SELECT 
    credential_type.name,
    credential_type.identity.display_name_i18n.*,
    auth_type.quality.security_level,
    auth_type.identity.display_name_i18n.* AS auth_type_name
FROM credential_type
WHERE auth_type.quality.security_level >= 4
ORDER BY auth_type.quality.security_level DESC;
*/

-- Requête : Compter credentials par type d'auth
/*
SELECT 
    auth_type AS type_id,
    auth_type.identity.display_name_i18n.* AS type_name,
    count() AS total
FROM credential_type
GROUP BY auth_type
ORDER BY total DESC;
*/

-- Requête : Compter credentials par provider
/*
SELECT 
    provider AS provider_id,
    provider.name AS provider_name,
    count() AS total
FROM credential_type
WHERE provider IS NOT NONE
GROUP BY provider
ORDER BY total DESC;
*/

-- =====================================================
-- WEBSOCKET : Écoute des changements en temps réel
-- =====================================================
--
-- Côté serveur (SurrealDB) :
-- LIVE SELECT * FROM credential_type WHERE is_active = true;
--
-- Côté client (JavaScript) :
-- ws.on('message', (data) => {
--   if (data.action === 'CREATE' || data.action === 'UPDATE') {
--     console.log('Credential type modifié:', data.result);
--     console.log('Nouveau ETag:', data.result.etag);
--     updateCache(data.result);
--     refreshUI(data.result);
--   }
-- });
--
-- Flow de mise à jour :
-- 1. Client A écoute les changements via LIVE SELECT
-- 2. Client B crée/modifie un credential_type
-- 3. ETag généré automatiquement (DEFAULT)
-- 4. Client A reçoit la notification avec le nouvel ETag
-- 5. Client A met à jour son UI en temps réel
--
-- =============================================================================================
