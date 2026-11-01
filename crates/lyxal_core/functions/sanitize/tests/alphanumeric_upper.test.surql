-- lyxal-test: assertions
-- Tests de fn::sanitize_alphanumeric_upper (format : crates/lyxal_core/implementation_plan.md §5).

-- test: IBAN avec espaces
RETURN fn::sanitize_alphanumeric_upper(" fr76 3000 6000 0112 3456 7890 189 ") == "FR7630006000011234567890189";

-- test: BIC
RETURN fn::sanitize_alphanumeric_upper("bnpa-fr-pp") == "BNPAFRPP";

-- test: entrée absente → NONE
RETURN fn::sanitize_alphanumeric_upper(NONE) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_alphanumeric_upper(NULL);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_alphanumeric_upper(42);
