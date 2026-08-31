-- ============================================================================
-- LYXAL OS — TESTS VALIDATION ENGINE
-- ============================================================================
-- Fichier      : core/validation/tests/apply_range.test.surql
-- Fonction     : fn::validation_apply_range
-- Version      : 1.0.0
--
-- Les tests qui attendent un THROW doivent être exécutés individuellement.
-- ============================================================================


-- TEST 1 — Entier valide
RETURN fn::validation_apply_range(
    25,
    "AGE",
    18,
    120
);

-- TEST 2 — Valeur trop petite
-- Erreur attendue : AGE_TOO_SMALL
RETURN fn::validation_apply_range(
    17,
    "AGE",
    18,
    120
);

-- TEST 3 — Date valide
RETURN fn::validation_apply_range(
    d"2026-08-03T00:00:00Z",
    "DATE",
    d"2026-01-01T00:00:00Z",
    d"2026-12-31T00:00:00Z"
);
