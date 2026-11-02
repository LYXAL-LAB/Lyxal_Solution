-- lyxal-test: assertions
-- Tests de fn::security_step_catalog (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: 22 règles
RETURN array::len(fn::security_step_catalog()) == 22;

-- test: règles uniques
RETURN array::len(array::distinct(fn::security_step_catalog().map(|$e| $e.rule))) == 22;

-- test: aucune règle déclarée idempotente (enregistrements cumulés)
RETURN !array::any(fn::security_step_catalog(), |$e| $e.idempotent = true);

-- test: aucune règle du moteur masquée
RETURN array::len(fn::utils_engine_pipeline([], fn::security_step_catalog(), 1)) == 0;

-- test: options obligatoires de permission_check
RETURN array::find(fn::security_step_catalog(), |$e| $e.rule = "permission_check").required == ["permissions", "resource", "action"];
