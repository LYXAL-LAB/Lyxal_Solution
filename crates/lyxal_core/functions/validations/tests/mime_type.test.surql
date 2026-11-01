-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- Version 1.0.0 — PERMISSIONS FULL
-- ============================================================================
RETURN fn::validation_mime_type("application/pdf", "MIME_TYPE", NONE);
RETURN fn::validation_mime_type("IMAGE/JPEG", "MIME_TYPE", NONE);
-- MIME_TYPE_MIME_TYPE_NOT_ALLOWED
RETURN fn::validation_mime_type("application/x-msdownload", "MIME_TYPE", ["application/pdf"]);
-- MIME_TYPE_INVALID_MIME_TYPE
RETURN fn::validation_mime_type("application", "MIME_TYPE", NONE);
