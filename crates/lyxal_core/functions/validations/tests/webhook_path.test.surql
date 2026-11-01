-- lyxal-test: assertions
-- Tests de fn::validation_webhook_path (format : crates/lyxal_core/implementation_plan.md §5).

-- test: valeur conforme
RETURN fn::validation_webhook_path(" /hooks/:provider/* ", true, true)
    == { valid: true, value: "/hooks/:provider/*", code: NONE, details: {} };

-- test: paramètre refusé
RETURN fn::validation_webhook_path("/hooks/:id", false, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { reason: "parameters" } };

-- test: joker refusé
RETURN fn::validation_webhook_path("/hooks/*", true, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { reason: "wildcard" } };

-- test: sans barre initiale
RETURN fn::validation_webhook_path("hooks/stripe", true, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "webhook_path" } };

-- test: double barre
RETURN fn::validation_webhook_path("/hooks//stripe", true, true).code == "CORE_VALIDATION_FORMAT";

-- test: remontée de répertoire
RETURN fn::validation_webhook_path("/hooks/../admin", true, true).code == "CORE_VALIDATION_FORMAT";

-- test: chaîne blanche
RETURN fn::validation_webhook_path("  ", true, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_webhook_path(NONE, true, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_webhook_path(NULL, true, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_webhook_path(42, true, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };
