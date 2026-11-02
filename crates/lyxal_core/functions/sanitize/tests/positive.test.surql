-- lyxal-test: assertions
-- Tests de fn::sanitize_positive (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: signe retiré
RETURN fn::sanitize_positive("-12,5") == "12.5";

-- test: entrée absente → NONE
RETURN fn::sanitize_positive(NONE) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_positive(NULL);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_positive(42);
