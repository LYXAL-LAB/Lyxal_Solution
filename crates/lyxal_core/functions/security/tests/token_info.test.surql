-- lyxal-test: assertions
-- Tests de fn::security_token_info (format : crates/lyxal_core/implementation_plan.md §5).

-- test: fiche
RETURN fn::security_token_info(u"0190b5a2-7c1e-7a3b-9f00-000000000001", " API ", d"2026-01-01T00:00:00Z", d"2026-01-01T01:00:00Z", " Active ").token_type == "api";
