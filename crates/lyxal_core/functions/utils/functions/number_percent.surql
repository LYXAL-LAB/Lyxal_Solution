-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/number_percent.surql
-- Fonction : fn::utils_number_percent
--
-- Calcule un pourcentage à partir d'une valeur et d'un total.
--
-- Paramètres
--   $value     : number
--   $total     : number
--   $precision : int
--
-- Valeur renvoyée : number (contrat : crates/lyxal_core/Readme.md, fonctions utils)
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $total = 0
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_number_percent(
    $value: number,
    $total: number,
    $precision: int
) -> number {
    IF $total = 0 {
        THROW "CORE_INVALID_ARGUMENT";
    };

    RETURN fn::sanitize_round(
        (type::float($value)/$total)*100,
        $precision
    );
}
COMMENT "Calcule un pourcentage à partir d'une valeur et d'un total."
PERMISSIONS FULL;
