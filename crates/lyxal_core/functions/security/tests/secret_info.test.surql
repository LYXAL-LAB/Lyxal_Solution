-- lyxal-test: assertions
-- Tests de fn::security_secret_info (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: fiche
RETURN fn::security_secret_info(" vault:db ", d"2026-01-01T00:00:00Z", NONE, " Active ") == { reference: "vault:db", created_at: d"2026-01-01T00:00:00Z", rotated_at: NONE, status: "active", contains_plaintext: false };
