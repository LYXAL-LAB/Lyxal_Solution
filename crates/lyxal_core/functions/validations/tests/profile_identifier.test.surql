-- lyxal-test: assertions
-- Tests de fn::validation_profile_identifier (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: valeur conforme
RETURN fn::validation_profile_identifier(" Jean.Dupont ", 3, 30)
    == { valid: true, value: "jean.dupont", code: NONE, details: {} };

-- test: séparateur final
RETURN fn::validation_profile_identifier("jean-", 3, 30)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "profile_identifier" } };

-- test: séparateur doublé
RETURN fn::validation_profile_identifier("jean__dupont", 3, 30).code == "CORE_VALIDATION_FORMAT";

-- test: chaîne blanche
RETURN fn::validation_profile_identifier("  ", 3, 30)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_profile_identifier(NONE, 3, 30)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_profile_identifier(NULL, 3, 30)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_profile_identifier(42, 3, 30)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: bornes inversées
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_profile_identifier("abc", 5, 3);
