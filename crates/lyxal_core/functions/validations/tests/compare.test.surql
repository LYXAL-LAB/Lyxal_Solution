-- lyxal-test: assertions
-- Tests de fn::validation_compare (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: supérieur vérifié
RETURN fn::validation_compare(5, 3, "gt")
    == { valid: true, value: { left: 5, right: 3, operator: "gt" }, code: NONE, details: {} };

-- test: opérateur insensible à la casse
RETURN fn::validation_compare(3, 3, " LTE ")
    == { valid: true, value: { left: 3, right: 3, operator: "lte" }, code: NONE, details: {} };

-- test: dates comparées
RETURN fn::validation_compare(d"2026-02-01T00:00:00Z", d"2026-01-01T00:00:00Z", "gte").valid;

-- test: comparaison fausse
RETURN fn::validation_compare(1, 2, "eq")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_COMPARISON", details: { operator: "eq" } };

-- test: différence vérifiée
RETURN fn::validation_compare("a", "b", "neq").valid;

-- test: valeur absente
RETURN fn::validation_compare(NONE, 2, "lt")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: opérateur inconnu
-- attendu-erreur: CORE_UNSUPPORTED_OPTION
RETURN fn::validation_compare(1, 2, "between");
