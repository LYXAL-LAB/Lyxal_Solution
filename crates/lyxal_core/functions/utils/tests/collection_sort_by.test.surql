-- lyxal-test: assertions
-- Tests de fn::utils_collection_sort_by (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: tri croissant
RETURN fn::utils_collection_sort_by([{ name: "A", team: "x", age: 30 }, { name: "B", team: "y", age: 20 }, { name: "C", team: "x", age: 25 }], "age", "asc").map(|$p| $p.name) == ["B", "C", "A"];

-- test: tri décroissant
RETURN fn::utils_collection_sort_by([{ name: "A", team: "x", age: 30 }, { name: "B", team: "y", age: 20 }, { name: "C", team: "x", age: 25 }], "age", " DESC ").map(|$p| $p.name) == ["A", "C", "B"];

-- test: valeurs absentes en fin
RETURN fn::utils_collection_sort_by([{ v: NONE, n: 1 }, { v: 2, n: 2 }, { v: 1, n: 3 }], "v", "asc").map(|$p| $p.n) == [3, 2, 1];

-- test: sens inconnu
-- attendu-erreur: CORE_UNSUPPORTED_OPTION
RETURN fn::utils_collection_sort_by([], "age", "up");
