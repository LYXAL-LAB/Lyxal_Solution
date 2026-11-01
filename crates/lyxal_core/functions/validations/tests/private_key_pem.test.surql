-- lyxal-test: assertions
-- Tests de fn::validation_private_key_pem (format : crates/lyxal_core/implementation_plan.md §5).

-- test: valeur conforme
RETURN fn::validation_private_key_pem("-----BEGIN PRIVATE KEY-----\nMIIEvQIBADAN\n-----END PRIVATE KEY-----", false, 65536)
    == { valid: true, value: "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADAN\n-----END PRIVATE KEY-----", code: NONE, details: {} };

-- test: clé chiffrée autorisée
RETURN fn::validation_private_key_pem("-----BEGIN ENCRYPTED PRIVATE KEY-----\nMIIFHDBOBgkq\n-----END ENCRYPTED PRIVATE KEY-----", true, 65536)
    == { valid: true, value: "-----BEGIN ENCRYPTED PRIVATE KEY-----\nMIIFHDBOBgkq\n-----END ENCRYPTED PRIVATE KEY-----", code: NONE, details: {} };

-- test: clé chiffrée refusée
RETURN fn::validation_private_key_pem("-----BEGIN ENCRYPTED PRIVATE KEY-----\nMIIFHDBOBgkq\n-----END ENCRYPTED PRIVATE KEY-----", false, 65536)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { reason: "encrypted" } };

-- test: enveloppe de certificat
RETURN fn::validation_private_key_pem("-----BEGIN CERTIFICATE-----\nMIIB\n-----END CERTIFICATE-----", false, 65536)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "private_key_pem" } };

-- test: chaîne blanche
RETURN fn::validation_private_key_pem("  ", false, 65536)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_private_key_pem(NONE, false, 65536)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_private_key_pem(NULL, false, 65536)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_private_key_pem(42, false, 65536)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: longueur maximale nulle
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_private_key_pem("a", false, 0);
