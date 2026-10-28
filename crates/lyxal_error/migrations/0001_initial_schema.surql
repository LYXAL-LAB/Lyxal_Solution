-- ============================================================================
-- MIGRATION : 0001_initial_schema.surql
-- MODULE    : lyxal_error
-- VERSION   : 0.1.0
-- RÔLE      : Initialisation de la baseline et validation d'amorce lyxal_error
-- ============================================================================

-- Les schémas déclaratifs (tables, index, assertions) sont gérés et appliqués
-- de manière idempotente par la phase Schéma du Runtime Lyxal OS (schema/*.surql).
-- Les migrations séquentielles sont exécutées et tracées par MigrationRunner.
RETURN {
    migration: "0001_initial_schema",
    module: "lyxal_error",
    status: "APPLIED",
    executed_at: time::now()
};
