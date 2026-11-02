-- lyxal-test: assertions
-- Tests de fn::sanitize_strip_dangerous_attributes (format : crates/lyxal_core/implementation_plan.md §5).

-- test: style retiré
RETURN fn::sanitize_strip_dangerous_attributes("<p style=\"color:red\">x</p>") == "<p>x</p>";

-- test: lien javascript neutralisé
RETURN fn::sanitize_strip_dangerous_attributes("<a href=\"javascript:alert(1)\">x</a>") == "<a href=\"#\">x</a>";

-- test: entrée absente → NONE
RETURN fn::sanitize_strip_dangerous_attributes(NONE) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_strip_dangerous_attributes(NULL);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_strip_dangerous_attributes(42);
