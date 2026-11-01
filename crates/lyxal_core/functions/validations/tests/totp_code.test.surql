-- lyxal-test: assertions
-- Tests de fn::validation_totp_code (format : crates/lyxal_core/implementation_plan.md §5).

-- test: valeur conforme
RETURN fn::validation_totp_code(" 123456 ", 6)
    == { valid: true, value: "123456", code: NONE, details: {} };

-- test: huit chiffres
RETURN fn::validation_totp_code("12345678", 8)
    == { valid: true, value: "12345678", code: NONE, details: {} };

-- test: cinq chiffres
RETURN fn::validation_totp_code("12345", 6)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "totp_code", digits: 6 } };

-- test: lettre
RETURN fn::validation_totp_code("12345a", 6).code == "CORE_VALIDATION_FORMAT";

-- test: chaîne blanche
RETURN fn::validation_totp_code("  ", 6)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_totp_code(NONE, 6)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_totp_code(NULL, 6)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_totp_code(42, 6)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: nombre de chiffres non pris en charge
-- attendu-erreur: CORE_UNSUPPORTED_OPTION
RETURN fn::validation_totp_code("123456", 7);
