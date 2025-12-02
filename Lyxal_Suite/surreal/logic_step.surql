-- Steps : représentation méta (séquentiel, conditionnel, etc.)

DEFINE TABLE IF NOT EXISTS logic_step TYPE NORMAL SCHEMAFULL
    COMMENT 'Étape d\'exécution (déclarative) rattachée à une version.'
    PERMISSIONS FULL;


DEFINE FIELD IF NOT EXISTS tenant ON TABLE logic_step 
    TYPE record<tenant>
    REFERENCE DELETE REJECT
    COMMENT 'Tenant parent';

DEFINE FIELD IF NOT EXISTS version ON TABLE logic_step 
    TYPE record<logic_version>
    REFERENCE DELETE REJECT
    COMMENT 'Version parent';

DEFINE FIELD IF NOT EXISTS key ON TABLE logic_step 
    TYPE string
    ASSERT string::len($value) > 0
    COMMENT 'Identifiant humain de l\'étape (unique par version)';

DEFINE FIELD IF NOT EXISTS order ON TABLE logic_step 
    TYPE number
    COMMENT 'Ordre d\'évaluation par défaut';

DEFINE FIELD IF NOT EXISTS kind ON TABLE logic_step 
    TYPE string
    ASSERT $value INSIDE ["action","condition","switch","loop","parallel","wait","call","subflow"]
    COMMENT 'Type d\'étape';

DEFINE FIELD IF NOT EXISTS config ON TABLE logic_step 
    TYPE object
    COMMENT 'Configuration de l\'étape';

DEFINE FIELD IF NOT EXISTS config.payload ON TABLE logic_step 
    TYPE object
    DEFAULT {}
    COMMENT 'Données d\'entrée';

DEFINE FIELD IF NOT EXISTS config.when ON TABLE logic_step 
    TYPE object
    DEFAULT {}
    COMMENT 'Expression conditionnelle (bindings)';

DEFINE FIELD IF NOT EXISTS config.ops ON TABLE logic_step 
    TYPE array
    DEFAULT []
    COMMENT 'Tableau d\'opérateurs à exécuter [{ op:"$http.request.get", params:{...} }, ...]';

DEFINE FIELD IF NOT EXISTS config.next ON TABLE logic_step 
    TYPE object
    DEFAULT {}
    COMMENT 'Clé(s) de routage { success:"stepA", failure:"stepB" } / tableau pour parallel';

DEFINE FIELD IF NOT EXISTS created_at ON TABLE logic_step 
    TYPE datetime 
    DEFAULT time::now()
    COMMENT 'Date de création de l\'étape';

DEFINE INDEX IF NOT EXISTS uniq_step_key ON TABLE logic_step 
    FIELDS version, key UNIQUE
    COMMENT 'Index unique pour filtrer par version et identifiant humain';

DEFINE INDEX IF NOT EXISTS idx_step_order ON TABLE logic_step 
    FIELDS version, order
    COMMENT 'Index pour filtrer par version et ordre';