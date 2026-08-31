-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/array_records.test.surql
-- Fonction     : fn::validation_array_records
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Record IDs valides
-- Résultat attendu : [user:one, user:two]
-- ============================================================================
RETURN fn::validation_array_records(
    [user:one, user:two],
    "USER_IDS",
    "user"
);

-- ============================================================================
-- TEST 2 — Plusieurs tables autorisées sans contrainte
-- Résultat attendu : [user:one, team:one]
-- ============================================================================
RETURN fn::validation_array_records(
    [user:one, team:one],
    "RECORD_IDS",
    NONE
);

-- ============================================================================
-- TEST 3 — Chaîne présente
-- Erreur attendue : USER_IDS_INVALID_RECORD_ITEM
-- ============================================================================
RETURN fn::validation_array_records(
    [user:one, "user:two"],
    "USER_IDS",
    "user"
);

-- ============================================================================
-- TEST 4 — Mauvaise table
-- Erreur attendue : USER_IDS_RECORD_TABLE_NOT_ALLOWED
-- ============================================================================
RETURN fn::validation_array_records(
    [user:one, team:one],
    "USER_IDS",
    "user"
);
