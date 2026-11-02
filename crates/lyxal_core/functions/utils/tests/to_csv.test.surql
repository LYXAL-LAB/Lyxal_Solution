-- lyxal-test: assertions
-- Tests de fn::utils_to_csv (format : crates/lyxal_core/implementation_plan.md §5).

-- test: en-tête et lignes
RETURN fn::utils_to_csv([{ a: 1, b: "x" }, { a: 2 }], ["a", "b"], ",", true) == "a,b\n1,x\n2,";

-- test: guillemets RFC 4180
RETURN fn::utils_to_csv([{ a: "x,y", b: "il dit \"oui\"" }], ["a", "b"], ",", false) == "\"x,y\",\"il dit \"\"oui\"\"\"";

-- test: retour à la ligne entouré
RETURN fn::utils_to_csv([{ a: "l1\nl2" }], ["a"], ";", false) == "\"l1\nl2\"";

-- test: séparateur par défaut
RETURN fn::utils_to_csv([{ a: 1, b: 2 }], ["a", "b"], "", false) == "1,2";
