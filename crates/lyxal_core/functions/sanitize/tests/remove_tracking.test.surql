-- lyxal-test: assertions
-- Tests de fn::sanitize_remove_tracking (format : crates/lyxal_core/implementation_plan.md §5).

-- test: paramètres de suivi retirés
RETURN fn::sanitize_remove_tracking("https://x.com/p?utm_source=nl&id=2&gclid=abc") == "https://x.com/p?id=2";

-- test: seuls paramètres de suivi
RETURN fn::sanitize_remove_tracking("https://x.com/p?utm_medium=mail&fbclid=z") == "https://x.com/p";

-- test: fragment conservé
RETURN fn::sanitize_remove_tracking("https://x.com/p?utm_campaign=a#top") == "https://x.com/p#top";

-- test: URL sans suivi inchangée
RETURN fn::sanitize_remove_tracking("https://x.com/p?q=1") == "https://x.com/p?q=1";

-- test: entrée absente → NONE
RETURN fn::sanitize_remove_tracking(NONE) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_remove_tracking(NULL);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_remove_tracking(42);
