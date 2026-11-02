-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/engine_report.surql
-- Fonction : fn::utils_engine_report
--
-- Rapport d'exécution { valid, value, errors, warnings, by_field } à partir
-- d'un état ; by_field regroupe les codes d'erreur par chemin (« $ » pour la
-- racine).
--
-- Paramètres
--   $state : object
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions utils)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_engine_report(
    $state: object
) -> object {
    RETURN {
        valid: array::len($state.issues) = 0,
        value: $state.value,
        errors: $state.issues,
        warnings: $state.warnings,
        by_field: fn::utils_engine_by_field($state.issues)
    };
}
COMMENT "Rapport d'exécution { valid, value, errors, warnings, by_field } à partir d'un état ; by_field regroupe les codes d'erreur par chemin (« $ » pour la racine)."
PERMISSIONS FULL;
