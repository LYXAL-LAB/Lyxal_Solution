-- lyxal-test: assertions
-- Tests de fn::security_secret_entropy (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: estimation
RETURN fn::security_secret_entropy("abcd") == { estimated_bits: 4f * math::log(26f, 2f), alphabet_size: 26, length: 4, heuristic_only: true };

-- test: chaîne vide
RETURN fn::security_secret_entropy("").estimated_bits == 0f;
