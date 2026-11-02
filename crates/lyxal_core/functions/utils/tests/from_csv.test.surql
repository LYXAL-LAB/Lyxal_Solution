-- lyxal-test: assertions
-- Tests de fn::utils_from_csv (format : crates/lyxal_core/implementation_plan.md §5).

-- test: avec en-tête
RETURN fn::utils_from_csv("a,b\n1,2\n\n3,4", ",", true) == { headers: ["a", "b"], rows: [{ a: "1", b: "2" }, { a: "3", b: "4" }] };

-- test: fins de ligne Windows
RETURN fn::utils_from_csv("a;b\r\n1;2\r\n", ";", true) == { headers: ["a", "b"], rows: [{ a: "1", b: "2" }] };

-- test: sans en-tête
RETURN fn::utils_from_csv("1,2", "", false) == { headers: ["column_0", "column_1"], rows: [{ column_0: "1", column_1: "2" }] };

-- test: texte vide
RETURN fn::utils_from_csv(" \n ", ",", true) == { headers: [], rows: [] };
