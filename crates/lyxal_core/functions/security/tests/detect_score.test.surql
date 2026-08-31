-- ============================================================================
-- TESTS — fn::security_detect_score
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_detect_score(
    [{score:20},{score:30},{score:70}]
);
