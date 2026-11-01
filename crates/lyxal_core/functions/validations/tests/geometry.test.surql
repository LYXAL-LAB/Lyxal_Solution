-- lyxal-test: assertions
-- Tests de fn::validation_geometry (format : crates/lyxal_core/implementation_plan.md §5).

-- test: point accepté
RETURN fn::validation_geometry((2.35f, 48.85f), NONE, true)
    == { valid: true, value: (2.35f, 48.85f), code: NONE, details: {} };

-- test: polygone autorisé
RETURN fn::validation_geometry({ type: "Polygon", coordinates: [[[0.0, 0.0], [1.0, 0.0], [1.0, 1.0], [0.0, 0.0]]] }, ["polygon"], true).valid;

-- test: point non autorisé
RETURN fn::validation_geometry((2.35f, 48.85f), ["polygon"], false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { allowed: ["polygon"], actual: "point" } };

-- test: valeur absente
RETURN fn::validation_geometry(NONE, NONE, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_geometry(NULL, NONE, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type string refusé
RETURN fn::validation_geometry("POINT(1 2)", NONE, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "geometry", actual: "string" } };

-- test: liste vide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_geometry((1.0f, 2.0f), [], false);

-- test: sous-type inconnu
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_geometry((1.0f, 2.0f), ["circle"], false);
