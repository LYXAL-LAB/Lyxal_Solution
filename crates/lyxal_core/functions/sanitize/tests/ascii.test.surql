-- lyxal-test: assertions
-- Tests de fn::sanitize_ascii (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: accents retirés
RETURN fn::sanitize_ascii("Éléphant", "") == "lphant";

-- test: remplacement
RETURN fn::sanitize_ascii("café", "?") == "caf?";

-- test: entrée absente → NONE
RETURN fn::sanitize_ascii(NONE, "") == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_ascii(NULL, "");

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_ascii(42, "");
