-- lyxal-test: assertions
-- Tests de fn::sanitize_safe_filename (format : crates/lyxal_core/implementation_plan.md §5).

-- test: caractères interdits
RETURN fn::sanitize_safe_filename(" mon:fichier?.pdf ", "_") == "mon_fichier_.pdf";

-- test: point final
RETURN fn::sanitize_safe_filename("rapport. ", "_") == "rapport";

-- test: remplacement vide
RETURN fn::sanitize_safe_filename("a/b", "") == "a_b";

-- test: remplacement interdit
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::sanitize_safe_filename("a", "/");

-- test: entrée absente → NONE
RETURN fn::sanitize_safe_filename(NONE, "_") == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_safe_filename(NULL, "_");

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_safe_filename(42, "_");
