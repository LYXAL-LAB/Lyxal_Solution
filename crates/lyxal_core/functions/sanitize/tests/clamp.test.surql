-- lyxal-test: assertions
-- Tests de fn::sanitize_clamp (format : crates/lyxal_core/implementation_plan.md §5).

-- test: dans l'intervalle
RETURN fn::sanitize_clamp(5, 0, 10) == 5;

-- test: sous le minimum
RETURN fn::sanitize_clamp(-3, 0, 10) == 0;

-- test: au-dessus du maximum
RETURN fn::sanitize_clamp(12.5f, 0, 10) == 10;

-- test: bornes inversées
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::sanitize_clamp(5, 10, 0);

-- test: entrée absente → NONE
RETURN fn::sanitize_clamp(NONE, 0, 10) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_clamp(NULL, 0, 10);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_clamp("5", 0, 10);
