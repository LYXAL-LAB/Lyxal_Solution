

-- Namespacing recommandé : <app_namespace>.<db> (géré par ton orchestrateur)

-- ======================================================================

-- 1) NAMESPACES & PLUGINS (gouvernance logique)

-- ======================================================================

DEFINE TABLE IF NOT EXISTS logic_namespace TYPE NORMAL SCHEMAFULL
    COMMENT 'Espace logique (isolation d\'opérateurs et de workflows).'
    PERMISSIONS FULL;



DEFINE FIELD IF NOT EXISTS tenant ON TABLE logic_namespace 
    TYPE record<tenant>
    ASSERT $value != NONE
    COMMENT 'Tenant parent';

DEFINE FIELD IF NOT EXISTS code ON TABLE logic_namespace 
    TYPE string
    ASSERT string::len($value) > 0 AND string::is::lowercase($value)
    COMMENT 'Code de l\'espace logique';

DEFINE FIELD IF NOT EXISTS label ON TABLE logic_namespace 
    TYPE string
    COMMENT 'Label de l\'espace logique';

DEFINE FIELD IF NOT EXISTS created_at ON TABLE logic_namespace 
    TYPE datetime 
    DEFAULT time::now()
    COMMENT 'Date de création de l\'espace logique';

DEFINE INDEX IF NOT EXISTS uniq_ns ON TABLE logic_namespace 
    FIELDS tenant, code UNIQUE
    COMMENT 'Index pour filtrer par tenant et code';
