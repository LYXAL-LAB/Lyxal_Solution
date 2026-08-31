-- ============================================================================
-- LYXAL OS — TESTS VALIDATION ENGINE
-- ============================================================================
-- Fichier      : core/validation/tests/apply_enum.test.surql
-- Fonction     : fn::validation_apply_enum
-- Version      : 1.0.0
--
-- Les tests qui attendent un THROW doivent être exécutés individuellement.
-- ============================================================================


-- TEST 1 — Valeur autorisée
RETURN fn::validation_apply_enum(
    "admin",
    "ROLE",
    ["admin", "member"]
);

-- TEST 2 — Valeur interdite
-- Erreur attendue : ROLE_VALUE_NOT_ALLOWED
RETURN fn::validation_apply_enum(
    "root",
    "ROLE",
    ["admin", "member"]
);
