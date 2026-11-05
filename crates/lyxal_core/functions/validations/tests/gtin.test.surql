-- lyxal-test: assertions
-- Tests de fn::validation_gtin (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: EAN-13 conforme
RETURN fn::validation_gtin("4006381333931")
    == { valid: true, value: "4006381333931", code: NONE, details: {} };

-- test: EAN-13 avec espaces et tirets
RETURN fn::validation_gtin(" 400-6381 333931 ")
    == { valid: true, value: "4006381333931", code: NONE, details: {} };

-- test: GTIN-8 conforme
RETURN fn::validation_gtin("96385074")
    == { valid: true, value: "96385074", code: NONE, details: {} };

-- test: UPC-A (GTIN-12) conforme
RETURN fn::validation_gtin("036000291452")
    == { valid: true, value: "036000291452", code: NONE, details: {} };

-- test: GTIN-14 conforme
RETURN fn::validation_gtin("10614141000415")
    == { valid: true, value: "10614141000415", code: NONE, details: {} };

-- test: clé de contrôle fausse
RETURN fn::validation_gtin("4006381333932")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "gtin_check_digit" } };

-- test: longueur non GTIN
RETURN fn::validation_gtin("123456789")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "gtin_length", length: 9 } };

-- test: lettre
RETURN fn::validation_gtin("400638133393A")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "digits" } };

-- test: chaîne blanche
RETURN fn::validation_gtin("  ")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_gtin(NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_gtin(NULL)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_gtin(4006381333931)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: règle du moteur
RETURN fn::validation_pipeline_execute("4006381333931", [{ rule: "gtin" }], 5).valid == true;
