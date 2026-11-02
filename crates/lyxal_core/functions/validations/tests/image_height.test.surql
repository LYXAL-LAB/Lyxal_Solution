-- lyxal-test: assertions
-- Tests de fn::validation_image_height (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: dans les bornes
RETURN fn::validation_image_height(1920, 16, 4096)
    == { valid: true, value: 1920, code: NONE, details: {} };

-- test: trop petite
RETURN fn::validation_image_height(8, 16, 4096)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SMALL", details: { min: 16 } };

-- test: trop grande
RETURN fn::validation_image_height(5000, 16, 4096)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LARGE", details: { max: 4096 } };

-- test: valeur absente
RETURN fn::validation_image_height(NONE, 16, 4096)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_image_height(NULL, 16, 4096)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type float refusé
RETURN fn::validation_image_height(1920.5f, 16, 4096)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "int", actual: "float" } };

-- test: bornes inversées
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_image_height(100, 200, 100);

-- test: borne nulle
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_image_height(100, 0, 100);
