-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/runtime_elapsed.surql
-- Fonction : fn::utils_runtime_elapsed
--
-- Retourne la durée écoulée dans plusieurs unités.
--
-- Paramètres
--   $started_at : datetime
--   $now        : datetime
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions utils)
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $now < $started_at
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_runtime_elapsed(
    $started_at: datetime,
    $now: datetime
) -> object {
    IF $now < $started_at {
        THROW "CORE_INVALID_ARGUMENT";
    };

    LET $duration = $now-$started_at;

    RETURN {
        duration:$duration,
        seconds:duration::secs($duration),
        milliseconds:duration::millis($duration),
        microseconds:duration::micros($duration)
    };
}
COMMENT "Retourne la durée écoulée dans plusieurs unités."
PERMISSIONS FULL;
