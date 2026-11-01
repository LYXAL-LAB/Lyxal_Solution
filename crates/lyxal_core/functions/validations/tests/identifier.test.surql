-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- Version 1.0.0 — PERMISSIONS FULL
-- ============================================================================
-- TEST 1 — valide
RETURN fn::validation_identifier("booking_team", "IDENTIFIER", 1, 100);
-- TEST 2 — chiffre initial interdit / IDENTIFIER_INVALID_IDENTIFIER
RETURN fn::validation_identifier("2booking", "IDENTIFIER", 1, 100);
-- TEST 3 — tiret interdit / IDENTIFIER_INVALID_IDENTIFIER
RETURN fn::validation_identifier("booking-team", "IDENTIFIER", 1, 100);
-- TEST 4 — limites invalides / VALIDATION_INVALID_IDENTIFIER_LENGTH
RETURN fn::validation_identifier("booking", "IDENTIFIER", 10, 2);
