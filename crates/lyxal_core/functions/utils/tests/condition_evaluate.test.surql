-- lyxal-test: assertions
-- Tests de fn::utils_condition_evaluate (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: eq et ne
RETURN fn::utils_condition_evaluate({ a: { b: "x" } }, { field: "a.b", op: "eq", value: "x" }, NONE) == { matched: true, error: NONE }
    AND !fn::utils_condition_evaluate({ a: { b: "x" } }, { field: "a.b", op: "ne", value: "x" }, NONE).matched
    AND fn::utils_condition_evaluate({ a: [1, 2] }, { field: "a", op: "eq", value: [1, 2] }, NONE).matched;

-- test: comparaisons de nombres
RETURN fn::utils_condition_evaluate({ n: 5 }, { field: "n", op: "lt", value: 6 }, NONE).matched
    AND fn::utils_condition_evaluate({ n: 5 }, { field: "n", op: "lte", value: 5 }, NONE).matched
    AND fn::utils_condition_evaluate({ n: 5.5 }, { field: "n", op: "gt", value: 5 }, NONE).matched
    AND fn::utils_condition_evaluate({ n: 5 }, { field: "n", op: "gte", value: 5 }, NONE).matched
    AND !fn::utils_condition_evaluate({ n: 5 }, { field: "n", op: "gt", value: 5 }, NONE).matched;

-- test: comparaisons de chaînes et de dates
RETURN fn::utils_condition_evaluate({ s: "b" }, { field: "s", op: "gt", value: "a" }, NONE).matched
    AND fn::utils_condition_evaluate({ d: d"2026-03-01T00:00:00Z" }, { field: "d", op: "lt", value: d"2026-04-01T00:00:00Z" }, NONE).matched;

-- test: between, bornes incluses
RETURN fn::utils_condition_evaluate({ n: 10 }, { field: "n", op: "between", value: [1, 10] }, NONE).matched
    AND !fn::utils_condition_evaluate({ n: 11 }, { field: "n", op: "between", value: [1, 10] }, NONE).matched;

-- test: in et not_in
RETURN fn::utils_condition_evaluate({ role: "admin" }, { field: "role", op: "in", value: ["admin", "owner"] }, NONE).matched
    AND fn::utils_condition_evaluate({ role: "membre" }, { field: "role", op: "not_in", value: ["admin"] }, NONE).matched
    AND !fn::utils_condition_evaluate({ role: "admin" }, { field: "role", op: "not_in", value: ["admin"] }, NONE).matched;

-- test: contains sur une chaîne et sur un tableau
RETURN fn::utils_condition_evaluate({ s: "chantier nord" }, { field: "s", op: "contains", value: "nord" }, NONE).matched
    AND fn::utils_condition_evaluate({ tags: ["btp", "bois"] }, { field: "tags", op: "contains", value: "bois" }, NONE).matched
    AND !fn::utils_condition_evaluate({ tags: ["btp"] }, { field: "tags", op: "contains", value: "bois" }, NONE).matched;

-- test: starts_with et ends_with
RETURN fn::utils_condition_evaluate({ s: "FR-75" }, { field: "s", op: "starts_with", value: "FR-" }, NONE).matched
    AND fn::utils_condition_evaluate({ s: "FR-75" }, { field: "s", op: "ends_with", value: "75" }, NONE).matched;

-- test: exists, missing et empty
RETURN fn::utils_condition_evaluate({ a: 0 }, { field: "a", op: "exists" }, NONE).matched
    AND fn::utils_condition_evaluate({ a: NULL }, { field: "a", op: "missing" }, NONE).matched
    AND fn::utils_condition_evaluate({}, { field: "a.b", op: "missing" }, NONE).matched
    AND fn::utils_condition_evaluate({ a: "" }, { field: "a", op: "empty" }, NONE).matched
    AND fn::utils_condition_evaluate({ a: [] }, { field: "a", op: "empty" }, NONE).matched
    AND !fn::utils_condition_evaluate({ a: [1] }, { field: "a", op: "empty" }, NONE).matched;

-- test: champ absent : règle fausse sans erreur, sauf ne, not_in, missing et empty
RETURN fn::utils_condition_evaluate({}, { field: "x", op: "gt", value: 1 }, NONE) == { matched: false, error: NONE }
    AND fn::utils_condition_evaluate({}, { field: "x", op: "eq", value: 1 }, NONE) == { matched: false, error: NONE }
    AND fn::utils_condition_evaluate({}, { field: "x", op: "ne", value: 1 }, NONE).matched
    AND fn::utils_condition_evaluate({}, { field: "x", op: "not_in", value: [1] }, NONE).matched
    AND fn::utils_condition_evaluate("pas un objet", { field: "x", op: "missing" }, NONE).matched;

-- test: types incompatibles : règle fausse avec erreur
RETURN fn::utils_condition_evaluate({ n: "12" }, { field: "n", op: "gt", value: 5 }, NONE)
    == { matched: false, error: { field: "n", op: "gt", reason: "type_mismatch" } }
    AND fn::utils_condition_evaluate({ n: 12 }, { field: "n", op: "starts_with", value: "1" }, NONE).error.reason == "type_mismatch"
    AND fn::utils_condition_evaluate({ n: 12 }, { field: "n", op: "contains", value: "1" }, NONE).error.reason == "type_mismatch";

-- test: all : toutes vraies, arrêt au premier échec
RETURN fn::utils_condition_evaluate({ a: 1, b: 2 }, { all: [{ field: "a", op: "eq", value: 1 }, { field: "b", op: "eq", value: 2 }] }, NONE).matched
    AND !fn::utils_condition_evaluate({ a: 1, b: 3 }, { all: [{ field: "a", op: "eq", value: 1 }, { field: "b", op: "eq", value: 2 }] }, NONE).matched;

-- test: any : une vraie suffit ; erreur rapportée si aucune ne l'est
RETURN fn::utils_condition_evaluate({ a: 1 }, { any: [{ field: "a", op: "eq", value: 2 }, { field: "a", op: "eq", value: 1 }] }, NONE) == { matched: true, error: NONE }
    AND fn::utils_condition_evaluate({ a: "x" }, { any: [{ field: "a", op: "gt", value: 2 }, { field: "a", op: "eq", value: "y" }] }, NONE).error.reason == "type_mismatch";

-- test: not, et négation d'une règle en erreur qui reste fausse
RETURN fn::utils_condition_evaluate({ a: 1 }, { not: { field: "a", op: "eq", value: 2 } }, NONE).matched
    AND !fn::utils_condition_evaluate({ a: "x" }, { not: { field: "a", op: "gt", value: 2 } }, NONE).matched;

-- test: imbrication
RETURN fn::utils_condition_evaluate(
    { subscriber: { data: { region: "nord", niveau: 3 } }, payload: { montant: 1500 } },
    { all: [{ field: "payload.montant", op: "gte", value: 1000 }, { any: [{ field: "subscriber.data.region", op: "eq", value: "sud" }, { not: { field: "subscriber.data.niveau", op: "lt", value: 2 } }] }] },
    NONE
).matched;

-- test: forme invalide
-- attendu-erreur: CORE_CONDITION_INVALID
RETURN fn::utils_condition_evaluate({ a: 1 }, { field: "a", op: "regex", value: "." }, NONE);

-- test: condition trop profonde pour les limites
-- attendu-erreur: CORE_CONDITION_INVALID
RETURN fn::utils_condition_evaluate({ a: 1 }, { not: { not: { field: "a", op: "exists" } } }, { max_depth: 2 });
