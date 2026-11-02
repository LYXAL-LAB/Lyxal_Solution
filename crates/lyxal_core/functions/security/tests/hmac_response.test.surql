-- lyxal-test: assertions
-- Tests de fn::security_hmac_response (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: forme canonique
RETURN fn::security_hmac_response(200, d"2026-01-01T00:00:00Z", "n1", "ok", "text/plain") == { algorithm: "hmac-sha256", canonical: "200\n1767225600\nn1\nok", timestamp: d"2026-01-01T00:00:00Z", nonce: "n1" };
