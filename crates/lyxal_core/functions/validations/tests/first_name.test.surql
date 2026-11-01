-- lyxal-test: assertions
-- Tests de fn::validation_first_name (format : crates/lyxal_core/implementation_plan.md §5).

-- test: valeur conforme
RETURN fn::validation_first_name(" Jean-Pierre d'Arc ", 1, 50)
    == { valid: true, value: "Jean-Pierre d'Arc", code: NONE, details: {} };

-- test: lettres accentuées
RETURN fn::validation_first_name("Élodie", 1, 50)
    == { valid: true, value: "Élodie", code: NONE, details: {} };

-- test: chiffre refusé
RETURN fn::validation_first_name("Jean2", 1, 50)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "first_name" } };

-- test: double séparateur
RETURN fn::validation_first_name("Jean--Pierre", 1, 50).code == "CORE_VALIDATION_FORMAT";

-- test: trop long
RETURN fn::validation_first_name("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA", 1, 50)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LONG", details: { max_length: 50, length: 51 } };

-- test: chaîne blanche
RETURN fn::validation_first_name("  ", 1, 50)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_first_name(NONE, 1, 50)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_first_name(NULL, 1, 50)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_first_name(42, 1, 50)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: bornes inversées
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_first_name("a", 5, 1);
