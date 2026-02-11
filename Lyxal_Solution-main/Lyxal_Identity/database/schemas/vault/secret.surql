-- ============================================================
-- TABLE: secret (SÉCURITÉ & AUTHENTIFICATION)
-- Namespace: NS_IDENTITY_{UUID} (Vault Privé)
-- ============================================================

DEFINE IF NOT EXISTS TABLE secret TYPE NORMAL SCHEMAFULL
COMMENT "Secrets d'authentification (Mot de passe, MFA)"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS password_hash ON TABLE secret 
    TYPE option<string>
    COMMENT "Hash du mot de passe (Argon2id)";

DEFINE FIELD IF NOT EXISTS password_algo ON TABLE secret 
    TYPE option<string>
    DEFAULT 'Argon2id'
    ASSERT $value == NONE OR $value INSIDE ['Argon2id', 'Argon2i', 'Bcrypt', 'SHA256']
    COMMENT "Algorithme de hashage utilisé";

DEFINE FIELD IF NOT EXISTS mfa_verifications ON TABLE secret 
    TYPE array
    DEFAULT []
    COMMENT "Liste des dispositifs MFA (TOTP, WebAuthn)";

DEFINE FIELD IF NOT EXISTS password_changed_at ON TABLE secret 
    TYPE option<datetime>
    COMMENT "Date du dernier changement de mot de passe";

DEFINE FIELD IF NOT EXISTS created_at ON TABLE secret 
    TYPE datetime 
    DEFAULT time::now()
    READONLY;

DEFINE FIELD IF NOT EXISTS updated_at ON TABLE secret 
    TYPE datetime 
    DEFAULT ALWAYS time::now()
    READONLY;
