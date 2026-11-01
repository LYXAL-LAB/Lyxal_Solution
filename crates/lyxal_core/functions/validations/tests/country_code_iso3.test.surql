-- lyxal-test: assertions
-- Tests de fn::validation_country_code_iso3 (format : crates/lyxal_core/implementation_plan.md §5).

-- test: valeur conforme
RETURN fn::validation_country_code_iso3(" fra ", ["FRA", "BEL"])
    == { valid: true, value: "FRA", code: NONE, details: {} };

-- test: mauvaise longueur
RETURN fn::validation_country_code_iso3("FR", ["FRA", "BEL"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "country_code_iso3" } };

-- test: code non autorisé
RETURN fn::validation_country_code_iso3("ZZZ", ["FRA", "BEL"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { allowed: ["FRA", "BEL"] } };

-- test: chaîne blanche
RETURN fn::validation_country_code_iso3("  ", ["FRA", "BEL"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_country_code_iso3(NONE, ["FRA", "BEL"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_country_code_iso3(NULL, ["FRA", "BEL"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_country_code_iso3(42, ["FRA", "BEL"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: liste vide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_country_code_iso3("fra", []);

-- test: code autorisé mal formé
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_country_code_iso3("fra", ["1"]);
