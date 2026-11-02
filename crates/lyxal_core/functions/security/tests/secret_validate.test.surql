-- lyxal-test: assertions
-- Tests de fn::security_secret_validate (format : crates/lyxal_core/implementation_plan.md §5).

-- test: valide
RETURN fn::security_secret_validate("abc12345", 8, 64).valid;

-- test: sans chiffre
RETURN !fn::security_secret_validate("abcdefgh", 8, 64).valid;

-- test: bornes inversées
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::security_secret_validate("a", 10, 5);
