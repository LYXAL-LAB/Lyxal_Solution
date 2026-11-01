-- lyxal-test: assertions
-- Tests de fn::sanitize_domain (format : crates/lyxal_core/implementation_plan.md §5).

-- test: URL complète
RETURN fn::sanitize_domain(" HTTPS://Example.com:8443/a/b ") == "example.com";

-- test: point final
RETURN fn::sanitize_domain("example.com.") == "example.com";

-- test: entrée absente → NONE
RETURN fn::sanitize_domain(NONE) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_domain(NULL);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_domain(42);
