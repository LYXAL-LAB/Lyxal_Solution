-- lyxal-test: assertions
-- Tests de fn::security_hmac_request (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: forme canonique
RETURN fn::security_hmac_request(" post ", "/v1/hook", d"2026-01-01T00:00:00Z", " n1 ", { host: "api.x" }, ["host"], { a: 1 }, "application/json") == { algorithm: "hmac-sha256", canonical: "POST\n/v1/hook\n1767225600\nn1\nhost:api.x\n{\"a\":1}", timestamp: d"2026-01-01T00:00:00Z", nonce: "n1" };
