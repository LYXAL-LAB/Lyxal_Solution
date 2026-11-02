-- lyxal-test: assertions
-- Tests de fn::security_redact_object (format : crates/lyxal_core/implementation_plan.md §5).

-- test: clés sensibles, casse ignorée
RETURN fn::security_redact_object({ Password: "x", name: "A" }, [" password "]) == { Password: "***REDACTED***", name: "A" };
