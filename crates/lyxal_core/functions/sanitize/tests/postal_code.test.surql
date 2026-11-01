-- lyxal-test: assertions
-- Tests de fn::sanitize_postal_code (format : crates/lyxal_core/implementation_plan.md §5).

-- test: majuscules et tiret
RETURN fn::sanitize_postal_code(" sw1a-1aa ") == "SW1A-1AA";

-- test: espaces internes
RETURN fn::sanitize_postal_code("75 008") == "75008";

-- test: entrée absente → NONE
RETURN fn::sanitize_postal_code(NONE) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_postal_code(NULL);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_postal_code(42);
