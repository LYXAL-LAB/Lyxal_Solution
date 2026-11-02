-- lyxal-test: assertions
-- Tests de fn::security_nonce (format : crates/lyxal_core/implementation_plan.md §5).

-- test: longueur
RETURN string::len(fn::security_nonce(32)) == 32;

-- test: alphanumérique
RETURN string::is_alphanum(fn::security_nonce(16));

-- test: trop court
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::security_nonce(8);

-- test: trop long
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::security_nonce(129);
