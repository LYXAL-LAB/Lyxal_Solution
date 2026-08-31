-- ============================================================================
-- LYXAL OS — TESTS VALIDATION PIPELINE
-- ============================================================================
-- Fichier      : core/validation/tests/pipeline_required.test.surql
-- Fonction     : fn::validation_pipeline_required
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- TEST 1 — Valeur présente
RETURN fn::validation_pipeline_required(
    "Lyxal",
    "NAME"
);

-- TEST 2 — NONE
-- Erreur attendue : NAME_REQUIRED
RETURN fn::validation_pipeline_required(
    NONE,
    "NAME"
);

-- TEST 3 — Chaîne blanche
-- Erreur attendue : NAME_BLANK_NOT_ALLOWED
RETURN fn::validation_pipeline_required(
    "   ",
    "NAME"
);
