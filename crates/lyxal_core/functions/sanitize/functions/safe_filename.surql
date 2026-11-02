-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/safe_filename.surql
-- Fonction : fn::sanitize_safe_filename
--
-- Rend un nom de fichier sûr : caractères interdits (< > : " / \ | ? * et
-- contrôles) remplacés, points et espaces finaux retirés.
--
-- Paramètres
--   $value       : any — valeur à nettoyer (chaîne, ou NONE)
--   $replacement : string — remplacement des caractères interdits ("" vaut "_")
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : le nom de fichier sûr
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $replacement contenant lui-même un caractère interdit
--
-- Exemple
--   LET $name = fn::sanitize_safe_filename($params.file_name, "_");
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_safe_filename(
    $value: any,
    $replacement: string
) -> option<string> {
    IF string::matches($replacement, "[<>:\"/\\\\|?*\\x00-\\x1F]") { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_string($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    LET $replacing = IF $replacement = "" { "_" } ELSE { $replacement };
    RETURN string::replace(string::replace(string::trim($value), <regex>"[<>:\"/\\\\|?*\\x00-\\x1F]", $replacing), <regex>"[. ]+$", "");
}
COMMENT "Rend un nom de fichier sûr : caractères interdits (< > : \" / \\ | ? * et contrôles) remplacés, points et espaces finaux retirés. NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
