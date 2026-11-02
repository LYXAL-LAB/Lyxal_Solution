-- lyxal-test: assertions
-- Tests de fn::validation_image_dimensions (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: dimensions valides
RETURN fn::validation_image_dimensions(1920, 1080, 16, 4096, 16, 4096, NONE)
    == { valid: true, value: { width: 1920, height: 1080, pixels: 2073600 }, code: NONE, details: {} };

-- test: trop de pixels
RETURN fn::validation_image_dimensions(1920, 1080, 16, 4096, 16, 4096, 1000000)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LARGE", details: { bound: "pixels", max: 1000000 } };

-- test: largeur trop petite
RETURN fn::validation_image_dimensions(8, 1080, 16, 4096, 16, 4096, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SMALL", details: { bound: "width", min: 16 } };

-- test: hauteur absente
RETURN fn::validation_image_dimensions(1920, NONE, 16, 4096, 16, 4096, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: { bound: "height" } };

-- test: bornes inversées
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_image_dimensions(1, 1, 100, 10, 1, 10, NONE);

-- test: pixels nuls
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_image_dimensions(1, 1, 1, 10, 1, 10, 0);
