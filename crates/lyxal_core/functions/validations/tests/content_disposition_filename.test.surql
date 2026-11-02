-- lyxal-test: assertions
-- Tests de fn::validation_content_disposition_filename (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: valeur conforme
RETURN fn::validation_content_disposition_filename(" rapport.pdf ", 255)
    == { valid: true, value: "rapport.pdf", code: NONE, details: {} };

-- test: guillemet
RETURN fn::validation_content_disposition_filename("rap\"port.pdf", 255)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "content_disposition_filename" } };

-- test: retour à la ligne
RETURN fn::validation_content_disposition_filename("rap\nport.pdf", 255).code == "CORE_VALIDATION_FORMAT";

-- test: point initial
RETURN fn::validation_content_disposition_filename(".env", 255).code == "CORE_VALIDATION_FORMAT";

-- test: chaîne blanche
RETURN fn::validation_content_disposition_filename("  ", 255)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_content_disposition_filename(NONE, 255)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_content_disposition_filename(NULL, 255)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_content_disposition_filename(42, 255)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: longueur maximale nulle
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_content_disposition_filename("a", 0);
