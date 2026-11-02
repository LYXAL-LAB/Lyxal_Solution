-- lyxal-test: assertions
-- Tests de fn::utils_engine_optimize (format : crates/lyxal_core/implementation_plan.md §5).

-- test: doublons consécutifs idempotents retirés
RETURN fn::utils_engine_optimize([{ rule: "trim" }, { rule: "trim" }, { rule: "hash" }, { rule: "trim" }], [{ rule: "trim", cost: 1, idempotent: true }, { rule: "hash", cost: 2 }]) == { pipeline: [{ rule: "trim" }, { rule: "hash" }, { rule: "trim" }], removed: 1, cost_before: 5, cost_after: 4 };

-- test: règle non idempotente conservée
RETURN fn::utils_engine_optimize([{ rule: "hash" }, { rule: "hash" }], [{ rule: "trim", cost: 1, idempotent: true }, { rule: "hash", cost: 2 }]).removed == 0;

-- test: options différentes conservées
RETURN fn::utils_engine_optimize([{ rule: "trim", options: { a: 1 } }, { rule: "trim", options: { a: 2 } }], [{ rule: "trim", cost: 1, idempotent: true }, { rule: "hash", cost: 2 }]).removed == 0;

-- test: aucun réordonnancement
RETURN fn::utils_engine_optimize([{ rule: "hash" }, { rule: "trim" }], [{ rule: "trim", cost: 1, idempotent: true }, { rule: "hash", cost: 2 }]).pipeline.map(|$x| $x.rule) == ["hash", "trim"];
