-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- Version 1.0.0 — PERMISSIONS FULL
-- ============================================================================
RETURN fn::validation_base64("SGVsbG8=", "BASE64", false, true);
RETURN fn::validation_base64("SGVsbG8", "BASE64", false, false);
RETURN fn::validation_base64("SGVsbG8td29ybGQ_", "BASE64", true, false);
-- BASE64_INVALID_BASE64
RETURN fn::validation_base64("SGVsbG8*", "BASE64", false, false);
-- BASE64_INVALID_BASE64_PADDING
RETURN fn::validation_base64("SGVsbG8", "BASE64", false, true);
