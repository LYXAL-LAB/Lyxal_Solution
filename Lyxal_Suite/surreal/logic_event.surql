
-- ======================================================================

-- 4) OBSERVABILITY (events / traces / replay)

-- ======================================================================

DEFINE TABLE IF NOT EXISTS logic_event TYPE NORMAL SCHEMAFULL

    COMMENT 'Événements d\'exécution (logs, traces, métriques).'
    PERMISSIONS FULL;



DEFINE FIELD IF NOT EXISTS tenant ON TABLE logic_event 
    TYPE record<tenant> 
    ASSERT $value != NONE
    COMMENT 'Tenant parent';

DEFINE FIELD IF NOT EXISTS workflow ON TABLE logic_event 
    TYPE option<record<logic_workflow>>
    COMMENT 'Workflow parent';

DEFINE FIELD IF NOT EXISTS version ON TABLE logic_event 
    TYPE option<record<logic_version>>
    COMMENT 'Version parent';

DEFINE FIELD IF NOT EXISTS step ON TABLE logic_event 
    TYPE option<record<logic_step>>
    COMMENT 'Step parent';

DEFINE FIELD IF NOT EXISTS level ON TABLE logic_event 
    TYPE string 
    ASSERT $value INSIDE ["debug","info","warn","error","fatal"] 
    DEFAULT "info"
    COMMENT 'Niveau de l\'événement';

DEFINE FIELD IF NOT EXISTS message ON TABLE logic_event 
    TYPE string
    COMMENT 'Message de l\'événement';

DEFINE FIELD IF NOT EXISTS data ON TABLE logic_event 
    TYPE object
    COMMENT 'Données de l\'événement';

DEFINE FIELD IF NOT EXISTS trace_id ON TABLE logic_event 
    TYPE string
    COMMENT 'Corrélation exécution';

DEFINE FIELD IF NOT EXISTS span_id ON TABLE logic_event 
    TYPE string
    COMMENT 'Sous-étape';

DEFINE FIELD IF NOT EXISTS created_at ON TABLE logic_event 
    TYPE datetime 
    DEFAULT time::now()
    COMMENT 'Date de création de l\'événement';

DEFINE INDEX IF NOT EXISTS idx_event_tenant_time ON TABLE logic_event 
    FIELDS tenant, created_at
    COMMENT 'Index pour filtrer par tenant et date de création';