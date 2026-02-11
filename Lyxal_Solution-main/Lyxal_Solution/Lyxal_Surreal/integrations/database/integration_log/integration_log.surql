-- =============================================================================================
-- |
-- | Fichier : integration_log.surql
-- | Module : integrations > database > integration_log
-- | Description : Logs de tous les appels API via fn::execute_tool
-- |
-- | Cette table enregistre tous les appels API effectués via fn::execute_tool pour
-- | traçabilité, debugging, analytics et monitoring.
-- |
-- | Architecture:
-- | • Champs à PLAT : user_id, service_id, status (pour index/recherche)
-- | • Champs GROUPÉS : identity, request, response, error, metadata
-- |
-- | Tables référencées:
-- | • user : Utilisateurs du système
-- | • service : Services des providers
-- | • tool : Tools utilisés
-- | • provider : Providers (dérivé du service)
-- |
-- | Sécurité:
-- | • Anonymisation des données sensibles (tokens, passwords) avant stockage
-- | • Permissions granulaires : utilisateur voit uniquement ses propres logs
-- |
-- | Performance:
-- | • Index optimisés pour requêtes fréquentes (user_id + timestamp, service_id + timestamp)
-- | • Rotation/archivage recommandé pour logs anciens (> 90 jours)
-- |
-- =============================================================================================

DEFINE TABLE IF NOT EXISTS integration_log TYPE NORMAL SCHEMAFULL
COMMENT 'Logs de tous les appels API via fn::execute_tool - Traçabilité, debugging, analytics.'
PERMISSIONS
    FOR SELECT WHERE user_id = $auth.id OR $auth.role IN ["admin", "analyst"]
    FOR CREATE NONE  -- Créé uniquement par fn::execute_tool
    FOR UPDATE NONE
    FOR DELETE WHERE $auth.role = "admin";

-- =====================================================
-- CHAMPS À PLAT (pour index et recherche)
-- =====================================================

DEFINE FIELD IF NOT EXISTS user_id ON integration_log 
    TYPE record<user>
    ASSERT $value != NONE
    COMMENT 'Utilisateur ayant effectué l\'appel.';

DEFINE FIELD IF NOT EXISTS service_id ON integration_log 
    TYPE record<service>
    ASSERT $value != NONE
    COMMENT 'Service appelé.';

DEFINE FIELD IF NOT EXISTS tool_id ON integration_log 
    TYPE option<record<tool>>
    COMMENT 'Tool utilisé (optionnel si erreur avant tool).';

DEFINE FIELD IF NOT EXISTS provider_id ON integration_log 
    TYPE option<record<provider>>
    COMMENT 'Provider (dérivé du service).';

DEFINE FIELD IF NOT EXISTS status ON integration_log 
    TYPE string
    ASSERT $value IN ['success', 'failed', 'exception', 'timeout', 'cancelled']
    COMMENT 'Statut de l\'appel.';

-- =====================================================
-- OBJET: identity (Identification du log)
-- =====================================================

DEFINE FIELD IF NOT EXISTS identity ON integration_log 
    TYPE object
    COMMENT 'Identification du log.';

DEFINE FIELD IF NOT EXISTS identity.log_type ON integration_log 
    TYPE string
    ASSERT $value IN ['api_call', 'error', 'retry', 'refresh_token']
    DEFAULT 'api_call'
    COMMENT 'Type de log: api_call, error, retry, refresh_token.';

DEFINE FIELD IF NOT EXISTS identity.request_id ON integration_log 
    TYPE option<string>
    COMMENT 'ID unique de la requête (pour traçabilité, ex: UUID).';

-- =====================================================
-- OBJET: request (Détails de la requête)
-- =====================================================

DEFINE FIELD IF NOT EXISTS request ON integration_log 
    TYPE object
    COMMENT 'Détails de la requête HTTP.';

DEFINE FIELD IF NOT EXISTS request.method ON integration_log 
    TYPE string
    ASSERT $value IN ['GET', 'POST', 'PUT', 'PATCH', 'DELETE']
    COMMENT 'Méthode HTTP (GET, POST, PUT, DELETE).';

DEFINE FIELD IF NOT EXISTS request.url ON integration_log 
    TYPE string
    COMMENT 'URL complète appelée (anonymisée si contient credentials).';

