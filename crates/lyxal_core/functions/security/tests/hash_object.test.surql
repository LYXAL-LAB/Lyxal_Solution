-- ============================================================================
-- TESTS — fn::security_hash_object
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_hash_object(
    {name:"Lyxal",version:1},
    "sha256"
);
