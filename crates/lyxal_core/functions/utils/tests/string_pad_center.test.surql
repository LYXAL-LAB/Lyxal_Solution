-- lyxal-test: assertions
-- Tests de fn::utils_string_pad_center (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: centrage
RETURN fn::utils_string_pad_center("ab", 6, "*") == "**ab**";

-- test: reste à droite
RETURN fn::utils_string_pad_center("ab", 5, "-") == "-ab--";

-- test: déjà assez long
RETURN fn::utils_string_pad_center("abc", 2, "*") == "abc";

-- test: remplissage vide
RETURN fn::utils_string_pad_center("a", 3, "") == " a ";

-- test: largeur négative
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::utils_string_pad_center("a", -1, "*");
