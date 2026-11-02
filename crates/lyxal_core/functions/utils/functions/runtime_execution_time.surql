-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/runtime_execution_time.surql
-- Fonction : fn::utils_runtime_execution_time
--
-- Calcule la durée totale d'une exécution.
--
-- Paramètres
--   $started_at   : datetime
--   $completed_at : datetime
--
-- Valeur renvoyée : duration (contrat : crates/lyxal_core/Readme.md, fonctions utils)
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $completed_at < $started_at
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_runtime_execution_time(
    $started_at: datetime,
    $completed_at: datetime
) -> duration {
    IF $completed_at < $started_at {
        THROW "CORE_INVALID_ARGUMENT";
    };

    RETURN $completed_at-$started_at;
}
COMMENT "Calcule la durée totale d'une exécution."
PERMISSIONS FULL;
