-- lyxal-test: assertions
-- Tests de fn::validation_uuid (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: UUID natif
RETURN fn::validation_uuid(u"0190b5a2-7c1e-7a3b-9f00-1234567890ab")
    == { valid: true, value: u"0190b5a2-7c1e-7a3b-9f00-1234567890ab", code: NONE, details: {} };

-- test: valeur absente
RETURN fn::validation_uuid(NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_uuid(NULL)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type string refusé
RETURN fn::validation_uuid("0190b5a2-7c1e-7a3b-9f00-1234567890ab")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "uuid", actual: "string" } };
