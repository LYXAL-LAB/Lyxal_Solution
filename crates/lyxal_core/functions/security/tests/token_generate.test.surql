-- lyxal-test: assertions
-- Tests de fn::security_token_generate (format : crates/lyxal_core/implementation_plan.md §5).

-- test: jeton préfixé
RETURN string::starts_with(fn::security_token_generate(" PAT ", 32, d"2026-01-01T00:00:00Z", 1h).token, "pat_");

-- test: expiration
RETURN fn::security_token_generate("", 24, d"2026-01-01T00:00:00Z", 1h).expires_at == d"2026-01-01T01:00:00Z";

-- test: trop court
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::security_token_generate("p", 10, d"2026-01-01T00:00:00Z", 1h);

-- test: durée nulle
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::security_token_generate("p", 32, d"2026-01-01T00:00:00Z", 0s);
