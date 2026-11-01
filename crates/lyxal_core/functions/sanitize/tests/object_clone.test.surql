-- lyxal-test: assertions
-- Tests de fn::sanitize_object_clone (format : crates/lyxal_core/implementation_plan.md §5).

-- test: copie
RETURN fn::sanitize_object_clone({ a: 1, b: { c: 2 } }) == { a: 1, b: { c: 2 } };

-- test: entrée absente → NONE
RETURN fn::sanitize_object_clone(NONE) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_object_clone(NULL);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_object_clone([1]);
