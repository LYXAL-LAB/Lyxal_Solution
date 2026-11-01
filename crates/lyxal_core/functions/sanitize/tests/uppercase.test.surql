-- lyxal-test: assertions
-- Tests de fn::sanitize_uppercase (format : crates/lyxal_core/implementation_plan.md §5).

-- test: majuscules Unicode
RETURN fn::sanitize_uppercase("été lyxal") == "ÉTÉ LYXAL";

-- test: entrée absente → NONE
RETURN fn::sanitize_uppercase(NONE) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_uppercase(NULL);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_uppercase(42);
