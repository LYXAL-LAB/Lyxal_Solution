-- ============================================================
-- TABLE: vault_location (NŒUD - Localisation du coffre)
-- Namespace: LYXAL_IDENTITY / Database: CORE
-- ============================================================

DEFINE IF NOT EXISTS TABLE vault_location TYPE NORMAL SCHEMAFULL
COMMENT "Localisation physique du namespace de données (Nœud de graphe)"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS namespace_name ON TABLE vault_location 
    TYPE string 
    COMMENT "Nom technique du namespace (ex: 'NS_IDENTITY_01J8...')";

DEFINE FIELD IF NOT EXISTS region ON TABLE vault_location 
    TYPE string 
    DEFAULT 'eu-west-1'
    COMMENT "Région de stockage (souveraineté des données)";

DEFINE FIELD IF NOT EXISTS created_at ON TABLE vault_location 
    TYPE datetime 
    DEFAULT time::now()
    READONLY;

-- INDEX

DEFINE INDEX IF NOT EXISTS idx_namespace ON TABLE vault_location 
    FIELDS namespace_name UNIQUE
    COMMENT "Un namespace est unique";
