-- lyxal-test: assertions
-- Tests de fn::validation_object_values_type (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: valeurs du bon type
RETURN fn::validation_object_values_type({ fr: "Bonjour", en: "Hello" }, "string", false, NONE)
    == { valid: true, value: { fr: "Bonjour", en: "Hello" }, code: NONE, details: {} };

-- test: objet vide autorisé
RETURN fn::validation_object_values_type({}, "string", true, NONE)
    == { valid: true, value: {}, code: NONE, details: {} };

-- test: objet vide refusé
RETURN fn::validation_object_values_type({}, "string", false, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_EMPTY", details: {} };

-- test: valeur d'un autre type
RETURN fn::validation_object_values_type({ fr: "Bonjour", en: 1 }, " String ", true, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { scope: "value", expected: "string" } };

-- test: valeur absente
RETURN fn::validation_object_values_type(NONE, "string", true, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_object_values_type(NULL, "string", true, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type array refusé
RETURN fn::validation_object_values_type([], "string", true, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "object", actual: "array" } };

-- test: valeurs chaîne dans la longueur maximale (borne incluse)
RETURN fn::validation_object_values_type({ fr: "Bonjour", en: "Hi" }, "string", false, 7)
    == { valid: true, value: { fr: "Bonjour", en: "Hi" }, code: NONE, details: {} };

-- test: valeur chaîne trop longue
RETURN fn::validation_object_values_type({ en: "Hi", fr: "Bonjour" }, "string", false, 5)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LONG", details: { key: "fr", max_length: 5, length: 7 } };

-- test: longueur maximale sans effet sur des valeurs non chaîne
RETURN fn::validation_object_values_type({ a: 123456, b: 7 }, "int", false, 1)
    == { valid: true, value: { a: 123456, b: 7 }, code: NONE, details: {} };

-- test: par le moteur, option max_length facultative
RETURN fn::validation_pipeline_execute({ fr: "Bonjour" }, [{ rule: "object_values_type", options: { expected_type: "string", allow_empty: false, max_length: 3 } }], 5).errors[0].code == "CORE_VALIDATION_TOO_LONG"
    AND fn::validation_pipeline_execute({ fr: "Bonjour" }, [{ rule: "object_values_type", options: { expected_type: "string", allow_empty: false } }], 5).valid;

-- test: type attendu vide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_object_values_type({}, " ", true, NONE);

-- test: longueur maximale négative
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_object_values_type({}, "string", true, -1);
