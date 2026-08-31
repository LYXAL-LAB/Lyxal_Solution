-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_to_csv
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_to_csv(
    $rows: array<object>,
    $columns: array<string>,
    $delimiter: string,
    $include_header: bool
) -> string {
    LET $sep = IF $delimiter = "" { "," } ELSE { $delimiter };

    LET $header = IF $include_header {
        array::join($columns,$sep)
    } ELSE {
        ""
    };

    LET $lines = array::map(
        $rows,
        |$row| array::join(
            array::map(
                $columns,
                |$column| string::replace(
                    <string>$row[$column],
                    "\"",
                    "\"\""
                )
            ),
            $sep
        )
    );

    RETURN array::join(
        IF $include_header {
            array::concat([$header],$lines)
        } ELSE {
            $lines
        },
        "\n"
    );
}
COMMENT "Encode un tableau d'objets en CSV simple."
PERMISSIONS FULL;
