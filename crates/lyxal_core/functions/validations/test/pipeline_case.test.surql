-- ============================================================================
-- LYXAL OS — TESTS VALIDATION PIPELINE
-- ============================================================================
-- Fichier      : core/validation/tests/pipeline_case.test.surql
-- Fonction     : fn::validation_pipeline_case
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- TEST 1 — Minuscules
RETURN fn::validation_pipeline_case(
    "LYXAL",
    "NAME",
    "lowercase"
);

-- TEST 2 — Majuscules
RETURN fn::validation_pipeline_case(
    "lyxal",
    "NAME",
    "uppercase"
);
