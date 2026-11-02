-- lyxal-test: assertions
-- Tests de fn::sanitize_email_domain (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: domaine
RETURN fn::sanitize_email_domain(" Jean@Example.COM ") == "example.com";

-- test: sans arobase
RETURN fn::sanitize_email_domain("jean") == "";

-- test: entrée absente → NONE
RETURN fn::sanitize_email_domain(NONE) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_email_domain(NULL);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_email_domain(42);
