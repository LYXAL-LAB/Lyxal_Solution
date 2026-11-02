-- lyxal-test: assertions
-- Tests de fn::sanitize_safe_redirect (format : crates/lyxal_core/implementation_plan.md §5).

-- test: chemin interne conservé
RETURN fn::sanitize_safe_redirect(" /compte?onglet=1 ", "/") == "/compte?onglet=1";

-- test: URL absolue refusée
RETURN fn::sanitize_safe_redirect("https://evil.com", "/") == "/";

-- test: double barre refusée
RETURN fn::sanitize_safe_redirect("//evil.com", "/") == "/";

-- test: barre inverse refusée
RETURN fn::sanitize_safe_redirect("/\\evil.com", "/") == "/";

-- test: javascript refusé
RETURN fn::sanitize_safe_redirect("javascript:alert(1)", "/") == "/";

-- test: repli externe
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::sanitize_safe_redirect("/a", "https://x");

-- test: entrée absente → NONE
RETURN fn::sanitize_safe_redirect(NONE, "/") == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_safe_redirect(NULL, "/");

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_safe_redirect(42, "/");
