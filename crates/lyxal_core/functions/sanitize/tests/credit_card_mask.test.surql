-- ============================================================================
-- TESTS — fn::sanitize_credit_card_mask
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_credit_card_mask("4111 1111 1111 1111","CARD",4);
