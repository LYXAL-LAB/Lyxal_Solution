-- lyxal-test: assertions
-- Tests de fn::utils_decode_uri (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: UTF-8
RETURN fn::utils_decode_uri("a%20b%2F%C3%A9") == "a b/é";

-- test: sans encodage
RETURN fn::utils_decode_uri("abc") == "abc";

-- test: aller-retour
RETURN fn::utils_decode_uri(fn::utils_encode_uri("Été à 100 % ?")) == "Été à 100 % ?";

-- test: pourcentage isolé
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::utils_decode_uri("100%");

-- test: UTF-8 invalide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::utils_decode_uri("%C3");
