-- lyxal-test: assertions
-- Tests de fn::validation_bic (format : crates/lyxal_core/implementation_plan.md §5).

-- test: valeur conforme
RETURN fn::validation_bic(" bnpafrppxxx ", ["FR"])
    == { valid: true, value: "BNPAFRPPXXX", code: NONE, details: {} };

-- test: BIC à 8 caractères
RETURN fn::validation_bic("BNPAFRPP", NONE)
    == { valid: true, value: "BNPAFRPP", code: NONE, details: {} };

-- test: longueur incorrecte
RETURN fn::validation_bic("BNPAFRPPX", ["FR"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "bic" } };

-- test: pays non autorisé
RETURN fn::validation_bic("DEUTDEFF", ["FR"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { allowed: ["FR"] } };

-- test: chaîne blanche
RETURN fn::validation_bic("  ", ["FR"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_bic(NONE, ["FR"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_bic(NULL, ["FR"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_bic(42, ["FR"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: liste vide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_bic("BNPAFRPP", []);
