-- lyxal-test: assertions
-- Tests de fn::validation_public_alias (format : crates/lyxal_core/implementation_plan.md §5).

-- test: valeur conforme
RETURN fn::validation_public_alias(" Élise_42 ", 3, 20)
    == { valid: true, value: "Élise_42", code: NONE, details: {} };

-- test: espace refusée
RETURN fn::validation_public_alias("Élise 42", 3, 20)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "public_alias" } };

-- test: chaîne blanche
RETURN fn::validation_public_alias("  ", 3, 20)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_public_alias(NONE, 3, 20)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_public_alias(NULL, 3, 20)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_public_alias(42, 3, 20)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: bornes inversées
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_public_alias("abc", 5, 3);
