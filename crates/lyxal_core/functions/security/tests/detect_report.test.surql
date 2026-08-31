-- ============================================================================
-- TESTS — fn::security_detect_report
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_detect_report(
    "payload",
    [
        {detected:true,category:"xss",score:60},
        {detected:false,category:"sql_injection",score:0}
    ]
);
