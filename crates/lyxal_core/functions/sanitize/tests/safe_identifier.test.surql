-- lyxal-test: assertions
-- Tests de fn::sanitize_safe_identifier (format : crates/lyxal_core/implementation_plan.md §5).

-- test: espaces et ponctuation
RETURN fn::sanitize_safe_identifier(" Mon Champ-Clé! ") == "mon_champ_cl";

-- test: chiffre initial
RETURN fn::sanitize_safe_identifier("2fa code") == "_2fa_code";

-- test: entrée absente → NONE
RETURN fn::sanitize_safe_identifier(NONE) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_safe_identifier(NULL);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_safe_identifier(42);
