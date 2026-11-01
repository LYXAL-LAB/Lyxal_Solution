-- lyxal-test: assertions
-- Tests de fn::validation_exists (format : crates/lyxal_core/implementation_plan.md §5).

-- test: valeur présente
RETURN { UPSERT lyxal_test_ref:one SET code = "ONE"; RETURN fn::validation_exists("ONE", "lyxal_test_ref", "code")
    == { valid: true, value: "ONE", code: NONE, details: {} }; };

-- test: valeur absente
RETURN { UPSERT lyxal_test_ref:one SET code = "ONE"; RETURN fn::validation_exists("TWO", "lyxal_test_ref", "code")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_FOUND", details: {} }; };

-- test: valeur absente
RETURN fn::validation_exists(NONE, "lyxal_test_ref", "code")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_exists(NULL, "lyxal_test_ref", "code")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: nom de table invalide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_exists("x", "a-b", "code");

-- test: champ vide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_exists("x", "lyxal_test_absent", " ");
