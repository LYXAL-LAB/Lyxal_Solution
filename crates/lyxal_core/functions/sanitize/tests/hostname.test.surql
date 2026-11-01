-- lyxal-test: assertions
-- Tests de fn::sanitize_hostname (format : crates/lyxal_core/implementation_plan.md §5).

-- test: caractères interdits
RETURN fn::sanitize_hostname("https://ex_ample.com/x") == "example.com";

-- test: entrée absente → NONE
RETURN fn::sanitize_hostname(NONE) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_hostname(NULL);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_hostname(42);
