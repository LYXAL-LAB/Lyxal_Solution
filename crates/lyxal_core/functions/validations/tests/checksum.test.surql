-- lyxal-test: assertions
-- Tests de fn::validation_checksum (format : crates/lyxal_core/Readme.md, section « Tests »).

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

-- test: empreinte blake3 (64 caractères hexadécimaux), rendue en minuscules
RETURN fn::validation_checksum("AF1349B9F5F9A1A6A0404DEA36DCC9499BCB25C9ADC112B7CC9A93CAE41F3262", "BLAKE3")
    == { valid: true, value: "af1349b9f5f9a1a6a0404dea36dcc9499bcb25c9adc112b7cc9a93cae41f3262", code: NONE, details: {} };

-- test: empreinte blake3 de mauvaise longueur
RETURN fn::validation_checksum("AF1349B9F5F9A1A6A0404DEA36DCC9499BCB25C9", "blake3")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "blake3", length: 64 } };

-- test: algorithme inconnu
-- attendu-erreur: CORE_UNSUPPORTED_OPTION
RETURN fn::validation_checksum("ab", "whirlpool");
