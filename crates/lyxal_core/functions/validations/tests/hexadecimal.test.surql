-- lyxal-test: assertions
-- Tests de fn::validation_hexadecimal (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: hexadécimal mis en minuscules
RETURN fn::validation_hexadecimal(" FF00aa ", 6, 6, false)
    == { valid: true, value: "ff00aa", code: NONE, details: {} };

-- test: préfixe autorisé, hors longueur
RETURN fn::validation_hexadecimal("0xFF", 2, 2, true)
    == { valid: true, value: "0xff", code: NONE, details: {} };

-- test: préfixe refusé
RETURN fn::validation_hexadecimal("0xFF", NONE, NONE, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "hexadecimal" } };

-- test: caractère non hexadécimal
RETURN fn::validation_hexadecimal("FG", NONE, NONE, false).code == "CORE_VALIDATION_FORMAT";

-- test: trop court
RETURN fn::validation_hexadecimal("abc", 4, NONE, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SHORT", details: { min_length: 4, length: 3 } };

-- test: trop long
RETURN fn::validation_hexadecimal("0xabc", NONE, 2, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LONG", details: { max_length: 2, length: 3 } };

-- test: chaîne blanche
RETURN fn::validation_hexadecimal(" ", NONE, NONE, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_hexadecimal(NONE, NONE, NONE, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_hexadecimal(NULL, NONE, NONE, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_hexadecimal(255, NONE, NONE, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: longueur minimale nulle
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_hexadecimal("a", 0, NONE, false);

-- test: bornes inversées
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_hexadecimal("a", 4, 2, false);
