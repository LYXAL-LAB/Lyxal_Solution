-- lyxal-test: assertions
-- Tests de fn::validation_country_code_iso2 (format : crates/lyxal_core/implementation_plan.md §5).

-- test: valeur conforme
RETURN fn::validation_country_code_iso2(" fr ", ["FR", "BE"])
    == { valid: true, value: "FR", code: NONE, details: {} };

-- test: mauvaise longueur
RETURN fn::validation_country_code_iso2("FRA", ["FR", "BE"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "country_code_iso2" } };

-- test: code non autorisé
RETURN fn::validation_country_code_iso2("ZZ", ["FR", "BE"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { allowed: ["FR", "BE"] } };

-- test: chaîne blanche
RETURN fn::validation_country_code_iso2("  ", ["FR", "BE"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_country_code_iso2(NONE, ["FR", "BE"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_country_code_iso2(NULL, ["FR", "BE"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_country_code_iso2(42, ["FR", "BE"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: liste vide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_country_code_iso2("fr", []);

-- test: code autorisé mal formé
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_country_code_iso2("fr", ["1"]);
