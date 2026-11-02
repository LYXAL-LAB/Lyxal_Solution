-- lyxal-test: assertions
-- Tests de fn::sanitize_markdown_quotes (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: citation
RETURN fn::sanitize_markdown_quotes("> citée\nnormale") == "citée\nnormale";

-- test: entrée absente → NONE
RETURN fn::sanitize_markdown_quotes(NONE) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_markdown_quotes(NULL);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_markdown_quotes(42);
