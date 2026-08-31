-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_nonce_verify
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_nonce_verify(
    $entry: object,
    $nonce: string,
    $subject: string,
    $now: datetime
) -> object {
    LET $matches = $entry.nonce_hash
        = crypto::sha256(string::trim($nonce));

    LET $subject_matches = $entry.subject
        = string::trim($subject);

    LET $expired = $entry.expires_at <= $now;
    LET $reused = $entry.consumed = true;

    RETURN {
        valid:$matches
            AND $subject_matches
            AND !$expired
            AND !$reused,
        matches:$matches,
        subject_matches:$subject_matches,
        expired:$expired,
        reused:$reused
    };
}
COMMENT "Vérifie un nonce stocké, son sujet, son expiration et son usage."
PERMISSIONS FULL;
