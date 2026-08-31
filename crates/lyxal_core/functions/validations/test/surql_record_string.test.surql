-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/surql_record_string.test.surql
-- Fonction     : fn::validation_surql_record_string
-- Domaine      : Core / Validation / SurrealQL
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests qui attendent un THROW doivent être exécutés individuellement.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Record textuel valide
-- Résultat attendu : "person:tobie"
-- ============================================================================
RETURN fn::validation_surql_record_string(
    "person:tobie",
    "RECORD_ID",
    NONE
);

-- ============================================================================
-- TEST 2 — Table attendue
-- Résultat attendu : "person:tobie"
-- ============================================================================
RETURN fn::validation_surql_record_string(
    "person:tobie",
    "RECORD_ID",
    "person"
);

-- ============================================================================
-- TEST 3 — Mauvaise table
-- Erreur attendue : RECORD_ID_RECORD_TABLE_NOT_ALLOWED
-- ============================================================================
RETURN fn::validation_surql_record_string(
    "company:lyxal",
    "RECORD_ID",
    "person"
);

-- ============================================================================
-- TEST 4 — Chaîne ordinaire
-- Erreur attendue : RECORD_ID_INVALID_RECORD_STRING
-- ============================================================================
RETURN fn::validation_surql_record_string(
    "not a record",
    "RECORD_ID",
    NONE
);
