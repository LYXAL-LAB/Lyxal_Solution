-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/from_csv.surql
-- Fonction : fn::utils_from_csv
--
-- Décode un CSV simple sans gestion avancée des guillemets.
--
-- Paramètres
--   $value      : string
--   $delimiter  : string
--   $has_header : bool
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions utils)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_from_csv(
    $value: string,
    $delimiter: string,
    $has_header: bool
) -> object {
    LET $sep = IF $delimiter = "" { "," } ELSE { $delimiter };
    LET $lines = array::filter(
        array::map(string::split($value, "\n"), |$line| string::replace($line, <regex>"\r$", "")),
        |$line| string::trim($line) != ""
    );

    IF array::len($lines)=0 {
        RETURN {headers:[],rows:[]};
    };

    LET $headers = IF $has_header {
        string::split($lines[0],$sep)
    } ELSE {
        array::map(
            array::range(0,array::len(string::split($lines[0],$sep))),
            |$index| string::concat("column_",<string>$index)
        )
    };

    LET $data_lines = IF $has_header {
        array::slice($lines,1,array::len($lines))
    } ELSE {
        $lines
    };

    LET $rows = array::map(
        $data_lines,
        |$line| {
            LET $values = string::split($line,$sep);
            object::from_entries(
                array::map(
                    $headers,
                    |$header,$index|[
                        $header,
                        $values[$index]
                    ]
                )
            )
        }
    );

    RETURN {
        headers:$headers,
        rows:$rows
    };
}
COMMENT "Décode un CSV simple sans gestion avancée des guillemets."
PERMISSIONS FULL;
