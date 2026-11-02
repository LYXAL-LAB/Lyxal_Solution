-- lyxal-test: assertions
-- Tests de fn::security_hash_sha512 (format : crates/lyxal_core/implementation_plan.md §5).

-- test: vecteur abc
RETURN string::starts_with(fn::security_hash_sha512("abc"), "ddaf35a193617abacc41");
