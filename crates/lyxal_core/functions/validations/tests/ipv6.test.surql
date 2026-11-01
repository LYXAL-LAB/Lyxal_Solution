-- lyxal-test: assertions
-- Tests de fn::validation_ipv6 (format : crates/lyxal_core/implementation_plan.md §5).

-- test: valeur conforme
RETURN fn::validation_ipv6(" 2001:DB8::1 ")
    == { valid: true, value: "2001:db8::1", code: NONE, details: {} };

-- test: adresse IPv4
RETURN fn::validation_ipv6("10.0.0.1")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "ipv6" } };

-- test: chaîne blanche
RETURN fn::validation_ipv6("  ")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_ipv6(NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_ipv6(NULL)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_ipv6(42)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };
