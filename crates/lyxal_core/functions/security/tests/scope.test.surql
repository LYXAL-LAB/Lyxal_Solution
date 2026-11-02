-- lyxal-test: assertions
-- Tests de fn::security_scope (format : crates/lyxal_core/implementation_plan.md §5).

-- test: scope normalisé
RETURN fn::security_scope(" Booking:Read ") == "booking:read";

-- test: sans séparateur
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::security_scope("booking");
