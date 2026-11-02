-- lyxal-test: assertions
-- Tests de fn::validation_alphanumeric (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: lettres et chiffres, nettoyée
RETURN fn::validation_alphanumeric(" Abc123 ", true)
    == { valid: true, value: "Abc123", code: NONE, details: {} };

-- test: espaces non retirés
RETURN fn::validation_alphanumeric(" Abc123 ", false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "alphanumeric" } };

-- test: ponctuation refusée
RETURN fn::validation_alphanumeric("abc-123", true).code == "CORE_VALIDATION_FORMAT";

-- test: chaîne vide
RETURN fn::validation_alphanumeric("", true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_alphanumeric(NONE, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_alphanumeric(NULL, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_alphanumeric(123, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };
