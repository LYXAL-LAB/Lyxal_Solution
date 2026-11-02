-- lyxal-test: assertions
-- Tests de fn::utils_engine_pipeline (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: étapes normalisées
RETURN fn::utils_engine_pipeline([{ rule: " TRIM " }, { rule: "min", value: 2 }], [{ rule: "trim", cost: 1 }, { rule: "min", cost: 3 }], 10) == [{ rule: "trim", value: NONE, options: {} }, { rule: "min", value: 2, options: {} }];

-- test: règle each contrôlée récursivement
RETURN fn::utils_engine_pipeline([{ rule: "each", options: { pipeline: [{ rule: "Trim" }] } }], [{ rule: "trim", cost: 1 }, { rule: "min", cost: 3 }], 10)[0].options.pipeline[0].rule == "trim";

-- test: règle when normalisée
RETURN fn::utils_engine_pipeline([{ rule: "when", options: { equals: 1, then: [{ rule: "trim" }] } }], [{ rule: "trim", cost: 1 }, { rule: "min", cost: 3 }], 10)[0].options.else == [];

-- test: règle inconnue
-- attendu-erreur: CORE_UNSUPPORTED_OPTION
RETURN fn::utils_engine_pipeline([{ rule: "upper" }], [{ rule: "trim", cost: 1 }, { rule: "min", cost: 3 }], 10);

-- test: règle inconnue dans each
-- attendu-erreur: CORE_UNSUPPORTED_OPTION
RETURN fn::utils_engine_pipeline([{ rule: "each", options: { pipeline: [{ rule: "upper" }] } }], [{ rule: "trim", cost: 1 }, { rule: "min", cost: 3 }], 10);

-- test: trop d'étapes
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::utils_engine_pipeline([{ rule: "trim" }, { rule: "trim" }], [{ rule: "trim", cost: 1 }, { rule: "min", cost: 3 }], 1);

-- test: étape mal formée
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::utils_engine_pipeline(["trim"], [{ rule: "trim", cost: 1 }, { rule: "min", cost: 3 }], 10);

-- test: when sans condition
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::utils_engine_pipeline([{ rule: "when", options: { then: [] } }], [{ rule: "trim", cost: 1 }, { rule: "min", cost: 3 }], 10);

-- test: one_of à une seule branche
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::utils_engine_pipeline([{ rule: "one_of", options: { pipelines: [[]] } }], [{ rule: "trim", cost: 1 }, { rule: "min", cost: 3 }], 10);

-- test: option obligatoire absente
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::utils_engine_pipeline([{ rule: "pad" }], [{ rule: "pad", required: ["width"] }], 10);

-- test: option obligatoire présente
RETURN fn::utils_engine_pipeline([{ rule: "pad", options: { width: 3 } }], [{ rule: "pad", required: ["width"] }], 10)[0].options.width == 3;

-- test: catalogue masquant une règle du moteur
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::utils_engine_pipeline([], [{ rule: "each" }], 10);
