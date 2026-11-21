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
    LET $paths = array::distinct($issues.path);
    LET $entries = array::map($paths, |$path| [IF $path = "" { "$" } ELSE { $path }, $issues[WHERE path = $path].code]);
    RETURN object::from_entries($entries);
}
COMMENT "Regroupe les codes d'erreurs par chemin { <chemin>: [codes] } ; la racine (chemin vide) est notée « $ »."
PERMISSIONS FULL;
