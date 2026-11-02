-- lyxal-test: assertions
-- Tests de fn::utils_engine_report_merge (format : crates/lyxal_core/implementation_plan.md §5).

-- test: fusion
RETURN fn::utils_engine_report_merge([{ valid: true, value: 1, errors: [], warnings: [] }, { valid: false, value: 2, errors: [{ path: "a", code: "X" }], warnings: [{ code: "W" }] }]) == { valid: false, values: [1, 2], errors: [{ path: "a", code: "X" }], warnings: [{ code: "W" }], by_field: { a: ["X"] } };

-- test: aucun rapport
RETURN fn::utils_engine_report_merge([]) == { valid: true, values: [], errors: [], warnings: [], by_field: {} };
