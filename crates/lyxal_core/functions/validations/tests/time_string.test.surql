-- lyxal-test: assertions
-- Tests de fn::validation_time_string (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: valeur conforme nettoyée
RETURN fn::validation_time_string(" 09:30 ", false)
    == { valid: true, value: "09:30", code: NONE, details: {} };

-- test: heure impossible
RETURN fn::validation_time_string("24:00", false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "time_string" } };

-- test: secondes non attendues
RETURN fn::validation_time_string("09:30:00", false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "time_string" } };

-- test: chaîne blanche
RETURN fn::validation_time_string("  ", false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_time_string(NONE, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_time_string(NULL, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_time_string(1, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: secondes exigées
RETURN fn::validation_time_string("23:59:59", true)
    == { valid: true, value: "23:59:59", code: NONE, details: {} };

-- test: secondes manquantes
RETURN fn::validation_time_string("23:59", true).code == "CORE_VALIDATION_FORMAT";
