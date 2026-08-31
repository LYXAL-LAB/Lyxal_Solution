-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_hmac_response
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_hmac_response(
    $status: int,
    $timestamp: datetime,
    $nonce: string,
    $payload: any,
    $content_type: string
) -> object {
    LET $canonical = array::join([
        <string>$status,
        fn::security_hmac_timestamp($timestamp),
        string::trim($nonce),
        fn::security_hmac_payload($payload,$content_type)
    ], "\n");

    RETURN {
        algorithm: "hmac-sha256",
        canonical: $canonical,
        timestamp: $timestamp,
        nonce: string::trim($nonce)
    };
}
COMMENT "Construit la représentation canonique d'une réponse HMAC."
PERMISSIONS FULL;
