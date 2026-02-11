-- ============================================================
-- TABLE: account_center (PORTAIL SELF-SERVICE)
-- Namespace: LYXAL_SYSTEM (Vault System)
-- ============================================================

DEFINE IF NOT EXISTS TABLE account_center TYPE NORMAL SCHEMAFULL
COMMENT "Configuration du portail utilisateur (Account Center)"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS enabled ON TABLE account_center 
    TYPE bool 
    DEFAULT true
    COMMENT "Si le portail est activé";

DEFINE FIELD IF NOT EXISTS fields ON TABLE account_center 
    TYPE object
    DEFAULT {}
    COMMENT "Configuration des champs modifiables (AccountCenterFieldControl)";

DEFINE FIELD IF NOT EXISTS webauthn_related_origins ON TABLE account_center 
    TYPE array
    DEFAULT []
    COMMENT "Origines autorisées pour WebAuthn (Passkeys)";

DEFINE FIELD IF NOT EXISTS created_at ON TABLE account_center 
    TYPE datetime 
    DEFAULT time::now()
    READONLY;

DEFINE FIELD IF NOT EXISTS updated_at ON TABLE account_center 
    TYPE datetime 
    DEFAULT ALWAYS time::now()
    READONLY;
