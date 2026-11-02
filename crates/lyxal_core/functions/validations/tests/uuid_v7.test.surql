-- lyxal-test: assertions
-- Tests de fn::validation_uuid_v7 (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: UUID v7 natif
RETURN fn::validation_uuid_v7(u"0190b5a2-7c1e-7a3b-9f00-1234567890ab", false)
    == { valid: true, value: u"0190b5a2-7c1e-7a3b-9f00-1234567890ab", code: NONE, details: {} };

-- test: UUID v7 en chaîne autorisée
RETURN fn::validation_uuid_v7("0190b5a2-7c1e-7a3b-9f00-1234567890ab", true)
    == { valid: true, value: "0190b5a2-7c1e-7a3b-9f00-1234567890ab", code: NONE, details: {} };

-- test: chaîne refusée si non autorisée
RETURN fn::validation_uuid_v7("0190b5a2-7c1e-7a3b-9f00-1234567890ab", false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "uuid", actual: "string" } };

-- test: UUID v4 refusé
RETURN fn::validation_uuid_v7(u"9b2c6a3e-1f4d-4c8a-9e7b-2d5f8a1c3e60", false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "uuid_v7" } };

-- test: chaîne mal formée
RETURN fn::validation_uuid_v7("pas-un-uuid", true).code == "CORE_VALIDATION_FORMAT";

-- test: type int refusé
RETURN fn::validation_uuid_v7(7, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "uuid", actual: "int" } };

-- test: valeur absente
RETURN fn::validation_uuid_v7(NONE, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_uuid_v7(NULL, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };
