-- lyxal-test: assertions
-- Tests de fn::sanitize_decimal (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: virgule décimale
RETURN fn::sanitize_decimal(" -1 234,56 ") == "-1234.56";

-- test: points multiples
RETURN fn::sanitize_decimal("1.2.3") == "1.23";

-- test: entier
RETURN fn::sanitize_decimal("42") == "42";

-- test: entrée absente → NONE
RETURN fn::sanitize_decimal(NONE) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_decimal(NULL);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_decimal(42);
