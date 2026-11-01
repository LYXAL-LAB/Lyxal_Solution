-- lyxal-test: assertions
-- Tests de fn::validation_filename (format : crates/lyxal_core/implementation_plan.md §5).

-- test: valeur conforme
RETURN fn::validation_filename(" devis 2026.pdf ", 1, 255)
    == { valid: true, value: "devis 2026.pdf", code: NONE, details: {} };

-- test: séparateur
RETURN fn::validation_filename("a/b.pdf", 1, 255)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "filename" } };

-- test: caractère réservé
RETURN fn::validation_filename("devis?.pdf", 1, 255).code == "CORE_VALIDATION_FORMAT";

-- test: point final
RETURN fn::validation_filename("devis.", 1, 255).code == "CORE_VALIDATION_FORMAT";

-- test: trop long
RETURN fn::validation_filename("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", 1, 255)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LONG", details: { max_length: 255, length: 256 } };

-- test: chaîne blanche
RETURN fn::validation_filename("  ", 1, 255)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_filename(NONE, 1, 255)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_filename(NULL, 1, 255)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_filename(42, 1, 255)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: bornes inversées
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_filename("a", 5, 1);
