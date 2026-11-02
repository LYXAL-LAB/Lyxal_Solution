-- lyxal-test: assertions
-- Tests de fn::sanitize_precision (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: decimal arrondi
RETURN fn::sanitize_precision(3.14159f, 2) == 3.14dec;

-- test: type decimal
RETURN type::of(fn::sanitize_precision(1.005f, 1)) == "decimal";

-- test: précision négative
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::sanitize_precision(1, -1);

-- test: entrée absente → NONE
RETURN fn::sanitize_precision(NONE, 2) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_precision(NULL, 2);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_precision("3.14", 2);
