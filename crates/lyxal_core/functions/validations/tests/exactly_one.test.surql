-- lyxal-test: assertions
-- Tests de fn::validation_exactly_one (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: une seule valeur
RETURN fn::validation_exactly_one([user:a, NONE])
    == { valid: true, value: [user:a, NONE], code: NONE, details: {} };

-- test: aucune valeur
RETURN fn::validation_exactly_one([NONE, NONE])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: { scope: "group" } };

-- test: deux valeurs
RETURN fn::validation_exactly_one([user:a, team:b])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_COMBINATION", details: { present: 2, max: 1 } };
