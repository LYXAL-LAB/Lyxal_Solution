-- ============================================================================
-- LYXAL OS — TESTS VALIDATION PIPELINE
-- ============================================================================
-- Fichier      : core/validation/tests/pipeline_definition.test.surql
-- Fonction     : fn::validation_pipeline_definition
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- TEST 1 — Pipeline valide
RETURN fn::validation_pipeline_definition(
    [
        { rule: "required" },
        { rule: "trim" },
        { rule: "lowercase" },
        { rule: "min_length", value: 3 }
    ],
    "PIPELINE",
    20
);

-- TEST 2 — Pipeline vide
-- Erreur attendue : PIPELINE_INVALID_PIPELINE
RETURN fn::validation_pipeline_definition(
    [],
    "PIPELINE",
    20
);
