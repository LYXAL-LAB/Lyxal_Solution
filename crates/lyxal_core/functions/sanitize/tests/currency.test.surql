-- lyxal-test: assertions
-- Tests de fn::sanitize_currency (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: montant en euros
RETURN fn::sanitize_currency("1 234,50 €", ",") == "1234.50";

-- test: montant en dollars
RETURN fn::sanitize_currency("$1,234.50", ".") == "1234.50";

-- test: séparateur inconnu
-- attendu-erreur: CORE_UNSUPPORTED_OPTION
RETURN fn::sanitize_currency("1", " ");

-- test: entrée absente → NONE
RETURN fn::sanitize_currency(NONE, ",") == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_currency(NULL, ",");

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_currency(42, ",");
