-- lyxal-test: assertions
-- Tests de fn::security_nonce_store (format : crates/lyxal_core/implementation_plan.md §5).

-- test: entrée stockée
RETURN fn::security_nonce_store("nonce-0123456789abcdef", " user:1 ", d"2026-01-01T00:00:00Z", 5m) == { nonce_hash: "e672218e57ca6e2f343f0d9dc8c01cba42788acbf00f7b4b61e13b09f885369a", subject: "user:1", issued_at: d"2026-01-01T00:00:00Z", expires_at: d"2026-01-01T00:05:00Z", consumed: false };

-- test: nonce trop court
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::security_nonce_store("abc", "s", d"2026-01-01T00:00:00Z", 5m);

-- test: durée nulle
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::security_nonce_store("nonce-0123456789abcdef", "s", d"2026-01-01T00:00:00Z", 0s);
