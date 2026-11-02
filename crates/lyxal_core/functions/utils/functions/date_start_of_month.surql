-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/date_start_of_month.surql
-- Fonction : fn::utils_date_start_of_month
--
-- Retourne le début du mois UTC.
--
-- Paramètres
--   $value : datetime
--
-- Valeur renvoyée : datetime (contrat : crates/lyxal_core/Readme.md, fonctions utils)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_date_start_of_month(
    $value: datetime
) -> datetime {
    RETURN time::group($value,"month");
}
COMMENT "Retourne le début du mois UTC."
PERMISSIONS FULL;
