-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/safe_identifier.surql
-- Fonction : fn::sanitize_safe_identifier
--
-- Transforme une chaîne en identifiant technique : minuscules, caractères
-- hors [a-z0-9_] remplacés par « _ », « _ » regroupés et retirés aux
-- extrémités, « _ » ajouté devant un chiffre initial.
--
-- Paramètres
--   $value : any — valeur à nettoyer (chaîne, ou NONE)
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : l'identifiant
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Exemple
--   LET $clean = fn::sanitize_safe_identifier($params.safe_identifier);
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_safe_identifier(
    $value: any
) -> option<string> {
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_string($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    LET $raw = string::replace(string::lowercase(string::trim($value)), <regex>"[^a-z0-9_]+", "_");
    LET $clean = string::replace(string::replace($raw, <regex>"_+", "_"), <regex>"^_|_$", "");
    RETURN IF string::matches($clean, "^[0-9]") { "_" + $clean } ELSE { $clean };
}
COMMENT "Transforme une chaîne en identifiant technique : minuscules, caractères hors [a-z0-9_] remplacés par « _ », « _ » regroupés et retirés aux extrémités, « _ » ajouté devant un chiffre initial. NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
