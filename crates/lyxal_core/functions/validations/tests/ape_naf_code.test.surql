-- lyxal-test: assertions
-- Tests de fn::validation_ape_naf_code (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: valeur conforme
RETURN fn::validation_ape_naf_code(" 62.01z ")
    == { valid: true, value: "6201Z", code: NONE, details: {} };

-- test: sans lettre
RETURN fn::validation_ape_naf_code("6201")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "ape_naf_code" } };

-- test: chaîne blanche
RETURN fn::validation_ape_naf_code("  ")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_ape_naf_code(NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_ape_naf_code(NULL)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_ape_naf_code(42)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };
