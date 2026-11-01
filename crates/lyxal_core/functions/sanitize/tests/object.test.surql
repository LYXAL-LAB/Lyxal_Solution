-- lyxal-test: assertions
-- Tests de fn::sanitize_object (format : crates/lyxal_core/implementation_plan.md §5).

-- test: objet inchangé
RETURN fn::sanitize_object({ a: 1 }) == { a: 1 };

-- test: NONE → objet vide
RETURN fn::sanitize_object(NONE) == {};

-- test: NULL → objet vide
RETURN fn::sanitize_object(NULL) == {};

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_object([1]);
