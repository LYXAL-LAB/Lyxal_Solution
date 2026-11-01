-- lyxal-test: assertions
-- Tests de fn::validation_lyxal_storage_path (format : crates/lyxal_core/implementation_plan.md §5).

-- test: valeur conforme
RETURN fn::validation_lyxal_storage_path(" tenants/acme/doc.pdf ", "tenants", true, 1024)
    == { valid: true, value: "tenants/acme/doc.pdf", code: NONE, details: {} };

-- test: extension refusée
RETURN fn::validation_lyxal_storage_path("tenants/doc.pdf", NONE, false, 1024)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { reason: "extension" } };

-- test: racine manquante
RETURN fn::validation_lyxal_storage_path("public/doc.pdf", "tenants", true, 1024)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "lyxal_storage_path", root: "tenants" } };

-- test: chemin absolu
RETURN fn::validation_lyxal_storage_path("/tenants/a", "tenants", true, 1024)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "lyxal_storage_path" } };

-- test: remontée
RETURN fn::validation_lyxal_storage_path("tenants/../x", "tenants", true, 1024).code == "CORE_VALIDATION_FORMAT";

-- test: chaîne blanche
RETURN fn::validation_lyxal_storage_path("  ", "tenants", true, 1024)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_lyxal_storage_path(NONE, "tenants", true, 1024)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_lyxal_storage_path(NULL, "tenants", true, 1024)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_lyxal_storage_path(42, "tenants", true, 1024)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: longueur maximale nulle
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_lyxal_storage_path("a", NONE, true, 0);

-- test: racine vide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_lyxal_storage_path("a", " ", true, 10);
