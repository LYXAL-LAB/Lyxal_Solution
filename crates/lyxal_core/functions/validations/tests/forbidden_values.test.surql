-- lyxal-test: assertions
-- Tests de fn::validation_forbidden_values (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: valeur permise
RETURN fn::validation_forbidden_values(" equipe ", ["admin", "root"], false, true)
    == { valid: true, value: "equipe", code: NONE, details: {} };

-- test: valeur interdite, casse ignorée
RETURN fn::validation_forbidden_values("ADMIN", ["admin"], false, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORBIDDEN", details: {} };

-- test: casse distinguée
RETURN fn::validation_forbidden_values("ADMIN", ["admin"], true, true)
    == { valid: true, value: "ADMIN", code: NONE, details: {} };

-- test: fragment non interdit
RETURN fn::validation_forbidden_values("administrateur", ["admin"], false, true)
    == { valid: true, value: "administrateur", code: NONE, details: {} };

-- test: valeur absente
RETURN fn::validation_forbidden_values(NONE, ["a"], true, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_forbidden_values(NULL, ["a"], true, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_forbidden_values(1, ["a"], true, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: liste vide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_forbidden_values("abc", [], true, true);

-- test: valeur vide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_forbidden_values("abc", [""], true, true);
