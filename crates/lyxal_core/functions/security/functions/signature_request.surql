-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_signature_request
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_signature_request(
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
        fn::security_signature_timestamp($timestamp),
        string::trim($nonce),
        fn::security_signature_headers($headers,$included_headers),
        fn::security_signature_payload($payload,$content_type)
    ], "\n");

    RETURN {
        canonical: $canonical,
        timestamp: $timestamp,
        nonce: string::trim($nonce),
        included_headers: $included_headers
    };
}
COMMENT "Construit la représentation canonique d'une requête signée."
PERMISSIONS FULL;
