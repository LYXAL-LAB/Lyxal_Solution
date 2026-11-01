-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/array_unique.surql
-- Fonction : fn::sanitize_array_unique
--
-- Retire les doublons d'un tableau (égalité SurrealQL), en gardant la
-- première occurrence.
--
-- Paramètres
--   $value : any — valeur à nettoyer (tableau, ou NONE)
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : le tableau sans doublon
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Exemple
--   LET $clean = fn::sanitize_array_unique($params.array_unique);
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_array_unique(
    $value: any
) -> option<array> {
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_array($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    RETURN array::distinct($value);
}
COMMENT "Retire les doublons d'un tableau (égalité SurrealQL), en gardant la première occurrence. NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
