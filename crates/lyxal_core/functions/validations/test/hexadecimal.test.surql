-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- Version 1.0.0 — PERMISSIONS FULL
-- ============================================================================
RETURN fn::validation_hexadecimal("AABBCC", "HEX", NONE, NONE, false);
RETURN fn::validation_hexadecimal("0xAABBCC", "HEX", 6, 6, true);
-- HEX_INVALID_HEXADECIMAL
RETURN fn::validation_hexadecimal("AABBGG", "HEX", NONE, NONE, false);
-- HEX_TOO_SHORT
RETURN fn::validation_hexadecimal("AABB", "HEX", 6, NONE, false);
