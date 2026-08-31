-- ============================================================================
-- TESTS — fn::utils_base64_to_bytes
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::utils_base64_to_bytes(
    encoding::base64::encode(<bytes>"Lyxal")
);
