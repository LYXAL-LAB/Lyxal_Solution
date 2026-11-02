-- lyxal-test: assertions
-- Tests de fn::security_permission (format : crates/lyxal_core/implementation_plan.md §5).

-- test: permission normalisée
RETURN fn::security_permission(" Booking ", "READ", " Allow ", NONE) == { resource: "booking", action: "read", effect: "allow", conditions: {} };

-- test: ressource vide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::security_permission(" ", "read", "allow", NONE);

-- test: effet inconnu
-- attendu-erreur: CORE_UNSUPPORTED_OPTION
RETURN fn::security_permission("booking", "read", "maybe", NONE);
