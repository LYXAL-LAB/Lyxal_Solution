-- ======================================================================

-- POLICIES (permissions & cloisonnement logique)

-- ======================================================================

DEFINE TABLE IF NOT EXISTS logic_policy TYPE NORMAL SCHEMAFULL
    COMMENT 'Politiques de sécurité pour l\'exécution logique (namespaces, opérateurs, plugins).'
    PERMISSIONS FULL;

DEFINE FIELD IF NOT EXISTS tenant ON TABLE logic_policy 
    TYPE record<tenant>
    REFERENCE DELETE REJECT
    COMMENT 'Tenant parent';

DEFINE FIELD IF NOT EXISTS namespace ON TABLE logic_policy 
    TYPE record<logic_namespace>
    REFERENCE DELETE REJECT
    COMMENT 'Namespace parent';

DEFINE FIELD IF NOT EXISTS name ON TABLE logic_policy 
    TYPE string
    ASSERT string::len($value) > 0
    COMMENT 'Nom de la politique';

DEFINE FIELD IF NOT EXISTS allow_ops ON TABLE logic_policy 
    TYPE array
    DEFAULT []
    COMMENT 'Listes d\'opérateurs autorisés (glob patterns)';

DEFINE FIELD IF NOT EXISTS deny_ops ON TABLE logic_policy 
    TYPE array
    DEFAULT []
    COMMENT 'Listes d\'opérateurs interdits';

DEFINE FIELD IF NOT EXISTS allow_plugins ON TABLE logic_policy 
    TYPE array
    DEFAULT []
    COMMENT 'Listes de plugins autorisés';

DEFINE FIELD IF NOT EXISTS deny_plugins ON TABLE logic_policy 
    TYPE array
    DEFAULT []
    COMMENT 'Listes de plugins interdits';

DEFINE FIELD IF NOT EXISTS runtime ON TABLE logic_policy 
    TYPE string
    ASSERT $value INSIDE ["ui","backend","both"]
    DEFAULT "both"
    COMMENT 'Runtime de la politique';

DEFINE FIELD IF NOT EXISTS created_at ON TABLE logic_policy 
    TYPE datetime 
    DEFAULT time::now()
    COMMENT 'Date de création de la politique';

DEFINE INDEX IF NOT EXISTS uniq_policy ON TABLE logic_policy 
    FIELDS tenant, namespace, name UNIQUE
    COMMENT 'Index unique pour filtrer par tenant, namespace et nom';