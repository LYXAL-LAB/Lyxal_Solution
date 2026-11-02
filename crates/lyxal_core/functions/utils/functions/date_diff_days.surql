-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/date_diff_days.surql
-- Fonction : fn::utils_date_diff_days
--
-- Calcule l'écart entre deux dates en jours décimaux.
--
-- Paramètres
--   $start : datetime
--   $end   : datetime
--
-- Valeur renvoyée : decimal (contrat : crates/lyxal_core/Readme.md, fonctions utils)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_date_diff_days(
    $start: datetime,
    $end: datetime
) -> decimal {
    RETURN type::decimal(
        duration::secs($end-$start)
    ) / 86400dec;
}
COMMENT "Calcule l'écart entre deux dates en jours décimaux."
PERMISSIONS FULL;
