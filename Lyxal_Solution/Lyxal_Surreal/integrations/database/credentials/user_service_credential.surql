-- =============================================================================================
-- |
-- | Fichier : user_service_credential.surql
-- | Module : integrations > database > credentials
-- | Description : Credentials des utilisateurs pour chaque service
-- |
-- | Cette table stocke les credentials réels des utilisateurs pour chaque service
-- | (OAuth2 tokens, API Keys, Basic Auth). Les données sensibles doivent être
-- | chiffrées côté application avant stockage.
-- |
-- | Architecture:
-- | • Champs à PLAT : user_id, service_id, is_active (pour index/recherche)
-- | • Champs GROUPÉS : identity, credentials, metadata
-- |
-- | Tables référencées:
-- | • user : Utilisateurs du système
-- | • service : Services des providers
-- | • credential_type : Type de credential utilisé
-- | • i18n_key : Clés de traduction pour l'internationalisation
-- |
-- | Sécurité:
-- | • Les credentials sensibles doivent être CHIFFRÉS côté application avant INSERT
-- | • SurrealDB ne fournit PAS de chiffrement automatique au niveau des champs
-- | • Utiliser une bibliothèque de chiffrement côté application (ex: AES-256-GCM)
-- | • Le chiffrement en transit (TLS/SSL) est géré par SurrealDB automatiquement
-- | • Permissions granulaires : utilisateur voit/modifie uniquement ses credentials
-- |
-- | Fonctionnalités temps réel:
-- | • ETag automatique (UUID v7) pour détecter les changements
-- | • Support WebSocket via LIVE SELECT pour mise à jour UI en temps réel
-- |   (voir: integrations/documentation/webhook/WEBSOCKET_CREDENTIALS.md)
-- |
-- =============================================================================================

DEFINE TABLE IF NOT EXISTS user_service_credential TYPE NORMAL SCHEMAFULL
COMMENT 'Credentials des utilisateurs pour chaque service (OAuth2, API Key, Basic Auth) - À CHIFFRER côté application.'
PERMISSIONS
    FOR SELECT WHERE user_id = $auth.id OR $auth.role IN ["admin"]
    FOR CREATE WHERE user_id = $auth.id OR $auth.role IN ["admin"]
    FOR UPDATE WHERE user_id = $auth.id OR $auth.role IN ["admin"]
    FOR DELETE WHERE user_id = $auth.id OR $auth.role IN ["admin"];

-- =====================================================
-- CHAMPS À PLAT (pour index et recherche)
-- =====================================================

DEFINE FIELD IF NOT EXISTS user_id ON user_service_credential 
    TYPE record<user>
    ASSERT $value != NONE
    COMMENT 'Utilisateur propriétaire de la credential.';

DEFINE FIELD IF NOT EXISTS service_id ON user_service_credential 
    TYPE record<service>
    ASSERT $value != NONE
    COMMENT 'Service associé à cette credential.';

DEFINE FIELD IF NOT EXISTS credential_type_id ON user_service_credential 
    TYPE record<credential_type>
    ASSERT $value != NONE
    COMMENT 'Type de credential utilisé (OAuth2, API Key, Basic Auth).';

DEFINE FIELD IF NOT EXISTS is_active ON user_service_credential 
    TYPE bool
    DEFAULT true
    COMMENT 'Indique si la credential est active et utilisable.';

