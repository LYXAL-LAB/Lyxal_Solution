-- ============================================================================
-- TESTS — fn::sanitize_remove_non_printable
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_remove_non_printable("Lyxal\u0000OS","VALUE");
