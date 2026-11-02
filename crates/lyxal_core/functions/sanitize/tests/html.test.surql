-- lyxal-test: assertions
-- Tests de fn::sanitize_html (format : crates/lyxal_core/implementation_plan.md §5).

-- test: fragment nettoyé
RETURN fn::sanitize_html("<p onclick=\"x()\">Bonjour</p><script>alert(1)</script><!-- c -->") == "<p>Bonjour</p>";

-- test: entrée absente → NONE
RETURN fn::sanitize_html(NONE) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_html(NULL);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_html(42);
