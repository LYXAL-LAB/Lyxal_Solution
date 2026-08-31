-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_hmac_signature_header
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_hmac_signature_header(
    $algorithm: string,
    $key_id: string,
    $timestamp: datetime,
    $nonce: string,
    $signature: string
) -> string {
    RETURN string::concat(
        "algorithm=", string::lowercase(string::trim($algorithm)),
        ",keyid=", string::trim($key_id),
        ",timestamp=", fn::security_hmac_timestamp($timestamp),
        ",nonce=", string::trim($nonce),
        ",signature=", string::trim($signature)
    );
}
COMMENT "Construit un en-tête de signature HMAC normalisé."
PERMISSIONS FULL;
