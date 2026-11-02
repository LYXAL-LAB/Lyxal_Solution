-- lyxal-test: assertions
-- Tests de fn::sanitize_percentage (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: symbole retiré
RETURN fn::sanitize_percentage(" 12,5 % ") == "12.5";

-- test: entrée absente → NONE
RETURN fn::sanitize_percentage(NONE) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_percentage(NULL);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_percentage(42);
