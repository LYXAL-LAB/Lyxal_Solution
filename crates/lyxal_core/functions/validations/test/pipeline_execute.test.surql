-- ============================================================================
-- LYXAL OS — TESTS VALIDATION PIPELINE
-- ============================================================================
-- Fichier      : core/validation/tests/pipeline_execute.test.surql
-- Fonction     : fn::validation_pipeline_execute
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- TEST 1 — Pipeline complet
-- Résultat attendu : "lyxal-core"
RETURN fn::validation_pipeline_execute(
    "  LYXAL-CORE  ",
    "SLUG",
    [
        { rule: "required" },
        { rule: "trim" },
        { rule: "lowercase" },
        { rule: "min_length", value: 3 },
        { rule: "max_length", value: 64 },
        { rule: "pattern", value: "^[a-z-]+$" }
    ],
    20
);

-- TEST 2 — Valeur par défaut
-- Résultat attendu : "pending"
RETURN fn::validation_pipeline_execute(
    NONE,
    "STATUS",
    [
        { rule: "default", value: "pending" },
        { rule: "enum", value: ["pending", "active"] }
    ],
    20
);

-- TEST 3 — Pattern échoué
-- Erreur attendue : SLUG_PATTERN_MISMATCH
RETURN fn::validation_pipeline_execute(
    "  Lyxal Core  ",
    "SLUG",
    [
        { rule: "trim" },
        { rule: "lowercase" },
        { rule: "pattern", value: "^[a-z-]+$" }
    ],
    20
);
