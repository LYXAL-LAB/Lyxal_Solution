-- lyxal-test: assertions
-- Tests de fn::validation_extension (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: valeur conforme
RETURN fn::validation_extension(" PDF ", ["pdf", "png"], false)
    == { valid: true, value: "pdf", code: NONE, details: {} };

-- test: point initial exigé
RETURN fn::validation_extension(".tar.gz", NONE, true)
    == { valid: true, value: ".tar.gz", code: NONE, details: {} };

-- test: point initial refusé
RETURN fn::validation_extension(".pdf", ["pdf", "png"], false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "extension" } };

-- test: extension non autorisée
RETURN fn::validation_extension("exe", ["pdf", "png"], false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { allowed: ["pdf", "png"] } };

-- test: chaîne blanche
RETURN fn::validation_extension("  ", ["pdf", "png"], false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_extension(NONE, ["pdf", "png"], false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_extension(NULL, ["pdf", "png"], false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_extension(42, ["pdf", "png"], false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: liste vide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_extension("pdf", [], false);
