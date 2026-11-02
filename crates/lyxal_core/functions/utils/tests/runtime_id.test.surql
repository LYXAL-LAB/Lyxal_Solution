-- lyxal-test: assertions
-- Tests de fn::utils_runtime_id (format : crates/lyxal_core/implementation_plan.md §5).

-- test: préfixe et longueur
RETURN string::len(fn::utils_runtime_id(" Job ", 16)) == 20 AND string::starts_with(fn::utils_runtime_id("Job", 16), "job_");

-- test: sans préfixe
RETURN string::len(fn::utils_runtime_id("", 8)) == 8;

-- test: trop court
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::utils_runtime_id("x", 7);
