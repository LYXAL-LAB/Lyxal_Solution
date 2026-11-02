-- lyxal-test: assertions
-- Tests de fn::validation_past_datetime (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: du bon côté de la référence
RETURN fn::validation_past_datetime(d"2025-12-31T00:00:00Z", d"2026-01-01T00:00:00Z", false, NONE, NONE)
    == { valid: true, value: d"2025-12-31T00:00:00Z", code: NONE, details: {} };

-- test: égal refusé
RETURN fn::validation_past_datetime(d"2026-01-01T00:00:00Z", d"2026-01-01T00:00:00Z", false, NONE, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LARGE", details: { max: d"2026-01-01T00:00:00Z", exclusive: true } };

-- test: égal autorisé
RETURN fn::validation_past_datetime(d"2026-01-01T00:00:00Z", d"2026-01-01T00:00:00Z", true, NONE, NONE)
    == { valid: true, value: d"2026-01-01T00:00:00Z", code: NONE, details: {} };

-- test: du mauvais côté
RETURN fn::validation_past_datetime(d"2026-01-02T00:00:00Z", d"2026-01-01T00:00:00Z", true, NONE, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LARGE", details: { max: d"2026-01-01T00:00:00Z", exclusive: false } };

-- test: écart trop faible
RETURN fn::validation_past_datetime(d"2025-12-31T00:00:00Z", d"2026-01-01T00:00:00Z", false, 2d, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SMALL", details: { min_age: 2d, age: 1d } };

-- test: écart trop grand
RETURN fn::validation_past_datetime(d"2025-12-31T00:00:00Z", d"2026-01-01T00:00:00Z", false, NONE, 12h)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LARGE", details: { max_age: 12h, age: 1d } };

-- test: référence par défaut : maintenant
RETURN fn::validation_past_datetime(d"1990-01-01T00:00:00Z", NONE, false, NONE, NONE).valid;

-- test: valeur absente
RETURN fn::validation_past_datetime(NONE, NONE, false, NONE, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_past_datetime(NULL, NONE, false, NONE, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type string refusé
RETURN fn::validation_past_datetime("2026-01-02", NONE, false, NONE, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "datetime", actual: "string" } };

-- test: écarts inversés
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_past_datetime(d"2025-12-31T00:00:00Z", d"2026-01-01T00:00:00Z", false, 2d, 1d);

-- test: écart maximal nul sans égalité
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_past_datetime(d"2025-12-31T00:00:00Z", d"2026-01-01T00:00:00Z", false, NONE, 0ns);
