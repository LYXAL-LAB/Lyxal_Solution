-- lyxal-test: assertions
-- Tests de fn::validation_lyxal_namespace (format : crates/lyxal_core/implementation_plan.md §5).

-- test: valeur conforme
RETURN fn::validation_lyxal_namespace(" Lyxal-Prod_1 ", 2, 64)
    == { valid: true, value: "lyxal-prod_1", code: NONE, details: {} };

-- test: séparateurs mélangés
RETURN fn::validation_lyxal_namespace("lyxal-_prod", 2, 64)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "lyxal_namespace" } };

-- test: chiffre initial
RETURN fn::validation_lyxal_namespace("1lyxal", 2, 64).code == "CORE_VALIDATION_FORMAT";

-- test: chaîne blanche
RETURN fn::validation_lyxal_namespace("  ", 2, 64)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_lyxal_namespace(NONE, 2, 64)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_lyxal_namespace(NULL, 2, 64)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_lyxal_namespace(42, 2, 64)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: bornes inversées
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_lyxal_namespace("ab", 5, 2);
