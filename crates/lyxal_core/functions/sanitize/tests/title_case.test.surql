-- lyxal-test: assertions
-- Tests de fn::sanitize_title_case (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: chaque mot
RETURN fn::sanitize_title_case("jean-pierre DE la fontaine") == "Jean-pierre De La Fontaine";

-- test: entrée absente → NONE
RETURN fn::sanitize_title_case(NONE) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_title_case(NULL);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_title_case(42);
