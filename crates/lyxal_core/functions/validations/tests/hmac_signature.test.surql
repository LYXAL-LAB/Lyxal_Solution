-- lyxal-test: assertions
-- Tests de fn::validation_hmac_signature (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: valeur conforme
RETURN fn::validation_hmac_signature(" DEADBEEF ", "hex", 8)
    == { valid: true, value: "deadbeef", code: NONE, details: {} };

-- test: Base64 conservée telle quelle
RETURN fn::validation_hmac_signature("AbC+/w==", "BASE64", NONE)
    == { valid: true, value: "AbC+/w==", code: NONE, details: {} };

-- test: caractère non hexadécimal
RETURN fn::validation_hmac_signature("DEADBEEG", "hex", 8)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "hex" } };

-- test: longueur incorrecte
RETURN fn::validation_hmac_signature("DEADBEEF00", "hex", 8)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "hex", length: 8 } };

-- test: chaîne blanche
RETURN fn::validation_hmac_signature("  ", "hex", 8)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_hmac_signature(NONE, "hex", 8)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_hmac_signature(NULL, "hex", 8)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_hmac_signature(42, "hex", 8)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: encodage inconnu
-- attendu-erreur: CORE_UNSUPPORTED_OPTION
RETURN fn::validation_hmac_signature("a", "base32", NONE);

-- test: longueur nulle
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_hmac_signature("a", "hex", 0);
