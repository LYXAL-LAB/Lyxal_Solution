-- lyxal-test: assertions
-- Tests de fn::utils_engine_by_field (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: regroupement
RETURN fn::utils_engine_by_field([{ path: "a", code: "X" }, { path: "a", code: "Y" }, { path: "", code: "Z" }]) == { a: ["X", "Y"], "$": ["Z"] };

-- test: aucune erreur
RETURN fn::utils_engine_by_field([]) == {};
