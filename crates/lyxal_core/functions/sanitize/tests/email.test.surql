-- lyxal-test: assertions
-- Tests de fn::sanitize_email (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: minuscules sans espace
RETURN fn::sanitize_email(" Jean.Dupont @Example.COM ") == "jean.dupont@example.com";

-- test: entrée absente → NONE
RETURN fn::sanitize_email(NONE) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_email(NULL);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_email(42);
