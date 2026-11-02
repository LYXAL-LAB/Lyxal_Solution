-- lyxal-test: assertions
-- Tests de fn::sanitize_url (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: espaces et contrôles retirés
RETURN fn::sanitize_url("  https://example.com/a b\t ") == "https://example.com/ab";

-- test: entrée absente → NONE
RETURN fn::sanitize_url(NONE) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_url(NULL);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_url(42);
