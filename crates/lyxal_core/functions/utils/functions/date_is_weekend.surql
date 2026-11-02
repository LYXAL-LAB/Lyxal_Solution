-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/date_is_weekend.surql
-- Fonction : fn::utils_date_is_weekend
--
-- Indique si une date tombe un samedi ou un dimanche.
--
-- Paramètres
--   $value : datetime
--
-- Valeur renvoyée : bool (contrat : crates/lyxal_core/Readme.md, fonctions utils)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_date_is_weekend(
    $value: datetime
) -> bool {
    LET $weekday = time::wday($value);

    RETURN $weekday = 6 OR $weekday = 7;
}
COMMENT "Indique si une date tombe un samedi ou un dimanche."
PERMISSIONS FULL;
