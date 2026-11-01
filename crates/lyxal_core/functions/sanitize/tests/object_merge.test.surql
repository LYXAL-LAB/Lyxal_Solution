-- lyxal-test: assertions
-- Tests de fn::sanitize_object_merge (format : crates/lyxal_core/implementation_plan.md §5).

-- test: clés remplacées et ajoutées
RETURN fn::sanitize_object_merge({ a: 1, b: 2 }, { b: 3, c: 4 }) == { a: 1, b: 3, c: 4 };

-- test: entrée absente → NONE
RETURN fn::sanitize_object_merge(NONE, { b: 3, c: 4 }) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_object_merge(NULL, { b: 3, c: 4 });

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_object_merge([1], { b: 3, c: 4 });
