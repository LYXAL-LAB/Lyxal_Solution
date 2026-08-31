-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_pipeline_map
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_pipeline_map(
    $pipeline: array<object>,
    $key: string
) -> array<any> {
    RETURN array::map(
        $pipeline,
        |$step|$step[$key]
    );
}
COMMENT "Extrait une propriété de chaque étape d'un pipeline."
PERMISSIONS FULL;
