-- lyxal-test: assertions
-- Tests de fn::validation_ip (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: valeur conforme
RETURN fn::validation_ip(" 192.168.1.10 ", NONE)
    == { valid: true, value: "192.168.1.10", code: NONE, details: {} };

-- test: IPv6 refusée si IPv4 exigée
RETURN fn::validation_ip("::1", "ipv4")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "ipv4" } };

-- test: IPv6 acceptée
RETURN fn::validation_ip("::1", "IPV6")
    == { valid: true, value: "::1", code: NONE, details: {} };

-- test: adresse invalide
RETURN fn::validation_ip("300.1.1.1", NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "ip" } };

-- test: chaîne blanche
RETURN fn::validation_ip("  ", NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_ip(NONE, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_ip(NULL, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_ip(42, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: version inconnue
-- attendu-erreur: CORE_UNSUPPORTED_OPTION
RETURN fn::validation_ip("1.1.1.1", "ipv5");
