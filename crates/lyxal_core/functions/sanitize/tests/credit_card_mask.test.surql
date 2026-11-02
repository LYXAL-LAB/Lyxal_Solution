-- lyxal-test: assertions
-- Tests de fn::sanitize_credit_card_mask (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: quatre chiffres visibles
RETURN fn::sanitize_credit_card_mask("4111 1111 1111 1111", 4) == "************1111";

-- test: numéro court
RETURN fn::sanitize_credit_card_mask("12", 4) == "12";

-- test: tout masqué
RETURN fn::sanitize_credit_card_mask("1234", 0) == "****";

-- test: nombre négatif
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::sanitize_credit_card_mask("1", -1);

-- test: entrée absente → NONE
RETURN fn::sanitize_credit_card_mask(NONE, 4) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_credit_card_mask(NULL, 4);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_credit_card_mask(42, 4);
