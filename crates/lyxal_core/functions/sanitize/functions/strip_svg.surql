-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/strip_svg.surql
-- Fonction : fn::sanitize_strip_svg
--
-- Supprime les éléments <svg>…</svg> (contenu compris, insensible à la
-- casse). Nettoyage lexical par expressions régulières : il ne remplace pas
-- un parseur HTML anti-XSS.
--
-- Paramètres
--   $value : any — valeur à nettoyer (chaîne, ou NONE)
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : le texte sans élément svg
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Exemple
--   LET $clean = fn::sanitize_strip_svg($params.strip_svg);
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_strip_svg(
    $value: any
) -> option<string> {
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_string($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    RETURN string::replace($value, <regex>"(?is)<svg\\b[^>]*>.*?</svg\\s*>", "");
}
COMMENT "Supprime les éléments <svg>…</svg> (contenu compris, insensible à la casse). Nettoyage lexical par expressions régulières : il ne remplace pas un parseur HTML anti-XSS. NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
