-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_runtime_stats
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_runtime_stats(
    $responses: array<object>
) -> object {
    RETURN {
        total:array::len($responses),
        changed:array::len(array::filter($responses, |$response| $response.changed = true)),
        unchanged:array::len(array::filter($responses, |$response| $response.changed = false))
    };
}
COMMENT "Calcule des statistiques sur des réponses runtime."
PERMISSIONS FULL;
