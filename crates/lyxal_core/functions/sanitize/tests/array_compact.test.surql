-- lyxal-test: assertions
-- Tests de fn::sanitize_array_compact (format : crates/lyxal_core/implementation_plan.md §5).

-- test: NONE, NULL et vides retirés
RETURN fn::sanitize_array_compact([NONE, NULL, "", " ", "A", 0], true, true) == ["A", 0];

-- test: NULL conservé
RETURN fn::sanitize_array_compact([NONE, NULL, ""], false, false) == [NULL, ""];

-- test: entrée absente → NONE
RETURN fn::sanitize_array_compact(NONE, true, true) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_array_compact(NULL, true, true);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_array_compact("a", true, true);
