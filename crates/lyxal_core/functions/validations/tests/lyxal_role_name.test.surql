-- lyxal-test: assertions
-- Tests de fn::validation_lyxal_role_name (format : crates/lyxal_core/implementation_plan.md §5).

-- test: valeur conforme
RETURN fn::validation_lyxal_role_name(" Team_Admin ", ["owner"], 2, 32)
    == { valid: true, value: "team_admin", code: NONE, details: {} };

-- test: rôle réservé
RETURN fn::validation_lyxal_role_name("Owner", ["owner"], 2, 32)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORBIDDEN", details: {} };

-- test: souligné final
RETURN fn::validation_lyxal_role_name("admin_", ["owner"], 2, 32)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "lyxal_role_name" } };

-- test: chaîne blanche
RETURN fn::validation_lyxal_role_name("  ", ["owner"], 2, 32)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_lyxal_role_name(NONE, ["owner"], 2, 32)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_lyxal_role_name(NULL, ["owner"], 2, 32)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_lyxal_role_name(42, ["owner"], 2, 32)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: bornes inversées
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_lyxal_role_name("ab", NONE, 5, 2);
