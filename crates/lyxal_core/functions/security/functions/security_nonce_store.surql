-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_nonce_store
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_nonce_store(
    $nonce: string,
    $subject: string,
    $issued_at: datetime,
    $ttl: duration
) -> object {
    IF string::len(string::trim($nonce)) < 16 {
        THROW "SECURITY_NONCE_TOO_SHORT";
    };

    IF $ttl <= 0s {
        THROW "SECURITY_INVALID_NONCE_TTL";
    };

    RETURN {
        nonce_hash:crypto::sha256(string::trim($nonce)),
        subject:string::trim($subject),
        issued_at:$issued_at,
        expires_at:$issued_at+$ttl,
        consumed:false
    };
}
COMMENT "Construit une entrée de stockage de nonce sans conserver le nonce brut."
PERMISSIONS FULL;
