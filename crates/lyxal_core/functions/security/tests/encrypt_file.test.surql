-- ============================================================================
-- TESTS — fn::security_encrypt_file
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_encrypt_file(
    "bunny://input/report.pdf",
    "vault://keys/files",
    "xchacha20-poly1305",
    "bunny://encrypted/report.pdf.enc"
);
