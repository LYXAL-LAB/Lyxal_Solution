-- ============================================================================
-- TESTS — fn::security_encrypt_object
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_encrypt_object(
    {name:"Lyxal",secret:true},
    "vault://keys/data",
    "xchacha20-poly1305",
    "tenant:acme"
);
