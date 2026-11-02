-- lyxal-test: assertions
-- Tests de fn::security_hash_verify (format : crates/lyxal_core/implementation_plan.md §5).

-- test: SHA-256 correcte
RETURN fn::security_hash_verify("BA7816BF8F01CFEA414140DE5DAE2223B00361A396177A9CB410FF61F20015AD", "abc", "sha256") == true;

-- test: valeur différente
RETURN fn::security_hash_verify("ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad", "abd", "sha256") == false;

-- test: BLAKE3 correcte
RETURN fn::security_hash_verify("6437b3ac38465133ffb63b75273a8db548c558465d79db03fd359c6cd5bd9d85", "abc", "blake3") == true;

-- test: argon2 retiré
-- attendu-erreur: CORE_UNSUPPORTED_OPTION
RETURN fn::security_hash_verify("x", "abc", "argon2");
