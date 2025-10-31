-- =============================================================================================
-- |
-- | Fichier : provider.surql
-- | Module : integrations > provider
-- | Description : Table de référence des fournisseurs d'API (Google, Stripe, Slack, etc.).
-- |
-- | Cette table centralise tous les fournisseurs d'API utilisés dans le système.
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
-- | • logo_brand : Logos des marques (thème clair/sombre)
-- | • url : URLs normalisées pour documentation
-- |
-- | Fonctionnalités temps réel:
-- | • ETag automatique (UUID v7) pour détecter les changements
-- | • Support WebSocket via LIVE SELECT pour mise à jour UI en temps réel
-- |
-- =============================================================================================

DEFINE TABLE IF NOT EXISTS provider TYPE NORMAL SCHEMAFULL
COMMENT 'Fournisseurs d\'API (Google, Stripe, Slack, etc.) - Source unique de vérité.'
PERMISSIONS
FOR SELECT,CREATE FULL
FOR UPDATE,DELETE NONE;

-- =====================================================
-- CHAMPS À PLAT (pour index et recherche)
-- =====================================================

DEFINE FIELD IF NOT EXISTS name ON provider 
    TYPE string
    ASSERT $value != NONE AND string::len($value) > 0
    COMMENT 'Nom technique unique du provider (ex: google, stripe, slack).';

DEFINE FIELD IF NOT EXISTS slug ON provider 
    TYPE string
    ASSERT $value != NONE AND string::len($value) > 0 
        AND string::matches($value, '^[a-z0-9-]+$')
    COMMENT 'Slug unique pour URL et recherche (ex: google, stripe, slack).';

DEFINE FIELD IF NOT EXISTS is_active ON provider 
    TYPE bool
    DEFAULT true
    COMMENT 'Indique si le provider est actif et utilisable.';

