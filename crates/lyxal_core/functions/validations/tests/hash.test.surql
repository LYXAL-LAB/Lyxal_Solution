-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- Version 1.0.0 — PERMISSIONS FULL
-- ============================================================================
RETURN fn::validation_hash("E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855", "HASH", "sha256");
RETURN fn::validation_hash("d41d8cd98f00b204e9800998ecf8427e", "HASH", "md5");
-- HASH_INVALID_HASH_LENGTH
RETURN fn::validation_hash("AABBCC", "HASH", "sha256");
-- VALIDATION_UNSUPPORTED_HASH_ALGORITHM
RETURN fn::validation_hash("AABB", "HASH", "blake3");
