-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_replay_detect
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_replay_detect(
    $nonce_entries: array<object>,
    $nonce: string,
    $subject: string,
    $timestamp: datetime,
    $now: datetime,
    $window: duration
) -> object {
    LET $nonce_hash = crypto::sha256(string::trim($nonce));

    LET $matches = array::filter(
        $nonce_entries,
        |$entry|
            $entry.nonce_hash = $nonce_hash
            AND $entry.subject = string::trim($subject)
    );

    LET $outside_window = $timestamp < $now-$window
        OR $timestamp > $now+$window;

    RETURN {
        replay:array::len($matches)>0 OR $outside_window,
        nonce_seen:array::len($matches)>0,
        outside_window:$outside_window,
        matching_entries:$matches
    };
}
COMMENT "Détecte la réutilisation d'un nonce ou un timestamp hors fenêtre."
PERMISSIONS FULL;
