-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_number_scale
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_number_scale(
    $value: number,
    $source_min: number,
    $source_max: number,
    $target_min: number,
    $target_max: number
) -> number {
    IF $source_min = $source_max {
        THROW "UTILS_INVALID_SCALE_SOURCE_RANGE";
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
