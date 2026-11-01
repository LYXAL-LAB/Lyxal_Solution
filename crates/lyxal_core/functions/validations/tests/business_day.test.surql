-- lyxal-test: assertions
-- Tests de fn::validation_business_day (format : crates/lyxal_core/implementation_plan.md §5).

-- test: lundi ouvré
RETURN fn::validation_business_day(d"2026-08-03T00:00:00Z", NONE)
    == { valid: true, value: d"2026-08-03T00:00:00Z", code: NONE, details: {} };

-- test: samedi refusé
RETURN fn::validation_business_day(d"2026-08-08T00:00:00Z", NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { reason: "weekend" } };

-- test: dimanche refusé
RETURN fn::validation_business_day(d"2026-08-09T00:00:00Z", NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { reason: "weekend" } };

-- test: jour férié refusé
RETURN fn::validation_business_day(d"2026-07-14T00:00:00Z", [d"2026-07-14T00:00:00Z"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { reason: "holiday" } };

-- test: jour non férié accepté
RETURN fn::validation_business_day(d"2026-08-03T00:00:00Z", [d"2026-07-14T00:00:00Z"])
    == { valid: true, value: d"2026-08-03T00:00:00Z", code: NONE, details: {} };

-- test: date avec heure
RETURN fn::validation_business_day(d"2026-08-03T12:00:00Z", NONE).code == "CORE_VALIDATION_FORMAT";

-- test: valeur absente
RETURN fn::validation_business_day(NONE, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_business_day(NULL, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type string refusé
RETURN fn::validation_business_day("2026-08-03", NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "datetime", actual: "string" } };

-- test: jour férié avec heure
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_business_day(d"2026-08-03T00:00:00Z", [d"2026-08-03T12:00:00Z"]);
