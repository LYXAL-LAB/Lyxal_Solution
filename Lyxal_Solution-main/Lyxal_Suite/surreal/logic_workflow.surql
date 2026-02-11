-- ======================================================================

-- 2) WORKFLOWS / VERSIONS / STEPS (moteur méta)

-- ======================================================================

DEFINE TABLE IF NOT EXISTS logic_workflow TYPE NORMAL SCHEMAFULL
    COMMENT 'Workflow logique méta (défini par données, versionné).'
    PERMISSIONS FULL;

DEFINE FIELD IF NOT EXISTS tenant ON TABLE logic_workflow 
    TYPE record<tenant>
    REFERENCE DELETE REJECT
    COMMENT 'Tenant parent';

DEFINE FIELD IF NOT EXISTS namespace ON TABLE logic_workflow 
    TYPE record<logic_namespace>
    REFERENCE DELETE REJECT
    COMMENT 'Namespace parent';

DEFINE FIELD IF NOT EXISTS code ON TABLE logic_workflow 
    TYPE string
    ASSERT string::len($value) > 0
    COMMENT 'Code du workflow';

DEFINE FIELD IF NOT EXISTS label ON TABLE logic_workflow 
    TYPE string
    COMMENT 'Label du workflow';

DEFINE FIELD IF NOT EXISTS tags ON TABLE logic_workflow 
    TYPE array
    DEFAULT []
    COMMENT 'Tags du workflow';

DEFINE FIELD IF NOT EXISTS active_version ON TABLE logic_workflow 
    TYPE option<record<logic_version>>
    COMMENT 'Version active du workflow';

DEFINE FIELD IF NOT EXISTS status ON TABLE logic_workflow 
    TYPE string
    ASSERT $value INSIDE ["draft","active","archived"]
    DEFAULT "draft"
    COMMENT 'Statut du workflow';

DEFINE FIELD IF NOT EXISTS created_at ON TABLE logic_workflow 
    TYPE datetime 
    DEFAULT time::now()
    COMMENT 'Date de création du workflow';

DEFINE INDEX IF NOT EXISTS uniq_wf ON TABLE logic_workflow 
    FIELDS tenant, namespace, code UNIQUE
    COMMENT 'Index unique pour filtrer par tenant, namespace et code';