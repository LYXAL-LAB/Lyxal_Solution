-- lyxal-test: assertions
-- Tests de fn::validation_ends_with (format : crates/lyxal_core/implementation_plan.md §5).

-- test: suffixe présent
RETURN fn::validation_ends_with(" devis.pdf ", [".pdf"], true, true)
    == { valid: true, value: "devis.pdf", code: NONE, details: {} };

-- test: insensible à la casse
RETURN fn::validation_ends_with("DEVIS.PDF", [".pdf"], false, true)
    == { valid: true, value: "DEVIS.PDF", code: NONE, details: {} };

-- test: suffixe absent
RETURN fn::validation_ends_with("devis.doc", [".pdf"], true, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { ends_with_any: [".pdf"] } };

-- test: valeur absente
RETURN fn::validation_ends_with(NONE, ["a"], true, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_ends_with(NULL, ["a"], true, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_ends_with(1, ["a"], true, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: liste vide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_ends_with("abc", [], true, true);

-- test: suffixe vide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_ends_with("abc", ["  "], true, true);
