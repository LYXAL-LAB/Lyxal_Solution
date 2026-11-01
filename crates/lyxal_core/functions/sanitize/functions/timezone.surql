-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/timezone.surql
-- Fonction : fn::sanitize_timezone
--
-- Normalise une désignation de fuseau UTC : « Z » et « UTC » (seuls,
-- insensibles à la casse) deviennent « +00:00 » ; toute autre valeur est
-- seulement nettoyée de ses espaces périphériques.
--
-- Paramètres
--   $value : any — valeur à nettoyer (chaîne, ou NONE)
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : « +00:00 » ou la valeur sans espaces périphériques
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Exemple
--   LET $clean = fn::sanitize_timezone($params.timezone);
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_timezone(
    $value: any
) -> option<string> {
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_string($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    LET $clean = string::trim($value);
    RETURN IF string::uppercase($clean) IN ["Z", "UTC"] { "+00:00" } ELSE { $clean };
}
COMMENT "Normalise une désignation de fuseau UTC : « Z » et « UTC » (seuls, insensibles à la casse) deviennent « +00:00 ». NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
