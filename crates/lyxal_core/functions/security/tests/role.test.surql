-- lyxal-test: assertions
-- Tests de fn::security_role (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: rôle normalisé
RETURN fn::security_role(" Booking::Manager ", [{ resource: "booking", action: "read", effect: "allow", conditions: {} }], [" Viewer ", "viewer"], true) == { name: "booking::manager", permissions: [{ resource: "booking", action: "read", effect: "allow", conditions: {} }], inherits: ["viewer"], enabled: true };

-- test: nom invalide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::security_role("2admin", [], [], true);
