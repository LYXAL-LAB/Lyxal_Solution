-- lyxal-test: assertions
-- Tests de fn::validation_checksum (format : crates/lyxal_core/implementation_plan.md §5).

-- test: valeur conforme
RETURN fn::validation_checksum(" CBF43926 ", "crc32")
    == { valid: true, value: "cbf43926", code: NONE, details: {} };

-- test: longueur incorrecte
RETURN fn::validation_checksum("CBF439", "crc32")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "crc32", length: 8 } };

-- test: caractère non hexadécimal
RETURN fn::validation_checksum("ZBF43926", "crc32").code == "CORE_VALIDATION_FORMAT";

-- test: chaîne blanche
RETURN fn::validation_checksum("  ", "crc32")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_checksum(NONE, "crc32")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_checksum(NULL, "crc32")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_checksum(42, "crc32")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: algorithme inconnu
-- attendu-erreur: CORE_UNSUPPORTED_OPTION
RETURN fn::validation_checksum("ab", "whirlpool");
