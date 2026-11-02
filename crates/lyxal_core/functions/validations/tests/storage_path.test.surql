-- lyxal-test: assertions
-- Tests de fn::validation_storage_path (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: valeur conforme
RETURN fn::validation_storage_path(" tenant-1/docs/a.pdf ", false, false, 1024)
    == { valid: true, value: "tenant-1/docs/a.pdf", code: NONE, details: {} };

-- test: barres autorisées
RETURN fn::validation_storage_path("/tenant-1/docs/", true, true, 1024)
    == { valid: true, value: "/tenant-1/docs/", code: NONE, details: {} };

-- test: barre initiale refusée
RETURN fn::validation_storage_path("/tenant-1/a.pdf", false, false, 1024)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "storage_path" } };

-- test: remontée
RETURN fn::validation_storage_path("tenant-1/../a.pdf", false, false, 1024).code == "CORE_VALIDATION_FORMAT";

-- test: caractère interdit
RETURN fn::validation_storage_path("tenant 1/a.pdf", false, false, 1024).code == "CORE_VALIDATION_FORMAT";

-- test: chaîne blanche
RETURN fn::validation_storage_path("  ", false, false, 1024)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_storage_path(NONE, false, false, 1024)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_storage_path(NULL, false, false, 1024)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_storage_path(42, false, false, 1024)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: longueur maximale nulle
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_storage_path("a", false, false, 0);
