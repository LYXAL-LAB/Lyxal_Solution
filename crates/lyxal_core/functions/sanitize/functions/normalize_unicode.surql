-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/normalize_unicode.surql
-- Fonction : fn::sanitize_normalize_unicode
--
-- Normalise les espaces Unicode : espaces insécables et typographiques →
-- espace simple, caractères invisibles (U+200B…, BOM) supprimés, séparateurs
-- de ligne Unicode → \n ; regroupe les espaces si demandé.
--
-- Paramètres
--   $value               : any — valeur à nettoyer (chaîne, ou NONE)
--   $collapse_whitespace : bool — true pour regrouper les espaces et retirer les espaces périphériques
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : la chaîne normalisée
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Exemple
--   LET $text = fn::sanitize_normalize_unicode($params.text, true);
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_normalize_unicode(
    $value: any,
    $collapse_whitespace: bool
) -> option<string> {
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_string($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    LET $spaces = string::replace($value, <regex>"[\u00A0\u1680\u2000-\u200A\u202F\u205F\u3000]", " ");
    LET $visible = string::replace($spaces, <regex>"[\u200B\u200C\u200D\u2060\uFEFF]", "");
    LET $lines = string::replace($visible, <regex>"[\u2028\u2029]", "\n");
    RETURN IF $collapse_whitespace { string::trim(string::replace($lines, <regex>"\\s+", " ")) } ELSE { $lines };
}
COMMENT "Normalise les espaces Unicode : espaces insécables et typographiques → espace simple, caractères invisibles (U+200B…, BOM) supprimés, séparateurs de ligne Unicode → \\n. NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
