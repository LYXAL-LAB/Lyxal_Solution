-- lyxal-test: assertions
-- Tests de fn::validation_pipeline_execute (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: valeur valide
RETURN fn::validation_pipeline_execute(" A@b.fr ", [{ rule: "email", options: { max_length: 254 } }], 10) == { valid: true, value: "A@b.fr", errors: [], warnings: [], by_field: {} };

-- test: valeur invalide sans erreur levée
RETURN fn::validation_pipeline_execute("x", [{ rule: "email", options: { max_length: 254 } }], 10).by_field == { "$": ["CORE_VALIDATION_FORMAT"] };

-- test: arrêt à la première erreur
RETURN array::len(fn::validation_pipeline_execute("x", [{ rule: "min_length", options: { min_length: 3 } }, { rule: "max_length", options: { max_length: 0 } }], 10).errors) == 1;

-- test: each sur un tableau
RETURN fn::validation_pipeline_execute([1, "a", 3], [{ rule: "array" }, { rule: "each", options: { pipeline: [{ rule: "integer" }] } }], 10).by_field == { "[1]": ["CORE_VALIDATION_TYPE"] };

-- test: règle inconnue
-- attendu-erreur: CORE_UNSUPPORTED_OPTION
RETURN fn::validation_pipeline_execute(1, [{ rule: "inconnue" }], 10);

-- test: option obligatoire absente
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_pipeline_execute("a", [{ rule: "min_length" }], 10);
