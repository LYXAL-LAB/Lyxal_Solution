-- lyxal-test: assertions
-- Tests de fn::sanitize_country_code (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: lettres en majuscules
RETURN fn::sanitize_country_code(" f.r ") == "FR";

-- test: entrée absente → NONE
RETURN fn::sanitize_country_code(NONE) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_country_code(NULL);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_country_code(42);
