-- lyxal-test: assertions
-- Tests de fn::validation_cidr (format : crates/lyxal_core/implementation_plan.md §5).

-- test: valeur conforme
RETURN fn::validation_cidr(" 10.0.0.0/8 ", true, true)
    == { valid: true, value: "10.0.0.0/8", code: NONE, details: {} };

-- test: IPv6 en minuscules
RETURN fn::validation_cidr("2001:DB8::/32", true, true)
    == { valid: true, value: "2001:db8::/32", code: NONE, details: {} };

-- test: IPv6 non autorisée
RETURN fn::validation_cidr("2001:db8::/32", true, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { reason: "ipv6" } };

-- test: préfixe IPv4 trop grand
RETURN fn::validation_cidr("10.0.0.0/33", true, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "cidr" } };

-- test: sans préfixe
RETURN fn::validation_cidr("10.0.0.0", true, true).code == "CORE_VALIDATION_FORMAT";

-- test: préfixe démesuré
RETURN fn::validation_cidr("10.0.0.0/99999999999999999999", true, true).code == "CORE_VALIDATION_FORMAT";

-- test: chaîne blanche
RETURN fn::validation_cidr("  ", true, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_cidr(NONE, true, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_cidr(NULL, true, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_cidr(42, true, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: aucune famille
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_cidr("10.0.0.0/8", false, false);
