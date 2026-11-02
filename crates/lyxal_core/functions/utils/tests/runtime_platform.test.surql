-- lyxal-test: assertions
-- Tests de fn::utils_runtime_platform (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: normalisée
RETURN fn::utils_runtime_platform(" SurrealDB ", "SurrealQL", " X86_64 ") == { engine: "surrealdb", language: "surrealql", architecture: "x86_64" };
