-- lyxal-test: assertions
-- Tests de fn::security_hash_blake3 (format : crates/lyxal_core/implementation_plan.md §5).

-- test: vecteur abc
RETURN fn::security_hash_blake3("abc") == "6437b3ac38465133ffb63b75273a8db548c558465d79db03fd359c6cd5bd9d85";
