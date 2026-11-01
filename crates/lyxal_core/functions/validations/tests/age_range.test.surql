-- lyxal-test: assertions
-- Tests de fn::validation_age_range (format : crates/lyxal_core/implementation_plan.md §5).

-- test: majeur
RETURN fn::validation_age_range(d"1990-01-01T00:00:00Z", 18, NONE).valid;

-- test: âge révolu renvoyé
RETURN fn::validation_age_range(d"1990-01-01T00:00:00Z", NONE, NONE).value.age
    == <int> time::format(time::now(), "%Y") - 1990;

-- test: né aujourd'hui : âge 0
RETURN fn::validation_age_range(time::floor(time::now(), 1d), NONE, NONE)
    == { valid: true, value: { birthdate: time::floor(time::now(), 1d), age: 0 }, code: NONE, details: {} };

-- test: trop jeune
RETURN fn::validation_age_range(time::floor(time::now(), 1d), 18, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SMALL", details: { min_age: 18, age: 0 } };

-- test: trop âgé
RETURN fn::validation_age_range(d"1900-01-01T00:00:00Z", NONE, 100).code == "CORE_VALIDATION_TOO_LARGE";

-- test: naissance future
RETURN fn::validation_age_range(d"2999-01-01T00:00:00Z", NONE, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LARGE", details: { max: time::floor(time::now(), 1d) } };

-- test: date avec heure
RETURN fn::validation_age_range(d"1990-01-01T10:00:00Z", NONE, NONE).code == "CORE_VALIDATION_FORMAT";

-- test: valeur absente
RETURN fn::validation_age_range(NONE, NONE, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_age_range(NULL, NONE, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_age_range(1990, NONE, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "datetime", actual: "int" } };

-- test: âge négatif
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_age_range(d"1990-01-01T00:00:00Z", -1, NONE);

-- test: âges inversés
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_age_range(d"1990-01-01T00:00:00Z", 30, 18);
