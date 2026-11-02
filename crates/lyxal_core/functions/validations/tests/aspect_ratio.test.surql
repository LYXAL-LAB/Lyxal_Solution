-- lyxal-test: assertions
-- Tests de fn::validation_aspect_ratio (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: rapport valide
RETURN fn::validation_aspect_ratio(1920, 1080, 1dec, 2dec)
    == { valid: true, value: { width: 1920, height: 1080, ratio: 1920dec / 1080dec }, code: NONE, details: {} };

-- test: rapport trop petit
RETURN fn::validation_aspect_ratio(1080, 1920, 1dec, 2dec).code == "CORE_VALIDATION_TOO_SMALL";

-- test: rapport trop grand
RETURN fn::validation_aspect_ratio(3000, 1000, 1dec, 2dec)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LARGE", details: { bound: "ratio", max: 2dec, ratio: 3dec } };

-- test: dimension nulle
RETURN fn::validation_aspect_ratio(0, 1000, 1dec, 2dec)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SMALL", details: { bound: "width", min: 1 } };

-- test: hauteur de type chaîne
RETURN fn::validation_aspect_ratio(100, "100", 1dec, 2dec)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { bound: "height", expected: "int", actual: "string" } };

-- test: rapport minimal nul
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_aspect_ratio(1, 1, 0dec, 2dec);

-- test: rapports inversés
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_aspect_ratio(1, 1, 2dec, 1dec);
