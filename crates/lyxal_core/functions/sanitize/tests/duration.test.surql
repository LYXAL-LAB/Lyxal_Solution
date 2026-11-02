-- lyxal-test: assertions
-- Tests de fn::sanitize_duration (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: à la seconde
RETURN fn::sanitize_duration(1m30s500ms, 1s) == 1m30s;

-- test: précision nulle
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::sanitize_duration(1s, 0ns);

-- test: entrée absente → NONE
RETURN fn::sanitize_duration(NONE, 1s) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_duration(NULL, 1s);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_duration("1s", 1s);
