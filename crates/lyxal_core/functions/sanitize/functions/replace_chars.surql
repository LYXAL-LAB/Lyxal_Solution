-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/replace_chars.surql
-- Fonction : fn::sanitize_replace_chars
--
-- Retire une liste de caractères d'une chaîne, puis remplace des caractères
-- par une chaîne. Les suppressions sont appliquées d'abord, puis les
-- remplacements dans l'ordre de la liste (un remplacement voit le résultat
-- des précédents). Les caractères sont comparés tels quels : aucune
-- expression régulière, casse respectée.
--
-- Paramètres
--   $value   : any — valeur à nettoyer (chaîne, ou NONE)
--   $remove  : any — caractères à retirer : tableau de chaînes d'un seul caractère ([] ou NONE : aucun)
--   $replace : any — remplacements : tableau d'objets { from, to }, from d'un seul caractère, to chaîne de 8 caractères au plus ([] ou NONE : aucun)
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : la chaîne sans les caractères retirés, caractères remplacés
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $remove et $replace tous deux vides ; $remove ou $replace qui n'est pas un tableau ; caractère qui n'est pas une chaîne d'un seul caractère ; remplacement qui n'est pas un objet { from, to } ; to de plus de 8 caractères
--
-- Exemple
--   LET $key = fn::sanitize_replace_chars($unit, [".", "-", "_"], [{ from: "²", to: "2" }]);
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_replace_chars(
    $value: any,
    $remove: any,
    $replace: any
) -> option<string> {
    LET $chars = $remove ?? [];
    LET $pairs = $replace ?? [];
    IF !type::is_array($chars) OR !type::is_array($pairs) { THROW "CORE_INVALID_ARGUMENT"; };
    IF array::len($chars) = 0 AND array::len($pairs) = 0 { THROW "CORE_INVALID_ARGUMENT"; };
    IF !array::all($chars, |$char| type::is_string($char) AND string::len($char) = 1) { THROW "CORE_INVALID_ARGUMENT"; };
    IF !array::all($pairs, |$pair| type::is_object($pair)
        AND array::sort::asc(object::keys($pair)) == ["from", "to"]
        AND type::is_string($pair.from) AND string::len($pair.from) = 1
        AND type::is_string($pair.to) AND string::len($pair.to) <= 8) { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_string($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    LET $removed = array::fold($chars, $value, |$text, $char| string::replace($text, $char, ""));
    RETURN array::fold($pairs, $removed, |$text, $pair| string::replace($text, $pair.from, $pair.to));
}
COMMENT "Retire une liste de caractères d'une chaîne, puis remplace des caractères par une chaîne (suppressions d'abord, remplacements dans l'ordre). NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE ; listes vides ou mal formées → CORE_INVALID_ARGUMENT."
PERMISSIONS FULL;
