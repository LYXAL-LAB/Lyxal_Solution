-- lyxal-test: assertions
-- Tests de fn::validation_dsl_compile (format : crates/lyxal_core/implementation_plan.md §5).

-- test: pipelines construits
RETURN fn::validation_dsl_compile({ name: "contact", version: "v1", fields: { name: { required: true, type: "string", min_length: 2, max_length: 50 }, age: { min: 0, max: 130 }, role: { enum: ["admin", "user"], default: "user" } } }).fields.name.pipeline.map(|$s| $s.rule) == ["value_type", "min_length", "max_length"];

-- test: required, défaut et nom conservés
RETURN fn::validation_dsl_compile({ name: "contact", version: "v1", fields: { name: { required: true, type: "string", min_length: 2, max_length: 50 }, age: { min: 0, max: 130 }, role: { enum: ["admin", "user"], default: "user" } } }).fields.role.default == "user" AND fn::validation_dsl_compile({ name: "contact", version: "v1", fields: { name: { required: true, type: "string", min_length: 2, max_length: 50 }, age: { min: 0, max: 130 }, role: { enum: ["admin", "user"], default: "user" } } }).fields.name.required AND fn::validation_dsl_compile({ name: "contact", version: "v1", fields: { name: { required: true, type: "string", min_length: 2, max_length: 50 }, age: { min: 0, max: 130 }, role: { enum: ["admin", "user"], default: "user" } } }).name == "contact";

-- test: utilisable par object_execute
RETURN fn::validation_object_execute({ name: "A", age: 10 }, fn::validation_dsl_compile({ name: "contact", version: "v1", fields: { name: { required: true, type: "string", min_length: 2, max_length: 50 }, age: { min: 0, max: 130 }, role: { enum: ["admin", "user"], default: "user" } } }), 10).by_field == { name: ["CORE_VALIDATION_TOO_SHORT"] };

-- test: défaut appliqué
RETURN fn::validation_object_execute({ name: "Al" }, fn::validation_dsl_compile({ name: "contact", version: "v1", fields: { name: { required: true, type: "string", min_length: 2, max_length: 50 }, age: { min: 0, max: 130 }, role: { enum: ["admin", "user"], default: "user" } } }), 10).value.role == "user";

-- test: clé de normalisation refusée
-- attendu-erreur: CORE_UNSUPPORTED_OPTION
RETURN fn::validation_dsl_compile({ name: "c", version: "v1", fields: { a: { trim: true } } });

-- test: nom de champ invalide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_dsl_compile({ name: "c", version: "v1", fields: { "1a": {} } });

-- test: version absente
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_dsl_compile({ name: "c", fields: { a: {} } });
