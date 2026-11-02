-- lyxal-test: assertions
-- Tests de fn::security_permission_merge (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: doublons retirés
RETURN fn::security_permission_merge([{ resource: "booking", action: "read", effect: "allow", conditions: {} }], [{ resource: "booking", action: "read", effect: "allow", conditions: {} }, { resource: "booking", action: "write", effect: "allow", conditions: {} }]) == [{ resource: "booking", action: "read", effect: "allow", conditions: {} }, { resource: "booking", action: "write", effect: "allow", conditions: {} }];
