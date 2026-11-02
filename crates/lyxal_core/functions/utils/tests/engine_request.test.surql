-- lyxal-test: assertions
-- Tests de fn::utils_engine_request (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: requête
RETURN fn::utils_engine_request(" Validate ", { a: 1 }, NONE).operation == "validate" AND fn::utils_engine_request("v", 1, NONE).context == {};

-- test: identifiant UUID
RETURN type::is_uuid(fn::utils_engine_request("v", 1, NONE).request_id);

-- test: opération vide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::utils_engine_request(" ", 1, NONE);
