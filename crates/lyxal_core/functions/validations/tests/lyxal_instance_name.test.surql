-- lyxal-test: assertions
-- Tests de fn::validation_lyxal_instance_name (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: valeur conforme
RETURN fn::validation_lyxal_instance_name(" Api-Prod ", "prod", 3, 63)
    == { valid: true, value: "api-prod", code: NONE, details: {} };

-- test: sans environnement
RETURN fn::validation_lyxal_instance_name("api-1", NONE, 3, 63)
    == { valid: true, value: "api-1", code: NONE, details: {} };

-- test: suffixe d'environnement manquant
RETURN fn::validation_lyxal_instance_name("api-staging", "prod", 3, 63)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "lyxal_instance_name", environment: "prod" } };

-- test: tiret doublé
RETURN fn::validation_lyxal_instance_name("api--prod", "prod", 3, 63)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "lyxal_instance_name" } };

-- test: chaîne blanche
RETURN fn::validation_lyxal_instance_name("  ", "prod", 3, 63)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_lyxal_instance_name(NONE, "prod", 3, 63)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_lyxal_instance_name(NULL, "prod", 3, 63)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_lyxal_instance_name(42, "prod", 3, 63)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: environnement inconnu
-- attendu-erreur: CORE_UNSUPPORTED_OPTION
RETURN fn::validation_lyxal_instance_name("api-prod", "qa", 3, 63);

-- test: bornes inversées
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_lyxal_instance_name("api", NONE, 5, 3);
