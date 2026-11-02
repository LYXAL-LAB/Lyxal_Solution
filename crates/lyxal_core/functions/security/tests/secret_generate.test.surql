-- lyxal-test: assertions
-- Tests de fn::security_secret_generate (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: longueur et préfixe
RETURN string::len(fn::security_secret_generate(32, "sk")) == 35 AND string::starts_with(fn::security_secret_generate(32, "sk"), "sk_");

-- test: sans préfixe
RETURN string::len(fn::security_secret_generate(24, NONE)) == 24;

-- test: trop court
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::security_secret_generate(10, NONE);
