-- lyxal-test: assertions
-- Tests de fn::utils_string_snake_case (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: depuis PascalCase
RETURN fn::utils_string_snake_case("HelloBigWorld") == "hello_big_world";

-- test: tirets
RETURN fn::utils_string_snake_case("-a-b-") == "a_b";
