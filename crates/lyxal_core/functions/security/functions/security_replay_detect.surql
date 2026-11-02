-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/security/functions/security_replay_detect.surql
-- Fonction : fn::security_replay_detect
--
-- Détecte la réutilisation d'un nonce ou un timestamp hors fenêtre.
--
-- Paramètres
--   $nonce_entries : array<object>
--   $nonce         : string
--   $subject       : string
--   $timestamp     : datetime
--   $now           : datetime
--   $window        : duration
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions security)
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
