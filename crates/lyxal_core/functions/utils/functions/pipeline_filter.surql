-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_pipeline_filter
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_pipeline_filter(
    $pipeline: array<object>,
    $key: string,
    $expected: any
) -> array<object> {
    RETURN array::filter(
        $pipeline,
        |$step|$step[$key]=$expected
    );
}
COMMENT "Filtre les étapes d'un pipeline selon une propriété."
PERMISSIONS FULL;
