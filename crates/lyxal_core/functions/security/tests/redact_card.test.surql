-- lyxal-test: assertions
-- Tests de fn::security_redact_card (format : crates/lyxal_core/implementation_plan.md §5).

-- test: quatre derniers chiffres
RETURN fn::security_redact_card("4111 1111 1111 1111") == "************1111";

-- test: numéro court
RETURN fn::security_redact_card("123") == "***";
