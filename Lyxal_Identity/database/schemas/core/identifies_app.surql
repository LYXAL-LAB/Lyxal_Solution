-- ============================================================
-- RELATION: identifies_app (client_id_hash -> application)
-- Namespace: LYXAL_IDENTITY / Database: CORE
-- ============================================================

DEFINE IF NOT EXISTS TABLE identifies_app TYPE RELATION 
    IN client_id_hash
    OUT application
SCHEMAFULL
COMMENT "Relation : Un hash de Client ID identifie une application"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS ADDITIONNELS

DEFINE FIELD IF NOT EXISTS created_at ON TABLE identifies_app 
    TYPE datetime 
    DEFAULT time::now()
    READONLY;
