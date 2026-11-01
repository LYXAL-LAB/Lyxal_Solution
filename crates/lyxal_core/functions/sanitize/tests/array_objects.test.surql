-- lyxal-test: assertions
-- Tests de fn::sanitize_array_objects (format : crates/lyxal_core/implementation_plan.md §5).

-- test: objets seuls
RETURN fn::sanitize_array_objects([{ a: 1 }, 1, "x", {}]) == [{ a: 1 }, {}];

-- test: entrée absente → NONE
RETURN fn::sanitize_array_objects(NONE) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_array_objects(NULL);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_array_objects("a");
