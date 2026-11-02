-- lyxal-test: assertions
-- Tests de fn::sanitize_markdown_code (format : crates/lyxal_core/implementation_plan.md §5).

-- test: bloc et code en ligne
RETURN fn::sanitize_markdown_code("a\n```\nlet x = 1;\n```\nb `code` c") == "a\n\nb code c";

-- test: entrée absente → NONE
RETURN fn::sanitize_markdown_code(NONE) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_markdown_code(NULL);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_markdown_code(42);
