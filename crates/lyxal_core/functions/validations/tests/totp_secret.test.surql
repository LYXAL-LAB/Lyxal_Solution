-- lyxal-test: assertions
-- Tests de fn::validation_totp_secret (format : crates/lyxal_core/implementation_plan.md §5).

-- test: valeur conforme
RETURN fn::validation_totp_secret(" jbswy3dpehpk3pxp ", 16, 64)
    == { valid: true, value: "JBSWY3DPEHPK3PXP", code: NONE, details: {} };

-- test: caractère hors Base32
RETURN fn::validation_totp_secret("JBSWY3DPEHPK3PX1", 16, 64)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "base32" } };

-- test: trop court
RETURN fn::validation_totp_secret("JBSWY3DP", 16, 64)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SHORT", details: { min_length: 16, length: 8 } };

-- test: chaîne blanche
RETURN fn::validation_totp_secret("  ", 16, 64)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_totp_secret(NONE, 16, 64)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_totp_secret(NULL, 16, 64)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_totp_secret(42, 16, 64)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: bornes inversées
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_totp_secret("x", 20, 16);
