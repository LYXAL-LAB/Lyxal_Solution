-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_runtime_request_id
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_runtime_request_id(
    $service: string
) -> string {
    LET $clean = string::lowercase(string::trim($service));

    RETURN string::concat(
        IF $clean = "" { "request" } ELSE { $clean },
        "_",
        <string>rand::uuid::v7()
    );
}
COMMENT "Génère un identifiant de requête."
PERMISSIONS FULL;
