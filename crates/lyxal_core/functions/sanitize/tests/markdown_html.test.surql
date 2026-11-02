-- lyxal-test: assertions
-- Tests de fn::sanitize_markdown_html (format : crates/lyxal_core/implementation_plan.md §5).

-- test: balises retirées
RETURN fn::sanitize_markdown_html("texte <b>gras</b>") == "texte gras";

-- test: entrée absente → NONE
RETURN fn::sanitize_markdown_html(NONE) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_markdown_html(NULL);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_markdown_html(42);
