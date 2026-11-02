-- lyxal-test: assertions
-- Tests de fn::security_redact_secret (format : crates/lyxal_core/implementation_plan.md §5).

-- test: début et fin visibles
RETURN fn::security_redact_secret("sk_live_abcdef", 3, 2) == "sk_*********ef";
