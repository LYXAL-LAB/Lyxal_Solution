-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/collection_sort_by.surql
-- Fonction : fn::utils_collection_sort_by
--
-- Trie une collection d'objets selon une clé, en ordre croissant (asc) ou
-- décroissant (desc), en temps n log n (tri natif). Tri stable : les éléments
-- de même clé gardent leur ordre. Éléments sans clé (NONE ou NULL) en fin,
-- dans leur ordre d'origine.
--
-- Paramètres
--   $value     : array<object>
--   $key       : string
--   $direction : string
--
-- Valeur renvoyée : array<object> (contrat : crates/lyxal_core/Readme.md, fonctions utils)
--
-- Erreurs de programmation (THROW)
--   CORE_UNSUPPORTED_OPTION : sens de tri autre que « asc » ou « desc »
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_collection_sort_by(
    $value: array<object>,
    $key: string,
    $direction: string
) -> array<object> {
    LET $clean_direction = string::lowercase(string::trim($direction));
    IF $clean_direction NOT IN ["asc", "desc"] { THROW "CORE_UNSUPPORTED_OPTION"; };
    -- Tri natif (n log n) de triplets [clé, rang, élément] : le rang départage les clés égales dans
    -- l'ordre d'origine (rang opposé en ordre décroissant), l'élément n'est jamais comparé
    LET $sign = IF $clean_direction = "asc" { 1 } ELSE { -1 };
    LET $decorated = array::map($value, |$item, $index| [$item[$key], $sign * $index, $item]);
    LET $keyed = $decorated[WHERE $this[0] IS NOT NONE AND !type::is_null($this[0])];
    LET $sorted = IF $clean_direction = "asc" { array::sort::asc($keyed) } ELSE { array::sort::desc($keyed) };
    -- Éléments sans clé (NONE ou NULL) en fin, dans l'ordre d'origine
    LET $missing = $decorated[WHERE $this[0] IS NONE OR type::is_null($this[0])];
    RETURN array::map(array::concat($sorted, $missing), |$entry| $entry[2]);
}
COMMENT "Trie une collection d'objets selon une clé, en ordre croissant (asc) ou décroissant (desc) ; tri stable (les éléments de même clé gardent leur ordre) ; éléments sans clé (NONE ou NULL) en fin, dans leur ordre d'origine."
PERMISSIONS FULL;
