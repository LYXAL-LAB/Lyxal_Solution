-- lyxal-test: assertions
-- Tests de fn::security_secret_mask (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: masque personnalisé
RETURN fn::security_secret_mask("abcdefgh", 2, 2, "#!") == "ab####gh";

-- test: tout visible
RETURN fn::security_secret_mask("abc", 2, 2, "*") == "abc";

-- test: visibilité négative
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::security_secret_mask("abc", -1, 0, "*");
