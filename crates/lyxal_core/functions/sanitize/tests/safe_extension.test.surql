-- lyxal-test: assertions
-- Tests de fn::sanitize_safe_extension (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: point et majuscules
RETURN fn::sanitize_safe_extension(" ..PDF ") == "pdf";

-- test: caractères retirés
RETURN fn::sanitize_safe_extension("t-a r") == "tar";

-- test: entrée absente → NONE
RETURN fn::sanitize_safe_extension(NONE) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_safe_extension(NULL);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_safe_extension(42);
