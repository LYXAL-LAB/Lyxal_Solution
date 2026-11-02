-- lyxal-test: assertions
-- Tests de fn::security_token_expiration (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: non expiré
RETURN fn::security_token_expiration(d"2026-01-01T00:00:00Z", 1h, d"2026-01-01T00:15:00Z") == { issued_at: d"2026-01-01T00:00:00Z", expires_at: d"2026-01-01T01:00:00Z", expired: false, remaining: 45m };

-- test: expiré
RETURN fn::security_token_expiration(d"2026-01-01T00:00:00Z", 1h, d"2026-01-01T02:00:00Z").remaining == 0s;

-- test: durée nulle
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::security_token_expiration(d"2026-01-01T00:00:00Z", 0s, d"2026-01-01T00:00:00Z");
