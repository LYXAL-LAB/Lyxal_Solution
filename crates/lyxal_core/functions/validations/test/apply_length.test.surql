-- ============================================================================
-- LYXAL OS — TESTS VALIDATION ENGINE
-- ============================================================================
-- Fichier      : core/validation/tests/apply_length.test.surql
-- Fonction     : fn::validation_apply_length
-- Version      : 1.0.0
--
-- Les tests qui attendent un THROW doivent être exécutés individuellement.
-- ============================================================================


-- TEST 1 — Chaîne valide
RETURN fn::validation_apply_length(
    "Lyxal",
    "NAME",
    2,
    100
);

-- TEST 2 — Tableau trop court
-- Erreur attendue : ITEMS_TOO_SHORT
RETURN fn::validation_apply_length(
    [],
    "ITEMS",
    1,
    10
);

-- TEST 3 — Type non pris en charge
-- Erreur attendue : AGE_LENGTH_NOT_SUPPORTED
RETURN fn::validation_apply_length(
    18,
    "AGE",
    1,
    3
);