-- =====================================================
-- OBJET: identity (Informations d'identification)
-- =====================================================

DEFINE FIELD IF NOT EXISTS identity ON provider 
    TYPE object
    COMMENT 'Informations d\'identification et description du provider.';

DEFINE FIELD IF NOT EXISTS identity.display_name_i18n ON provider 
    TYPE record<i18n_key>
    REFERENCE ON DELETE REJECT
    COMMENT 'Nom affiché multilingue (ex: Google, Stripe, Slack).';

DEFINE FIELD IF NOT EXISTS identity.description_i18n ON provider 
    TYPE option<record<i18n_key>>
    REFERENCE ON DELETE REJECT
    COMMENT 'Description détaillée multilingue du provider.';

-- =====================================================
-- OBJET: presentation (Éléments visuels pour UI)
-- =====================================================

DEFINE FIELD IF NOT EXISTS presentation ON provider 
    TYPE object
    COMMENT 'Éléments de présentation pour l\'interface utilisateur.';

DEFINE FIELD IF NOT EXISTS presentation.logo_light ON provider 
    TYPE option<record<logo_brand>>
    VALUE type::thing('logo_brand', $value)
    REFERENCE ON DELETE REJECT
    COMMENT 'Logo du provider en thème clair (référence vers logo_brand).';

DEFINE FIELD IF NOT EXISTS presentation.logo_dark ON provider 
    TYPE option<record<logo_brand>>
    VALUE type::thing('logo_brand', $value)
    REFERENCE ON DELETE REJECT
    COMMENT 'Logo du provider en thème sombre (référence vers logo_brand).';

DEFINE FIELD IF NOT EXISTS presentation.color ON provider 
    TYPE string
    ASSERT string::starts_with($value, '#') AND string::len($value) = 7
    COMMENT 'Couleur hexadécimale du brand (ex: #4285F4 pour Google).';

DEFINE FIELD IF NOT EXISTS presentation.color_daisy ON provider 
    TYPE string
    ASSERT $value IN ['primary', 'secondary', 'accent', 'neutral', 'info', 'success', 'warning', 'error']
    DEFAULT 'neutral'
    COMMENT 'Classe de couleur DaisyUI pour l\'UI.';

DEFINE FIELD IF NOT EXISTS presentation.tooltip_i18n ON provider 
    TYPE option<record<i18n_key>>
    REFERENCE ON DELETE REJECT
    COMMENT 'Tooltip contextuel affiché dans l\'UI.';

DEFINE FIELD IF NOT EXISTS presentation.display_order ON provider 
    TYPE int
    DEFAULT 999
    COMMENT 'Ordre d\'affichage dans l\'UI (plus petit = plus haut).';

-- =====================================================
-- OBJET: config (Configuration technique)
-- =====================================================

DEFINE FIELD IF NOT EXISTS config ON provider 
    TYPE object
    COMMENT 'Configuration technique du provider.';

DEFINE FIELD IF NOT EXISTS config.urls ON provider 
    TYPE object
    COMMENT 'URLs du provider (site web, documentation, API).';

DEFINE FIELD IF NOT EXISTS config.urls.website ON provider 
    TYPE option<record<url>>
    VALUE type::thing('url', $value)
    REFERENCE ON DELETE REJECT
    COMMENT 'URL du site web officiel du provider.';

DEFINE FIELD IF NOT EXISTS config.urls.documentation ON provider 
    TYPE option<record<url>>
    VALUE type::thing('url', $value)
    REFERENCE ON DELETE REJECT
    COMMENT 'URL de la documentation développeur du provider.';

DEFINE FIELD IF NOT EXISTS config.urls.api_base ON provider 
    TYPE option<string>
    COMMENT 'URL de base de l\'API (ex: https://api.stripe.com).';

DEFINE FIELD IF NOT EXISTS config.urls.status_page ON provider 
    TYPE option<string>
    COMMENT 'URL de la page de statut du service (ex: https://status.stripe.com).';

DEFINE FIELD IF NOT EXISTS config.capabilities ON provider 
    TYPE object
    COMMENT 'Capacités et fonctionnalités supportées par le provider.';

DEFINE FIELD IF NOT EXISTS config.capabilities.supports_oauth2 ON provider 
    TYPE bool
    DEFAULT false
    COMMENT 'Support de l\'authentification OAuth2.';

DEFINE FIELD IF NOT EXISTS config.capabilities.supports_api_key ON provider 
    TYPE bool
    DEFAULT false
    COMMENT 'Support de l\'authentification API Key.';

DEFINE FIELD IF NOT EXISTS config.capabilities.supports_basic_auth ON provider 
    TYPE bool
    DEFAULT false
    COMMENT 'Support de l\'authentification Basic Auth.';

DEFINE FIELD IF NOT EXISTS config.capabilities.supports_webhooks ON provider 
    TYPE bool
    DEFAULT false
    COMMENT 'Support des webhooks pour notifications temps réel.';

DEFINE FIELD IF NOT EXISTS config.capabilities.supports_rate_limiting ON provider 
    TYPE bool
    DEFAULT true
    COMMENT 'Présence de rate limiting sur l\'API.';

DEFINE FIELD IF NOT EXISTS config.api_version ON provider 
    TYPE option<string>
    COMMENT 'Version actuelle de l\'API (ex: v1, v2, 2024-10).';

-- =====================================================
-- OBJET: metadata (Métadonnées enrichies)
-- =====================================================

DEFINE FIELD IF NOT EXISTS metadata ON provider 
    TYPE object
    COMMENT 'Métadonnées enrichies du provider.';

DEFINE FIELD IF NOT EXISTS metadata.founded_year ON provider 
    TYPE option<int>
    ASSERT $value == NONE OR ($value >= 1900 AND $value <= 2100)
    COMMENT 'Année de fondation de l\'entreprise.';

DEFINE FIELD IF NOT EXISTS metadata.headquarters ON provider 
    TYPE option<string>
    COMMENT 'Siège social (ville, pays).';

DEFINE FIELD IF NOT EXISTS metadata.industry ON provider 
    TYPE option<string>
    COMMENT 'Secteur d\'activité (ex: Payments, Cloud, CRM, Analytics).';

DEFINE FIELD IF NOT EXISTS metadata.company_size ON provider 
    TYPE option<string>
    ASSERT $value == NONE OR $value IN ['startup', 'small', 'medium', 'large', 'enterprise']
    COMMENT 'Taille de l\'entreprise (startup, small, medium, large, enterprise).';

DEFINE FIELD IF NOT EXISTS metadata.stock_symbol ON provider 
    TYPE option<string>
    COMMENT 'Symbole boursier (ex: GOOGL, MSFT).';

DEFINE FIELD IF NOT EXISTS metadata.tags ON provider 
    TYPE array<string>
    DEFAULT []
    COMMENT 'Tags pour catégorisation et recherche (ex: payment, cloud, crm).';

-- =====================================================
-- OBJET: documentation (Documentation et ressources)
-- =====================================================

DEFINE FIELD IF NOT EXISTS documentation ON provider 
    TYPE object
    COMMENT 'Documentation et ressources du provider.';

DEFINE FIELD IF NOT EXISTS documentation.getting_started_url ON provider 
    TYPE option<record<url>>
    VALUE type::thing('url', $value)
    REFERENCE ON DELETE REJECT
    COMMENT 'URL du guide de démarrage rapide.';

DEFINE FIELD IF NOT EXISTS documentation.api_reference_url ON provider 
    TYPE option<record<url>>
    VALUE type::thing('url', $value)
    REFERENCE ON DELETE REJECT
    COMMENT 'URL de la référence API complète.';

DEFINE FIELD IF NOT EXISTS documentation.sdk_urls ON provider 
    TYPE option<object>
    COMMENT 'URLs des SDKs officiels par langage.';

DEFINE FIELD IF NOT EXISTS documentation.sdk_urls.javascript ON provider 
    TYPE option<string>
    COMMENT 'URL du SDK JavaScript/Node.js.';

DEFINE FIELD IF NOT EXISTS documentation.sdk_urls.python ON provider 
    TYPE option<string>
    COMMENT 'URL du SDK Python.';

DEFINE FIELD IF NOT EXISTS documentation.sdk_urls.php ON provider 
    TYPE option<string>
    COMMENT 'URL du SDK PHP.';

DEFINE FIELD IF NOT EXISTS documentation.sdk_urls.ruby ON provider 
    TYPE option<string>
    COMMENT 'URL du SDK Ruby.';

DEFINE FIELD IF NOT EXISTS documentation.sdk_urls.go ON provider 
    TYPE option<string>
    COMMENT 'URL du SDK Go.';

DEFINE FIELD IF NOT EXISTS documentation.sdk_urls.java ON provider 
    TYPE option<string>
    COMMENT 'URL du SDK Java.';

DEFINE FIELD IF NOT EXISTS documentation.community_url ON provider 
    TYPE option<string>
    COMMENT 'URL du forum ou communauté de support.';

-- =====================================================
-- CHAMPS SYSTÈME
-- =====================================================

DEFINE FIELD IF NOT EXISTS etag ON provider 
    TYPE string
    DEFAULT rand::uuid::v7()
    COMMENT 'ETag pour la détection de changements et synchronisation temps réel.';

DEFINE FIELD IF NOT EXISTS created_at ON provider 
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT 'Date de création.';

DEFINE FIELD IF NOT EXISTS updated_at ON provider 
    TYPE datetime
    READONLY
    DEFAULT ALWAYS time::now()
    COMMENT 'Date de dernière mise à jour (auto-updated).';

-- =====================================================
-- INDEX (uniquement sur champs à plat)
-- =====================================================

DEFINE INDEX IF NOT EXISTS provider_name_idx ON provider FIELDS name UNIQUE
    COMMENT 'Unicité du nom technique.';

DEFINE INDEX IF NOT EXISTS provider_slug_idx ON provider FIELDS slug UNIQUE
    COMMENT 'Unicité du slug.';

DEFINE INDEX IF NOT EXISTS provider_active_idx ON provider FIELDS is_active
    COMMENT 'Filtrage rapide des providers actifs.';

-- =====================================================
-- EXEMPLES D'UTILISATION
-- =====================================================

-- EXEMPLE 1: Insertion - Google Provider
/*
CREATE provider:google SET
    name = "google",
    slug = "google",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:provider_google_name,
        description_i18n: i18n_key:provider_google_description
    },
    
    presentation = {
        logo_light: logo_brand:google_light,
        logo_dark: logo_brand:google_dark,
        color: "#4285F4",
        color_daisy: "info",
        tooltip_i18n: i18n_key:provider_google_tooltip,
        display_order: 1
    },
    
    config = {
        urls: {
            website: url:google_com,
            documentation: url:google_developers,
            api_base: "https://www.googleapis.com",
            status_page: "https://status.cloud.google.com"
        },
        capabilities: {
            supports_oauth2: true,
            supports_api_key: true,
            supports_basic_auth: false,
            supports_webhooks: true,
            supports_rate_limiting: true
        },
        api_version: "v1"
    },
    
    metadata = {
        founded_year: 1998,
        headquarters: "Mountain View, CA, USA",
        industry: "Technology, Cloud, Search",
        company_size: "enterprise",
        stock_symbol: "GOOGL",
        tags: ["cloud", "search", "email", "storage", "maps"]
    },
    
    documentation = {
        getting_started_url: url:google_quickstart,
        api_reference_url: url:google_api_reference,
        sdk_urls: {
            javascript: "https://github.com/googleapis/google-api-nodejs-client",
            python: "https://github.com/googleapis/google-api-python-client",
            php: "https://github.com/googleapis/google-api-php-client",
            java: "https://github.com/googleapis/google-api-java-client",
            go: "https://github.com/googleapis/google-api-go-client"
        },
        community_url: "https://stackoverflow.com/questions/tagged/google-api"
    };
*/

-- EXEMPLE 2: Insertion - Stripe Provider
/*
CREATE provider:stripe SET
    name = "stripe",
    slug = "stripe",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:provider_stripe_name,
        description_i18n: i18n_key:provider_stripe_description
    },
    
    presentation = {
        logo_light: logo_brand:stripe_light,
        logo_dark: logo_brand:stripe_dark,
        color: "#635BFF",
        color_daisy: "primary",
        tooltip_i18n: i18n_key:provider_stripe_tooltip,
        display_order: 2
    },
    
    config = {
        urls: {
            website: url:stripe_com,
            documentation: url:stripe_docs,
            api_base: "https://api.stripe.com",
            status_page: "https://status.stripe.com"
        },
        capabilities: {
            supports_oauth2: true,
            supports_api_key: true,
            supports_basic_auth: false,
            supports_webhooks: true,
            supports_rate_limiting: true
        },
        api_version: "2024-10-28"
    },
    
    metadata = {
        founded_year: 2010,
        headquarters: "San Francisco, CA, USA",
        industry: "Financial Technology, Payments",
        company_size: "large",
        stock_symbol: NONE,
        tags: ["payment", "fintech", "subscription", "billing"]
    },
    
    documentation = {
        getting_started_url: url:stripe_quickstart,
        api_reference_url: url:stripe_api_reference,
        sdk_urls: {
            javascript: "https://github.com/stripe/stripe-node",
            python: "https://github.com/stripe/stripe-python",
            php: "https://github.com/stripe/stripe-php",
            ruby: "https://github.com/stripe/stripe-ruby",
            go: "https://github.com/stripe/stripe-go",
            java: "https://github.com/stripe/stripe-java"
        },
        community_url: "https://stackoverflow.com/questions/tagged/stripe-payments"
    };
*/

-- EXEMPLE 3: Requête UI - Liste des providers actifs avec traductions
/*
SELECT 
    id,
    name,
    slug,
    identity.display_name_i18n.*,
    identity.description_i18n.*,
    presentation,
    config.capabilities
FROM provider
WHERE is_active = true
ORDER BY presentation.display_order ASC;
*/

-- EXEMPLE 4: Requête IA - Provider avec documentation complète
/*
SELECT 
    provider.*,
    config.urls.*,
    config.capabilities,
    documentation.*,
    metadata
FROM provider
WHERE name = "google";
*/

-- EXEMPLE 5: Requête - Providers supportant OAuth2
/*
SELECT 
    name,
    identity.display_name_i18n.*,
    presentation.color,
    config.capabilities.supports_oauth2
FROM provider
WHERE config.capabilities.supports_oauth2 = true
ORDER BY presentation.display_order ASC;
*/

-- EXEMPLE 6: Requête - Providers par industrie
/*
SELECT 
    name,
    identity.display_name_i18n.*,
    metadata.industry,
    metadata.tags
FROM provider
WHERE metadata.tags CONTAINS "payment"
ORDER BY name ASC;
*/

-- =====================================================
-- WEBSOCKET : Écoute des changements en temps réel
-- =====================================================
--
-- Côté serveur (SurrealDB) :
-- LIVE SELECT * FROM provider WHERE is_active = true;
--
-- Côté client (JavaScript) :
-- ws.on('message', (data) => {
--   if (data.action === 'CREATE' || data.action === 'UPDATE') {
--     console.log('Provider modifié:', data.result);
--     console.log('Nouveau ETag:', data.result.etag);
--     updateCache(data.result);
--     refreshUI(data.result);
--   }
-- });
--
-- Flow de mise à jour :
-- 1. Client A écoute les changements via LIVE SELECT
-- 2. Client B crée/modifie un provider
-- 3. ETag généré automatiquement (DEFAULT)
-- 4. Client A reçoit la notification avec le nouvel ETag
-- 5. Client A met à jour son UI en temps réel
--
-- =============================================================================================
