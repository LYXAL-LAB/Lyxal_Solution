-- lyxal-test: assertions
-- Tests de fn::sanitize_strip_comments (format : crates/lyxal_core/implementation_plan.md §5).

-- test: commentaire retiré
RETURN fn::sanitize_strip_comments("a<!-- secret\nmulti -->b") == "ab";

-- test: entrée absente → NONE
RETURN fn::sanitize_strip_comments(NONE) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_strip_comments(NULL);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_strip_comments(42);
