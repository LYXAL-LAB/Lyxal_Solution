-- lyxal-test: assertions
-- Tests de fn::validation_mutually_exclusive (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: une seule valeur
RETURN fn::validation_mutually_exclusive(["A", NONE], false)
    == { valid: true, value: ["A", NONE], code: NONE, details: {} };

-- test: aucune valeur autorisée
RETURN fn::validation_mutually_exclusive([NONE, NONE], true)
    == { valid: true, value: [NONE, NONE], code: NONE, details: {} };

-- test: aucune valeur refusée
RETURN fn::validation_mutually_exclusive([NONE, NONE], false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: { scope: "group" } };

-- test: deux valeurs
RETURN fn::validation_mutually_exclusive(["A", "B"], true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_COMBINATION", details: { present: 2, max: 1 } };
