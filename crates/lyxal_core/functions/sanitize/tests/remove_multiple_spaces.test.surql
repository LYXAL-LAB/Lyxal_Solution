-- lyxal-test: assertions
-- Tests de fn::sanitize_remove_multiple_spaces (format : crates/lyxal_core/implementation_plan.md §5).

-- test: espaces multiples
RETURN fn::sanitize_remove_multiple_spaces("a   b\t\tc") == "a b\t\tc";

-- test: entrée absente → NONE
RETURN fn::sanitize_remove_multiple_spaces(NONE) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_remove_multiple_spaces(NULL);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_remove_multiple_spaces(42);
