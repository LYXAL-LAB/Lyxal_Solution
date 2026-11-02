-- lyxal-test: assertions
-- Tests de fn::security_hash_fingerprint (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: groupes de 4
RETURN fn::security_hash_fingerprint("abcdef0123", 4, ":") == "abcd:ef01:23";

-- test: longueur multiple de la taille
RETURN fn::security_hash_fingerprint("abcdef01", 4, "-") == "abcd-ef01";

-- test: taille de groupe nulle
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::security_hash_fingerprint("abcd", 0, ":");
