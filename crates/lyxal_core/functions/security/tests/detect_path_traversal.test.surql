-- ============================================================================
-- TESTS — fn::security_detect_path_traversal
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_detect_path_traversal(
    "../../etc/passwd"
);
