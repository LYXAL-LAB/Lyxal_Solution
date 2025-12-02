-- ======================================================================
--   VERSIONS (gestion des versions de workflows)
-- ======================================================================

DEFINE TABLE IF NOT EXISTS logic_version TYPE NORMAL SCHEMAFULL
    COMMENT 'Version d\'un workflow (immuable une fois publiée).'
    PERMISSIONS FULL;


DEFINE FIELD IF NOT EXISTS tenant ON TABLE logic_version 
    TYPE record<tenant>
    REFERENCE DELETE REJECT
    COMMENT 'Tenant parent';

DEFINE FIELD IF NOT EXISTS workflow ON TABLE logic_version 
    TYPE record<logic_version>
    REFERENCE DELETE REJECT
    COMMENT 'Workflow parent';

DEFINE FIELD IF NOT EXISTS number ON TABLE logic_version 
    TYPE int
    ASSERT $value > 0
    COMMENT 'Numéro de version';

DEFINE FIELD IF NOT EXISTS status ON TABLE logic_version 
    TYPE string
    ASSERT $value INSIDE ["draft","released","deprecated","revoked"]
    DEFAULT "draft"
    COMMENT 'Statut de la version';

DEFINE FIELD IF NOT EXISTS changelog ON TABLE logic_version 
    TYPE string
    COMMENT 'Changelog de la version';


DEFINE FIELD IF NOT EXISTS created_by ON TABLE logic_version 
    TYPE string
    COMMENT 'Créé par';

DEFINE FIELD IF NOT EXISTS created_at ON TABLE logic_version 
    TYPE datetime 
    DEFAULT time::now()
    COMMENT 'Date de création de la version';

DEFINE INDEX IF NOT EXISTS uniq_version ON TABLE logic_version 
    FIELDS workflow, number UNIQUE
    COMMENT 'Index unique pour filtrer par workflow et numéro de version';