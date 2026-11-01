-- lyxal-test: assertions
-- Tests de fn::validation_geohash (format : crates/lyxal_core/implementation_plan.md §5).

-- test: valeur conforme
RETURN fn::validation_geohash(" U09TVW ", 5, 12)
    == { valid: true, value: "u09tvw", code: NONE, details: {} };

-- test: lettre exclue
RETURN fn::validation_geohash("u09tva", 5, 12)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "geohash" } };

-- test: trop court
RETURN fn::validation_geohash("u09", 5, 12)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SHORT", details: { min_length: 5, length: 3 } };

-- test: chaîne blanche
RETURN fn::validation_geohash("  ", 5, 12)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_geohash(NONE, 5, 12)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_geohash(NULL, 5, 12)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_geohash(42, 5, 12)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: bornes inversées
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_geohash("u09tv", 6, 5);
