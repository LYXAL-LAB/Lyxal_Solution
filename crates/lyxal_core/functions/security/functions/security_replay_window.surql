-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_replay_window
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_replay_window(
    $timestamp: datetime,
    $now: datetime,
    $window: duration
) -> object {
    IF $window <= 0s {
        THROW "SECURITY_INVALID_REPLAY_WINDOW";
    };

    LET $earliest = $now-$window;
    LET $latest = $now+$window;

    RETURN {
        timestamp:$timestamp,
        earliest:$earliest,
        latest:$latest,
        valid:$timestamp >= $earliest AND $timestamp <= $latest
    };
}
COMMENT "Vérifie qu'un timestamp appartient à une fenêtre anti-rejeu."
PERMISSIONS FULL;
