-- ============================================================
-- TABLE: systems
-- SOURCE: systems.sql
-- ============================================================

DEFINE IF NOT EXISTS TABLE systems TYPE NORMAL SCHEMAFULL
COMMENT "Configuration Système (Clé-Valeur)"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS key ON TABLE systems 
    TYPE string;

DEFINE FIELD IF NOT EXISTS value ON TABLE systems 
    TYPE object
    DEFAULT {};

-- INDEX & CONTRAINTES

-- PK key
DEFINE INDEX IF NOT EXISTS idx_pk ON TABLE systems 
    FIELDS key UNIQUE;
