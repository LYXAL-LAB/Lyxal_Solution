-- lyxal-test: assertions
-- Tests de fn::validation_postal_code_fr (format : crates/lyxal_core/implementation_plan.md §5).

-- test: valeur conforme
RETURN fn::validation_postal_code_fr(" 75008 ", false)
    == { valid: true, value: "75008", code: NONE, details: {} };

-- test: CEDEX autorisé
RETURN fn::validation_postal_code_fr("75008 cedex 08", true)
    == { valid: true, value: "75008 CEDEX 08", code: NONE, details: {} };

-- test: quatre chiffres
RETURN fn::validation_postal_code_fr("7508", false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "postal_code_fr" } };

-- test: CEDEX refusé
RETURN fn::validation_postal_code_fr("75008 CEDEX", false).code == "CORE_VALIDATION_FORMAT";

-- test: chaîne blanche
RETURN fn::validation_postal_code_fr("  ", false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_postal_code_fr(NONE, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_postal_code_fr(NULL, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_postal_code_fr(42, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };
