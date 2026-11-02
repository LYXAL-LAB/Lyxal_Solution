-- lyxal-test: assertions
-- Tests de fn::sanitize_markdown_lists (format : crates/lyxal_core/implementation_plan.md §5).

-- test: puces et numéros
RETURN fn::sanitize_markdown_lists("- a\n* b\n2. c") == "a\nb\nc";

-- test: entrée absente → NONE
RETURN fn::sanitize_markdown_lists(NONE) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_markdown_lists(NULL);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_markdown_lists(42);
