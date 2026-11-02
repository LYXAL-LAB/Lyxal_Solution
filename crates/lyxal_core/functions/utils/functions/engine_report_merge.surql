-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/engine_report_merge.surql
-- Fonction : fn::utils_engine_report_merge
--
-- Fusionne plusieurs rapports : valide si aucun rapport n'a d'erreur ;
-- valeurs, erreurs et avertissements concaténés ; by_field recalculé.
--
-- Paramètres
--   $reports : array<object>
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions utils)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_engine_report_merge(
    $reports: array<object>
) -> object {
    LET $errors = array::flatten(array::map($reports, |$report| $report.errors));
    RETURN {
        valid: array::len($errors) = 0,
        values: array::map($reports, |$report| $report.value),
        errors: $errors,
        warnings: array::flatten(array::map($reports, |$report| $report.warnings)),
        by_field: fn::utils_engine_by_field($errors)
    };
}
COMMENT "Fusionne plusieurs rapports : valide si aucun rapport n'a d'erreur ; valeurs, erreurs et avertissements concaténés ; by_field recalculé."
PERMISSIONS FULL;
