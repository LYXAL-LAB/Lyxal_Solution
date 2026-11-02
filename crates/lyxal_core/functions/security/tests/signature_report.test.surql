-- lyxal-test: assertions
-- Tests de fn::security_signature_report (format : crates/lyxal_core/implementation_plan.md §5).

-- test: rapport normalisé
RETURN fn::security_signature_report(" HMAC-SHA256 ", " k1 ", d"2026-01-01T00:00:00Z", " n ", true, NONE) == { algorithm: "hmac-sha256", key_id: "k1", timestamp: d"2026-01-01T00:00:00Z", nonce: "n", verified: true, reason: NONE };
