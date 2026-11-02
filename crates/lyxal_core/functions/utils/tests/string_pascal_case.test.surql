-- lyxal-test: assertions
-- Tests de fn::utils_string_pascal_case (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: séparateurs
RETURN fn::utils_string_pascal_case("hello big world") == "HelloBigWorld";

-- test: depuis camelCase
RETURN fn::utils_string_pascal_case("helloWorld") == "HelloWorld";

-- test: chaîne vide
RETURN fn::utils_string_pascal_case("") == "";
