-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/security/functions/security_replay_window.surql
-- Fonction : fn::security_replay_window
--
-- Vérifie qu'un timestamp appartient à une fenêtre anti-rejeu.
--
-- Paramètres
--   $timestamp : datetime
--   $now       : datetime
--   $window    : duration
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions security)
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $window <= 0s
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::security_replay_window(
    $timestamp: datetime,
    $now: datetime,
    $window: duration
) -> object {
    IF $window <= 0s {
        THROW "CORE_INVALID_ARGUMENT";
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
