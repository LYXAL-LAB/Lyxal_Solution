-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_signature_verify
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_signature_verify(
    $canonical: string,
    $signature: string,
    $public_key_reference: string,
    $algorithm: string
) -> object {
    LET $algo = string::lowercase(string::trim($algorithm));
    LET $sig = string::trim($signature);
    LET $pub = string::trim($public_key_reference);
    IF $canonical IS NONE OR $sig = "" OR $pub = "" OR $algo = "" {
        THROW "SECURITY_UNSUPPORTED_SIGNATURE_ALGORITHM";
    };

    THROW "SECURITY_UNSUPPORTED_SIGNATURE_ALGORITHM";
}
COMMENT "Vérification asymétrique désactivée tant qu'elle n'est pas validée dans lyxal_crypto STABLE."
PERMISSIONS FULL;
