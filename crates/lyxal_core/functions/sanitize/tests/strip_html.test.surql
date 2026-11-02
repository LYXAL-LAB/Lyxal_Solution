-- lyxal-test: assertions
-- Tests de fn::sanitize_strip_html (format : crates/lyxal_core/implementation_plan.md §5).

-- test: balises retirées
RETURN fn::sanitize_strip_html("<p>Bonjour <b>Lyxal</b></p>") == "Bonjour Lyxal";

-- test: entrée absente → NONE
RETURN fn::sanitize_strip_html(NONE) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_strip_html(NULL);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_strip_html(42);
