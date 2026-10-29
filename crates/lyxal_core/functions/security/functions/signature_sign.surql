-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_signature_sign
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_signature_sign(
    $canonical: string,
    $key_reference: string,
    $algorithm: string
) -> object {
    LET $algo = string::lowercase(string::trim($algorithm));
    LET $ref = string::trim($key_reference);
    IF $canonical IS NONE OR $ref = "" OR $algo = "" {
        THROW "SECURITY_UNSUPPORTED_SIGNATURE_ALGORITHM";
    };

    THROW "SECURITY_UNSUPPORTED_SIGNATURE_ALGORITHM";
}
COMMENT "Signature asymétrique désactivée tant qu'elle n'est pas validée dans lyxal_crypto STABLE."
PERMISSIONS FULL;
