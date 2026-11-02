-- lyxal-test: assertions
-- Tests de fn::security_redact_array (format : crates/lyxal_core/implementation_plan.md §5).

-- test: indices masqués
RETURN fn::security_redact_array(["a", "b", "c"], [0, 2]) == ["***REDACTED***", "b", "***REDACTED***"];
