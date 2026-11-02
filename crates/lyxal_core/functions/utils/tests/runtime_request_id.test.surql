-- lyxal-test: assertions
-- Tests de fn::utils_runtime_request_id (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: service et UUID
RETURN string::starts_with(fn::utils_runtime_request_id(" API "), "api_") AND string::len(fn::utils_runtime_request_id("api")) == 40;

-- test: service par défaut
RETURN string::starts_with(fn::utils_runtime_request_id(""), "request_");
