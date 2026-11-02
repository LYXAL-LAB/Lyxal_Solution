-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/compare_dates.surql
-- Fonction : fn::utils_compare_dates
--
-- Compare deux dates.
--
-- Paramètres
--   $left  : datetime
--   $right : datetime
--
-- Valeur renvoyée : int (contrat : crates/lyxal_core/Readme.md, fonctions utils)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_compare_dates(
    $left: datetime,
    $right: datetime
) -> int {
    RETURN IF $left = $right {
        0
    } ELSE IF $left < $right {
        -1
    } ELSE {
        1
    };
}
COMMENT "Compare deux dates."
PERMISSIONS FULL;
