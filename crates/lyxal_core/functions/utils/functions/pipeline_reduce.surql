-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_pipeline_reduce
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_pipeline_reduce(
    $pipeline: array<object>,
    $numeric_key: string,
    $initial: number
) -> number {
    RETURN array::fold(
        $pipeline,
        $initial,
        |$total,$step|
            $total
            + IF type::is_number($step[$numeric_key]) {
                $step[$numeric_key]
            } ELSE {
                0
            }
    );
}
COMMENT "Réduit les valeurs numériques d'une propriété de pipeline."
PERMISSIONS FULL;
