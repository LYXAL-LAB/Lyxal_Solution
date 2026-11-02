-- lyxal-test: assertions
-- Tests de fn::utils_encode_uri (format : crates/lyxal_core/implementation_plan.md §5).

-- test: caractères réservés
RETURN fn::utils_encode_uri("a b/é?") == "a%20b%2F%C3%A9%3F";

-- test: non réservés conservés
RETURN fn::utils_encode_uri("A-z_0.~") == "A-z_0.~";
