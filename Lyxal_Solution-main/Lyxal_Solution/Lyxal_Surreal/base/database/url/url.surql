-- ============================================================================
-- TABLE : url
-- ============================================================================
-- Description : URLs universelles du système Lyxal (tous modules)
-- Module      : base/assets
-- Usage       : Tous les modules (integrations, builder, storage, automation, etc.)
-- Philosophy  : Core minimaliste + Extensions optionnelles par besoin
-- ============================================================================

-- ============================================================================
-- TABLE DEFINITION
-- ============================================================================

DEFINE TABLE IF NOT EXISTS url TYPE NORMAL SCHEMAFULL
COMMENT 'Table universelle pour toutes les URLs du système Lyxal'
PERMISSIONS FOR SELECT,CREATE FULL
FOR UPDATE,DELETE NONE;

-- ============================================================================
-- IDENTITY FIELDS (Identification unique)
-- ============================================================================

DEFINE FIELD IF NOT EXISTS identity ON TABLE url 
    TYPE object
    COMMENT 'Bloc identité : identification unique de l\'URL';

    DEFINE FIELD IF NOT EXISTS identity.value ON TABLE url 
    TYPE string
    ASSERT $value != NONE AND $value != "" AND string::len($value) > 0
    COMMENT 'Valeur technique (slug) : google_oauth2_docs';

    DEFINE FIELD IF NOT EXISTS identity.slug ON TABLE url 
    TYPE string
    ASSERT $value != NONE AND $value != "" AND string::len($value) > 0 AND string::matches($value, '^[a-z0-9-]+$')
    COMMENT 'Slug URL-friendly : google-oauth2-docs';

-- ============================================================================
-- PRESENTATION FIELDS (Affichage UI)
-- ============================================================================

DEFINE FIELD IF NOT EXISTS presentation ON TABLE url 
    TYPE object
    COMMENT 'Bloc présentation : affichage dans l\'interface';

    DEFINE FIELD IF NOT EXISTS presentation.title_i18n ON TABLE url 
    TYPE record<i18n_key>
    REFERENCE ON DELETE REJECT
    VALUE type::thing('i18n_key', $value)
    COMMENT 'Titre de l\'URL (i18n)';

    DEFINE FIELD IF NOT EXISTS presentation.description_i18n ON TABLE url 
    TYPE option<record<i18n_key>>
    REFERENCE ON DELETE REJECT
    VALUE {IF $value != NONE {type::thing('i18n_key', $value)} ELSE {NONE}}
    COMMENT 'Description de l\'URL (i18n)';

    DEFINE FIELD IF NOT EXISTS presentation.icon ON TABLE url 
    TYPE option<record<url>>
    REFERENCE ON DELETE REJECT
    VALUE {IF $value != NONE {type::thing('url', $value)} ELSE {NONE}}
    COMMENT 'URL de l\'icône : https://icons.lyxal.b-cdn.net/lucide/book.svg';

-- ============================================================================
-- URL FIELDS (Core - toujours présent)
-- ============================================================================

DEFINE FIELD IF NOT EXISTS url ON TABLE url 
    TYPE object
    COMMENT 'Bloc URL : informations principales (core)';

    DEFINE FIELD IF NOT EXISTS url.href ON TABLE url 
        TYPE record<url>
        REFERENCE ON DELETE REJECT
        VALUE {IF $value != NONE {type::thing('url', $value)} ELSE {NONE}}
        COMMENT 'URL complète : url:example_com_path ou url:internal_path';

    DEFINE FIELD IF NOT EXISTS url.protocol ON TABLE url 
        TYPE option<string>
        COMMENT 'Protocole : https, http, ftp, file, etc. (optionnel si URL relative)';

    DEFINE FIELD IF NOT EXISTS url.is_external ON TABLE url 
        TYPE bool
        DEFAULT false
        COMMENT 'URL externe au système Lyxal ?';

