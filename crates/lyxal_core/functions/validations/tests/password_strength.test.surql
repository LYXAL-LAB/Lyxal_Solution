-- lyxal-test: assertions
-- Tests de fn::validation_password_strength (format : crates/lyxal_core/implementation_plan.md §5).

-- test: mot de passe robuste
RETURN fn::validation_password_strength("Abcdef12!", 8, 64, true, true, true, true)
    == { valid: true, value: "Abcdef12!", code: NONE, details: {} };

-- test: trop court
RETURN fn::validation_password_strength("Ab1!", 8, 64, true, true, true, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SHORT", details: { min_length: 8, length: 4 } };

-- test: classes manquantes
RETURN fn::validation_password_strength("abcdefgh", 8, 64, true, true, true, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "password", missing: ["uppercase", "digit", "special"] } };

-- test: aucune classe exigée
RETURN fn::validation_password_strength("abcdefgh", 8, 64, false, false, false, false)
    == { valid: true, value: "abcdefgh", code: NONE, details: {} };

-- test: espaces conservés
RETURN fn::validation_password_strength(" abcdefg", 8, 64, false, false, false, false)
    == { valid: true, value: " abcdefg", code: NONE, details: {} };

-- test: valeur absente
RETURN fn::validation_password_strength(NONE, 8, 64, false, false, false, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_password_strength(NULL, 8, 64, false, false, false, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_password_strength(12345678, 8, 64, false, false, false, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: bornes inversées
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_password_strength("a", 10, 8, false, false, false, false);
