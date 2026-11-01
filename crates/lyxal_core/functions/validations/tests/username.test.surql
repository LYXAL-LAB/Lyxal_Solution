-- lyxal-test: assertions
-- Tests de fn::validation_username (format : crates/lyxal_core/implementation_plan.md §5).

-- test: valeur conforme
RETURN fn::validation_username(" jean.dupont ", 3, 20, true)
    == { valid: true, value: "jean.dupont", code: NONE, details: {} };

-- test: majuscules autorisées
RETURN fn::validation_username("JeanDupont", 3, 20, false)
    == { valid: true, value: "JeanDupont", code: NONE, details: {} };

-- test: séparateur initial
RETURN fn::validation_username(".jean", 3, 20, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "username" } };

-- test: séparateur doublé
RETURN fn::validation_username("jean..dupont", 3, 20, true).code == "CORE_VALIDATION_FORMAT";

-- test: majuscules refusées
RETURN fn::validation_username("JeanDupont", 3, 20, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "lowercase" } };

-- test: trop court
RETURN fn::validation_username("jd", 3, 20, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SHORT", details: { min_length: 3, length: 2 } };

-- test: chaîne blanche
RETURN fn::validation_username("  ", 3, 20, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_username(NONE, 3, 20, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_username(NULL, 3, 20, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_username(42, 3, 20, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: bornes inversées
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_username("abc", 5, 3, false);
