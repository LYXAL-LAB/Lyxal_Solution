-- lyxal-test: assertions
-- Tests de fn::utils_from_hex (format : crates/lyxal_core/implementation_plan.md §5).

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
