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

-- test: définitions identiques : même normalisation
RETURN { LET $fields = fn::utils_engine_schema({ fields: { a: { pipeline: [{ rule: " Trim " }], default: "x" }, b: { pipeline: [{ rule: " Trim " }], default: "x" }, c: { pipeline: [{ rule: "min", value: 2 }] } } }, [{ rule: "trim", cost: 1 }, { rule: "min", cost: 3 }], 10).fields; RETURN $fields.a == $fields.b AND $fields.a == { pipeline: [{ rule: "trim", value: NONE, options: {} }], required: false, nullable: false, default: "x" } AND $fields.c.pipeline[0].value == 2; };

-- test: valeurs égales de types différents : définitions distinctes
RETURN { LET $fields = fn::utils_engine_schema({ fields: { a: { default: 1 }, b: { default: 1.0 }, c: { default: 1dec } } }, [{ rule: "trim", cost: 1 }], 10).fields; RETURN type::is_int($fields.a.default) AND type::is_float($fields.b.default) AND type::is_decimal($fields.c.default); };

-- test: grand catalogue : pipelines des champs contrôlés
RETURN fn::utils_engine_schema({ fields: { a: { pipeline: [{ rule: "R7" }] }, b: { pipeline: [{ rule: "each", options: { pipeline: [{ rule: "trim" }] } }] } } }, array::concat((<array> (0..40)).map(|$i| { rule: "r" + <string> $i, cost: 1 }), [{ rule: "trim", cost: 1 }]), 10).fields.b.pipeline[0].options.pipeline[0].rule == "trim";

-- test: grand catalogue : règle inconnue dans un champ
-- attendu-erreur: CORE_UNSUPPORTED_OPTION
RETURN fn::utils_engine_schema({ fields: { a: { pipeline: [{ rule: "r1" }] }, b: { pipeline: [{ rule: "x" }] } } }, (<array> (0..40)).map(|$i| { rule: "r" + <string> $i, cost: 1 }), 10);

-- test: grand catalogue masquant une règle du moteur
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::utils_engine_schema({ fields: { a: { pipeline: [{ rule: "r1" }] } } }, array::concat((<array> (0..40)).map(|$i| { rule: "r" + <string> $i, cost: 1 }), [{ rule: "each" }]), 10);
