-- ============================================================
-- TABLE: auth_flow
-- Namespace: LYXAL_IDENTITY / Database: CORE
-- Description: Stocke l'état temporaire d'un flux d'authentification en cours.
-- ============================================================

DEFINE TABLE IF NOT EXISTS auth_flow TYPE NORMAL SCHEMAFULL
    PERMISSIONS NONE; -- Interne uniquement

-- CHAMPS
DEFINE FIELD IF NOT EXISTS type ON TABLE auth_flow 
    TYPE string 
    ASSERT $value INSIDE ['login', 'signup', 'reset_password', 'mfa_challenge']
    COMMENT "Type de flux";

DEFINE FIELD IF NOT EXISTS stage ON TABLE auth_flow 
    TYPE string 
    DEFAULT 'identify'
    COMMENT "Étape actuelle (identify, verify_email, completed)";

DEFINE FIELD IF NOT EXISTS email ON TABLE auth_flow 
    TYPE string 
    COMMENT "Email concerné (si connu)";

DEFINE FIELD IF NOT EXISTS identity_id ON TABLE auth_flow 
    TYPE record<identity> 
    COMMENT "Identité liée (si identifiée)";

DEFINE FIELD IF NOT EXISTS expires_at ON TABLE auth_flow 
    TYPE datetime 
    COMMENT "Expiration du flux (ex: 15min)";

DEFINE FIELD IF NOT EXISTS created_at ON TABLE auth_flow 
    TYPE datetime 
    DEFAULT time::now() 
    READONLY;

-- INDEX
-- Nettoyage automatique ? (SurrealDB n'a pas de TTL natif simple, géré par CRON ou Query)

