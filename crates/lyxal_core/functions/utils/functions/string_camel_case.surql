-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_string_camel_case
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_string_camel_case(
    $value: string
) -> string {
    LET $words = array::filter(
        string::split(
            string::replace(
                string::trim($value),
                <regex>"[^A-Za-z0-9]+",
                " "
            ),
            " "
        ),
        |$word| $word != ""
    );

    RETURN array::join(
        array::map(
            $words,
            |$word,$index| IF $index = 0 {
                string::lowercase($word)
            } ELSE {
                string::capitalize(
                    string::lowercase($word)
                )
            }
        ),
        ""
    );
}
COMMENT "Transforme une chaîne en camelCase."
PERMISSIONS FULL;
