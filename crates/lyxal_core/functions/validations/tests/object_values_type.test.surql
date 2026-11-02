-- lyxal-test: assertions
-- Tests de fn::validation_object_values_type (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: valeurs du bon type
RETURN fn::validation_object_values_type({ fr: "Bonjour", en: "Hello" }, "string", false)
    == { valid: true, value: { fr: "Bonjour", en: "Hello" }, code: NONE, details: {} };

-- test: objet vide autorisé
RETURN fn::validation_object_values_type({}, "string", true)
    == { valid: true, value: {}, code: NONE, details: {} };

-- test: objet vide refusé
RETURN fn::validation_object_values_type({}, "string", false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_EMPTY", details: {} };

-- test: valeur d'un autre type
RETURN fn::validation_object_values_type({ fr: "Bonjour", en: 1 }, " String ", true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { scope: "value", expected: "string" } };

-- test: valeur absente
RETURN fn::validation_object_values_type(NONE, "string", true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_object_values_type(NULL, "string", true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type array refusé
RETURN fn::validation_object_values_type([], "string", true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "object", actual: "array" } };

-- test: type attendu vide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_object_values_type({}, " ", true);
