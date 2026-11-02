-- lyxal-test: assertions
-- Tests de fn::sanitize_query (format : crates/lyxal_core/implementation_plan.md §5).

-- test: point d'interrogation et fragment retirés
RETURN fn::sanitize_query(" ?a=1&b=2#top ") == "a=1&b=2";

-- test: entrée absente → NONE
RETURN fn::sanitize_query(NONE) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_query(NULL);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_query(42);
