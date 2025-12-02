-- ======================================================================

-- AI HOOKS (propositions IA, corrections, auto-optimisation)

-- ======================================================================

DEFINE TABLE logic_ai_suggestion TYPE NORMAL SCHEMAFULL
    COMMENT 'Suggestions IA liées à des workflows/versions/steps (non destructives).'
    PERMISSIONS FOR select, create, update, delete FULL;

DEFINE FIELD IF NOT EXISTS tenant ON TABLE logic_ai_suggestion 
    TYPE record<tenant>
    REFERENCE DELETE REJECT
    COMMENT 'Tenant parent';

DEFINE FIELD IF NOT EXISTS workflow ON TABLE logic_ai_suggestion 
    TYPE option<record<logic_workflow>>
    REFERENCE DELETE REJECT
    COMMENT 'Workflow parent';

DEFINE FIELD IF NOT EXISTS version ON TABLE logic_ai_suggestion 
    TYPE option<record<logic_version>>
    REFERENCE DELETE REJECT
    COMMENT 'Version parent';

DEFINE FIELD IF NOT EXISTS step ON TABLE logic_ai_suggestion 
    TYPE option<record<logic_step>>
    REFERENCE DELETE REJECT
    COMMENT 'Step parent';

DEFINE FIELD IF NOT EXISTS kind ON TABLE logic_ai_suggestion TYPE string
    ASSERT $value INSIDE ["improvement","fix","refactor","security","performance","governance"]
    COMMENT 'Type de suggestion';

DEFINE FIELD IF NOT EXISTS prompt ON TABLE logic_ai_suggestion 
    TYPE string
    ASSERT string::len($value) > 0
    COMMENT 'Contexte/raisonnement IA';

DEFINE FIELD IF NOT EXISTS suggestion ON TABLE logic_ai_suggestion
    FLEXIBLE 
    TYPE object
    DEFAULT {}
    COMMENT 'Patch proposé (JSON Patch-like)';

DEFINE FIELD IF NOT EXISTS applied ON TABLE logic_ai_suggestion 
    TYPE bool
    DEFAULT false
    COMMENT 'Suggestion appliquée';

DEFINE FIELD IF NOT EXISTS created_at ON TABLE logic_ai_suggestion 
    TYPE datetime 
    DEFAULT time::now()
    COMMENT 'Date de création de la suggestion';