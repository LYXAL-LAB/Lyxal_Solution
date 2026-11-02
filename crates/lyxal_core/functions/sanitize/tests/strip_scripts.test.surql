-- lyxal-test: assertions
-- Tests de fn::sanitize_strip_scripts (format : crates/lyxal_core/implementation_plan.md §5).

-- test: élément script retiré
RETURN fn::sanitize_strip_scripts("a<SCRIPT x=1>contenu</script>b") == "ab";

-- test: entrée absente → NONE
RETURN fn::sanitize_strip_scripts(NONE) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_strip_scripts(NULL);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_strip_scripts(42);
