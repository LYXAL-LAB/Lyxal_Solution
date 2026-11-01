-- lyxal-test: assertions
-- Tests de fn::sanitize_remove_unknown_keys (format : crates/lyxal_core/implementation_plan.md §5).

-- test: clés filtrées
RETURN fn::sanitize_remove_unknown_keys({ name: "A", email: "a@b.c", role: "admin" }, ["name", "email"]) == { name: "A", email: "a@b.c" };

-- test: entrée absente → NONE
RETURN fn::sanitize_remove_unknown_keys(NONE, ["name", "email"]) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_remove_unknown_keys(NULL, ["name", "email"]);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_remove_unknown_keys([1], ["name", "email"]);
