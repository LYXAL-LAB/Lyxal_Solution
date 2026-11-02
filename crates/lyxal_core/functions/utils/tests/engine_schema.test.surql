-- lyxal-test: assertions
-- Tests de fn::utils_engine_schema (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: valeurs par défaut
RETURN fn::utils_engine_schema({ name: "contact", fields: { name: { pipeline: [{ rule: "trim" }, { rule: "min", value: 2 }], required: true }, note: { pipeline: [{ rule: "trim" }], nullable: true }, lang: { default: "fr" } } }, [{ rule: "trim", cost: 1 }, { rule: "min", cost: 3 }], 10).fields.lang == { pipeline: [], required: false, nullable: false, default: "fr" };

-- test: politique par défaut
RETURN fn::utils_engine_schema({ name: "contact", fields: { name: { pipeline: [{ rule: "trim" }, { rule: "min", value: 2 }], required: true }, note: { pipeline: [{ rule: "trim" }], nullable: true }, lang: { default: "fr" } } }, [{ rule: "trim", cost: 1 }, { rule: "min", cost: 3 }], 10).unknown_keys == "reject";

-- test: champs absents
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::utils_engine_schema({ name: "x" }, [{ rule: "trim", cost: 1 }, { rule: "min", cost: 3 }], 10);

-- test: politique inconnue
-- attendu-erreur: CORE_UNSUPPORTED_OPTION
RETURN fn::utils_engine_schema({ fields: { a: {} }, unknown_keys: "allow" }, [{ rule: "trim", cost: 1 }, { rule: "min", cost: 3 }], 10);

-- test: required non booléen
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::utils_engine_schema({ fields: { a: { required: "oui" } } }, [{ rule: "trim", cost: 1 }, { rule: "min", cost: 3 }], 10);

-- test: règle inconnue dans un champ
-- attendu-erreur: CORE_UNSUPPORTED_OPTION
RETURN fn::utils_engine_schema({ fields: { a: { pipeline: [{ rule: "x" }] } } }, [{ rule: "trim", cost: 1 }, { rule: "min", cost: 3 }], 10);
