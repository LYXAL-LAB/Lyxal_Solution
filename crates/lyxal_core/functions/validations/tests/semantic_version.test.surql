-- lyxal-test: assertions
-- Tests de fn::validation_semantic_version (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: valeur conforme
RETURN fn::validation_semantic_version(" 1.2.3-rc.1+build.5 ", false)
    == { valid: true, value: "1.2.3-rc.1+build.5", code: NONE, details: {} };

-- test: préfixe v autorisé
RETURN fn::validation_semantic_version("v1.2.3", true)
    == { valid: true, value: "v1.2.3", code: NONE, details: {} };

-- test: zéro initial
RETURN fn::validation_semantic_version("01.2.3", false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "semantic_version" } };

-- test: préfixe v refusé
RETURN fn::validation_semantic_version("v1.2.3", false).code == "CORE_VALIDATION_FORMAT";

-- test: chaîne blanche
RETURN fn::validation_semantic_version("  ", false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_semantic_version(NONE, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_semantic_version(NULL, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_semantic_version(42, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };
