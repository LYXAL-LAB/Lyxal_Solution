-- lyxal-test: assertions
-- Tests de fn::validation_timezone (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: valeur conforme nettoyée
RETURN fn::validation_timezone(" Europe/Paris ", false)
    == { valid: true, value: "Europe/Paris", code: NONE, details: {} };

-- test: sans zone
RETURN fn::validation_timezone("Paris", false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "timezone" } };

-- test: UTC non autorisé
RETURN fn::validation_timezone("UTC", false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "timezone" } };

-- test: chaîne blanche
RETURN fn::validation_timezone("  ", false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_timezone(NONE, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_timezone(NULL, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_timezone(1, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: UTC autorisé
RETURN fn::validation_timezone("UTC", true)
    == { valid: true, value: "UTC", code: NONE, details: {} };

-- test: fuseau à trois niveaux
RETURN fn::validation_timezone("America/Argentina/Buenos_Aires", false)
    == { valid: true, value: "America/Argentina/Buenos_Aires", code: NONE, details: {} };
