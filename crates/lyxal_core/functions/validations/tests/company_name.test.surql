-- lyxal-test: assertions
-- Tests de fn::validation_company_name (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: valeur conforme
RETURN fn::validation_company_name(" Dupont & Fils (SARL) ", 2, 100)
    == { valid: true, value: "Dupont & Fils (SARL)", code: NONE, details: {} };

-- test: caractère interdit
RETURN fn::validation_company_name("Dupont <script>", 2, 100)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "company_name" } };

-- test: chaîne blanche
RETURN fn::validation_company_name("  ", 2, 100)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_company_name(NONE, 2, 100)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_company_name(NULL, 2, 100)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_company_name(42, 2, 100)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: bornes inversées
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_company_name("ab", 5, 2);
