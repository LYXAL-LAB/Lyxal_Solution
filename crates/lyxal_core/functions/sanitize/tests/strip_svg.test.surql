-- lyxal-test: assertions
-- Tests de fn::sanitize_strip_svg (format : crates/lyxal_core/implementation_plan.md §5).

-- test: élément svg retiré
RETURN fn::sanitize_strip_svg("a<SVG x=1>contenu</svg>b") == "ab";

-- test: entrée absente → NONE
RETURN fn::sanitize_strip_svg(NONE) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_strip_svg(NULL);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_strip_svg(42);
