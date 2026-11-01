-- lyxal-test: assertions
-- Tests de fn::sanitize_keep_keys (format : crates/lyxal_core/implementation_plan.md §5).

-- test: clés filtrées
RETURN fn::sanitize_keep_keys({ name: "A", role: "admin" }, ["name"]) == { name: "A" };

-- test: entrée absente → NONE
RETURN fn::sanitize_keep_keys(NONE, ["name"]) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_keep_keys(NULL, ["name"]);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_keep_keys([1], ["name"]);
