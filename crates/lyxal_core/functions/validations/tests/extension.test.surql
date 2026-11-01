-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- Version 1.0.0 — PERMISSIONS FULL
-- ============================================================================
RETURN fn::validation_extension(".PDF", "EXTENSION", NONE, true);
RETURN fn::validation_extension("PDF", "EXTENSION", NONE, false);
-- EXTENSION_EXTENSION_NOT_ALLOWED
RETURN fn::validation_extension(".exe", "EXTENSION", [".pdf"], true);
-- EXTENSION_INVALID_EXTENSION
RETURN fn::validation_extension("pdf", "EXTENSION", NONE, true);
