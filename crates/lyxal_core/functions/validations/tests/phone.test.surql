-- lyxal-test: assertions
-- Tests de fn::validation_phone (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: valeur conforme
RETURN fn::validation_phone(" +33612345678 ")
    == { valid: true, value: "+33612345678", code: NONE, details: {} };

-- test: format national
RETURN fn::validation_phone("0612345678")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "e164" } };

-- test: espaces internes
RETURN fn::validation_phone("+33 6 12 34 56 78").code == "CORE_VALIDATION_FORMAT";

-- test: chaîne blanche
RETURN fn::validation_phone("  ")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_phone(NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_phone(NULL)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_phone(42)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };
