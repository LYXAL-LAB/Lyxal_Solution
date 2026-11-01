-- lyxal-test: assertions
-- Tests de fn::validation_siren (format : crates/lyxal_core/implementation_plan.md §5).

-- test: valeur conforme
RETURN fn::validation_siren(" 732 829 320 ")
    == { valid: true, value: "732829320", code: NONE, details: {} };

-- test: clé fausse
RETURN fn::validation_siren("732829321")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "luhn" } };

-- test: dix chiffres
RETURN fn::validation_siren("7328293200")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LONG", details: { max_length: 9, length: 10 } };

-- test: chaîne blanche
RETURN fn::validation_siren("  ")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_siren(NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_siren(NULL)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_siren(42)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };
