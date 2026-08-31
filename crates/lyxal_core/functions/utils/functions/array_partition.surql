-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_array_partition
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_array_partition(
    $value: array<object>,
    $key: string,
    $expected: any
) -> object {
    RETURN {
        matched: array::filter(
            $value,
            |$item| $item[$key] = $expected
        ),
        unmatched: array::filter(
            $value,
            |$item| $item[$key] != $expected
        )
    };
}
COMMENT "Sépare un tableau d'objets selon une valeur de clé."
PERMISSIONS FULL;
