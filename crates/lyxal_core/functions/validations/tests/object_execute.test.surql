-- lyxal-test: assertions
-- Tests de fn::validation_object_execute (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: objet valide
RETURN fn::validation_object_execute({ email: "A@b.fr", age: 30 }, { fields: { email: { pipeline: [{ rule: "email", options: { max_length: 254 } }], required: true }, age: { pipeline: [{ rule: "integer", options: { min_value: 0, max_value: 130 } }] } } }, 10) == { valid: true, value: { email: "A@b.fr", age: 30 }, errors: [], warnings: [], by_field: {} };

-- test: erreurs par champ
RETURN fn::validation_object_execute({ age: 200, extra: 1 }, { fields: { email: { pipeline: [{ rule: "email", options: { max_length: 254 } }], required: true }, age: { pipeline: [{ rule: "integer", options: { min_value: 0, max_value: 130 } }] } } }, 10).by_field == { email: ["CORE_VALIDATION_REQUIRED"], age: ["CORE_VALIDATION_TOO_LARGE"], extra: ["CORE_VALIDATION_NOT_ALLOWED"] };

-- test: valeur qui n'est pas un objet
RETURN fn::validation_object_execute("a", { fields: { email: { pipeline: [{ rule: "email", options: { max_length: 254 } }], required: true }, age: { pipeline: [{ rule: "integer", options: { min_value: 0, max_value: 130 } }] } } }, 10).by_field == { "$": ["CORE_VALIDATION_TYPE"] };

-- test: valeur absente
RETURN fn::validation_object_execute(NONE, { fields: { email: { pipeline: [{ rule: "email", options: { max_length: 254 } }], required: true }, age: { pipeline: [{ rule: "integer", options: { min_value: 0, max_value: 130 } }] } } }, 10).errors[0].code == "CORE_VALIDATION_REQUIRED";

-- test: schéma invalide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_object_execute({}, { fields: {} }, 10);
