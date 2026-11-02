-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/security/functions/hmac_response.surql
-- Fonction : fn::security_hmac_response
--
-- Construit la représentation canonique d'une réponse HMAC.
--
-- Paramètres
--   $status       : int
--   $timestamp    : datetime
--   $nonce        : string
--   $payload      : any
--   $content_type : string
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions security)
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
