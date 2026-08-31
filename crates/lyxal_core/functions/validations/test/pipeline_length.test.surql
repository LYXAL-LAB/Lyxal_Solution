-- ============================================================================
-- LYXAL OS — TESTS VALIDATION PIPELINE
-- ============================================================================
-- Fichier      : core/validation/tests/pipeline_length.test.surql
-- Fonction     : fn::validation_pipeline_length
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- TEST 1 — Longueur minimale respectée
RETURN fn::validation_pipeline_length(
    "Lyxal",
    "NAME",
    "min_length",
    3
);

-- TEST 2 — Trop court
-- Erreur attendue : NAME_TOO_SHORT
RETURN fn::validation_pipeline_length(
    "Ly",
    "NAME",
    "min_length",
    3
);
