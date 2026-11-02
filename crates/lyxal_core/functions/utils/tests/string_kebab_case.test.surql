-- lyxal-test: assertions
-- Tests de fn::utils_string_kebab_case (format : crates/lyxal_core/implementation_plan.md §5).

-- test: depuis camelCase
RETURN fn::utils_string_kebab_case("helloBigWorld2") == "hello-big-world2";

-- test: séparateurs multiples
RETURN fn::utils_string_kebab_case("  Hello  World__x ") == "hello-world-x";

-- test: chiffre puis majuscule
RETURN fn::utils_string_kebab_case("v2Api") == "v2-api";
