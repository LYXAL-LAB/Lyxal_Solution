-- lyxal-test: assertions
-- Tests de fn::sanitize_strip_iframes (format : crates/lyxal_core/implementation_plan.md §5).

-- test: élément iframe retiré
RETURN fn::sanitize_strip_iframes("a<IFRAME x=1>contenu</iframe>b") == "ab";

-- test: entrée absente → NONE
RETURN fn::sanitize_strip_iframes(NONE) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_strip_iframes(NULL);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_strip_iframes(42);
