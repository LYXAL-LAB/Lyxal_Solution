-- lyxal-test: assertions
-- Tests de fn::sanitize_markdown_images (format : crates/lyxal_core/implementation_plan.md §5).

-- test: image remplacée par son texte
RETURN fn::sanitize_markdown_images("Logo ![Lyxal OS](https://x/logo.png) fin") == "Logo Lyxal OS fin";

-- test: texte alternatif vide
RETURN fn::sanitize_markdown_images("a![](x.png)b") == "ab";

-- test: crochet ordinaire conservé
RETURN fn::sanitize_markdown_images("a ![b c") == "a ![b c";

-- test: entrée absente → NONE
RETURN fn::sanitize_markdown_images(NONE) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_markdown_images(NULL);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_markdown_images(42);
