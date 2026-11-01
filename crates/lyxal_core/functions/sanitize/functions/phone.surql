-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/phone.surql
-- Fonction : fn::sanitize_phone
--
-- Normalise une saisie de téléphone : chiffres seuls, « + » initial
-- conservé.
--
-- Paramètres
--   $value : any — valeur à nettoyer (chaîne, ou NONE)
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : « +33612345678 » ou « 0612345678 »
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Exemple
--   LET $clean = fn::sanitize_phone($params.phone);
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_phone(
    $value: any
) -> option<string> {
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_string($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    LET $clean = string::trim($value);
    LET $digits = string::replace($clean, <regex>"[^0-9]", "");
    RETURN IF string::starts_with($clean, "+") { "+" + $digits } ELSE { $digits };
}
COMMENT "Normalise une saisie de téléphone : chiffres seuls, « + » initial conservé. NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
