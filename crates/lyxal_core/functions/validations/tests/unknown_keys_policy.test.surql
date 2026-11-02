-- lyxal-test: assertions
-- Tests de fn::validation_unknown_keys_policy (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: allow : clés inconnues conservées
RETURN fn::validation_unknown_keys_policy({ name: "a", x: 1 }, ["name"], "allow")
    == { valid: true, value: { name: "a", x: 1 }, code: NONE, details: {} };

-- test: strip : clés inconnues retirées
RETURN fn::validation_unknown_keys_policy({ name: "a", x: 1 }, ["name"], "STRIP")
    == { valid: true, value: { name: "a" }, code: NONE, details: {} };

-- test: reject : clé inconnue refusée
RETURN fn::validation_unknown_keys_policy({ name: "a", x: 1 }, ["name"], "reject")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { scope: "key", keys: ["x"] } };

-- test: reject : aucune clé inconnue
RETURN fn::validation_unknown_keys_policy({ name: "a" }, ["name"], "reject")
    == { valid: true, value: { name: "a" }, code: NONE, details: {} };

-- test: valeur absente
RETURN fn::validation_unknown_keys_policy(NONE, ["a"], "allow")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_unknown_keys_policy(NULL, ["a"], "allow")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type array refusé
RETURN fn::validation_unknown_keys_policy([], ["a"], "allow")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "object", actual: "array" } };

-- test: politique inconnue
-- attendu-erreur: CORE_UNSUPPORTED_OPTION
RETURN fn::validation_unknown_keys_policy({}, [], "ignore");
