-- lyxal-test: assertions
-- Tests de fn::security_token_parse (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: préfixe et secret
RETURN fn::security_token_parse(" pat_ab_cd ") == { raw: "pat_ab_cd", prefix: "pat", secret: "ab_cd", length: 9 };

-- test: sans préfixe
RETURN fn::security_token_parse("abcd") == { raw: "abcd", prefix: NONE, secret: "abcd", length: 4 };

-- test: jeton vide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::security_token_parse("  ");
