-- lyxal-test: assertions
-- Tests de fn::sanitize_remove_empty (format : crates/lyxal_core/implementation_plan.md §5).

-- test: valeurs vides retirées
RETURN fn::sanitize_remove_empty({ a: NULL, b: " ", c: [], d: {}, e: 0, f: "x" }, true, true, true, true) == { e: 0, f: "x" };

-- test: options désactivées
RETURN fn::sanitize_remove_empty({ a: NULL, b: "", c: NONE }, false, false, false, false) == { a: NULL, b: "" };

-- test: entrée absente → NONE
RETURN fn::sanitize_remove_empty(NONE, true, true, true, true) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_remove_empty(NULL, true, true, true, true);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_remove_empty([1], true, true, true, true);
