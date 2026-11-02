-- lyxal-test: assertions
-- Tests de fn::sanitize_strip_styles (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: élément style retiré
RETURN fn::sanitize_strip_styles("a<STYLE x=1>contenu</style>b") == "ab";

-- test: entrée absente → NONE
RETURN fn::sanitize_strip_styles(NONE) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_strip_styles(NULL);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_strip_styles(42);
