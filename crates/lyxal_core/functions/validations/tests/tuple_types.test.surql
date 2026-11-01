-- lyxal-test: assertions
-- Tests de fn::validation_tuple_types (format : crates/lyxal_core/implementation_plan.md §5).

-- test: types conformes
RETURN fn::validation_tuple_types(["a", 1], ["string", " INT "])
    == { valid: true, value: ["a", 1], code: NONE, details: {} };

-- test: type d'élément incorrect
RETURN fn::validation_tuple_types([1, "a"], ["string", "int"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { scope: "item", expected: ["string", "int"] } };

-- test: trop court
RETURN fn::validation_tuple_types(["a"], ["string", "int"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SHORT", details: { min_length: 2, length: 1 } };

-- test: trop long
RETURN fn::validation_tuple_types(["a", 1, 2], ["string", "int"]).code == "CORE_VALIDATION_TOO_LONG";

-- test: valeur absente
RETURN fn::validation_tuple_types(NONE, ["int"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_tuple_types(NULL, ["int"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_tuple_types(1, ["int"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "array", actual: "int" } };

-- test: liste de types vide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_tuple_types([], []);

-- test: type vide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_tuple_types([1], [" "]);
