-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/to_csv.surql
-- Fonction : fn::utils_to_csv
--
-- Produit un texte CSV (RFC 4180) à partir d'objets et d'une liste de
-- colonnes : un champ contenant le séparateur, un guillemet ou un retour à
-- la ligne est entouré de guillemets (guillemets internes doublés) ; une
-- valeur absente ou NULL donne un champ vide.
--
-- Paramètres
--   $rows           : array<object>
--   $columns        : array<string>
--   $delimiter      : string
--   $include_header : bool
--
-- Valeur renvoyée : string (contrat : crates/lyxal_core/Readme.md, fonctions utils)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_to_csv(
    $rows: array<object>,
    $columns: array<string>,
    $delimiter: string,
    $include_header: bool
) -> string {
    LET $sep = IF $delimiter = "" { "," } ELSE { $delimiter };
    LET $quote = |$cell: string| IF string::contains($cell, $sep) OR string::contains($cell, "\"") OR string::contains($cell, "\n") OR string::contains($cell, "\r") {
        "\"" + string::replace($cell, "\"", "\"\"") + "\""
    } ELSE { $cell };
    LET $lines = array::map($rows, |$row| array::join(array::map($columns, |$column| $quote(IF $row[$column] IS NONE OR type::is_null($row[$column]) { "" } ELSE { <string> $row[$column] })), $sep));
    RETURN array::join(IF $include_header { array::concat([array::join(array::map($columns, |$column| $quote($column)), $sep)], $lines) } ELSE { $lines }, "\n");
}
COMMENT "Produit un texte CSV (RFC 4180) à partir d'objets et d'une liste de colonnes : un champ contenant le séparateur, un guillemet ou un retour à la ligne est entouré de guillemets (guillemets internes doublés) ; une valeur absente ou NULL donne un champ vide."
PERMISSIONS FULL;
