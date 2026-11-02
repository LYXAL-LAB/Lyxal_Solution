-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/security/functions/hmac_signature_header.surql
-- Fonction : fn::security_hmac_signature_header
--
-- Construit un en-tête de signature HMAC normalisé.
--
-- Paramètres
--   $algorithm : string
--   $key_id    : string
--   $timestamp : datetime
--   $nonce     : string
--   $signature : string
--
-- Valeur renvoyée : string (contrat : crates/lyxal_core/Readme.md, fonctions security)
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
