-- lyxal-test: assertions
-- Tests de fn::sanitize_trim_right (format : crates/lyxal_core/implementation_plan.md §5).

-- test: espaces finaux
RETURN fn::sanitize_trim_right("  a b  ") == "  a b";

-- test: entrée absente → NONE
RETURN fn::sanitize_trim_right(NONE) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_trim_right(NULL);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_trim_right(42);