-- =====================================================
-- OBJET: identity (Informations d'identification)
-- =====================================================

DEFINE FIELD IF NOT EXISTS identity ON user_service_credential 
    TYPE object
    COMMENT 'Informations d\'identification de la credential.';

DEFINE FIELD IF NOT EXISTS identity.name ON user_service_credential 
    TYPE string
    ASSERT $value != NONE AND string::len($value) > 0
    COMMENT 'Nom de la credential (ex: "Mon compte Slack", "API Key Production").';

DEFINE FIELD IF NOT EXISTS identity.description_i18n ON user_service_credential 
    TYPE option<record<i18n_key>>
    REFERENCE ON DELETE REJECT
    COMMENT 'Description multilingue de la credential (optionnel).';

-- =====================================================
-- OBJET: credentials (Données sensibles - À CHIFFRER)
-- =====================================================

DEFINE FIELD IF NOT EXISTS credentials ON user_service_credential 
    TYPE object
    COMMENT 'Données de credentials (À CHIFFRER côté application avant stockage).';

-- OAuth2
DEFINE FIELD IF NOT EXISTS credentials.oauth2 ON user_service_credential 
    TYPE option<object>
    COMMENT 'Credentials OAuth2 (si credential_type est OAuth2).';

DEFINE FIELD IF NOT EXISTS credentials.oauth2.access_token ON user_service_credential 
    TYPE option<string>
    COMMENT 'Access token (chiffré).';

DEFINE FIELD IF NOT EXISTS credentials.oauth2.refresh_token ON user_service_credential 
    TYPE option<string>
    COMMENT 'Refresh token (chiffré).';

DEFINE FIELD IF NOT EXISTS credentials.oauth2.token_type ON user_service_credential 
    TYPE option<string>
    DEFAULT 'Bearer'
    COMMENT 'Type de token (Bearer, etc.).';

DEFINE FIELD IF NOT EXISTS credentials.oauth2.expires_at ON user_service_credential 
    TYPE option<datetime>
    COMMENT 'Date d\'expiration du access token.';

DEFINE FIELD IF NOT EXISTS credentials.oauth2.scope ON user_service_credential 
    TYPE option<string>
    COMMENT 'Scopes accordés (ex: "read:user write:message").';

-- API Key
DEFINE FIELD IF NOT EXISTS credentials.api_key ON user_service_credential 
    TYPE option<object>
    COMMENT 'Credentials API Key (si credential_type est API Key).';

DEFINE FIELD IF NOT EXISTS credentials.api_key.key ON user_service_credential 
    TYPE option<string>
    COMMENT 'Clé API (chiffrée).';

DEFINE FIELD IF NOT EXISTS credentials.api_key.header_name ON user_service_credential 
    TYPE option<string>
    COMMENT 'Nom du header (ex: "X-API-Key", "Authorization", "Accesskey").';

DEFINE FIELD IF NOT EXISTS credentials.api_key.query_param_name ON user_service_credential 
    TYPE option<string>
    COMMENT 'Nom du paramètre query si utilisé en query param (ex: "api_key").';

-- Basic Auth
DEFINE FIELD IF NOT EXISTS credentials.basic_auth ON user_service_credential 
    TYPE option<object>
    COMMENT 'Credentials Basic Auth (si credential_type est Basic Auth).';

DEFINE FIELD IF NOT EXISTS credentials.basic_auth.username ON user_service_credential 
    TYPE option<string>
    COMMENT 'Username (chiffré).';

DEFINE FIELD IF NOT EXISTS credentials.basic_auth.password ON user_service_credential 
    TYPE option<string>
    COMMENT 'Password (chiffré).';

-- Custom (pour autres types d'auth)
DEFINE FIELD IF NOT EXISTS credentials.custom ON user_service_credential 
    TYPE option<object>
    COMMENT 'Credentials custom pour types d\'authentification non standards.';

-- =====================================================
-- OBJET: metadata (Métadonnées système)
-- =====================================================

DEFINE FIELD IF NOT EXISTS metadata ON user_service_credential 
    TYPE object
    COMMENT 'Métadonnées système.';

DEFINE FIELD IF NOT EXISTS metadata.created_at ON user_service_credential 
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT 'Date de création.';

DEFINE FIELD IF NOT EXISTS metadata.updated_at ON user_service_credential 
    TYPE datetime
    DEFAULT ALWAYS time::now()
    READONLY
    COMMENT 'Date de dernière modification.';

DEFINE FIELD IF NOT EXISTS metadata.last_used_at ON user_service_credential 
    TYPE option<datetime>
    COMMENT 'Dernière utilisation de la credential.';

DEFINE FIELD IF NOT EXISTS metadata.usage_count ON user_service_credential 
    TYPE int
    DEFAULT 0
    COMMENT 'Nombre d\'utilisations de la credential.';

DEFINE FIELD IF NOT EXISTS metadata.last_refreshed_at ON user_service_credential 
    TYPE option<datetime>
    COMMENT 'Dernière actualisation (pour OAuth2 refresh token).';

-- =====================================================
-- CHAMPS: EXPIRATION
-- =====================================================

DEFINE FIELD IF NOT EXISTS expires_at ON user_service_credential 
    TYPE option<datetime>
    COMMENT 'Date d\'expiration globale (pour refresh automatique).';

-- =====================================================
-- CHAMPS: ETAG
-- =====================================================

DEFINE FIELD IF NOT EXISTS etag ON user_service_credential 
    TYPE uuid
    READONLY
    DEFAULT ALWAYS rand::uuid::v7()
    COMMENT 'ETag pour optimistic locking et Live Queries. Change à chaque modification.';

-- =====================================================
-- INDEX (Performance et contraintes)
-- =====================================================

DEFINE INDEX IF NOT EXISTS idx_user_service_credential_user_service ON user_service_credential 
    FIELDS user_id, service_id, is_active
    COMMENT 'Index pour récupération rapide des credentials actives d\'un utilisateur pour un service.';

DEFINE INDEX IF NOT EXISTS idx_user_service_credential_active ON user_service_credential 
    FIELDS is_active
    COMMENT 'Index sur statut actif.';

DEFINE INDEX IF NOT EXISTS idx_user_service_credential_user ON user_service_credential 
    FIELDS user_id
    COMMENT 'Index pour liste des credentials d\'un utilisateur.';

DEFINE INDEX IF NOT EXISTS idx_user_service_credential_expires ON user_service_credential 
    FIELDS expires_at
    COMMENT 'Index pour trouver les credentials expirées.';

-- =====================================================
-- NOTES TECHNIQUES
-- =====================================================

-- 1. CHIFFREMENT:
--    Les credentials sensibles (tokens, keys, passwords) doivent être chiffrés
--    côté application AVANT l'INSERT dans SurrealDB. SurrealDB ne fournit PAS
--    de chiffrement automatique au niveau des champs. Utiliser une bibliothèque
--    de chiffrement côté application (ex: AES-256-GCM, ChaCha20-Poly1305).
--    
--    SurrealDB gère automatiquement le chiffrement en transit (TLS/SSL) mais
--    pas le chiffrement au repos au niveau des champs individuels.

-- 2. PERMISSIONS:
--    - SELECT: Utilisateur voit uniquement ses propres credentials + admins voient tout
--    - CREATE/UPDATE/DELETE: Utilisateur modifie uniquement ses propres credentials + admins modifient tout

-- 3. EXPIRATION:
--    - expires_at global: Pour gestion automatique de refresh
--    - credentials.oauth2.expires_at: Pour le access token spécifique
--    - Vérifier expiration avant utilisation dans fn::execute_tool

-- 4. ETAG:
--    Change automatiquement à chaque UPDATE grâce à SurrealDB.
--    Utilisé pour optimistic locking et Live Queries.

-- 5. UNICITÉ:
--    Un utilisateur peut avoir plusieurs credentials pour le même service
--    (ex: credential personnelle + credential équipe). Utiliser identity.name pour distinguer.

-- =============================================================================================
-- FIN DU FICHIER user_service_credential.surql
-- =============================================================================================

