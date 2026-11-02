-- lyxal-test: assertions
-- Tests de fn::validation_not_blank (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: chaîne nettoyée
RETURN fn::validation_not_blank("  Titre ")
    == { valid: true, value: "Titre", code: NONE, details: {} };

-- test: chaîne blanche
RETURN fn::validation_not_blank(" \t ")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_not_blank(NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_not_blank(NULL)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type array refusé
RETURN fn::validation_not_blank([])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "array" } };
