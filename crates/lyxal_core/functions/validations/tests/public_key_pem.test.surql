-- lyxal-test: assertions
-- Tests de fn::validation_public_key_pem (format : crates/lyxal_core/implementation_plan.md §5).

-- test: valeur conforme
RETURN fn::validation_public_key_pem("-----BEGIN PUBLIC KEY-----\nMIIBCgKCAQEA\n-----END PUBLIC KEY-----", 65536)
    == { valid: true, value: "-----BEGIN PUBLIC KEY-----\nMIIBCgKCAQEA\n-----END PUBLIC KEY-----", code: NONE, details: {} };

-- test: trop long
RETURN fn::validation_public_key_pem("-----BEGIN PUBLIC KEY-----\nMIIBCgKCAQEA\n-----END PUBLIC KEY-----", 20).code == "CORE_VALIDATION_TOO_LONG";

-- test: sur une seule ligne
RETURN fn::validation_public_key_pem("-----BEGIN PUBLIC KEY-----MIIB-----END PUBLIC KEY-----", 65536)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "public_key_pem" } };

-- test: mauvaise enveloppe
RETURN fn::validation_public_key_pem("-----BEGIN PRIVATE KEY-----\nMIIB\n-----END PRIVATE KEY-----", 65536).code == "CORE_VALIDATION_FORMAT";

-- test: chaîne blanche
RETURN fn::validation_public_key_pem("  ", 65536)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_public_key_pem(NONE, 65536)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_public_key_pem(NULL, 65536)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_public_key_pem(42, 65536)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: longueur maximale nulle
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_public_key_pem("a", 0);
