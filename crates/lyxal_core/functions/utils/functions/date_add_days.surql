-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/date_add_days.surql
-- Fonction : fn::utils_date_add_days
--
-- Ajoute un nombre entier de jours à une date.
--
-- Paramètres
--   $value : datetime
--   $days  : int
--
-- Valeur renvoyée : datetime (contrat : crates/lyxal_core/Readme.md, fonctions utils)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_date_add_days(
    $value: datetime,
    $days: int
) -> datetime {
    RETURN IF $days < 0 { $value - duration::from_days(-$days) } ELSE { $value + duration::from_days($days) };
}
COMMENT "Ajoute un nombre entier de jours à une date."
PERMISSIONS FULL;
