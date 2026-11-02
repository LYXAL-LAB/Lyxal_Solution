-- lyxal-test: assertions
-- Tests de fn::security_token_claims (format : crates/lyxal_core/implementation_plan.md §5).

-- test: claims
RETURN fn::security_token_claims(" u1 ", ["api", "api"], ["read"], d"2026-01-01T00:00:00Z", d"2026-01-01T01:00:00Z", { tenant: "t1" }).exp == 1767229200;

-- test: audience dédoublonnée
RETURN fn::security_token_claims("u1", ["api", "api"], [], d"2026-01-01T00:00:00Z", d"2026-01-01T01:00:00Z", NONE).aud == ["api"];

-- test: dates inversées
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::security_token_claims("u1", [], [], d"2026-01-01T00:00:00Z", d"2026-01-01T00:00:00Z", NONE);
