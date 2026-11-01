-- lyxal-test: assertions
-- Tests de fn::validation_full_name (format : crates/lyxal_core/implementation_plan.md §5).

-- test: valeur conforme
RETURN fn::validation_full_name(" Marie Curie ", 2, 3, 100)
    == { valid: true, value: "Marie Curie", code: NONE, details: {} };

-- test: un seul mot
RETURN fn::validation_full_name("Marie", 2, 3, 100)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SHORT", details: { min_words: 2, words: 1 } };

-- test: trop de mots
RETURN fn::validation_full_name("Anne Marie Louise Curie", 2, 3, 100)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LONG", details: { max_words: 3, words: 4 } };

-- test: chiffre refusé
RETURN fn::validation_full_name("Marie 2", 2, 3, 100)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "full_name" } };

-- test: chaîne blanche
RETURN fn::validation_full_name("  ", 2, 3, 100)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_full_name(NONE, 2, 3, 100)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_full_name(NULL, 2, 3, 100)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_full_name(42, 2, 3, 100)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: mots inversés
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_full_name("a b", 3, 2, 100);
