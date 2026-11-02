-- lyxal-test: assertions
-- Tests de fn::security_policy_merge (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: permissions fusionnées et effet repris
RETURN fn::security_policy_merge({ permissions: [{ resource: "booking", action: "read", effect: "allow", conditions: {} }], default_effect: "deny" }, { permissions: [{ resource: "booking", action: "write", effect: "allow", conditions: {} }], default_effect: "allow" }, "merged", "v3") == { name: "merged", version: "v3", permissions: [{ resource: "booking", action: "read", effect: "allow", conditions: {} }, { resource: "booking", action: "write", effect: "allow", conditions: {} }], default_effect: "allow" };
