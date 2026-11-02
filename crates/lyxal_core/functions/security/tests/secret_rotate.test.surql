-- lyxal-test: assertions
-- Tests de fn::security_secret_rotate (format : crates/lyxal_core/implementation_plan.md §5).

-- test: rotation
RETURN fn::security_secret_rotate(" a ", " b ", d"2026-01-01T00:00:00Z", 1h) == { current_reference: "a", new_reference: "b", valid_from: d"2026-01-01T00:00:00Z", previous_valid_until: d"2026-01-01T01:00:00Z", status: "scheduled" };
