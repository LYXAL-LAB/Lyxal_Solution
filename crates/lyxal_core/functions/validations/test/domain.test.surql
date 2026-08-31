-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- Version 1.0.0 — PERMISSIONS FULL
-- ============================================================================
RETURN fn::validation_domain("Lyxal.COM", "DOMAIN", false);
RETURN fn::validation_domain("api.lyxal.com", "DOMAIN", true);
-- DOMAIN_SUBDOMAIN_NOT_ALLOWED
RETURN fn::validation_domain("api.lyxal.com", "DOMAIN", false);
-- DOMAIN_INVALID_DOMAIN
RETURN fn::validation_domain("https://lyxal.com", "DOMAIN", true);
