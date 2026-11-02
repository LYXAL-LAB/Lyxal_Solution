-- lyxal-test: assertions
-- Tests de fn::security_redact_phone (format : crates/lyxal_core/implementation_plan.md §5).

-- test: deux derniers chiffres
RETURN fn::security_redact_phone("+33 6 12 34 56 78", 2) == "*********78";

-- test: visibilité négative
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::security_redact_phone("06", -1);
