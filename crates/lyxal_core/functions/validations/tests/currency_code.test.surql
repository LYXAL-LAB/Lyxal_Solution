-- lyxal-test: assertions
-- Tests de fn::validation_currency_code (format : crates/lyxal_core/implementation_plan.md §5).

-- test: valeur conforme
RETURN fn::validation_currency_code(" eur ", ["EUR", "USD"])
    == { valid: true, value: "EUR", code: NONE, details: {} };

-- test: mauvaise longueur
RETURN fn::validation_currency_code("EU", ["EUR", "USD"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "currency_code" } };

-- test: code non autorisé
RETURN fn::validation_currency_code("ZZZ", ["EUR", "USD"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { allowed: ["EUR", "USD"] } };

-- test: chaîne blanche
RETURN fn::validation_currency_code("  ", ["EUR", "USD"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_currency_code(NONE, ["EUR", "USD"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_currency_code(NULL, ["EUR", "USD"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_currency_code(42, ["EUR", "USD"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: liste vide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_currency_code("eur", []);

-- test: code autorisé mal formé
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_currency_code("eur", ["1"]);
