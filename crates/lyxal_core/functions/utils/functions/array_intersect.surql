-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_array_intersect
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_array_intersect(
    $left: array<any>,
    $right: array<any>
) -> array<any> {
    RETURN array::distinct(
        array::filter(
            $left,
            |$item| array::contains($right,$item)
        )
    );
}
COMMENT "Retourne l'intersection de deux tableaux."
PERMISSIONS FULL;
