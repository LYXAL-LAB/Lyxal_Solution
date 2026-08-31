-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/surql_field.test.surql
-- Fonction     : fn::validation_surql_field
-- Domaine      : Core / Validation / SurrealQL
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests qui attendent un THROW doivent être exécutés individuellement.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Champ simple
-- Résultat attendu : "created_at"
-- ============================================================================
RETURN fn::validation_surql_field(
    "created_at",
    "FIELD_NAME",
    false,
    128
);

-- ============================================================================
-- TEST 2 — Champ id autorisé
-- Résultat attendu : "id"
-- ============================================================================
RETURN fn::validation_surql_field(
    "id",
    "FIELD_NAME",
    true,
    128
);

-- ============================================================================
-- TEST 3 — Champ id interdit
-- Erreur attendue : FIELD_NAME_ID_FIELD_NOT_ALLOWED
-- ============================================================================
RETURN fn::validation_surql_field(
    "id",
    "FIELD_NAME",
    false,
    128
);

-- ============================================================================
-- TEST 4 — Chemin refusé
-- Erreur attendue : FIELD_NAME_INVALID_FIELD_IDENTIFIER
-- ============================================================================
RETURN fn::validation_surql_field(
    "profile.name",
    "FIELD_NAME",
    true,
    128
);
