-- ============================================================================
-- LYXAL OS — TESTS VALIDATION PIPELINE
-- ============================================================================
-- Fichier      : core/validation/tests/pipeline_enum.test.surql
-- Fonction     : fn::validation_pipeline_enum
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- TEST 1 — Valeur autorisée
RETURN fn::validation_pipeline_enum(
    "admin",
    "ROLE",
    ["admin", "member"]
);

-- TEST 2 — Valeur interdite
-- Erreur attendue : ROLE_VALUE_NOT_ALLOWED
RETURN fn::validation_pipeline_enum(
    "root",
    "ROLE",
    ["admin", "member"]
);
