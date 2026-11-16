-- lyxal-test: assertions
-- Tests de fn::utils_condition_check (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: règle simple valide
RETURN fn::utils_condition_check({ field: "payload.montant", op: "gt", value: 1000 }, NONE)
    == { valid: true, code: NONE, details: {}, rules: 1, depth: 1 };

-- test: groupes imbriqués : règles et profondeur comptées
RETURN fn::utils_condition_check({ all: [{ field: "a", op: "exists" }, { any: [{ field: "b", op: "eq", value: 1 }, { not: { field: "c", op: "in", value: ["x"] } }] }] }, NONE).{ valid, rules, depth }
    == { valid: true, rules: 3, depth: 4 };

-- test: chaque opérateur accepté avec la valeur attendue
RETURN array::all([
    { field: "a", op: "eq", value: "x" }, { field: "a", op: "ne", value: 1 },
    { field: "a", op: "lt", value: 1 }, { field: "a", op: "lte", value: "m" },
    { field: "a", op: "gt", value: d"2026-01-01T00:00:00Z" }, { field: "a", op: "gte", value: 2.5 },
    { field: "a", op: "between", value: [1, 9] }, { field: "a", op: "in", value: [1, "b"] },
    { field: "a", op: "not_in", value: [1] }, { field: "a", op: "contains", value: "x" },
    { field: "a", op: "starts_with", value: "x" }, { field: "a", op: "ends_with", value: "x" },
    { field: "a", op: "exists" }, { field: "a", op: "missing" }, { field: "a", op: "empty" }
], |$rule| fn::utils_condition_check($rule, NONE).valid);

-- test: valeur qui n'est pas un objet
RETURN fn::utils_condition_check("a = 1", NONE).{ valid, code, details } == { valid: false, code: "CORE_CONDITION_INVALID", details: { path: "$", reason: "not_object" } };

-- test: groupe vide
RETURN fn::utils_condition_check({ any: [] }, NONE).details == { path: "$", reason: "empty_group" };

-- test: clé inconnue
RETURN fn::utils_condition_check({ field: "a", op: "eq", value: 1, extra: true }, NONE).details.reason == "unknown_keys";

-- test: chemin de champ invalide
RETURN fn::utils_condition_check({ field: "a..b", op: "exists" }, NONE).details.reason == "invalid_field"
    AND fn::utils_condition_check({ field: "", op: "exists" }, NONE).details.reason == "invalid_field";

-- test: opérateur inconnu
RETURN fn::utils_condition_check({ field: "a", op: "regex", value: ".*" }, NONE).details.reason == "unknown_operator";

-- test: valeur manquante, inattendue ou invalide
RETURN fn::utils_condition_check({ field: "a", op: "eq" }, NONE).details.reason == "missing_value"
    AND fn::utils_condition_check({ field: "a", op: "exists", value: true }, NONE).details.reason == "unexpected_value"
    AND fn::utils_condition_check({ field: "a", op: "between", value: [1, "z"] }, NONE).details.reason == "invalid_value"
    AND fn::utils_condition_check({ field: "a", op: "in", value: [] }, NONE).details.reason == "invalid_value"
    AND fn::utils_condition_check({ field: "a", op: "gt", value: true }, NONE).details.reason == "invalid_value"
    AND fn::utils_condition_check({ field: "a", op: "starts_with", value: 1 }, NONE).details.reason == "invalid_value";

-- test: chemin du nœud fautif
RETURN fn::utils_condition_check({ all: [{ field: "a", op: "exists" }, { not: { field: "b", op: "nope" } }] }, NONE).details
    == { path: "$.all[1].not", reason: "unknown_operator" };

-- test: profondeur bornée (5 par défaut, réglable)
RETURN fn::utils_condition_check({ not: { not: { not: { not: { not: { field: "a", op: "exists" } } } } } }, NONE).details.reason == "too_deep"
    AND fn::utils_condition_check({ not: { not: { not: { not: { field: "a", op: "exists" } } } } }, NONE).valid
    AND fn::utils_condition_check({ not: { not: { field: "a", op: "exists" } } }, { max_depth: 2 }).details.reason == "too_deep";

-- test: nombre de règles borné (50 par défaut, réglable)
RETURN fn::utils_condition_check({ any: array::map(<array>(0..51), |$i| { field: "a", op: "eq", value: $i }) }, NONE).details.reason == "too_many_rules"
    AND fn::utils_condition_check({ any: array::map(<array>(0..50), |$i| { field: "a", op: "eq", value: $i }) }, NONE).valid
    AND fn::utils_condition_check({ any: [{ field: "a", op: "exists" }, { field: "b", op: "exists" }] }, { max_rules: 1 }).details.reason == "too_many_rules";

-- test: limite au-delà du plafond
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::utils_condition_check({ field: "a", op: "exists" }, { max_depth: 11 });

-- test: limite inconnue
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::utils_condition_check({ field: "a", op: "exists" }, { max_nodes: 3 });
