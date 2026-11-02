-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/number_between.surql
-- Fonction : fn::utils_number_between
--
-- Indique si un nombre appartient à un intervalle.
--
-- Paramètres
--   $value     : number
--   $minimum   : number
--   $maximum   : number
--   $inclusive : bool
--
-- Valeur renvoyée : bool (contrat : crates/lyxal_core/Readme.md, fonctions utils)
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $minimum > $maximum
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_number_between(
    $value: number,
    $minimum: number,
    $maximum: number,
    $inclusive: bool
) -> bool {
    IF $minimum > $maximum {
        THROW "CORE_INVALID_ARGUMENT";
    };

    RETURN IF $inclusive {
        $value >= $minimum AND $value <= $maximum
    } ELSE {
        $value > $minimum AND $value < $maximum
    };
}
COMMENT "Indique si un nombre appartient à un intervalle."
PERMISSIONS FULL;
