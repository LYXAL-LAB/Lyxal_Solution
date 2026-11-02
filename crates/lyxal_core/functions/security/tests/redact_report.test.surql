-- lyxal-test: assertions
-- Tests de fn::security_redact_report (format : crates/lyxal_core/implementation_plan.md §5).

-- test: changement détecté
RETURN fn::security_redact_report("s", "a", "*", ["x", "x"]).redacted_fields == ["x"] AND fn::security_redact_report("s", "a", "*", []).changed;