DEFINE FIELD IF NOT EXISTS request.endpoint ON integration_log 
    TYPE option<string>
    COMMENT 'Endpoint relatif (ex: "/conversations.create").';

DEFINE FIELD IF NOT EXISTS request.has_body ON integration_log 
    TYPE bool
    DEFAULT false
    COMMENT 'Si la requête avait un body.';

DEFINE FIELD IF NOT EXISTS request.body_size ON integration_log 
    TYPE option<int>
    COMMENT 'Taille du body en bytes.';

-- =====================================================
-- OBJET: response (Détails de la réponse)
-- =====================================================

DEFINE FIELD IF NOT EXISTS response ON integration_log 
    TYPE option<object>
    COMMENT 'Détails de la réponse HTTP.';

DEFINE FIELD IF NOT EXISTS response.status_code ON integration_log 
    TYPE option<int>
    COMMENT 'Code HTTP de réponse (200, 201, 400, 401, 404, 500, etc.).';

DEFINE FIELD IF NOT EXISTS response.duration_ms ON integration_log 
    TYPE option<int>
    COMMENT 'Durée de l\'appel en millisecondes.';

DEFINE FIELD IF NOT EXISTS response.size_bytes ON integration_log 
    TYPE option<int>
    COMMENT 'Taille de la réponse en bytes.';

