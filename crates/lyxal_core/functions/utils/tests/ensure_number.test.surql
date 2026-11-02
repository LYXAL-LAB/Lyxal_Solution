-- lyxal-test: assertions
-- Tests de fn::utils_ensure_number (format : crates/lyxal_core/implementation_plan.md §5).

-- test: chaîne décimale
RETURN fn::utils_ensure_number(" -1.5 ", 0) == -1.5dec;

-- test: nombre conservé
RETURN fn::utils_ensure_number(3, 0) == 3;

-- test: NONE remplacé
RETURN fn::utils_ensure_number(NONE, 7) == 7;

-- test: texte
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::utils_ensure_number("abc", 0);
