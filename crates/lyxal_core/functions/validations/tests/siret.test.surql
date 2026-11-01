-- lyxal-test: assertions
-- Tests de fn::validation_siret (format : crates/lyxal_core/implementation_plan.md §5).

-- test: SIRET décomposé
RETURN fn::validation_siret("732 829 320 00074")
    == { valid: true, value: { siret: "73282932000074", siren: "732829320", nic: "00074" }, code: NONE, details: {} };

-- test: clé fausse
RETURN fn::validation_siret("73282932000075")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "luhn" } };

-- test: treize chiffres
RETURN fn::validation_siret("7328293200007")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SHORT", details: { min_length: 14, length: 13 } };

-- test: valeur absente
RETURN fn::validation_siret(NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_siret(NULL)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_siret(73282932000074)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };
