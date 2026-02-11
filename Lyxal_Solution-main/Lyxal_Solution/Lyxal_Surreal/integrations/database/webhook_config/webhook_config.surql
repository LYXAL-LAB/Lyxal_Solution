-- =============================================================================================
-- |
-- | Fichier : webhook_config.surql
-- | Module : integrations > database > webhook_config
-- | Description : Configuration des webhooks avec DEFINE API SurrealDB natif
-- |
-- | Cette table configure les webhooks pour recevoir des événements en temps réel depuis
-- | les services externes. Utilise DEFINE API SurrealDB (v2.2.0+) pour créer des endpoints
-- | HTTP natifs sans serveur Node.js.
-- |
-- | Architecture:
-- | • Champs à PLAT : service_id, is_active (pour index/recherche)
-- | • Champs GROUPÉS : identity, external_config, surreal_api, presentation, metadata
-- |
-- | Tables référencées:
-- | • service : Services des providers
-- | • provider : Providers (dérivé du service)
-- | • i18n_key : Clés de traduction pour l'internationalisation
-- | • icon : Icônes pour l'UI
-- |
-- | Fonctionnalités:
-- | • Configuration pour créer le webhook côté service externe (external_config)
-- | • Configuration pour l'endpoint SurrealDB DEFINE API (surreal_api)
-- | • Vérification de signature automatique
-- | • Support multi-événements (un webhook peut recevoir plusieurs types d'événements)
-- |
-- =============================================================================================

DEFINE TABLE IF NOT EXISTS webhook_config TYPE NORMAL SCHEMAFULL
COMMENT 'Configuration des webhooks avec DEFINE API SurrealDB natif - Recevoir des événements en temps réel.'
PERMISSIONS
    FOR SELECT FULL
    FOR CREATE, UPDATE, DELETE WHERE $auth.role IN ["admin", "editor"];

-- =====================================================
-- CHAMPS À PLAT (pour index et recherche)
-- =====================================================

DEFINE FIELD IF NOT EXISTS service_id ON webhook_config 
    TYPE record<service>
    ASSERT $value != NONE
    COMMENT 'Service associé à ce webhook.';

DEFINE FIELD IF NOT EXISTS provider_id ON webhook_config 
    TYPE option<record<provider>>
    COMMENT 'Provider (dérivé du service, pour recherche rapide).';

DEFINE FIELD IF NOT EXISTS is_active ON webhook_config 
    TYPE bool
    DEFAULT true
    COMMENT 'Indique si le webhook est actif.';

-- =====================================================
-- OBJET: identity (Identification du webhook)
-- =====================================================

DEFINE FIELD IF NOT EXISTS identity ON webhook_config 
    TYPE object
    COMMENT 'Identification du webhook.';

DEFINE FIELD IF NOT EXISTS identity.event_name ON webhook_config 
    TYPE string
    ASSERT $value != NONE AND string::len($value) > 0
    COMMENT 'Nom de l\'événement (ex: "message.channels", "app_mention", "reaction_added").';

DEFINE FIELD IF NOT EXISTS identity.display_name_i18n ON webhook_config 
    TYPE record<i18n_key>
    REFERENCE ON DELETE REJECT
    ASSERT $value != NONE
    COMMENT 'Nom affiché multilingue (ex: "Nouveau message dans un canal").';

DEFINE FIELD IF NOT EXISTS identity.description_i18n ON webhook_config 
    TYPE option<record<i18n_key>>
    REFERENCE ON DELETE REJECT
    COMMENT 'Description multilingue de l\'événement.';

-- =====================================================
-- OBJET: external_config (Configuration pour créer le webhook côté service externe)
-- =====================================================

DEFINE FIELD IF NOT EXISTS external_config ON webhook_config 
    TYPE option<object>
    COMMENT 'Configuration pour créer le webhook chez le service externe.';

DEFINE FIELD IF NOT EXISTS external_config.creation_endpoint ON webhook_config 
    TYPE option<string>
    COMMENT 'Endpoint API pour créer le webhook (ex: "/api/webhooks/create").';

DEFINE FIELD IF NOT EXISTS external_config.creation_method ON webhook_config 
    TYPE option<string>
    ASSERT $value == NONE OR $value IN ['GET', 'POST', 'PUT', 'PATCH']
    DEFAULT 'POST'
    COMMENT 'Méthode HTTP pour créer le webhook.';

DEFINE FIELD IF NOT EXISTS external_config.creation_body_template ON webhook_config 
    TYPE option<object>
    COMMENT 'Template du body de création. Variables: {{webhook_url}}, {{event_name}}.';

DEFINE FIELD IF NOT EXISTS external_config.deletion_endpoint ON webhook_config 
    TYPE option<string>
    COMMENT 'Endpoint API pour supprimer le webhook (ex: "/api/webhooks/{webhook_id}").';

DEFINE FIELD IF NOT EXISTS external_config.deletion_method ON webhook_config 
    TYPE option<string>
    ASSERT $value == NONE OR $value IN ['DELETE', 'POST']
    DEFAULT 'DELETE'
    COMMENT 'Méthode HTTP pour supprimer le webhook.';

DEFINE FIELD IF NOT EXISTS external_config.deletion_body_template ON webhook_config 
    TYPE option<object>
    COMMENT 'Template du body de suppression (si nécessaire).';

-- Signature verification
DEFINE FIELD IF NOT EXISTS external_config.signature_verification ON webhook_config 
    TYPE option<object>
    COMMENT 'Configuration de vérification de signature.';

DEFINE FIELD IF NOT EXISTS external_config.signature_verification.enabled ON webhook_config 
    TYPE bool
    DEFAULT true
    COMMENT 'Si la vérification de signature est activée.';

DEFINE FIELD IF NOT EXISTS external_config.signature_verification.header_name ON webhook_config 
    TYPE option<string>
    COMMENT 'Nom du header contenant la signature (ex: "X-Slack-Signature", "X-Hub-Signature-256").';

DEFINE FIELD IF NOT EXISTS external_config.signature_verification.algorithm ON webhook_config 
    TYPE option<string>
    ASSERT $value == NONE OR $value IN ['sha256', 'sha1', 'hmac-sha256', 'hmac-sha1']
    DEFAULT 'sha256'
    COMMENT 'Algorithme de signature: sha256, sha1, hmac-sha256, hmac-sha1.';

DEFINE FIELD IF NOT EXISTS external_config.signature_verification.secret_field ON webhook_config 
    TYPE option<string>
    COMMENT 'Champ dans user_service_credential contenant le secret (ex: "webhook_secret").';

DEFINE FIELD IF NOT EXISTS external_config.signature_verification.timestamp_header ON webhook_config 
    TYPE option<string>
    COMMENT 'Header contenant le timestamp (ex: "X-Slack-Request-Timestamp") pour vérifier l\'expiration.';

DEFINE FIELD IF NOT EXISTS external_config.signature_verification.timestamp_tolerance_seconds ON webhook_config 
    TYPE option<int>
    DEFAULT 300
    COMMENT 'Tolérance en secondes pour vérifier l\'expiration du timestamp (défaut: 5 minutes).';

-- =====================================================
-- OBJET: surreal_api (Configuration de l'endpoint SurrealDB DEFINE API)
-- =====================================================

DEFINE FIELD IF NOT EXISTS surreal_api ON webhook_config 
    TYPE option<object>
    COMMENT 'Configuration de l\'endpoint SurrealDB DEFINE API.';

DEFINE FIELD IF NOT EXISTS surreal_api.path ON webhook_config 
    TYPE option<string>
    COMMENT 'Chemin de l\'endpoint (ex: "/slack/message", "/github/webhook")'
    ASSERT $value == NONE OR string::starts_with($value, '/')
    COMMENT 'Doit commencer par "/".';

DEFINE FIELD IF NOT EXISTS surreal_api.methods ON webhook_config 
    TYPE option<array<string>>
    COMMENT 'Méthodes HTTP supportées (ex: ["POST"], ["GET", "POST"]).';

DEFINE FIELD IF NOT EXISTS surreal_api.middleware ON webhook_config 
    TYPE option<array<string>>
    COMMENT 'Fonctions middleware (ex: ["api::req::raw_body(false)", "fn::verify_slack_signature"]).';

DEFINE FIELD IF NOT EXISTS surreal_api.handler_function ON webhook_config 
    TYPE option<string>
    COMMENT 'Fonction de traitement (ex: "fn::handle_slack_message", "fn::handle_github_webhook").';

DEFINE FIELD IF NOT EXISTS surreal_api.permissions ON webhook_config 
    TYPE option<string>
    COMMENT 'Permissions SurrealQL (ex: "FULL" ou "WHERE ...").';

DEFINE FIELD IF NOT EXISTS surreal_api.auto_create ON webhook_config 
    TYPE bool
    DEFAULT false
    COMMENT 'Si l\'endpoint DEFINE API doit être créé automatiquement lors de l\'activation.';

-- =====================================================
-- OBJET: presentation (Présentation UI)
-- =====================================================

DEFINE FIELD IF NOT EXISTS presentation ON webhook_config 
    TYPE object
    COMMENT 'Présentation visuelle dans l\'UI.';

DEFINE FIELD IF NOT EXISTS presentation.icon ON webhook_config 
    TYPE option<record<icon>>
    REFERENCE ON DELETE REJECT
    COMMENT 'Icône représentant l\'événement.';

DEFINE FIELD IF NOT EXISTS presentation.color_type ON webhook_config 
    TYPE option<record<theme_color_type>>
    REFERENCE ON DELETE REJECT
    COMMENT 'Type de couleur pour les tags/badges dans l\'UI (référence vers theme_color_type: primary, error, warning, etc.).';

DEFINE FIELD IF NOT EXISTS presentation.display_order ON webhook_config 
    TYPE int
    DEFAULT 0
    COMMENT 'Ordre d\'affichage dans l\'UI (0 = premier).';

DEFINE FIELD IF NOT EXISTS presentation.badge_text ON webhook_config 
    TYPE option<string>
    COMMENT 'Texte du badge (ex: "Real-time", "Recommended", "Beta").';

DEFINE FIELD IF NOT EXISTS presentation.badge_color ON webhook_config 
    TYPE option<string>
    ASSERT $value == NONE OR string::starts_with($value, '#')
    COMMENT 'Couleur du badge (hexadécimale).';

-- =====================================================
-- OBJET: metadata (Métadonnées système)
-- =====================================================

DEFINE FIELD IF NOT EXISTS metadata ON webhook_config 
    TYPE object
    COMMENT 'Métadonnées système.';

DEFINE FIELD IF NOT EXISTS metadata.created_at ON webhook_config 
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT 'Date de création.';

DEFINE FIELD IF NOT EXISTS metadata.updated_at ON webhook_config 
    TYPE datetime
    DEFAULT ALWAYS time::now()
    READONLY
    COMMENT 'Date de dernière modification.';

DEFINE FIELD IF NOT EXISTS metadata.version ON webhook_config 
    TYPE int
    DEFAULT 1
    COMMENT 'Version de la configuration.';

DEFINE FIELD IF NOT EXISTS metadata.created_by ON webhook_config 
    TYPE option<record<user>>
    REFERENCE ON DELETE REJECT
    COMMENT 'Utilisateur ayant créé la configuration.';

DEFINE FIELD IF NOT EXISTS metadata.updated_by ON webhook_config 
    TYPE option<record<user>>
    REFERENCE ON DELETE REJECT
    COMMENT 'Utilisateur ayant modifié la configuration.';

DEFINE FIELD IF NOT EXISTS metadata.webhook_url ON webhook_config 
    TYPE option<string>
    COMMENT 'URL complète du webhook (ex: "https://lyxal-db.com/api/namespace/database/slack/message").';

DEFINE FIELD IF NOT EXISTS metadata.external_webhook_id ON webhook_config 
    TYPE option<string>
    COMMENT 'ID du webhook côté service externe (pour suppression).';

-- =====================================================
-- CHAMPS: ETAG
-- =====================================================

DEFINE FIELD IF NOT EXISTS etag ON webhook_config 
    TYPE string
    DEFAULT rand::uuid::v7()
    COMMENT 'ETag pour optimistic locking et Live Queries. Change à chaque modification.';

-- =====================================================
-- INDEX (Performance et contraintes)
-- =====================================================

DEFINE INDEX IF NOT EXISTS idx_webhook_config_service_event ON webhook_config 
    FIELDS service_id, identity.event_name, is_active
    COMMENT 'Index pour récupération rapide par service et événement.';

DEFINE INDEX IF NOT EXISTS idx_webhook_config_active ON webhook_config 
    FIELDS is_active
    COMMENT 'Index sur statut actif.';

DEFINE INDEX IF NOT EXISTS idx_webhook_config_path ON webhook_config 
    FIELDS surreal_api.path
    COMMENT 'Index pour recherche par chemin d\'endpoint.';

-- =====================================================
-- EXEMPLES D'UTILISATION
-- =====================================================

-- EXEMPLE 1: Configuration webhook Slack - Nouveau message
/*
CREATE webhook_config SET
    service_id = service:slack,
    provider_id = provider:slack,
    is_active = true,
    
    identity = {
        event_name: "message.channels",
        display_name_i18n: i18n_key:webhook_slack_message_channels_name,
        description_i18n: i18n_key:webhook_slack_message_channels_desc
    },
    
    external_config = {
        creation_endpoint: "/api/conversations.subscribe",
        creation_method: "POST",
        creation_body_template: {
            url: "{{webhook_url}}",
            events: ["message.channels"]
        },
        deletion_endpoint: "/api/conversations.unsubscribe",
        deletion_method: "POST",
        signature_verification: {
            enabled: true,
            header_name: "X-Slack-Signature",
            algorithm: "sha256",
            secret_field: "webhook_secret",
            timestamp_header: "X-Slack-Request-Timestamp",
            timestamp_tolerance_seconds: 300
        }
    },
    
    surreal_api = {
        path: "/slack/message",
        methods: ["POST"],
        middleware: [
            "api::req::raw_body(false)",
            "fn::verify_slack_signature"
        ],
        handler_function: "fn::handle_slack_message",
        permissions: "FULL",
        auto_create: true
    },
    
    presentation = {
        icon: icon:message,
        color: "#4A154B",
        display_order: 1,
        badge_text: "Real-time",
        badge_color: "#4CAF50"
    },
    
    metadata = {
        created_at: time::now(),
        updated_at: time::now(),
        version: 1,
        webhook_url: "https://lyxal-db.com/api/namespace/database/slack/message",
        external_webhook_id: NONE
    };
*/

-- EXEMPLE 2: Configuration webhook GitHub - Push event
/*
CREATE webhook_config SET
    service_id = service:github,
    provider_id = provider:github,
    is_active = true,
    
    identity = {
        event_name: "push",
        display_name_i18n: i18n_key:webhook_github_push_name,
        description_i18n: i18n_key:webhook_github_push_desc
    },
    
    external_config = {
        creation_endpoint: "/repos/{owner}/{repo}/hooks",
        creation_method: "POST",
        creation_body_template: {
            name: "web",
            active: true,
            events: ["push"],
            config: {
                url: "{{webhook_url}}",
                content_type: "json",
                secret: "{{webhook_secret}}"
            }
        },
        deletion_endpoint: "/repos/{owner}/{repo}/hooks/{hook_id}",
        deletion_method: "DELETE",
        signature_verification: {
            enabled: true,
            header_name: "X-Hub-Signature-256",
            algorithm: "sha256",
            secret_field: "webhook_secret",
            timestamp_header: NONE,
            timestamp_tolerance_seconds: NONE
        }
    },
    
    surreal_api = {
        path: "/github/webhook",
        methods: ["POST"],
        middleware: [
            "api::req::raw_body(false)",
            "fn::verify_github_signature"
        ],
        handler_function: "fn::handle_github_webhook",
        permissions: "FULL",
        auto_create: true
    },
    
    presentation = {
        icon: icon:git_push,
        color: "#24292e",
        display_order: 1,
        badge_text: NONE,
        badge_color: NONE
    },
    
    metadata = {
        created_at: time::now(),
        updated_at: time::now(),
        version: 1,
        webhook_url: "https://lyxal-db.com/api/namespace/database/github/webhook",
        external_webhook_id: NONE
    };
*/

-- EXEMPLE 3: Requête - Récupérer tous les webhooks actifs d'un service
/*
SELECT * FROM webhook_config
WHERE service_id = service:slack
AND is_active = true
ORDER BY presentation.display_order ASC;
*/

-- EXEMPLE 4: Requête - Trouver le webhook par chemin d'endpoint
/*
SELECT * FROM webhook_config
WHERE surreal_api.path = "/slack/message"
AND is_active = true
LIMIT 1;
*/

-- =====================================================
-- NOTES TECHNIQUES
-- =====================================================

-- 1. DEFINE API SURREALDB:
--    SurrealDB v2.2.0+ supporte DEFINE API pour créer des endpoints HTTP natifs.
--    Exemple de génération automatique:
--    DEFINE API surreal_api.path
--        FOR surreal_api.methods
--        MIDDLEWARE surreal_api.middleware
--        THEN surreal_api.handler_function;

-- 2. SIGNATURE VERIFICATION:
--    La vérification de signature se fait dans le middleware (ex: fn::verify_slack_signature).
--    Le secret est récupéré depuis user_service_credential.credentials.custom.webhook_secret.

-- 3. WEBHOOK URL:
--    Format: https://lyxal-db.com/api/{namespace}/{database}{surreal_api.path}
--    Exemple: https://lyxal-db.com/api/lyxal/production/slack/message

-- 4. HANDLER FUNCTION:
--    La fonction handler (ex: fn::handle_slack_message) doit:
--    - Vérifier la signature (si activée)
--    - Parser le body JSON
--    - Créer un événement dans une table dédiée (ex: webhook_event)
--    - Retourner un statut HTTP approprié

-- 5. EXTERNAL WEBHOOK CREATION:
--    Un script/worker doit créer le webhook côté service externe en utilisant
--    external_config.creation_endpoint et external_config.creation_body_template.
--    Stocker l'ID retourné dans metadata.external_webhook_id pour suppression ultérieure.

-- 6. PERMISSIONS:
--    - SELECT: Tous peuvent voir les configurations actives
--    - CREATE/UPDATE/DELETE: Réservé aux admins et editors

-- 7. AUTO_CREATE:
--    Si auto_create = true, un script doit générer automatiquement le DEFINE API
--    SurrealDB lors de l'activation du webhook.

-- =============================================================================================
-- FIN DU FICHIER webhook_config.surql
-- =============================================================================================

