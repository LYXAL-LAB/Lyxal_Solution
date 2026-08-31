-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_hmac_request
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_hmac_request(
    $method: string,
    $path: string,
    $timestamp: datetime,
    $nonce: string,
    $headers: object,
    $included_headers: array<string>,
    $payload: any,
    $content_type: string
) -> object {
    LET $canonical = array::join([
        string::uppercase(string::trim($method)),
        string::trim($path),
        fn::security_hmac_timestamp($timestamp),
        string::trim($nonce),
        fn::security_hmac_headers($headers,$included_headers),
        fn::security_hmac_payload($payload,$content_type)
    ], "\n");

    RETURN {
        algorithm: "hmac-sha256",
        canonical: $canonical,
        timestamp: $timestamp,
        nonce: string::trim($nonce)
    };
}
COMMENT "Construit la représentation canonique d'une requête HMAC."
PERMISSIONS FULL;
