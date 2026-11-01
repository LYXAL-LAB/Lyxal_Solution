-- lyxal-test: assertions
-- Tests de fn::validation_array_objects (format : crates/lyxal_core/implementation_plan.md §5).

-- test: objets acceptés
RETURN fn::validation_array_objects([{ a: 1 }], false)
    == { valid: true, value: [{ a: 1 }], code: NONE, details: {} };

-- test: objet vide autorisé
RETURN fn::validation_array_objects([{}], true)
    == { valid: true, value: [{}], code: NONE, details: {} };

-- test: objet vide refusé
RETURN fn::validation_array_objects([{ a: 1 }, {}], false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_EMPTY", details: { scope: "item" } };

-- test: élément non objet
RETURN fn::validation_array_objects([{ a: 1 }, 2], true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { scope: "item", expected: "object" } };

-- test: valeur absente
RETURN fn::validation_array_objects(NONE, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_array_objects(NULL, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type object refusé
RETURN fn::validation_array_objects({}, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "array", actual: "object" } };
