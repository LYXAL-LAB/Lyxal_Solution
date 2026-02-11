-- ============================================================
-- RELATION: identifies_org (org_id_hash -> organization)
-- Namespace: LYXAL_IDENTITY / Database: CORE
-- ============================================================

DEFINE IF NOT EXISTS TABLE identifies_org TYPE RELATION 
    IN org_id_hash
    OUT organization
SCHEMAFULL
COMMENT "Relation : Un hash d'ID identifie une organisation"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS ADDITIONNELS

DEFINE FIELD IF NOT EXISTS created_at ON TABLE identifies_org 
    TYPE datetime 
    DEFAULT time::now()
    READONLY;