-- =====================================================
-- OBJET: error (Détails de l'erreur si échec)
-- =====================================================

DEFINE FIELD IF NOT EXISTS error ON integration_log 
    TYPE option<object>
    COMMENT 'Détails de l\'erreur si échec.';

DEFINE FIELD IF NOT EXISTS error.code ON integration_log 
    TYPE option<string>
    COMMENT 'Code d\'erreur (ex: api_error, credentials_not_found, rate_limit_exceeded).';

DEFINE FIELD IF NOT EXISTS error.message ON integration_log 
    TYPE option<string>
    COMMENT 'Message d\'erreur (anonymisé si contient credentials).';

DEFINE FIELD IF NOT EXISTS error.is_retryable ON integration_log 
    TYPE option<bool>
    COMMENT 'Si l\'erreur est réessayable.';

DEFINE FIELD IF NOT EXISTS error.http_code ON integration_log 
    TYPE option<int>
    COMMENT 'Code HTTP d\'erreur (si applicable).';

-- =====================================================
-- OBJET: metadata (Métadonnées additionnelles)
-- =====================================================

DEFINE FIELD IF NOT EXISTS metadata ON integration_log 
    TYPE object
    COMMENT 'Métadonnées additionnelles.';

DEFINE FIELD IF NOT EXISTS metadata.timestamp ON integration_log 
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT 'Date/heure de l\'appel.';

DEFINE FIELD IF NOT EXISTS metadata.user_agent ON integration_log 
    TYPE option<string>
    COMMENT 'User agent de l\'appel (si disponible).';

DEFINE FIELD IF NOT EXISTS metadata.ip_address ON integration_log 
    TYPE option<string>
    COMMENT 'Adresse IP (anonymisée, ex: "192.168.1.xxx").';

DEFINE FIELD IF NOT EXISTS metadata.environment ON integration_log 
    TYPE option<string>
    COMMENT 'Environnement (production, staging, development).';

-- =====================================================
-- INDEX (Performance et contraintes)
-- =====================================================

DEFINE INDEX IF NOT EXISTS idx_integration_log_user_timestamp ON integration_log 
    FIELDS user_id, metadata.timestamp
    COMMENT 'Index pour historique utilisateur (tri chronologique).';

DEFINE INDEX IF NOT EXISTS idx_integration_log_service_timestamp ON integration_log 
    FIELDS service_id, metadata.timestamp
    COMMENT 'Index pour statistiques service (tri chronologique).';

DEFINE INDEX IF NOT EXISTS idx_integration_log_tool_timestamp ON integration_log 
    FIELDS tool_id, metadata.timestamp
    COMMENT 'Index pour statistiques tool (tri chronologique).';

DEFINE INDEX IF NOT EXISTS idx_integration_log_status ON integration_log 
    FIELDS status, metadata.timestamp
    COMMENT 'Index pour filtrage par statut (success, failed, etc.).';

DEFINE INDEX IF NOT EXISTS idx_integration_log_timestamp ON integration_log 
    FIELDS metadata.timestamp
    COMMENT 'Index pour tri chronologique global.';

DEFINE INDEX IF NOT EXISTS idx_integration_log_request_id ON integration_log 
    FIELDS identity.request_id
    COMMENT 'Index pour recherche par request_id (traçabilité).';

-- =====================================================
-- EXEMPLES D'UTILISATION
-- =====================================================

-- EXEMPLE 1: Requête - Historique des appels d'un utilisateur (dernières 24h)
/*
SELECT 
    metadata.timestamp,
    service_id.identity.display_name_i18n.* AS service_name,
    tool_id.identity.display_name_i18n.* AS tool_name,
    request.method,
    request.endpoint,
    response.status_code,
    response.duration_ms,
    status
FROM integration_log
WHERE user_id = user:john_doe
AND metadata.timestamp > time::now() - 1d
ORDER BY metadata.timestamp DESC
LIMIT 100;
*/

-- EXEMPLE 2: Requête - Statistiques par service (dernières 24h)
/*
SELECT 
    service_id,
    count() AS total_calls,
    count() FILTER (WHERE status = 'success') AS success_calls,
    count() FILTER (WHERE status = 'failed') AS failed_calls,
    math::mean(response.duration_ms) AS avg_duration_ms,
    math::max(response.duration_ms) AS max_duration_ms
FROM integration_log
WHERE metadata.timestamp > time::now() - 1d
GROUP BY service_id
ORDER BY total_calls DESC;
*/

-- EXEMPLE 3: Requête - Appels les plus lents
/*
SELECT 
    tool_id,
    request.url,
    response.duration_ms,
    metadata.timestamp
FROM integration_log
WHERE status = 'success'
AND response.duration_ms IS NOT NONE
ORDER BY response.duration_ms DESC
LIMIT 10;
*/

-- EXEMPLE 4: Requête - Taux d'erreur par tool
/*
SELECT 
    tool_id,
    count() AS total_calls,
    count() FILTER (WHERE status = 'success') AS success,
    count() FILTER (WHERE status = 'failed') AS failed,
    (count() FILTER (WHERE status = 'failed') * 100.0 / count()) AS error_rate_percent
FROM integration_log
WHERE metadata.timestamp > time::now() - 7d
GROUP BY tool_id
HAVING error_rate_percent > 5
ORDER BY error_rate_percent DESC;
*/

-- EXEMPLE 5: Requête - Erreurs nécessitant attention
/*
SELECT 
    metadata.timestamp,
    service_id,
    tool_id,
    error.code,
    error.message,
    error.is_retryable
FROM integration_log
WHERE status = 'failed'
AND metadata.timestamp > time::now() - 1d
ORDER BY metadata.timestamp DESC;
*/

-- =====================================================
-- NOTES TECHNIQUES
-- =====================================================

-- 1. ANONYMISATION:
--    Les données sensibles (tokens, passwords, API keys) doivent être anonymisées
--    avant stockage dans request.url, error.message, etc.
--    Exemple: "https://api.example.com/v1/users?token=abc123" → "https://api.example.com/v1/users?token=***"

-- 2. PERFORMANCE:
--    Cette table peut devenir très volumineuse. Recommandations:
--    - Rotation: Archiver les logs > 90 jours dans une table séparée
--    - Partitioning: Créer des tables par mois/année si nécessaire
--    - Index: Optimisés pour requêtes fréquentes (user_id + timestamp)

-- 3. PERMISSIONS:
--    - SELECT: Utilisateur voit uniquement ses propres logs + admins/analysts voient tout
--    - CREATE: Réservé à fn::execute_tool (aucun utilisateur ne peut créer directement)
--    - UPDATE: Interdit (logs immutables)
--    - DELETE: Réservé aux admins (pour nettoyage/rotation)

-- 4. STORAGE:
--    Ne pas stocker les bodies complets de requête/réponse (risque de taille).
--    Utiliser request.has_body et request.body_size pour métadonnées.

-- 5. RETRY:
--    Chaque retry crée un nouveau log avec identity.log_type = 'retry'.
--    Utiliser identity.request_id pour lier les retries au log original.

-- =============================================================================================
-- FIN DU FICHIER integration_log.surql
-- =============================================================================================

