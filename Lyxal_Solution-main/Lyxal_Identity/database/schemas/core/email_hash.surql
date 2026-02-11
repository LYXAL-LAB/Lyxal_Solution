-- ============================================================
-- TABLE: email_hash (NŒUD - Identifiant Email)
-- Namespace: LYXAL_IDENTITY / Database: CORE
-- ============================================================

DEFINE IF NOT EXISTS TABLE email_hash TYPE NORMAL SCHEMAFULL
COMMENT "Hash d'email pour recherche aveugle (Nœud de graphe)"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS hash ON TABLE email_hash 
    TYPE string 
    COMMENT "SHA256(email + sel_système)";

DEFINE FIELD IF NOT EXISTS created_at ON TABLE email_hash 
    TYPE datetime 
    DEFAULT time::now()
    READONLY;

-- INDEX

DEFINE INDEX IF NOT EXISTS idx_hash ON TABLE email_hash 
    FIELDS hash UNIQUE
    COMMENT "Garantit l'unicité de l'email";
