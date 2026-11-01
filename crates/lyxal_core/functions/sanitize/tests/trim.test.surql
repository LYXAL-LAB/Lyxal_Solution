-- lyxal-test: assertions
-- Tests de fn::sanitize_trim (format : crates/lyxal_core/implementation_plan.md §5).

-- test: espaces périphériques
RETURN fn::sanitize_trim("  Lyxal OS  ") == "Lyxal OS";

-- test: tabulations et retours
RETURN fn::sanitize_trim("\t a \n") == "a";

-- test: entrée absente → NONE
RETURN fn::sanitize_trim(NONE) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_trim(NULL);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_trim(42);
