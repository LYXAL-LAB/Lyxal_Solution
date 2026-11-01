-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- Version 1.0.0 — PERMISSIONS FULL
-- ============================================================================
-- TEST 1 — valide
RETURN fn::validation_filename("rapport-final.pdf", "FILENAME", 1, 255);
-- TEST 2 — traversée interdite / FILENAME_INVALID_FILENAME
RETURN fn::validation_filename("../secret.txt", "FILENAME", 1, 255);
-- TEST 3 — caractère interdit / FILENAME_INVALID_FILENAME
RETURN fn::validation_filename("rapport?.pdf", "FILENAME", 1, 255);
-- TEST 4 — fin par point / FILENAME_INVALID_FILENAME_END
RETURN fn::validation_filename("rapport.", "FILENAME", 1, 255);
