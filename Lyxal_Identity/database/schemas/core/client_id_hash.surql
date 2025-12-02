-- ============================================================
-- TABLE: client_id_hash (NŒUD - Identifiant App)
-- Namespace: LYXAL_IDENTITY / Database: CORE
-- ============================================================

DEFINE IF NOT EXISTS TABLE client_id_hash TYPE NORMAL SCHEMAFULL
COMMENT "Hash du Client ID pour recherche aveugle (Nœud de graphe)"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS hash ON TABLE client_id_hash 
    TYPE string 
    COMMENT "SHA256(client_id + sel_système)";

DEFINE FIELD IF NOT EXISTS created_at ON TABLE client_id_hash 
    TYPE datetime 
    DEFAULT time::now()
    READONLY;

-- INDEX

DEFINE INDEX IF NOT EXISTS idx_hash ON TABLE client_id_hash 
    FIELDS hash UNIQUE
    COMMENT "Garantit l'unicité du Client ID";
