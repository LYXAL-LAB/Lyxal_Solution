-- lyxal-test: assertions
-- Tests de fn::security_redact_email (format : crates/lyxal_core/implementation_plan.md §5).

-- test: adresse masquée
RETURN fn::security_redact_email(" jean.dupont@example.com ") == "j*********t@example.com";

-- test: partie locale courte
RETURN fn::security_redact_email("jd@example.com") == "**@example.com";

-- test: adresse invalide
RETURN fn::security_redact_email("x") == "***";
