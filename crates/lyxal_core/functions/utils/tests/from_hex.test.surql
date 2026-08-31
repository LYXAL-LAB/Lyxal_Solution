-- ============================================================================
-- TESTS — fn::utils_from_hex
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::utils_from_hex(
    encoding::hex::encode(<bytes>"Lyxal")
);
