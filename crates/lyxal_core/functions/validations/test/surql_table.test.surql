-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/surql_table.test.surql
-- Fonction     : fn::validation_surql_table
-- Domaine      : Core / Validation / SurrealQL
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests qui attendent un THROW doivent être exécutés individuellement.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Table simple
-- Résultat attendu : "user"
-- ============================================================================
RETURN fn::validation_surql_table("user", "TABLE_NAME", 128);

-- ============================================================================
-- TEST 2 — Tiret bas initial
-- Résultat attendu : "_system_event"
-- ============================================================================
RETURN fn::validation_surql_table(
    "_system_event",
    "TABLE_NAME",
    128
);

-- ============================================================================
-- TEST 3 — Tiret interdit
-- Erreur attendue : TABLE_NAME_INVALID_TABLE_NAME
-- ============================================================================
RETURN fn::validation_surql_table(
    "user-profile",
    "TABLE_NAME",
    128
);
