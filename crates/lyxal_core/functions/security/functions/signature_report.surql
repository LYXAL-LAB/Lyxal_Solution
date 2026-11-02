-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/security/functions/signature_report.surql
-- Fonction : fn::security_signature_report
--
-- Construit un rapport de signature ou vérification.
--
-- Paramètres
--   $algorithm : string
--   $key_id    : string
--   $timestamp : datetime
--   $nonce     : string
--   $verified  : option<bool>
--   $reason    : option<string>
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions security)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::security_signature_report(
    $algorithm: string,
    $key_id: string,
    $timestamp: datetime,
    $nonce: string,
    $verified: option<bool>,
    $reason: option<string>
) -> object {
    RETURN {
        algorithm: string::lowercase(string::trim($algorithm)),
        key_id: string::trim($key_id),
        timestamp: $timestamp,
        nonce: string::trim($nonce),
        verified: $verified,
        reason: IF $reason IS NONE { NONE } ELSE { string::trim($reason) }
    };
}
COMMENT "Construit un rapport de signature ou vérification."
PERMISSIONS FULL;
