-- ============================================================================
-- LYXAL OS — TESTS VALIDATION PIPELINE
-- ============================================================================
-- Fichier      : core/validation/tests/pipeline_default.test.surql
-- Fonction     : fn::validation_pipeline_default
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- TEST 1 — NONE remplacé
RETURN fn::validation_pipeline_default(
    NONE,
    "STATUS",
    "pending"
);

-- TEST 2 — Valeur conservée
RETURN fn::validation_pipeline_default(
    "active",
    "STATUS",
    "pending"
);

-- TEST 3 — NULL conservé
RETURN fn::validation_pipeline_default(
    NULL,
    "STATUS",
    "pending"
);
