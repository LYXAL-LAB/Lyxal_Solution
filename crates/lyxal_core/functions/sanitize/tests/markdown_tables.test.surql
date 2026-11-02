-- lyxal-test: assertions
-- Tests de fn::sanitize_markdown_tables (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: tableau
RETURN fn::sanitize_markdown_tables("|a|b|\n|---|---|\n|1|2|") == " a b \n\n 1 2 ";

-- test: entrée absente → NONE
RETURN fn::sanitize_markdown_tables(NONE) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_markdown_tables(NULL);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_markdown_tables(42);
