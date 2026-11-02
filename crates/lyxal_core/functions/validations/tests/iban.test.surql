-- lyxal-test: assertions
-- Tests de fn::validation_iban (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: valeur conforme
RETURN fn::validation_iban(" fr76 3000 6000 0112 3456 7890 189 ", ["FR"])
    == { valid: true, value: "FR7630006000011234567890189", code: NONE, details: {} };

-- test: longueur FR incorrecte
RETURN fn::validation_iban("FR763000600001123456789018", ["FR"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "iban", length: 27 } };

-- test: pays non autorisé
RETURN fn::validation_iban("DE89370400440532013000", ["FR"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { allowed: ["FR"] } };

-- test: forme invalide
RETURN fn::validation_iban("FRXX30006000011234567890189", ["FR"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "iban" } };

-- test: chaîne blanche
RETURN fn::validation_iban("  ", ["FR"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_iban(NONE, ["FR"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_iban(NULL, ["FR"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_iban(42, ["FR"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: liste vide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_iban("FR76", []);

-- test: code pays mal formé
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_iban("FR76", ["FRA"]);
