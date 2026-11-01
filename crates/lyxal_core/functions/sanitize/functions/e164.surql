-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/e164.surql
-- Fonction : fn::sanitize_e164
--
-- Normalise un numéro au format E.164 : un numéro national (sans « + ») perd
-- ses zéros initiaux et reçoit l'indicatif par défaut, s'il est fourni.
--
-- Paramètres
--   $value                : any — valeur à nettoyer (chaîne, ou NONE)
--   $default_country_code : option<string> — indicatif par défaut (ex. "33" ou "+33"), NONE pour aucun
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : le numéro « +<indicatif><numéro> » (ou les chiffres seuls si aucun indicatif n'est connu)
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Exemple
--   LET $phone = fn::sanitize_e164($params.phone, "33");
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_e164(
    $value: any,
    $default_country_code: option<string>
) -> option<string> {
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_string($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    LET $phone = fn::sanitize_phone($value);
    IF string::starts_with($phone, "+") { RETURN $phone; };
    LET $code = IF $default_country_code IS NONE { "" } ELSE { string::replace($default_country_code, <regex>"[^0-9]", "") };
    LET $national = string::replace($phone, <regex>"^0+", "");
    RETURN IF $code = "" { $national } ELSE { "+" + $code + $national };
}
COMMENT "Normalise un numéro au format E.164 : un numéro national (sans « + ») perd ses zéros initiaux et reçoit l'indicatif par défaut, s'il est fourni. NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
