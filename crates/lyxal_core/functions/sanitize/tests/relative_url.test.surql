-- lyxal-test: assertions
-- Tests de fn::sanitize_relative_url (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: hôte retiré
RETURN fn::sanitize_relative_url("https://example.com/a/b?c=1") == "/a/b?c=1";

-- test: barres multiples
RETURN fn::sanitize_relative_url("//a") == "/a";

-- test: sans barre
RETURN fn::sanitize_relative_url("a/b") == "/a/b";

-- test: entrée absente → NONE
RETURN fn::sanitize_relative_url(NONE) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_relative_url(NULL);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_relative_url(42);
