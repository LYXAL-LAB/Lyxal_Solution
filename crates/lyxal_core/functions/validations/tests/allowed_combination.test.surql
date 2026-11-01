-- lyxal-test: assertions
-- Tests de fn::validation_allowed_combination (format : crates/lyxal_core/implementation_plan.md §5).

-- test: combinaison autorisée
RETURN fn::validation_allowed_combination(["weight", "kg"], [["weight", "kg"], ["length", "m"]])
    == { valid: true, value: ["weight", "kg"], code: NONE, details: {} };

-- test: combinaison refusée
RETURN fn::validation_allowed_combination(["weight", "m"], [["weight", "kg"], ["length", "m"]])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_COMBINATION", details: { allowed: [["weight", "kg"], ["length", "m"]] } };

-- test: liste vide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_allowed_combination(["a"], []);

-- test: combinaison de longueur différente
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_allowed_combination(["a", "b"], [["a"]]);
