-- lyxal-test: assertions
-- Tests de fn::utils_runtime_environment (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: normalisé
RETURN fn::utils_runtime_environment(" Production ", false, NONE) == { name: "production", debug: false, metadata: {} };

-- test: environnement inconnu
-- attendu-erreur: CORE_UNSUPPORTED_OPTION
RETURN fn::utils_runtime_environment("qa", false, NONE);
