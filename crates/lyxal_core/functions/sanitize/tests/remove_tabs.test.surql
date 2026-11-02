-- lyxal-test: assertions
-- Tests de fn::sanitize_remove_tabs (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: tabulations
RETURN fn::sanitize_remove_tabs("a\tb\tc", " ") == "a b c";

-- test: entrée absente → NONE
RETURN fn::sanitize_remove_tabs(NONE, " ") == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_remove_tabs(NULL, " ");

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_remove_tabs(42, " ");
