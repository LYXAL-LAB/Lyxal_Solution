-- lyxal-test: assertions
-- Tests de fn::sanitize_html_entities (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: caractères échappés
RETURN fn::sanitize_html_entities("<a href=\"x\">Tom & Jerry's</a>") == "&lt;a href=&quot;x&quot;&gt;Tom &amp; Jerry&#39;s&lt;/a&gt;";

-- test: entrée absente → NONE
RETURN fn::sanitize_html_entities(NONE) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_html_entities(NULL);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_html_entities(42);
