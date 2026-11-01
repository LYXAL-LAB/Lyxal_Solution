-- lyxal-test: assertions
-- Tests de fn::validation_invoice_number (format : crates/lyxal_core/implementation_plan.md §5).

-- test: valeur conforme
RETURN fn::validation_invoice_number(" FAC-2026/0001 ", 3, 20, ["FAC-"])
    == { valid: true, value: "FAC-2026/0001", code: NONE, details: {} };

-- test: préfixe non autorisé
RETURN fn::validation_invoice_number("AV-2026/0001", 3, 20, ["FAC-"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { allowed_prefixes: ["FAC-"] } };

-- test: caractère interdit
RETURN fn::validation_invoice_number("FAC 2026", 3, 20, ["FAC-"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "invoice_number" } };

-- test: chaîne blanche
RETURN fn::validation_invoice_number("  ", 3, 20, ["FAC-"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_invoice_number(NONE, 3, 20, ["FAC-"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_invoice_number(NULL, 3, 20, ["FAC-"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_invoice_number(42, 3, 20, ["FAC-"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: bornes inversées
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_invoice_number("FAC-1", 10, 3, NONE);

-- test: liste vide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_invoice_number("FAC-1", 3, 20, []);
