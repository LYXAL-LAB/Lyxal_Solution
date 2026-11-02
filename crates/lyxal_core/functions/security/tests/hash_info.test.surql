-- lyxal-test: assertions
-- Tests de fn::security_hash_info (format : crates/lyxal_core/implementation_plan.md §5).

-- test: empreinte déterministe
RETURN fn::security_hash_info("abcd", " SHA256 ") == { algorithm: "sha256", hash: "abcd", length: 4, password_suitable: false, deterministic: true };

-- test: algorithme de mot de passe
RETURN fn::security_hash_info("x", "argon2").password_suitable;
