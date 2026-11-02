-- lyxal-test: assertions
-- Tests de fn::security_redact_object (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: clés sensibles, casse ignorée
RETURN fn::security_redact_object({ Password: "x", name: "A" }, [" password "]) == { Password: "***REDACTED***", name: "A" };
