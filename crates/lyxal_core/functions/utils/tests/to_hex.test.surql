-- lyxal-test: assertions
-- Tests de fn::utils_to_hex (format : crates/lyxal_core/implementation_plan.md §5).

-- test: octets
RETURN fn::utils_to_hex(<bytes>[0, 15, 255]) == "000fff";

-- test: vide
RETURN fn::utils_to_hex(<bytes>[]) == "";
