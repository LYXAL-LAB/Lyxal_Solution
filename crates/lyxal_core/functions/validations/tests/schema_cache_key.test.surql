-- ============================================================================
-- TESTS — fn::validation_schema_cache_key
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

-- TEST 1 — Clé valide
RETURN fn::validation_schema_cache_key(
    "user::profile",
    "v1",
    "aabbccddeeff0011"
);

-- TEST 2 — Version invalide
-- Erreur attendue : VALIDATION_INVALID_SCHEMA_CACHE_VERSION
RETURN fn::validation_schema_cache_key(
    "user",
    "1",
    "aabbccddeeff0011"
);
