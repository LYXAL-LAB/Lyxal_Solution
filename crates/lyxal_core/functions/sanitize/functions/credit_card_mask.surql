-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/credit_card_mask.surql
-- Fonction : fn::sanitize_credit_card_mask
--
-- Masque un numéro de carte : chiffres seuls, tous remplacés par « * » sauf
-- les N derniers.
--
-- Paramètres
--   $value          : any — valeur à nettoyer (chaîne, ou NONE)
--   $visible_digits : int — nombre de derniers chiffres laissés visibles (>= 0)
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : le numéro masqué (ex. « ************1111 »)
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $visible_digits < 0
--
-- Exemple
--   LET $masked = fn::sanitize_credit_card_mask($params.pan, 4);
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_credit_card_mask(
    $value: any,
    $visible_digits: int
) -> option<string> {
    IF $visible_digits < 0 { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_string($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    LET $digits = string::replace($value, <regex>"[^0-9]", "");
    LET $hidden = math::max([string::len($digits) - $visible_digits, 0]);
    RETURN string::repeat("*", $hidden) + string::slice($digits, $hidden);
}
COMMENT "Masque un numéro de carte : chiffres seuls, tous remplacés par « * » sauf les N derniers. NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
