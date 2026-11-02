-- lyxal-test: assertions
-- Tests de fn::security_redact_array (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: indices masqués
RETURN fn::security_redact_array(["a", "b", "c"], [0, 2]) == ["***REDACTED***", "b", "***REDACTED***"];
