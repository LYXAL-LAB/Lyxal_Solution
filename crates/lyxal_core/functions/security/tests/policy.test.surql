-- lyxal-test: assertions
-- Tests de fn::security_policy (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: politique normalisée
RETURN fn::security_policy(" Main ", " V2 ", [{ resource: "booking", action: "read", effect: "allow", conditions: {} }], " DENY ") == { name: "main", version: "v2", permissions: [{ resource: "booking", action: "read", effect: "allow", conditions: {} }], default_effect: "deny" };

-- test: version invalide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::security_policy("main", "2", [], "deny");

-- test: effet par défaut inconnu
-- attendu-erreur: CORE_UNSUPPORTED_OPTION
RETURN fn::security_policy("main", "v1", [], "maybe");
