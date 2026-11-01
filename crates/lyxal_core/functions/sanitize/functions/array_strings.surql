-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/array_strings.surql
-- Fonction : fn::sanitize_array_strings
--
-- Ne garde que les chaînes d'un tableau, nettoyées et mises en minuscules si
-- demandé.
--
-- Paramètres
--   $value     : any — valeur à nettoyer (tableau, ou NONE)
--   $trim      : bool — retirer les espaces périphériques
--   $lowercase : bool — mettre en minuscules
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : le tableau des chaînes
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Exemple
--   LET $roles = fn::sanitize_array_strings($params.roles, true, true);
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_array_strings(
    $value: any,
    $trim: bool,
    $lowercase: bool
) -> option<array> {
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_array($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    LET $strings = array::filter($value, |$item| type::is_string($item));
    LET $trimmed = IF $trim { array::map($strings, |$item| string::trim($item)) } ELSE { $strings };
    RETURN IF $lowercase { array::map($trimmed, |$item| string::lowercase($item)) } ELSE { $trimmed };
}
COMMENT "Ne garde que les chaînes d'un tableau, nettoyées et mises en minuscules si demandé. NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
