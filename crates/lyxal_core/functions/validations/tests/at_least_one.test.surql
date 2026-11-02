-- lyxal-test: assertions
-- Tests de fn::validation_at_least_one (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: une valeur présente
RETURN fn::validation_at_least_one([NONE, "06 00 00 00 00"])
    == { valid: true, value: [NONE, "06 00 00 00 00"], code: NONE, details: {} };

-- test: NULL compte comme présent
RETURN fn::validation_at_least_one([NULL, NONE]).valid;

-- test: aucune valeur
RETURN fn::validation_at_least_one([NONE, NONE])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: { scope: "group" } };
