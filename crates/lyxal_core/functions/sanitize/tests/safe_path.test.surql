-- lyxal-test: assertions
-- Tests de fn::sanitize_safe_path (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: remontées supprimées
RETURN fn::sanitize_safe_path(" /a/../b/./c//d/ ") == "a/b/c/d";

-- test: barres inverses
RETURN fn::sanitize_safe_path("a\\b") == "a/b";

-- test: entrée absente → NONE
RETURN fn::sanitize_safe_path(NONE) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_safe_path(NULL);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_safe_path(42);
