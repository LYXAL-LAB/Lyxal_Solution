-- lyxal-test: assertions
-- Tests de fn::validation_locale (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: valeur conforme
RETURN fn::validation_locale(" fr_fr ", false)
    == { valid: true, value: "fr-FR", code: NONE, details: {} };

-- test: langue seule
RETURN fn::validation_locale("EN", false)
    == { valid: true, value: "en", code: NONE, details: {} };

-- test: région exigée
RETURN fn::validation_locale("en", true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "locale", require_region: true } };

-- test: région à trois lettres
RETURN fn::validation_locale("fr-FRA", false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "locale" } };

-- test: script et région canoniques
RETURN fn::validation_locale("ZH_hant_tw", false)
    == { valid: true, value: "zh-Hant-TW", code: NONE, details: {} };

-- test: script sans région
RETURN fn::validation_locale("sr-latn", false).value == "sr-Latn";

-- test: région à trois chiffres
RETURN fn::validation_locale("es-419", true)
    == { valid: true, value: "es-419", code: NONE, details: {} };

-- test: script sans région refusé si la région est exigée
RETURN fn::validation_locale("zh-Hant", true).code == "CORE_VALIDATION_FORMAT";

-- test: trois segments sans script refusés
RETURN fn::validation_locale("fr-FR-CA", false).code == "CORE_VALIDATION_FORMAT";

-- test: variante refusée
RETURN fn::validation_locale("fr-Latn-FR-x", false).code == "CORE_VALIDATION_FORMAT";

-- test: trop de segments
RETURN fn::validation_locale("fr-FR-x", false).code == "CORE_VALIDATION_FORMAT";

-- test: chaîne blanche
RETURN fn::validation_locale("  ", false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_locale(NONE, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_locale(NULL, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_locale(42, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };
