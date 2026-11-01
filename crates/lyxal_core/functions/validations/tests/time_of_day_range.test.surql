-- lyxal-test: assertions
-- Tests de fn::validation_time_of_day_range (format : crates/lyxal_core/implementation_plan.md §5).

-- test: plage de jour
RETURN fn::validation_time_of_day_range(540, 1080, false, false)
    == { valid: true, value: { start_minute: 540, end_minute: 1080, duration_minutes: 540, overnight: false }, code: NONE, details: {} };

-- test: plage de nuit autorisée
RETURN fn::validation_time_of_day_range(1320, 360, true, false)
    == { valid: true, value: { start_minute: 1320, end_minute: 360, duration_minutes: 480, overnight: true }, code: NONE, details: {} };

-- test: plage de nuit refusée
RETURN fn::validation_time_of_day_range(1320, 360, false, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_RANGE_ORDER", details: { start: 1320, end: 360, allow_equal: false, allow_overnight: false } };

-- test: durée nulle refusée
RETURN fn::validation_time_of_day_range(600, 600, true, false).code == "CORE_VALIDATION_RANGE_ORDER";

-- test: durée nulle autorisée
RETURN fn::validation_time_of_day_range(600, 600, false, true).value.duration_minutes == 0;

-- test: début négatif
RETURN fn::validation_time_of_day_range(-1, 600, false, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SMALL", details: { bound: "start", min: 0 } };

-- test: fin hors journée
RETURN fn::validation_time_of_day_range(0, 1440, false, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LARGE", details: { bound: "end", max: 1439 } };

-- test: début absent
RETURN fn::validation_time_of_day_range(NONE, 600, false, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: { bound: "start" } };

-- test: fin de type chaîne
RETURN fn::validation_time_of_day_range(0, "10:00", false, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { bound: "end", expected: "int", actual: "string" } };
