-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/markdown_images.surql
-- Fonction : fn::sanitize_markdown_images
--
-- Remplace chaque image Markdown ![texte](url) par son texte alternatif.
--
-- Paramètres
--   $value : any — valeur à nettoyer (chaîne, ou NONE)
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : le texte sans image
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Exemple
--   LET $clean = fn::sanitize_markdown_images($params.markdown_images);
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_markdown_images(
    $value: any
) -> option<string> {
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_string($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    LET $parts = string::split($value, "![");
    RETURN array::fold(array::slice($parts, 1), $parts[0], |$text, $part| {
        IF string::matches($part, "^[^\\]]*\\]\\([^\\)]+\\)") {
            LET $rest = array::join(array::slice(string::split($part, "]("), 1), "](");
            $text + string::split($part, "](")[0] + array::join(array::slice(string::split($rest, ")"), 1), ")")
        } ELSE {
            $text + "![" + $part
        }
    });
}
COMMENT "Remplace chaque image Markdown ![texte](url) par son texte alternatif. NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
