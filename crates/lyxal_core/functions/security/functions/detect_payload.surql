-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_detect_payload
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_detect_payload(
    $value: string
) -> object {
    LET $results = [
        fn::security_detect_sql_injection($value),
        fn::security_detect_xss($value),
        fn::security_detect_path_traversal($value),
        fn::security_detect_command_injection($value),
        fn::security_detect_header_injection($value),
        fn::security_detect_open_redirect($value)
    ];

    RETURN {
        detected: array::any($results, |$result| $result.detected),
        results: $results,
        score: fn::security_detect_score($results)
    };
}
COMMENT "Exécute les détecteurs textuels principaux sur un payload."
PERMISSIONS FULL;
