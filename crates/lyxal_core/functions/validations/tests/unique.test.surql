-- lyxal-test: assertions
-- Tests de fn::validation_unique (format : crates/lyxal_core/implementation_plan.md §5).

-- test: valeur libre
RETURN { UPSERT lyxal_test_ref:one SET code = "ONE"; RETURN fn::validation_unique("TWO", "lyxal_test_ref", "code", NONE)
    == { valid: true, value: "TWO", code: NONE, details: {} }; };

-- test: valeur déjà prise
RETURN { UPSERT lyxal_test_ref:one SET code = "ONE"; RETURN fn::validation_unique("ONE", "lyxal_test_ref", "code", NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_ALREADY_EXISTS", details: {} }; };

-- test: valeur prise par l'enregistrement exclu
RETURN { UPSERT lyxal_test_ref:one SET code = "ONE"; RETURN fn::validation_unique("ONE", "lyxal_test_ref", "code", lyxal_test_ref:one).valid; };

-- test: valeur absente
RETURN fn::validation_unique(NONE, "lyxal_test_ref", "code", NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_unique(NULL, "lyxal_test_ref", "code", NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: nom de table invalide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_unique("x", "a b", "code", NONE);

-- test: champ vide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_unique("x", "lyxal_test_absent", "", NONE);

-- test: enregistrement exclu d'une autre table
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_unique("x", "lyxal_test_absent", "code", other:a);
