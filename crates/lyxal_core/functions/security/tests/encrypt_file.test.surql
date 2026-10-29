-- ============================================================================
-- TESTS — fn::security_encrypt_file
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_encrypt_file(
    "bunny://input/report.pdf",
    "vault://keys/files",
    "aes-256-gcm",
    "bunny://encrypted/report.pdf.enc"
);
