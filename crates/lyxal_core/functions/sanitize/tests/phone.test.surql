-- lyxal-test: assertions
-- Tests de fn::sanitize_phone (format : crates/lyxal_core/implementation_plan.md §5).

-- test: format international
RETURN fn::sanitize_phone(" +33 (0)6 12-34-56-78 ") == "+330612345678";

-- test: format national
RETURN fn::sanitize_phone("06 12 34 56 78") == "0612345678";

-- test: entrée absente → NONE
RETURN fn::sanitize_phone(NONE) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_phone(NULL);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_phone(42);
