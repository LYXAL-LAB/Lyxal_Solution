-- lyxal-test: assertions
-- Tests de fn::sanitize_markdown_safe (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: lien javascript neutralisé
RETURN fn::sanitize_markdown_safe("[clic](javascript:alert(1)) <script>x</script>ok") == "[clic](about:blank) ok";

-- test: Markdown conservé
RETURN fn::sanitize_markdown_safe("# Titre **gras**") == "# Titre **gras**";

-- test: lien data neutralisé, texte suivant conservé
RETURN fn::sanitize_markdown_safe("[x](data:text/html,a) suite (note)") == "[x](about:blank) suite (note)";

-- test: lien javascript avec titre
RETURN fn::sanitize_markdown_safe("[clic](javascript:evil \"titre\") fin") == "[clic](about:blank) fin";

-- test: lien javascript avec titre entre apostrophes
RETURN fn::sanitize_markdown_safe("[clic](javascript:x(1) 't') fin") == "[clic](about:blank) fin";

-- test: entrée absente → NONE
RETURN fn::sanitize_markdown_safe(NONE) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_markdown_safe(NULL);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_markdown_safe(42);
