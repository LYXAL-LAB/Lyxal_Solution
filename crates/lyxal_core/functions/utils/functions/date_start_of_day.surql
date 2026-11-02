-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/date_start_of_day.surql
-- Fonction : fn::utils_date_start_of_day
--
-- Retourne le début de journée UTC.
--
-- Paramètres
--   $value : datetime
--
-- Valeur renvoyée : datetime (contrat : crates/lyxal_core/Readme.md, fonctions utils)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_date_start_of_day(
    $value: datetime
) -> datetime {
    RETURN time::floor($value,1d);
}
COMMENT "Retourne le début de journée UTC."
PERMISSIONS FULL;
