-- lyxal-test: assertions
-- Tests de fn::validation_datetime_string (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: valeur conforme nettoyée
RETURN fn::validation_datetime_string(" 2026-08-03T14:30:00Z ", NONE)
    == { valid: true, value: "2026-08-03T14:30:00Z", code: NONE, details: {} };

-- test: texte libre
RETURN fn::validation_datetime_string("demain matin", NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "datetime_string" } };

-- test: chaîne blanche
RETURN fn::validation_datetime_string("  ", NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_datetime_string(NONE, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_datetime_string(NULL, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_datetime_string(1, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: format personnalisé
RETURN fn::validation_datetime_string("2026-08-03 14:30", "%Y-%m-%d %H:%M")
    == { valid: true, value: "2026-08-03 14:30", code: NONE, details: {} };

-- test: format personnalisé non respecté
RETURN fn::validation_datetime_string("2026-08-03T14:30:00Z", "%Y-%m-%d %H:%M").code == "CORE_VALIDATION_FORMAT";

-- test: format vide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_datetime_string("2026-08-03", " ");
