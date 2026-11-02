-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/number_scale.surql
-- Fonction : fn::utils_number_scale
--
-- Convertit une valeur d'une échelle vers une autre.
--
-- Paramètres
--   $value      : number
--   $source_min : number
--   $source_max : number
--   $target_min : number
--   $target_max : number
--
-- Valeur renvoyée : number (contrat : crates/lyxal_core/Readme.md, fonctions utils)
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $source_min = $source_max
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_number_scale(
    $value: number,
    $source_min: number,
    $source_max: number,
    $target_min: number,
    $target_max: number
) -> number {
    IF $source_min = $source_max {
        THROW "CORE_INVALID_ARGUMENT";
    };

    RETURN $target_min
        + (
            ($value-$source_min)
            * ($target_max-$target_min)
            / ($source_max-$source_min)
        );
}
COMMENT "Convertit une valeur d'une échelle vers une autre."
PERMISSIONS FULL;
