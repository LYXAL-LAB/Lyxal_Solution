-- lyxal-test: assertions
-- Tests de fn::validation_lyxal_permission_name (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: valeur conforme
RETURN fn::validation_lyxal_permission_name(" Booking.Slot.Read ", ["read", "write"])
    == { valid: true, value: "booking.slot.read", code: NONE, details: {} };

-- test: un seul segment
RETURN fn::validation_lyxal_permission_name("booking", ["read", "write"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "lyxal_permission_name" } };

-- test: action non autorisée
RETURN fn::validation_lyxal_permission_name("booking.slot.delete", ["read", "write"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { allowed: ["read", "write"] } };

-- test: chaîne blanche
RETURN fn::validation_lyxal_permission_name("  ", ["read", "write"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_lyxal_permission_name(NONE, ["read", "write"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_lyxal_permission_name(NULL, ["read", "write"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_lyxal_permission_name(42, ["read", "write"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: liste vide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_lyxal_permission_name("a.b", []);
