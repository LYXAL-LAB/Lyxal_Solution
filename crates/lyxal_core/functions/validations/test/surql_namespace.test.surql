-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/surql_namespace.test.surql
-- Fonction     : fn::validation_surql_namespace
-- Domaine      : Core / Validation / SurrealQL
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests qui attendent un THROW doivent être exécutés individuellement.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Namespace valide
-- Résultat attendu : "lyxal"
-- ============================================================================
RETURN fn::validation_surql_namespace(
    "lyxal",
    "NAMESPACE",
    128
);

-- ============================================================================
-- TEST 2 — Tiret interdit
-- Erreur attendue : NAMESPACE_INVALID_NAMESPACE_NAME
-- ============================================================================
RETURN fn::validation_surql_namespace(
    "lyxal-core",
    "NAMESPACE",
    128
);
