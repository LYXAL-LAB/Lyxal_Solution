-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/date_end_of_day.surql
-- Fonction : fn::utils_date_end_of_day
--
-- Retourne la fin de journée UTC.
--
-- Paramètres
--   $value : datetime
--
-- Valeur renvoyée : datetime (contrat : crates/lyxal_core/Readme.md, fonctions utils)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_date_end_of_day(
    $value: datetime
) -> datetime {
    RETURN time::floor($value,1d)+1d-1ns;
}
COMMENT "Retourne la fin de journée UTC."
PERMISSIONS FULL;
