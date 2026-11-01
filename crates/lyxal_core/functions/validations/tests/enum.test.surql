-- lyxal-test: assertions
-- Tests de fn::validation_enum (format : crates/lyxal_core/implementation_plan.md §5).

-- test: valeur autorisée, casse ignorée
RETURN fn::validation_enum(" Admin ", ["owner", "admin"], false)
    == { valid: true, value: "admin", code: NONE, details: {} };

-- test: valeur autorisée, casse distinguée
RETURN fn::validation_enum("Admin", ["Admin"], true)
    == { valid: true, value: "Admin", code: NONE, details: {} };

-- test: casse distinguée refusée
RETURN fn::validation_enum("admin", ["Admin"], true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { allowed: ["Admin"] } };

-- test: valeur inconnue
RETURN fn::validation_enum("guest", ["Owner", "admin"], false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { allowed: ["owner", "admin"] } };

-- test: chaîne blanche
RETURN fn::validation_enum(" ", ["a"], false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_enum(NONE, ["a"], false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_enum(NULL, ["a"], false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_enum(1, ["a"], false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: liste vide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_enum("a", [], false);

-- test: valeur vide dans la liste
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_enum("a", ["a", " "], false);
