-- lyxal-test: assertions
-- Tests de fn::validation_coordinates (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: coordonnées valides
RETURN fn::validation_coordinates(48.8566f, 2.3522f)
    == { valid: true, value: { latitude: 48.8566f, longitude: 2.3522f }, code: NONE, details: {} };

-- test: latitude hors bornes
RETURN fn::validation_coordinates(91, 0)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LARGE", details: { bound: "latitude", max: 90 } };

-- test: longitude hors bornes
RETURN fn::validation_coordinates(0, -181)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SMALL", details: { bound: "longitude", min: -180 } };

-- test: latitude absente
RETURN fn::validation_coordinates(NONE, 0)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: { bound: "latitude" } };

-- test: longitude de type chaîne
RETURN fn::validation_coordinates(0, "2.35")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { bound: "longitude", expected: "number", actual: "string" } };
