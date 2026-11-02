-- lyxal-test: assertions
-- Tests de fn::validation_contract_version (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: valeur conforme
RETURN fn::validation_contract_version(" V2 ")
    == { valid: true, value: "v2", code: NONE, details: {} };

-- test: version zéro
RETURN fn::validation_contract_version("v0")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "contract_version" } };

-- test: sans v
RETURN fn::validation_contract_version("2").code == "CORE_VALIDATION_FORMAT";

-- test: chaîne blanche
RETURN fn::validation_contract_version("  ")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_contract_version(NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_contract_version(NULL)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_contract_version(42)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };
