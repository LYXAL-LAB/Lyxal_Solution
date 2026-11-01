-- lyxal-test: assertions
-- Tests de fn::sanitize_negative (format : crates/lyxal_core/implementation_plan.md §5).

-- test: rendu négatif
RETURN fn::sanitize_negative("12,5") == "-12.5";

-- test: déjà négatif
RETURN fn::sanitize_negative("-3") == "-3";

-- test: aucun chiffre
RETURN fn::sanitize_negative("x") == "";

-- test: entrée absente → NONE
RETURN fn::sanitize_negative(NONE) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_negative(NULL);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_negative(42);
