-- lyxal-test: assertions
-- Tests de fn::sanitize_remove_newlines (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: trois formes de retour
RETURN fn::sanitize_remove_newlines("a\r\nb\nc\rd", " ") == "a b c d";

-- test: remplacement vide
RETURN fn::sanitize_remove_newlines("a\nb", "") == "ab";

-- test: entrée absente → NONE
RETURN fn::sanitize_remove_newlines(NONE, " ") == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_remove_newlines(NULL, " ");

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_remove_newlines(42, " ");
