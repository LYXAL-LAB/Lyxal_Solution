-- lyxal-test: assertions
-- Tests de fn::validation_all_or_none (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: toutes présentes
RETURN fn::validation_all_or_none(["a", "b"])
    == { valid: true, value: ["a", "b"], code: NONE, details: {} };

-- test: toutes absentes
RETURN fn::validation_all_or_none([NONE, NONE])
    == { valid: true, value: [NONE, NONE], code: NONE, details: {} };

-- test: présence partielle
RETURN fn::validation_all_or_none(["a", NONE, "c"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_COMBINATION", details: { present: 2, total: 3 } };
