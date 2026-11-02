-- lyxal-test: assertions
-- Tests de fn::validation_record_id (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: Record ID de table autorisée
RETURN fn::validation_record_id(identity_user:a, ["identity_user", "identity_team"])
    == { valid: true, value: identity_user:a, code: NONE, details: {} };

-- test: toutes tables
RETURN fn::validation_record_id(team:b, NONE)
    == { valid: true, value: team:b, code: NONE, details: {} };

-- test: table non autorisée
RETURN fn::validation_record_id(team:b, ["identity_user"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { allowed: ["identity_user"] } };

-- test: valeur absente
RETURN fn::validation_record_id(NONE, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_record_id(NULL, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type string refusé
RETURN fn::validation_record_id("team:b", NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "record", actual: "string" } };

-- test: liste vide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_record_id(team:b, []);

-- test: nom de table invalide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_record_id(team:b, ["team b"]);
