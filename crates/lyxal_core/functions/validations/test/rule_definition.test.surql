-- ============================================================================
-- LYXAL OS — TESTS VALIDATION ENGINE
-- ============================================================================
-- Fichier      : core/validation/tests/rule_definition.test.surql
-- Fonction     : fn::validation_rule_definition
-- Version      : 1.0.0
--
-- Les tests qui attendent un THROW doivent être exécutés individuellement.
-- ============================================================================


-- TEST 1 — Required
RETURN fn::validation_rule_definition(
    { rule: "required" },
    "RULE"
);

-- TEST 2 — Type
RETURN fn::validation_rule_definition(
    { rule: "type", value: "string" },
    "RULE"
);

-- TEST 3 — Règle inconnue
-- Erreur attendue : RULE_UNKNOWN_RULE
RETURN fn::validation_rule_definition(
    { rule: "custom" },
    "RULE"
);

-- TEST 4 — Valeur manquante
-- Erreur attendue : RULE_RULE_VALUE_REQUIRED
RETURN fn::validation_rule_definition(
    { rule: "min_length" },
    "RULE"
);
