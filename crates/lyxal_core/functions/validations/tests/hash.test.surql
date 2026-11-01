-- lyxal-test: assertions
-- Tests de fn::validation_hash (format : crates/lyxal_core/implementation_plan.md §5).

-- test: valeur conforme
RETURN fn::validation_hash(" A9993E364706816ABA3E25717850C26C9CD0D89D ", "sha1")
    == { valid: true, value: "a9993e364706816aba3e25717850c26c9cd0d89d", code: NONE, details: {} };

-- test: longueur incorrecte
RETURN fn::validation_hash("A9993E364706816ABA3E25717850C26C9CD0D8", "sha1")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "sha1", length: 40 } };

-- test: caractère non hexadécimal
RETURN fn::validation_hash("Z9993E364706816ABA3E25717850C26C9CD0D89D", "sha1").code == "CORE_VALIDATION_FORMAT";

-- test: chaîne blanche
RETURN fn::validation_hash("  ", "sha1")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_hash(NONE, "sha1")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_hash(NULL, "sha1")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_hash(42, "sha1")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: algorithme inconnu
-- attendu-erreur: CORE_UNSUPPORTED_OPTION
RETURN fn::validation_hash("ab", "whirlpool");
