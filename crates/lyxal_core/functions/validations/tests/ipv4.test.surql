-- lyxal-test: assertions
-- Tests de fn::validation_ipv4 (format : crates/lyxal_core/implementation_plan.md §5).

-- test: valeur conforme
RETURN fn::validation_ipv4(" 10.0.0.1 ")
    == { valid: true, value: "10.0.0.1", code: NONE, details: {} };

-- test: adresse IPv6
RETURN fn::validation_ipv4("::1")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "ipv4" } };

-- test: chaîne blanche
RETURN fn::validation_ipv4("  ")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_ipv4(NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_ipv4(NULL)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_ipv4(42)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };
