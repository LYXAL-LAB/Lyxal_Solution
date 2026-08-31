-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- Version 1.0.0 — PERMISSIONS FULL
-- ============================================================================
RETURN fn::validation_semantic_version("3.0.0", "VERSION", false);
RETURN fn::validation_semantic_version("3.0.0-beta.1", "VERSION", false);
RETURN fn::validation_semantic_version("v3.0.0", "VERSION", true);
-- VERSION_INVALID_SEMANTIC_VERSION
RETURN fn::validation_semantic_version("v3.0.0", "VERSION", false);
