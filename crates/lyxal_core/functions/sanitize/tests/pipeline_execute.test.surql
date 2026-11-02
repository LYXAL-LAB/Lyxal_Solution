-- lyxal-test: assertions
-- Tests de fn::sanitize_pipeline_execute (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: enchaînement d'étapes
RETURN fn::sanitize_pipeline_execute("  Hello   World ", [{ rule: "collapse_whitespace" }, { rule: "lowercase" }, { rule: "slug" }], 10) == "hello-world";

-- test: each sur un tableau
RETURN fn::sanitize_pipeline_execute([" A ", "b "], [{ rule: "each", options: { pipeline: [{ rule: "trim" }, { rule: "lowercase" }] } }], 10) == ["a", "b"];

-- test: NONE traversé
RETURN fn::sanitize_pipeline_execute(NONE, [{ rule: "trim" }], 10) IS NONE;

-- test: options obligatoires
RETURN fn::sanitize_pipeline_execute(150, [{ rule: "clamp", options: { min: 0, max: 100 } }], 10) == 100;

-- test: règle inconnue
-- attendu-erreur: CORE_UNSUPPORTED_OPTION
RETURN fn::sanitize_pipeline_execute("a", [{ rule: "inconnue" }], 10);

-- test: option obligatoire absente
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::sanitize_pipeline_execute(1, [{ rule: "clamp", options: { min: 0 } }], 10);

-- test: trop d'étapes
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::sanitize_pipeline_execute("a", [{ rule: "trim" }, { rule: "trim" }], 1);

-- test: type inattendu
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_pipeline_execute(12, [{ rule: "trim" }], 10);
