-- lyxal-test: assertions
-- Tests de fn::sanitize_float (format : crates/lyxal_core/implementation_plan.md §5).

-- test: format français
RETURN fn::sanitize_float("-1.234,5", ",") == "-1234.5";

-- test: format anglais
RETURN fn::sanitize_float("1,234.5", ".") == "1234.5";

-- test: séparateur inconnu
-- attendu-erreur: CORE_UNSUPPORTED_OPTION
RETURN fn::sanitize_float("1", ";");

-- test: entrée absente → NONE
RETURN fn::sanitize_float(NONE, ",") == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_float(NULL, ",");

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_float(42, ",");
