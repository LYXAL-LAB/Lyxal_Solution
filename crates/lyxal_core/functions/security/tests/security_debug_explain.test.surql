-- ============================================================================
-- TESTS — fn::security_debug_explain
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_debug_explain({
    field:"payload",
    rule:"detect_payload",
    changed:false,
    finding:{detected:true},
    decision:NONE
});
