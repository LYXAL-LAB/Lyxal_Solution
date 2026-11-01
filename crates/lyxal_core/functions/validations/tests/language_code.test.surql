-- lyxal-test: assertions
-- Tests de fn::validation_language_code (format : crates/lyxal_core/implementation_plan.md §5).

-- test: valeur conforme
RETURN fn::validation_language_code(" FR ", false, ["fr", "en"])
    == { valid: true, value: "fr", code: NONE, details: {} };

-- test: trois lettres autorisées
RETURN fn::validation_language_code("fra", true, NONE)
    == { valid: true, value: "fra", code: NONE, details: {} };

-- test: trois lettres refusées
RETURN fn::validation_language_code("fra", false, ["fr", "en"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "language_code" } };

-- test: code non autorisé
RETURN fn::validation_language_code("de", false, ["fr", "en"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { allowed: ["fr", "en"] } };

-- test: chaîne blanche
RETURN fn::validation_language_code("  ", false, ["fr", "en"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_language_code(NONE, false, ["fr", "en"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_language_code(NULL, false, ["fr", "en"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_language_code(42, false, ["fr", "en"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: liste vide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_language_code("fr", false, []);
