-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- Version 1.0.0 — PERMISSIONS FULL
-- ============================================================================
RETURN fn::validation_http_url("https://lyxal.com", "URL", false, true);
RETURN fn::validation_http_url("http://localhost:8000/api", "URL", true, false);
-- URL_INVALID_HTTP_SCHEME
RETURN fn::validation_http_url("http://lyxal.com", "URL", false, true);
-- URL_INVALID_HTTP_SCHEME
RETURN fn::validation_http_url("ftp://lyxal.com", "URL", true, true);
