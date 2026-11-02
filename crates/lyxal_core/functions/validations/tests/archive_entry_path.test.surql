-- lyxal-test: assertions
-- Tests de fn::validation_archive_entry_path (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: valeur conforme
RETURN fn::validation_archive_entry_path(" docs/readme.txt ", 1024)
    == { valid: true, value: "docs/readme.txt", code: NONE, details: {} };

-- test: chemin absolu
RETURN fn::validation_archive_entry_path("/etc/passwd", 1024)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "archive_entry_path" } };

-- test: remontée
RETURN fn::validation_archive_entry_path("docs/../../x", 1024).code == "CORE_VALIDATION_FORMAT";

-- test: lettre de lecteur
RETURN fn::validation_archive_entry_path("C:/x", 1024).code == "CORE_VALIDATION_FORMAT";

-- test: chaîne blanche
RETURN fn::validation_archive_entry_path("  ", 1024)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_archive_entry_path(NONE, 1024)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_archive_entry_path(NULL, 1024)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_archive_entry_path(42, 1024)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: longueur maximale nulle
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_archive_entry_path("a", 0);
