-- lyxal-test: assertions
-- Tests de fn::sanitize_capitalize (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: première lettre
RETURN fn::sanitize_capitalize("lYXAL os") == "Lyxal os";

-- test: chaîne vide
RETURN fn::sanitize_capitalize("") == "";

-- test: accent initial
RETURN fn::sanitize_capitalize("élan") == "Élan";

-- test: entrée absente → NONE
RETURN fn::sanitize_capitalize(NONE) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_capitalize(NULL);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_capitalize(42);
