-- lyxal-test: assertions
-- Tests de fn::validation_max_serialized_length (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: objet dans la limite (texte JSON {"a":1} : 7 caractères)
RETURN fn::validation_max_serialized_length({ a: 1 }, 7)
    == { valid: true, value: { a: 1 }, code: NONE, details: {} };

-- test: tableau dans la limite
RETURN fn::validation_max_serialized_length([1, "é"], 10)
    == { valid: true, value: [1, "é"], code: NONE, details: {} };

-- test: objet vide
RETURN fn::validation_max_serialized_length({}, 2).valid;

-- test: objet trop long d'un caractère
RETURN fn::validation_max_serialized_length({ a: 1 }, 6)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LONG", details: { max_length: 6, length: 7 } };

-- test: longueur comptée sur le texte JSON (caractères, valeurs imbriquées comprises)
RETURN fn::validation_max_serialized_length({ n: { s: "ééé" } }, 15).details == { max_length: 15, length: 17 };

-- test: chaîne refusée (objet ou tableau attendu)
RETURN fn::validation_max_serialized_length("texte", 100)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "object|array", actual: "string" } };

-- test: valeur absente
RETURN fn::validation_max_serialized_length(NONE, 10)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_max_serialized_length(NULL, 10)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: règle du moteur dans un schéma d'objet
RETURN fn::validation_object_execute({ data: { a: "xxxxxxxxxx" } }, { fields: { data: { pipeline: [{ rule: "is_object" }, { rule: "max_serialized_length", options: { max_length: 10 } }] } }, unknown_keys: "reject" }, 10).by_field
    == { data: ["CORE_VALIDATION_TOO_LONG"] };

-- test: règle du moteur sans sa limite refusée
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::utils_engine_pipeline([{ rule: "max_serialized_length", options: {} }], fn::validation_step_catalog(), 1);

-- test: limite négative
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_max_serialized_length({}, -1);
