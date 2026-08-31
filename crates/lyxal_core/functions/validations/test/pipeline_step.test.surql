-- ============================================================================
-- LYXAL OS — TESTS VALIDATION PIPELINE
-- ============================================================================
-- Fichier      : core/validation/tests/pipeline_step.test.surql
-- Fonction     : fn::validation_pipeline_step
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- TEST 1 — Étape trim
RETURN fn::validation_pipeline_step(
    { rule: "trim" },
    "STEP"
);

-- TEST 2 — Étape min_length
RETURN fn::validation_pipeline_step(
    { rule: "min_length", value: 3 },
    "STEP"
);

-- TEST 3 — Règle inconnue
-- Erreur attendue : STEP_UNKNOWN_PIPELINE_RULE
RETURN fn::validation_pipeline_step(
    { rule: "execute" },
    "STEP"
);
