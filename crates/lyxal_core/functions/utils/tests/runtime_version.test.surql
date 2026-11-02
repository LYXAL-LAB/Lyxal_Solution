-- lyxal-test: assertions
-- Tests de fn::utils_runtime_version (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: normalisée
RETURN fn::utils_runtime_version(" Lyxal ", " 0.1.0 ", " V1 ") == { name: "lyxal", version: "0.1.0", contract: "v1" };
