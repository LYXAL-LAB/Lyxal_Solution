-- ============================================================
-- TABLE: custom_phrases
-- SOURCE: custom_phrases.sql
-- ============================================================

DEFINE IF NOT EXISTS TABLE custom_phrases TYPE NORMAL SCHEMAFULL
COMMENT "Traductions personnalisées"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS tenant_id ON TABLE custom_phrases 
    TYPE string;

DEFINE FIELD IF NOT EXISTS id ON TABLE custom_phrases 
    TYPE string;

DEFINE FIELD IF NOT EXISTS language_tag ON TABLE custom_phrases 
    TYPE string
    COMMENT "Code langue (ex: fr-FR)";

DEFINE FIELD IF NOT EXISTS translation ON TABLE custom_phrases 
    TYPE object
    COMMENT "Objet JSON contenant les traductions";

-- INDEX & CONTRAINTES

-- Unique (tenant_id, language_tag) -> Une seule config de traduction par langue par tenant
DEFINE INDEX IF NOT EXISTS idx_unique_lang ON TABLE custom_phrases 
    FIELDS tenant_id, language_tag UNIQUE;

DEFINE INDEX IF NOT EXISTS idx_id ON TABLE custom_phrases 
    FIELDS tenant_id, id;
