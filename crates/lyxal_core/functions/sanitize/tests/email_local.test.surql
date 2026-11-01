-- lyxal-test: assertions
-- Tests de fn::sanitize_email_local (format : crates/lyxal_core/implementation_plan.md §5).

-- test: partie locale
RETURN fn::sanitize_email_local(" mailto:Jean.Dupont@example.com ") == "Jean.Dupont";

-- test: entrée absente → NONE
RETURN fn::sanitize_email_local(NONE) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_email_local(NULL);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_email_local(42);
