-- ======================================================================

-- LYXAL OS — LOGIC ENGINE V2 (Enterprise, X2 Adaptive)
-- Schema SurrealDB
-- ======================================================================

-- ======================================================================
--   PLUGINS (gouvernance logique)
-- ======================================================================

DEFINE TABLE IF NOT EXISTS logic_plugin TYPE NORMAL SCHEMAFULL
    COMMENT 'Plugin logique (opérateurs UI/Backend packagés, versionnés).'
    PERMISSIONS FULL;


DEFINE FIELD IF NOT EXISTS tenant ON TABLE logic_plugin 
    TYPE record<tenant>
    REFERENCE DELETE REJECT
    COMMENT 'Tenant parent';

DEFINE FIELD IF NOT EXISTS namespace ON TABLE logic_plugin 
    TYPE record<logic_namespace>
    REFERENCE DELETE REJECT
    COMMENT 'Namespace parent';

DEFINE FIELD IF NOT EXISTS name ON TABLE logic_plugin 
    TYPE string
    ASSERT string::len($value) > 0
    COMMENT 'Nom du plugin';

DEFINE FIELD IF NOT EXISTS version ON TABLE logic_plugin 
    TYPE string
    ASSERT string::len($value) > 0
    COMMENT 'Version du plugin';

DEFINE FIELD IF NOT EXISTS enabled ON TABLE logic_plugin 
    TYPE bool DEFAULT true
    COMMENT 'Plugin activé';

DEFINE FIELD IF NOT EXISTS meta ON TABLE logic_plugin
    FLEXIBLE
    TYPE object
    DEFAULT {}
    COMMENT 'Métadonnées du plugin (description, author, signatures, checksums)';

DEFINE FIELD IF NOT EXISTS created_at ON TABLE logic_plugin 
    TYPE datetime 
    DEFAULT time::now()
    COMMENT 'Date de création du plugin';

DEFINE INDEX IF NOT EXISTS uniq_plugin ON TABLE logic_plugin 
    FIELDS tenant, namespace, name, version UNIQUE
    COMMENT 'Index unique pour filtrer par tenant, namespace, nom et version';