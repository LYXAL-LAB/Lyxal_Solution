-- lyxal-test: assertions
-- Tests de fn::security_token_revoke (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: révocation
RETURN fn::security_token_revoke(u"0190b5a2-7c1e-7a3b-9f00-000000000001", d"2026-01-01T00:00:00Z", " Compromis ", NONE).token_id == u"0190b5a2-7c1e-7a3b-9f00-000000000001";
