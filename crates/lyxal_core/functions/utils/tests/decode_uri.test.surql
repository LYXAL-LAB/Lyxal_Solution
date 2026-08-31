-- ============================================================================
-- TESTS — fn::utils_decode_uri
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::utils_decode_uri(
    fn::utils_encode_uri("Lyxal OS / Core")
);
