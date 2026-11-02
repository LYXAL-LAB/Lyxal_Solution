-- lyxal-test: assertions
-- Tests de fn::validation_mac_address (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: valeur conforme
RETURN fn::validation_mac_address(" AA:BB:CC:DD:EE:FF ", true, true)
    == { valid: true, value: "aa:bb:cc:dd:ee:ff", code: NONE, details: {} };

-- test: tiret refusé
RETURN fn::validation_mac_address("AA-BB-CC-DD-EE-FF", false, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "mac_address" } };

-- test: tiret accepté
RETURN fn::validation_mac_address("AA-BB-CC-DD-EE-FF", true, false)
    == { valid: true, value: "aa-bb-cc-dd-ee-ff", code: NONE, details: {} };

-- test: octet manquant
RETURN fn::validation_mac_address("AA:BB:CC:DD:EE", true, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "mac_address" } };

-- test: chaîne blanche
RETURN fn::validation_mac_address("  ", true, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_mac_address(NONE, true, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_mac_address(NULL, true, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_mac_address(42, true, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: aucun séparateur
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_mac_address("a", false, false);
