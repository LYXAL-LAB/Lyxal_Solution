-- lyxal-test: assertions
-- Tests de fn::sanitize_remove_control_chars (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: contrôles et sauts retirés
RETURN fn::sanitize_remove_control_chars("a\u0000b\nc", false) == "abc";

-- test: mise en page conservée
RETURN fn::sanitize_remove_control_chars("a\u0007b\nc\td", true) == "ab\nc\td";

-- test: entrée absente → NONE
RETURN fn::sanitize_remove_control_chars(NONE, false) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_remove_control_chars(NULL, false);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_remove_control_chars(42, false);
