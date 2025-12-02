-- ============================================================
-- TABLE: audit_log
-- Namespace: LYXAL_IDENTITY / Database: CORE
-- Description: Traçabilité des actions de sécurité (Immutable).
-- ============================================================

DEFINE TABLE IF NOT EXISTS audit_log TYPE NORMAL SCHEMAFULL
    PERMISSIONS NONE; -- Personne ne touche, même pas en update

-- CHAMPS
DEFINE FIELD IF NOT EXISTS action ON TABLE audit_log 
    TYPE string 
    COMMENT "Event type (login_success, login_failed, password_changed...)";

DEFINE FIELD IF NOT EXISTS identity_id ON TABLE audit_log 
    TYPE record<identity> 
    COMMENT "Identité concernée (si connue)";

DEFINE FIELD IF NOT EXISTS actor_ip ON TABLE audit_log 
    TYPE string;

DEFINE FIELD IF NOT EXISTS metadata ON TABLE audit_log 
    TYPE object 
    DEFAULT {};

DEFINE FIELD IF NOT EXISTS created_at ON TABLE audit_log 
    TYPE datetime 
    DEFAULT time::now() 
    READONLY;

