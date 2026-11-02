-- lyxal-test: assertions
-- Tests de fn::security_hash_string (format : crates/lyxal_core/implementation_plan.md §5).

-- test: SHA-256
RETURN fn::security_hash_string("abc", " SHA256 ") == "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad";

-- test: BLAKE3
RETURN fn::security_hash_string("abc", "blake3") == "6437b3ac38465133ffb63b75273a8db548c558465d79db03fd359c6cd5bd9d85";

-- test: algorithme inconnu
-- attendu-erreur: CORE_UNSUPPORTED_OPTION
RETURN fn::security_hash_string("abc", "md5");
