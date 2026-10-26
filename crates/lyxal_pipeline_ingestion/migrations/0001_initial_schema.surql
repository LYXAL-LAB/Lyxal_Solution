-- ============================================================================
-- MIGRATION : 0001_initial_schema.surql
-- MODULE    : lyxal_pipeline_ingestion
-- VERSION   : 0.1.0
-- RÔLE      : Initialisation des tables, fonctions et règles du pipeline d'ingestion
-- ============================================================================

-- Les tables de staging et de gouvernance sont créées avec SCHEMAFULL
-- et sécurisées par les règles de permissions Lyxal OS (voir schema/*.surql).
-- Les migrations sont exécutées de manière ordonnée par le runtime Lyxal OS.
RETURN {
    migration: "0001_initial_schema",
    module: "lyxal_pipeline_ingestion",
    status: "APPLIED",
    executed_at: time::now()
};
