-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/surql_database.test.surql
-- Fonction     : fn::validation_surql_database
-- Domaine      : Core / Validation / SurrealQL
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests qui attendent un THROW doivent être exécutés individuellement.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Database valide
-- Résultat attendu : "workspace_main"
-- ============================================================================
RETURN fn::validation_surql_database(
    "workspace_main",
    "DATABASE",
    128
);

-- ============================================================================
-- TEST 2 — Point interdit
-- Erreur attendue : DATABASE_INVALID_DATABASE_NAME
-- ============================================================================
RETURN fn::validation_surql_database(
    "workspace.main",
    "DATABASE",
    128
);
