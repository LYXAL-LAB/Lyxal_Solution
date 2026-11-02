-- lyxal-test: assertions
-- Tests de fn::security_step_result (format : crates/lyxal_core/implementation_plan.md §5).

-- test: résultat vide
RETURN fn::security_step_result(fn::utils_engine_state("a", "", NONE)) == { value: "a", findings: [], score: 0, decisions: [], allowed: true, errors: [] };

-- test: refus d'une décision
RETURN fn::security_step_result(fn::utils_engine_record(fn::utils_engine_state(1, "", NONE), "permission_check", "decision", { allowed: false })).allowed == false;
