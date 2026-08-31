-- ============================================================================
-- TESTS — fn::security_detect_file_attack
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_detect_file_attack(
    "photo.jpg.exe",
    "image/jpeg"
);
