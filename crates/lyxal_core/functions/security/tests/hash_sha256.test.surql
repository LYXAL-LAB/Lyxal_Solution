-- lyxal-test: assertions
-- Tests de fn::security_hash_sha256 (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: vecteur abc
RETURN fn::security_hash_sha256("abc") == "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad";
