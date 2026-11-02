-- lyxal-test: assertions
-- Tests de fn::utils_cache_key (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: préfixe normalisé
RETURN string::starts_with(fn::utils_cache_key(" Users ", [1, "a"]), "users:");

-- test: déterministe
RETURN fn::utils_cache_key("u", [1, "a"]) == fn::utils_cache_key("u", [1, "a"]) AND fn::utils_cache_key("u", [1]) != fn::utils_cache_key("u", [2]);

-- test: espace de noms vide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::utils_cache_key(" ", [1]);
