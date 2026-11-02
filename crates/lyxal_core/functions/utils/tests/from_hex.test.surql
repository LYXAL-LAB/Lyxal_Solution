-- lyxal-test: assertions
-- Tests de fn::utils_from_hex (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: octets
RETURN fn::utils_from_hex(" 000FFF ") == <bytes>[0, 15, 255];

-- test: vide
RETURN fn::utils_from_hex("") == <bytes>[];

-- test: longueur impaire
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::utils_from_hex("abc");

-- test: caractère invalide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::utils_from_hex("zz");
