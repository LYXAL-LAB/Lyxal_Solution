-- lyxal-test: assertions
-- Tests de fn::sanitize_markdown_links (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: lien remplacé par son texte
RETURN fn::sanitize_markdown_links("Voir [la doc](https://x/doc) et [ici](/a).") == "Voir la doc et ici.";

-- test: crochets sans lien conservés
RETURN fn::sanitize_markdown_links("liste [a, b] ok") == "liste [a, b] ok";

-- test: parenthèse dans le texte
RETURN fn::sanitize_markdown_links("[a) b](u) fin") == "a) b fin";

-- test: entrée absente → NONE
RETURN fn::sanitize_markdown_links(NONE) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_markdown_links(NULL);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_markdown_links(42);
