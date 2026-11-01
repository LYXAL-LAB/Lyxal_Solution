-- lyxal-test: assertions
-- Tests de fn::validation_date (format : crates/lyxal_core/implementation_plan.md §5).

-- test: date à minuit dans les bornes
RETURN fn::validation_date(d"2026-08-03T00:00:00Z", d"2026-07-14T00:00:00Z", d"2026-08-09T00:00:00Z")
    == { valid: true, value: d"2026-08-03T00:00:00Z", code: NONE, details: {} };

-- test: date avec heure refusée
RETURN fn::validation_date(d"2026-08-03T12:00:00Z", NONE, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "date" } };

-- test: trop tôt
RETURN fn::validation_date(d"2026-07-14T00:00:00Z", d"2026-08-03T00:00:00Z", NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SMALL", details: { min: d"2026-08-03T00:00:00Z" } };

-- test: trop tard
RETURN fn::validation_date(d"2026-08-09T00:00:00Z", NONE, d"2026-08-08T00:00:00Z")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LARGE", details: { max: d"2026-08-08T00:00:00Z" } };

-- test: valeur absente
RETURN fn::validation_date(NONE, NONE, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_date(NULL, NONE, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type string refusé
RETURN fn::validation_date("2026-08-03", NONE, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "datetime", actual: "string" } };

-- test: borne avec heure
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_date(d"2026-08-03T00:00:00Z", d"2026-08-03T12:00:00Z", NONE);

-- test: bornes inversées
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_date(d"2026-08-03T00:00:00Z", d"2026-08-09T00:00:00Z", d"2026-07-14T00:00:00Z");
