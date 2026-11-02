-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/engine_by_field.surql
-- Fonction : fn::utils_engine_by_field
--
-- Regroupe les codes d'erreurs par chemin { <chemin>: [codes] } ; la racine
-- (chemin vide) est notée « $ ».
--
-- Paramètres
--   $issues : array<object>
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions utils)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_engine_by_field(
    $issues: array<object>
) -> object {
    RETURN object::from_entries(array::map(array::distinct(array::map($issues, |$issue| $issue.path)), |$path| [
        IF $path = "" { "$" } ELSE { $path },
        array::map(array::filter($issues, |$issue| $issue.path = $path), |$issue| $issue.code)
    ]));
}
COMMENT "Regroupe les codes d'erreurs par chemin { <chemin>: [codes] } ; la racine (chemin vide) est notée « $ »."
PERMISSIONS FULL;
