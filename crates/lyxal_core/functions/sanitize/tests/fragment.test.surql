-- lyxal-test: assertions
-- Tests de fn::sanitize_fragment (format : crates/lyxal_core/implementation_plan.md §5).

-- test: dièse retiré
RETURN fn::sanitize_fragment(" #section-2 ") == "section-2";

-- test: entrée absente → NONE
RETURN fn::sanitize_fragment(NONE) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_fragment(NULL);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_fragment(42);
