-- lyxal-test: assertions
-- Tests de fn::utils_to_hex (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: octets
RETURN fn::utils_to_hex(<bytes>[0, 15, 255]) == "000fff";

-- test: vide
RETURN fn::utils_to_hex(<bytes>[]) == "";
