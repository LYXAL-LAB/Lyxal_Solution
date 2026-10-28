-- ============================================================================
-- MIGRATION : 0001_initial_schema.surql
-- MODULE    : lyxal_error
-- VERSION   : 0.1.0
-- RÔLE      : Initialisation des tables canoniques d'erreurs, mappings et occurrences
-- ============================================================================

UPSERT ONLY schema_migration:['lyxal_error', '0001_initial_schema'] CONTENT {
    module: "lyxal_error",
    name: "0001_initial_schema",
    status: "APPLIED",
    applied_at: time::now()
};

RETURN {
    migration: "0001_initial_schema",
    module: "lyxal_error",
    status: "APPLIED",
    executed_at: time::now()
};