-- ============================================================================
-- CONTEXT FIELDS (Contexte d'utilisation)
-- ============================================================================

DEFINE FIELD IF NOT EXISTS context ON TABLE url 
    TYPE object
    COMMENT 'Bloc contexte : où et comment l\'URL est utilisée';

    DEFINE FIELD IF NOT EXISTS context.module ON TABLE url 
        TYPE option<record<builder_catalogue>>
        REFERENCE ON DELETE REJECT
        VALUE {IF $value != NONE {type::thing('builder_catalogue', $value)} ELSE {NONE}}
        COMMENT 'Module principal utilisant cette URL';

    DEFINE FIELD IF NOT EXISTS context.usage_type ON TABLE url 
        TYPE option<record<url_usage_type>>
        ASSERT $value INSIDE ['documentation', 'api_endpoint', 'webhook', 'asset', 'redirect', 'iframe', 'download', 'reference', 'other']
        COMMENT 'Type d\'utilisation de l\'URL';

    DEFINE FIELD IF NOT EXISTS context.tags ON TABLE url 
        TYPE option<array<record<tag>>>
        REFERENCE ON DELETE REJECT
        VALUE {IF $value != NONE {type::thing('tag', $value)} ELSE {NONE}}
        COMMENT 'Tags flexibles pour classification : ["oauth2", "api", "image", etc.]';

-- ============================================================================
-- EXTENSIONS FIELDS (Extensions optionnelles par besoin)
-- ============================================================================

DEFINE FIELD IF NOT EXISTS extensions ON TABLE url 
    TYPE object
    COMMENT 'Bloc extensions : métadonnées optionnelles selon le besoin';

    -- Extension 1 : Validation HTTP (pour APIs, documentation externe)
    DEFINE FIELD IF NOT EXISTS extensions.http_validation ON TABLE url 
        TYPE option<object>
        COMMENT 'Extension : validation HTTP pour URLs externes';
    
        DEFINE FIELD IF NOT EXISTS extensions.http_validation.is_verified ON TABLE url 
            TYPE bool
            DEFAULT false
            COMMENT 'URL vérifiée (HTTP 200) ?';
        
        DEFINE FIELD IF NOT EXISTS extensions.http_validation.last_check_at ON TABLE url 
            TYPE option<datetime>
            COMMENT 'Dernière vérification';

        DEFINE FIELD IF NOT EXISTS extensions.http_validation.last_status_code ON TABLE url 
            TYPE option<int>
            COMMENT 'Dernier code HTTP : 200, 404, 500, etc.';
        
        DEFINE FIELD IF NOT EXISTS extensions.http_validation.check_frequency ON TABLE url 
            TYPE string
            ASSERT $value INSIDE ['never', 'hourly', 'daily', 'weekly', 'monthly']
            DEFAULT 'never'
            COMMENT 'Fréquence de vérification';
        
        DEFINE FIELD IF NOT EXISTS extensions.http_validation.auto_disable_on_error ON TABLE url 
            TYPE bool
            DEFAULT false
            COMMENT 'Désactiver automatiquement si erreur 404/500 ?';

    -- Extension 2 : Asset (pour images, fichiers, ressources)
    DEFINE FIELD IF NOT EXISTS extensions.asset ON TABLE url 
        TYPE option<object>
        COMMENT 'Extension : métadonnées pour assets (images, fichiers)';
    
        DEFINE FIELD IF NOT EXISTS extensions.asset.mime_type ON TABLE url 
            TYPE option<string>
            COMMENT 'Type MIME : image/png, application/pdf, etc.';
        
        DEFINE FIELD IF NOT EXISTS extensions.asset.size_bytes ON TABLE url 
            TYPE option<int>
            COMMENT 'Taille en octets';
        
        DEFINE FIELD IF NOT EXISTS extensions.asset.width ON TABLE url 
            TYPE option<int>
            COMMENT 'Largeur (si image)';
        
        DEFINE FIELD IF NOT EXISTS extensions.asset.height ON TABLE url 
            TYPE option<int>
            COMMENT 'Hauteur (si image)';
        
        DEFINE FIELD IF NOT EXISTS extensions.asset.alt_text_i18n ON TABLE url 
            TYPE option<record<i18n_key>>
            REFERENCE ON DELETE REJECT
            VALUE {IF $value != NONE {type::thing('i18n_key', $value)} ELSE {NONE}}
            COMMENT 'Texte alternatif (i18n)';

    -- Extension 3 : Analytics (pour tracking, statistiques)
    DEFINE FIELD IF NOT EXISTS extensions.analytics ON TABLE url 
        TYPE option<object>
        COMMENT 'Extension : analytics et statistiques d\'usage';
    
        DEFINE FIELD IF NOT EXISTS extensions.analytics.view_count ON TABLE url 
            TYPE int
            DEFAULT 0
            COMMENT 'Nombre de vues/affichages';
        
        DEFINE FIELD IF NOT EXISTS extensions.analytics.click_count ON TABLE url 
            TYPE int
            DEFAULT 0
            COMMENT 'Nombre de clics';
        
        DEFINE FIELD IF NOT EXISTS extensions.analytics.last_viewed_at ON TABLE url 
            TYPE option<datetime>
            COMMENT 'Dernière vue';

    -- Extension 4 : Webhook (pour URLs de callback)
    DEFINE FIELD IF NOT EXISTS extensions.webhook ON TABLE url 
        TYPE option<object>
        COMMENT 'Extension : configuration pour webhooks';
    
        DEFINE FIELD IF NOT EXISTS extensions.webhook.method ON TABLE url 
            TYPE string
            ASSERT $value INSIDE ['GET', 'POST', 'PUT', 'PATCH', 'DELETE']
            DEFAULT 'POST'
            COMMENT 'Méthode HTTP attendue';
        
        DEFINE FIELD IF NOT EXISTS extensions.webhook.signature_verification ON TABLE url
            TYPE option<object>
            COMMENT 'Extension : vérification de signature pour webhooks';
        
            DEFINE FIELD IF NOT EXISTS extensions.webhook.signature_verification.enabled ON TABLE url 
                TYPE bool
                DEFAULT false
                COMMENT 'Vérification de signature activée ?';
            
            DEFINE FIELD IF NOT EXISTS extensions.webhook.signature_verification.algorithm ON TABLE url 
                TYPE option<string>
                COMMENT 'Algorithme : hmac-sha256, hmac-sha1, etc.';
            
            DEFINE FIELD IF NOT EXISTS extensions.webhook.signature_verification.header_name ON TABLE url 
                TYPE option<string>
                COMMENT 'Nom du header contenant la signature';
        
        DEFINE FIELD IF NOT EXISTS extensions.webhook.timeout_seconds ON TABLE url 
            TYPE int
            DEFAULT 30
            COMMENT 'Timeout pour l\'appel webhook';

    -- Extension 5 : API (pour endpoints API)
    DEFINE FIELD IF NOT EXISTS extensions.api ON TABLE url 
        TYPE option<object>
        COMMENT 'Extension : métadonnées pour endpoints API';
    
        DEFINE FIELD IF NOT EXISTS extensions.api.rate_limit ON TABLE url 
            TYPE option<object>
            COMMENT 'Limites de requêtes';
        
            DEFINE FIELD IF NOT EXISTS extensions.api.rate_limit.requests_per_minute ON TABLE url 
            TYPE option<int>
            COMMENT 'Nombre de requêtes par minute';

            DEFINE FIELD IF NOT EXISTS extensions.api.rate_limit.requests_per_hour ON TABLE url 
            TYPE option<int>
            COMMENT 'Nombre de requêtes par heure';
            
            DEFINE FIELD IF NOT EXISTS extensions.api.rate_limit.requests_per_day ON TABLE url 
            TYPE option<int>
            COMMENT 'Nombre de requêtes par jour';
        
        DEFINE FIELD IF NOT EXISTS extensions.api.requires_auth ON TABLE url 
            TYPE bool
            DEFAULT false
            COMMENT 'Nécessite authentification ?';
        
        DEFINE FIELD IF NOT EXISTS extensions.api.auth_type ON TABLE url 
            TYPE option<record<auth_type>>
            REFERENCE ON DELETE REJECT
            VALUE {IF $value != NONE {type::thing('auth_type', $value)} ELSE {NONE}}
            COMMENT 'Type d\'authentification : auth_type:bearer, auth_type:api_key, 
            auth_type:basic, auth_type:oauth2, auth_type:custom, etc.';

    -- Extension 6 : Custom (pour métadonnées custom par module)
    DEFINE FIELD IF NOT EXISTS extensions.custom ON TABLE url
        FLEXIBLE 
        TYPE option<object>
        COMMENT 'Extension : métadonnées custom flexibles (JSON libre)';

-- ============================================================================
-- STATUS FIELD (Statut général)
-- ============================================================================

DEFINE FIELD IF NOT EXISTS status ON TABLE url 
TYPE object
COMMENT 'Bloc statut : état général de l\'URL';

    DEFINE FIELD IF NOT EXISTS status.is_active ON TABLE url 
    TYPE bool
    DEFAULT true
    COMMENT 'URL active dans le système ?';

    DEFINE FIELD IF NOT EXISTS status.deactivation_reason ON TABLE url 
    TYPE option<string>
    COMMENT 'Raison de désactivation (si is_active = false)';

    DEFINE FIELD IF NOT EXISTS status.source ON TABLE url 
    TYPE string
    ASSERT $value INSIDE ['manual', 'import', 'extraction', 'api', 'user_input', 'system_generated', 'other']
    DEFAULT 'manual'
    COMMENT 'Source de création de l\'URL';

-- ============================================================================
-- METADATA FIELDS (Métadonnées système)
-- ============================================================================

DEFINE FIELD IF NOT EXISTS metadata ON TABLE url 
TYPE object
COMMENT 'Bloc métadonnées : informations système';

    DEFINE FIELD IF NOT EXISTS metadata.notes ON TABLE url 
    TYPE option<string>
    COMMENT 'Notes internes libres';

    DEFINE FIELD IF NOT EXISTS metadata.related_records ON TABLE url 
    TYPE option<array<record>>
    COMMENT 'Records liés (ex: service, provider, tool, etc.)';

    DEFINE FIELD IF NOT EXISTS metadata.owner_user_id ON TABLE url 
    TYPE option<record<user>>
    REFERENCE ON DELETE REJECT
    VALUE {IF $value != NONE {type::thing('user', $value)} ELSE {NONE}}
    COMMENT 'Utilisateur propriétaire (si applicable)';

-- ============================================================================
-- READONLY FIELDS (Création et modification)
-- ============================================================================

DEFINE FIELD IF NOT EXISTS created_at ON TABLE url 
    TYPE datetime
    READONLY
    DEFAULT time::now()
    COMMENT 'Date de création (readonly)';

DEFINE FIELD IF NOT EXISTS updated_at ON TABLE url 
    TYPE datetime
    READONLY
    DEFAULT ALWAYS time::now()
    COMMENT 'Date de dernière modification (readonly)';

DEFINE FIELD IF NOT EXISTS etag ON TABLE url 
    TYPE string
    READONLY
    DEFAULT ALWAYS rand::uuid::v7()
    COMMENT 'ETag pour optimistic locking (readonly)';

-- ============================================================================
-- INDEXES
-- ============================================================================

DEFINE INDEX IF NOT EXISTS idx_url_slug ON url 
    FIELDS identity.slug UNIQUE
    COMMENT 'Index unique sur le slug';

DEFINE INDEX IF NOT EXISTS idx_url_href ON url 
    FIELDS url.href UNIQUE
    COMMENT 'Index unique sur l\'URL complète';

DEFINE INDEX IF NOT EXISTS idx_url_module ON url 
    FIELDS context.module
    COMMENT 'Index sur le module utilisant l\'URL';

DEFINE INDEX IF NOT EXISTS idx_url_usage_type ON url 
    FIELDS context.usage_type
    COMMENT 'Index sur le type d\'utilisation';

DEFINE INDEX IF NOT EXISTS idx_url_active ON url 
    FIELDS status.is_active
    COMMENT 'Index sur les URLs actives';

DEFINE INDEX IF NOT EXISTS idx_url_external ON url 
    FIELDS url.is_external
    COMMENT 'Index sur les URLs externes';

-- ============================================================================
-- EXEMPLES D'UTILISATION PAR MODULE
-- ============================================================================

/*

-- ============================================================================
-- MODULE INTEGRATIONS : URL de documentation API
-- ============================================================================

CREATE url:google_oauth2_docs SET
    identity = {
        id: url:google_oauth2_docs,
        value: 'google_oauth2_docs',
        slug: 'google-oauth2-docs'
    },
    presentation = {
        title_i18n: i18n_key:url_google_oauth2_docs_title,
        description_i18n: i18n_key:url_google_oauth2_docs_desc,
        icon: '📚'
    },
    url = {
        href: 'https://developers.google.com/identity/protocols/oauth2',
        protocol: 'https',
        is_external: true
    },
    context = {
        module: 'integrations',
        usage_type: 'documentation',
        tags: ['oauth2', 'google', 'authentication']
    },
    extensions = {
        http_validation: {
            is_verified: true,
            last_check_at: time::now(),
            last_status_code: 200,
            check_frequency: 'monthly',
            auto_disable_on_error: false
        }
    },
    status = {
        is_active: true,
        source: 'extraction'
    },
    metadata = {
        notes: 'Documentation officielle Google OAuth2',
        related_records: [provider:google, credential_type:google_oauth2]
    };

-- ============================================================================
-- MODULE BUILDER : URL d'une image asset
-- ============================================================================

CREATE url:logo_lyxal_light SET
    identity = {
        id: url:logo_lyxal_light,
        value: 'logo_lyxal_light',
        slug: 'logo-lyxal-light'
    },
    presentation = {
        title_i18n: i18n_key:url_logo_lyxal_light_title,
        description_i18n: i18n_key:url_logo_lyxal_light_desc,
        icon: '🎨'
    },
    url = {
        href: '/assets/images/logo-light.png',
        protocol: NONE,
        is_external: false
    },
    context = {
        module: 'builder',
        usage_type: 'asset',
        tags: ['logo', 'branding', 'light-mode']
    },
    extensions = {
        asset: {
            mime_type: 'image/png',
            size_bytes: 45623,
            width: 512,
            height: 512,
            alt_text_i18n: i18n_key:url_logo_lyxal_light_alt
        },
        analytics: {
            view_count: 15420,
            click_count: 0,
            last_viewed_at: time::now()
        }
    },
    status = {
        is_active: true,
        source: 'system_generated'
    };

-- ============================================================================
-- MODULE AUTOMATION : URL de webhook
-- ============================================================================

CREATE url:webhook_slack_notifications SET
    identity = {
        id: url:webhook_slack_notifications,
        value: 'webhook_slack_notifications',
        slug: 'webhook-slack-notifications'
    },
    presentation = {
        title_i18n: i18n_key:url_webhook_slack_notifications_title,
        icon: '🔔'
    },
    url = {
        href: 'https://lyxal.com/api/webhooks/slack/notifications',
        protocol: 'https',
        is_external: false
    },
    context = {
        module: 'automation',
        usage_type: 'webhook',
        tags: ['slack', 'notifications', 'incoming']
    },
    extensions = {
        webhook: {
            method: 'POST',
            signature_verification: {
                enabled: true,
                algorithm: 'hmac-sha256',
                header_name: 'X-Slack-Signature'
            },
            timeout_seconds: 10
        }
    },
    status = {
        is_active: true,
        source: 'system_generated'
    },
    metadata = {
        related_records: [service:slack]
    };

-- ============================================================================
-- MODULE INTEGRATIONS : Endpoint API externe avec rate limit
-- ============================================================================

CREATE url:github_api_issues SET
    identity = {
        id: url:github_api_issues,
        value: 'github_api_issues',
        slug: 'github-api-issues'
    },
    presentation = {
        title_i18n: i18n_key:url_github_api_issues_title,
        icon: '🔗'
    },
    url = {
        href: 'https://api.github.com/repos/{owner}/{repo}/issues',
        protocol: 'https',
        is_external: true
    },
    context = {
        module: 'integrations',
        usage_type: 'api_endpoint',
        tags: ['github', 'issues', 'rest-api']
    },
    extensions = {
        api: {
            rate_limit: {
                requests_per_minute: NONE,
                requests_per_hour: 5000,
                requests_per_day: NONE
            },
            requires_auth: true,
            auth_type: 'bearer'
        },
        http_validation: {
            is_verified: true,
            check_frequency: 'weekly'
        }
    },
    status = {
        is_active: true,
        source: 'extraction'
    },
    metadata = {
        related_records: [service:github, tool:github_issue_list]
    };

-- ============================================================================
-- MODULE STORAGE : URL de téléchargement de fichier
-- ============================================================================

CREATE url:download_user_export SET
    identity = {
        id: url:download_user_export,
        value: 'download_user_export',
        slug: 'download-user-export'
    },
    presentation = {
        title_i18n: i18n_key:url_download_user_export_title,
        icon: '📥'
    },
    url = {
        href: '/storage/exports/user_data_2025_10_30.zip',
        protocol: NONE,
        is_external: false
    },
    context = {
        module: 'storage',
        usage_type: 'download',
        tags: ['export', 'user-data', 'zip']
    },
    extensions = {
        asset: {
            mime_type: 'application/zip',
            size_bytes: 15728640
        },
        analytics: {
            view_count: 0,
            click_count: 1,
            last_clicked_at: time::now()
        }
    },
    status = {
        is_active: true,
        source: 'system_generated'
    },
    metadata = {
        owner_user_id: user:john_doe,
        notes: 'Export RGPD généré automatiquement'
    };

-- ============================================================================
-- REQUÊTES PAR MODULE
-- ============================================================================

-- URLs du module integrations (documentation API)
SELECT * FROM url 
WHERE context.module = 'integrations' 
AND context.usage_type = 'documentation';

-- URLs du module builder (assets images)
SELECT * FROM url 
WHERE context.module = 'builder' 
AND extensions.asset IS NOT NONE;

-- URLs du module automation (webhooks)
SELECT * FROM url 
WHERE context.module = 'automation' 
AND extensions.webhook IS NOT NONE;

-- ============================================================================
-- REQUÊTES PAR TYPE D'USAGE
-- ============================================================================

-- Toutes les documentations (tous modules)
SELECT * FROM url WHERE context.usage_type = 'documentation';

-- Tous les webhooks (tous modules)
SELECT * FROM url WHERE context.usage_type = 'webhook';

-- Tous les assets (images, fichiers)
SELECT * FROM url WHERE context.usage_type = 'asset';

-- ============================================================================
-- REQUÊTES PAR TAGS
-- ============================================================================

-- URLs avec le tag 'oauth2'
SELECT * FROM url WHERE 'oauth2' IN context.tags;

-- URLs avec plusieurs tags
SELECT * FROM url 
WHERE 'github' IN context.tags 
AND 'api' IN context.tags;

-- ============================================================================
-- REQUÊTES SUR LES EXTENSIONS
-- ============================================================================

-- URLs avec validation HTTP activée
SELECT * FROM url 
WHERE extensions.http_validation IS NOT NONE
AND extensions.http_validation.is_verified = true;

-- URLs en erreur (status code != 200)
SELECT * FROM url 
WHERE extensions.http_validation.last_status_code != 200
AND extensions.http_validation.last_status_code IS NOT NONE;

-- URLs avec rate limit défini
SELECT * FROM url 
WHERE extensions.api.rate_limit IS NOT NONE;

-- Assets images (largeur > 500px)
SELECT * FROM url 
WHERE extensions.asset.mime_type CONTAINS 'image'
AND extensions.asset.width > 500;

-- ============================================================================
-- ANALYTICS : URLs les plus cliquées
-- ============================================================================

SELECT 
    identity.slug,
    presentation.title_i18n,
    url.href,
    extensions.analytics.click_count
FROM url
WHERE extensions.analytics IS NOT NONE
AND status.is_active = true
ORDER BY extensions.analytics.click_count DESC
LIMIT 10;

-- ============================================================================
-- MISE À JOUR : Incrémenter compteur de clics
-- ============================================================================

UPDATE url:google_oauth2_docs SET
    extensions.analytics.click_count += 1,
    extensions.analytics.last_clicked_at = time::now();

-- ============================================================================
-- MISE À JOUR : Marquer une URL comme vérifiée
-- ============================================================================

UPDATE url:slack_api_docs SET
    extensions.http_validation.is_verified = true,
    extensions.http_validation.last_check_at = time::now(),
    extensions.http_validation.last_status_code = 200;

-- ============================================================================
-- MISE À JOUR : Désactiver une URL cassée
-- ============================================================================

UPDATE url:broken_link SET
    status.is_active = false,
    status.deactivation_reason = 'URL cassée - HTTP 404',
    extensions.http_validation.last_status_code = 404,
    metadata.notes = 'Page introuvable';

*/

