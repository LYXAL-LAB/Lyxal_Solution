-- lyxal-test: assertions
-- Tests de fn::sanitize_markdown_headers (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: titres
RETURN fn::sanitize_markdown_headers("# Titre\n### Sous-titre\ntexte") == "Titre\nSous-titre\ntexte";

-- test: entrée absente → NONE
RETURN fn::sanitize_markdown_headers(NONE) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_markdown_headers(NULL);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_markdown_headers(42);
