-- lyxal-test: assertions
-- Tests de fn::security_permission_info (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: synthèse
RETURN fn::security_permission_info([{ resource: "booking", action: "read", effect: "allow", conditions: {} }, { resource: "booking", action: "read", effect: "deny", conditions: {} }, { resource: "booking", action: "write", effect: "allow", conditions: {} }]) == { total: 3, allow_count: 2, deny_count: 1, resources: ["booking"], actions: ["read", "write"] };
