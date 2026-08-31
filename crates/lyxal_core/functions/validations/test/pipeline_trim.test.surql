-- ============================================================================
-- LYXAL OS — TESTS VALIDATION PIPELINE
-- ============================================================================
-- Fichier      : core/validation/tests/pipeline_trim.test.surql
-- Fonction     : fn::validation_pipeline_trim
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- TEST 1 — Chaîne nettoyée
RETURN fn::validation_pipeline_trim(
    "  Lyxal  ",
    "NAME"
);

-- TEST 2 — NONE conservé
RETURN fn::validation_pipeline_trim(
    NONE,
    "NAME"
);
