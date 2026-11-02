-- lyxal-test: assertions
-- Tests de fn::utils_ensure_bool (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: texte vrai
RETURN fn::utils_ensure_bool(" Yes ", false) == true;

-- test: texte faux
RETURN fn::utils_ensure_bool("off", true) == false;

-- test: nombre
RETURN fn::utils_ensure_bool(0, true) == false;

-- test: NULL remplacé
RETURN fn::utils_ensure_bool(NULL, true) == true;

-- test: texte inconnu
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::utils_ensure_bool("peut-être", false);
