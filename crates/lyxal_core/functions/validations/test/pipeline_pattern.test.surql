-- ============================================================================
-- LYXAL OS — TESTS VALIDATION PIPELINE
-- ============================================================================
-- Fichier      : core/validation/tests/pipeline_pattern.test.surql
-- Fonction     : fn::validation_pipeline_pattern
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- TEST 1 — Pattern respecté
RETURN fn::validation_pipeline_pattern(
    "lyxal-core",
    "SLUG",
    "^[a-z-]+$"
);

-- TEST 2 — Pattern non respecté
-- Erreur attendue : SLUG_PATTERN_MISMATCH
RETURN fn::validation_pipeline_pattern(
    "Lyxal Core",
    "SLUG",
    "^[a-z-]+$"
);
