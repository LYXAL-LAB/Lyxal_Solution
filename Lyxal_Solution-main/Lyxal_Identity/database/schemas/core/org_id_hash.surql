-- ============================================================
-- TABLE: org_id_hash (NŒUD - Identifiant Org)
-- Namespace: LYXAL_IDENTITY / Database: CORE
-- ============================================================

DEFINE IF NOT EXISTS TABLE org_id_hash TYPE NORMAL SCHEMAFULL
COMMENT "Hash de l'ID public de l'organisation pour recherche aveugle"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS hash ON TABLE org_id_hash 
    TYPE string 
    COMMENT "SHA256(org_public_id + sel_système)";

DEFINE FIELD IF NOT EXISTS created_at ON TABLE org_id_hash 
    TYPE datetime 
    DEFAULT time::now()
    READONLY;

-- INDEX

DEFINE INDEX IF NOT EXISTS idx_hash ON TABLE org_id_hash 
    FIELDS hash UNIQUE
    COMMENT "Garantit l'unicité de l'ID d'organisation";
