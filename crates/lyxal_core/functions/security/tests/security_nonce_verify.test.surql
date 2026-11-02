-- lyxal-test: assertions
-- Tests de fn::security_nonce_verify (format : crates/lyxal_core/implementation_plan.md §5).

-- test: valide
RETURN fn::security_nonce_verify({ nonce_hash: "e672218e57ca6e2f343f0d9dc8c01cba42788acbf00f7b4b61e13b09f885369a", subject: "user:1", expires_at: d"2026-01-01T00:05:00Z", consumed: false }, "nonce-0123456789abcdef", "user:1", d"2026-01-01T00:00:00Z").valid;

-- test: expiré
RETURN fn::security_nonce_verify({ nonce_hash: "e672218e57ca6e2f343f0d9dc8c01cba42788acbf00f7b4b61e13b09f885369a", subject: "user:1", expires_at: d"2026-01-01T00:05:00Z", consumed: false }, "nonce-0123456789abcdef", "user:1", d"2026-01-01T00:06:00Z").expired;

-- test: autre sujet
RETURN !fn::security_nonce_verify({ nonce_hash: "e672218e57ca6e2f343f0d9dc8c01cba42788acbf00f7b4b61e13b09f885369a", subject: "user:1", expires_at: d"2026-01-01T00:05:00Z", consumed: false }, "nonce-0123456789abcdef", "user:2", d"2026-01-01T00:00:00Z").valid;
