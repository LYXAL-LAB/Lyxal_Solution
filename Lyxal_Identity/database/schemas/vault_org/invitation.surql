-- ============================================================
-- TABLE: invitation (INVITATIONS)
-- Namespace: NS_ORG_{UUID} (Vault Org)
-- ============================================================

DEFINE IF NOT EXISTS TABLE invitation TYPE NORMAL SCHEMAFULL
COMMENT "Invitations en attente"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS email ON TABLE invitation 
    TYPE string 
    ASSERT string::is::email($value)
    COMMENT "Email invité";

DEFINE FIELD IF NOT EXISTS inviter_id ON TABLE invitation 
    TYPE string 
    COMMENT "ID de celui qui invite";

DEFINE FIELD IF NOT EXISTS roles ON TABLE invitation 
    TYPE array
    DEFAULT []
    COMMENT "Rôles proposés";

DEFINE FIELD IF NOT EXISTS status ON TABLE invitation 
    TYPE string 
    DEFAULT 'pending'
    ASSERT $value INSIDE ['pending', 'accepted', 'expired']
    COMMENT "Statut de l'invitation";

DEFINE FIELD IF NOT EXISTS expires_at ON TABLE invitation 
    TYPE datetime 
    COMMENT "Date d'expiration";

DEFINE FIELD IF NOT EXISTS created_at ON TABLE invitation 
    TYPE datetime 
    DEFAULT time::now()
    READONLY;
