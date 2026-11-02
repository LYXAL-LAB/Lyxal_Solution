-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/engine_benchmark_run.surql
-- Fonction : fn::utils_engine_benchmark_run
--
-- Regroupe des échantillons en une campagne de mesure { name, samples,
-- sample_count, started_at, completed_at, wall_duration }.
--
-- Paramètres
--   $name         : string
--   $samples      : array<object>
--   $started_at   : datetime
--   $completed_at : datetime
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions utils)
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : nom vide ou $completed_at antérieur à $started_at
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_engine_benchmark_run(
    $name: string,
    $samples: array<object>,
    $started_at: datetime,
    $completed_at: datetime
) -> object {
    IF string::trim($name) = "" OR $completed_at < $started_at { THROW "CORE_INVALID_ARGUMENT"; };
    RETURN {
        name: string::lowercase(string::trim($name)),
        samples: $samples,
        sample_count: array::len($samples),
        started_at: $started_at,
        completed_at: $completed_at,
        wall_duration: $completed_at - $started_at
    };
}
COMMENT "Regroupe des échantillons en une campagne de mesure { name, samples, sample_count, started_at, completed_at, wall_duration }."
PERMISSIONS FULL;
