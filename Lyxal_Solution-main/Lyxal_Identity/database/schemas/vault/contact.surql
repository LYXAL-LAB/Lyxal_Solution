-- ============================================================
-- TABLE: contact (IDENTIFIANTS EN CLAIR)
-- Namespace: NS_IDENTITY_{UUID} (Vault Privé)
-- ============================================================

DEFINE IF NOT EXISTS TABLE contact TYPE NORMAL SCHEMAFULL
COMMENT "Identifiants de contact de l'utilisateur (en clair)"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS email ON TABLE contact 
    TYPE string
    ASSERT string::is::email($value)
    COMMENT "Email principal (en clair)";

DEFINE FIELD IF NOT EXISTS username ON TABLE contact 
    TYPE option<string>
    COMMENT "Nom d'utilisateur unique (optionnel)";

DEFINE FIELD IF NOT EXISTS phone ON TABLE contact 
    TYPE option<string>
    COMMENT "Numéro de téléphone principal (format E.164)";

DEFINE FIELD IF NOT EXISTS email_verified ON TABLE contact 
    TYPE bool
    DEFAULT false
    COMMENT "Email vérifié ?";

DEFINE FIELD IF NOT EXISTS phone_verified ON TABLE contact 
    TYPE bool
    DEFAULT false
    COMMENT "Téléphone vérifié ?";

DEFINE FIELD IF NOT EXISTS created_at ON TABLE contact 
    TYPE datetime 
    DEFAULT time::now()
    READONLY;

DEFINE FIELD IF NOT EXISTS updated_at ON TABLE contact 
    TYPE datetime 
    DEFAULT ALWAYS time::now()
    READONLY;
