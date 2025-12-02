-- ============================================================
-- TABLE: resources
-- SOURCE: resources.sql
-- ============================================================

DEFINE IF NOT EXISTS TABLE resources TYPE NORMAL SCHEMAFULL
COMMENT "Ressources API (API Identifiers)"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS tenant_id ON TABLE resources 
    TYPE string;

DEFINE FIELD IF NOT EXISTS id ON TABLE resources 
    TYPE string;

DEFINE FIELD IF NOT EXISTS name ON TABLE resources 
    TYPE string;

DEFINE FIELD IF NOT EXISTS indicator ON TABLE resources 
    TYPE string
    COMMENT "URI de l'API (Audience)";

DEFINE FIELD IF NOT EXISTS is_default ON TABLE resources 
    TYPE bool
    DEFAULT false;

DEFINE FIELD IF NOT EXISTS access_token_ttl ON TABLE resources 
    TYPE int
    DEFAULT 3600;

-- INDEX & CONTRAINTES

-- Unique (tenant_id, indicator)
DEFINE INDEX IF NOT EXISTS idx_unique_indicator ON TABLE resources 
    FIELDS tenant_id, indicator UNIQUE;

DEFINE INDEX IF NOT EXISTS idx_id ON TABLE resources 
    FIELDS tenant_id, id;

-- Index partiel unique (tenant_id) WHERE is_default = true
-- Note: Ignoré (voir conversion_notes.md)
