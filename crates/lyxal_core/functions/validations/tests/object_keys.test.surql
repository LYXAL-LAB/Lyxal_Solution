-- lyxal-test: assertions
-- Tests de fn::validation_object_keys (format : crates/lyxal_core/implementation_plan.md §5).

-- test: clés conformes
RETURN fn::validation_object_keys({ city: "Lyon", street: "x" }, ["city"], ["street", "city"])
    == { valid: true, value: { city: "Lyon", street: "x" }, code: NONE, details: {} };

-- test: sans contrainte
RETURN fn::validation_object_keys({ any: 1 }, NONE, NONE)
    == { valid: true, value: { any: 1 }, code: NONE, details: {} };

-- test: clé obligatoire absente
RETURN fn::validation_object_keys({ street: "x" }, ["city", "street"], NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: { scope: "key", keys: ["city"] } };

-- test: clé inconnue
RETURN fn::validation_object_keys({ city: "Lyon", zip: 1 }, NONE, ["city"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { scope: "key", keys: ["zip"] } };

-- test: valeur absente
RETURN fn::validation_object_keys(NONE, NONE, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_object_keys(NULL, NONE, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type array refusé
RETURN fn::validation_object_keys([], NONE, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "object", actual: "array" } };

-- test: clé vide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_object_keys({}, [" "], NONE);

-- test: clé obligatoire non autorisée
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_object_keys({}, ["city"], ["street"]);
