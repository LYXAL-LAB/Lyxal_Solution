-- lyxal-test: assertions
-- Tests de fn::validation_duration_range (format : crates/lyxal_core/implementation_plan.md §5).

-- test: intervalle valide
RETURN fn::validation_duration_range(30m, 8h, false, NONE, NONE)
    == { valid: true, value: { min_duration: 30m, max_duration: 8h, span: 7h30m }, code: NONE, details: {} };

-- test: bornes égales autorisées
RETURN fn::validation_duration_range(1h, 1h, true, NONE, NONE)
    == { valid: true, value: { min_duration: 1h, max_duration: 1h, span: 0ns }, code: NONE, details: {} };

-- test: bornes égales refusées
RETURN fn::validation_duration_range(1h, 1h, false, NONE, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_RANGE_ORDER", details: { min_value: 1h, max_value: 1h, allow_equal: false } };

-- test: bornes inversées
RETURN fn::validation_duration_range(2h, 1h, true, NONE, NONE).code == "CORE_VALIDATION_RANGE_ORDER";

-- test: écart trop faible
RETURN fn::validation_duration_range(1h, 2h, false, 2h, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SMALL", details: { min_span: 2h, span: 1h } };

-- test: écart trop grand
RETURN fn::validation_duration_range(1h, 2h, false, NONE, 30m)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LARGE", details: { max_span: 30m, span: 1h } };

-- test: borne basse absente
RETURN fn::validation_duration_range(NONE, 2h, false, NONE, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: { bound: "min" } };

-- test: borne haute de type chaîne
RETURN fn::validation_duration_range(1h, "2h", false, NONE, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { bound: "max", expected: "duration", actual: "string" } };

-- test: écarts inversés
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_duration_range(1h, 2h, false, 2h, 1h);

-- test: écart maximal nul sans égalité
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_duration_range(1h, 2h, false, NONE, 0ns);
