-- lyxal-test: assertions
-- Tests de fn::validation_cron_expression (format : crates/lyxal_core/implementation_plan.md §5).

-- test: valeur conforme
RETURN fn::validation_cron_expression(" */5 * * * MON-FRI ", false, true)
    == { valid: true, value: "*/5 * * * mon-fri", code: NONE, details: {} };

-- test: six champs autorisés
RETURN fn::validation_cron_expression("0 */5 * * * *", true, false)
    == { valid: true, value: "0 */5 * * * *", code: NONE, details: {} };

-- test: macro autorisée
RETURN fn::validation_cron_expression("@Daily", false, true)
    == { valid: true, value: "@daily", code: NONE, details: {} };

-- test: macro refusée
RETURN fn::validation_cron_expression("@daily", false, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { reason: "macro" } };

-- test: six champs refusés
RETURN fn::validation_cron_expression("0 */5 * * * *", false, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "cron_expression" } };

-- test: macro inconnue
RETURN fn::validation_cron_expression("@sometimes", false, true).code == "CORE_VALIDATION_FORMAT";

-- test: caractère interdit
RETURN fn::validation_cron_expression("*/5 * * * $", false, true).code == "CORE_VALIDATION_FORMAT";

-- test: chaîne blanche
RETURN fn::validation_cron_expression("  ", false, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_cron_expression(NONE, false, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_cron_expression(NULL, false, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_cron_expression(42, false, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };
