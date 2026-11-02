-- lyxal-test: assertions
-- Tests de fn::sanitize_absolute_url (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: schéma ajouté
RETURN fn::sanitize_absolute_url(" example.com/a ", "https") == "https://example.com/a";

-- test: schéma existant conservé
RETURN fn::sanitize_absolute_url("ftp://example.com", "https") == "ftp://example.com";

-- test: chaîne vide
RETURN fn::sanitize_absolute_url("  ", "https") == "";

-- test: schéma invalide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::sanitize_absolute_url("x", "ht tp");

-- test: entrée absente → NONE
RETURN fn::sanitize_absolute_url(NONE, "https") == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_absolute_url(NULL, "https");

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_absolute_url(42, "https");
