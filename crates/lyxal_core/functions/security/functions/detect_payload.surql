-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/security/functions/detect_payload.surql
-- Fonction : fn::security_detect_payload
--
-- Exécute les détecteurs textuels principaux sur un payload.
--
-- Paramètres
--   $value : string
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions security)
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
