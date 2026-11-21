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

-- test: tri croissant stable (clés égales dans l'ordre d'origine)
RETURN fn::utils_collection_sort_by([{ k: 2, n: 1 }, { k: 1, n: 2 }, { k: 2, n: 3 }, { k: 1, n: 4 }], "k", "asc").map(|$p| $p.n) == [2, 4, 1, 3];

-- test: tri décroissant stable
RETURN fn::utils_collection_sort_by([{ k: 2, n: 1 }, { k: 1, n: 2 }, { k: 2, n: 3 }, { k: 1, n: 4 }], "k", "desc").map(|$p| $p.n) == [1, 3, 2, 4];

-- test: clés NONE et NULL en fin, dans l'ordre d'origine, en ordre décroissant
RETURN fn::utils_collection_sort_by([{ n: 1 }, { k: NULL, n: 2 }, { k: 5, n: 3 }, { n: 4 }, { k: 1, n: 5 }], "k", "desc").map(|$p| $p.n) == [3, 5, 1, 2, 4];

-- test: nombres égaux de types différents dans l'ordre d'origine
RETURN fn::utils_collection_sort_by([{ k: 1dec, n: 1 }, { k: 1, n: 2 }, { k: 1.0, n: 3 }, { k: 0, n: 4 }], "k", "asc").map(|$p| $p.n) == [4, 1, 2, 3];

-- test: types différents rangés selon l'ordre de SurrealQL
RETURN fn::utils_collection_sort_by([{ k: "a" }, { k: 1 }, { k: true }], "k", "asc").map(|$p| $p.k) == [true, 1, "a"];

-- test: collection vide
RETURN fn::utils_collection_sort_by([], "k", "desc") == [];

-- test: 500 éléments : ordre des clés et stabilité
RETURN { LET $sorted = fn::utils_collection_sort_by((<array> (0..500)).map(|$i| { k: ($i * 7919) % 37, n: $i }), "k", "asc"); RETURN (<array> (1..500)).all(|$i| $sorted[$i - 1].k < $sorted[$i].k OR ($sorted[$i - 1].k == $sorted[$i].k AND $sorted[$i - 1].n < $sorted[$i].n)); };
