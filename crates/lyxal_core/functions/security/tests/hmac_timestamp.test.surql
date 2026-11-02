-- lyxal-test: assertions
-- Tests de fn::security_hmac_timestamp (format : crates/lyxal_core/implementation_plan.md §5).

-- test: secondes Unix
RETURN fn::security_hmac_timestamp(d"2026-01-01T00:00:00Z") == "1767225600";
