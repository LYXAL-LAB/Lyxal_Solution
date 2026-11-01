-- lyxal-test: assertions
-- Tests de fn::sanitize_round (format : crates/lyxal_core/implementation_plan.md §5).

-- test: arrondi
RETURN fn::sanitize_round(3.14159f, 2) == 3.14f;

-- test: entier
RETURN fn::sanitize_round(7, 2) == 7;

-- test: précision négative
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::sanitize_round(1, -1);

-- test: entrée absente → NONE
RETURN fn::sanitize_round(NONE, 2) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_round(NULL, 2);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_round("3.14", 2);
