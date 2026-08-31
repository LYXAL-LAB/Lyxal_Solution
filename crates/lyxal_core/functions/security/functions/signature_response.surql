-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_signature_response
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_signature_response(
    $status: int,
    $timestamp: datetime,
    $nonce: string,
    $payload: any,
    $content_type: string
) -> object {
    RETURN {
        canonical: array::join([
            <string>$status,
            fn::security_signature_timestamp($timestamp),
            string::trim($nonce),
            fn::security_signature_payload($payload,$content_type)
        ], "\n"),
        timestamp: $timestamp,
        nonce: string::trim($nonce)
    };
}
COMMENT "Construit la représentation canonique d'une réponse signée."
PERMISSIONS FULL;
