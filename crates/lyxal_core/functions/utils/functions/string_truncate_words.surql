-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_string_truncate_words
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_string_truncate_words(
    $value: string,
    $max_words: int,
    $suffix: string
) -> string {
    IF $max_words < 0 {
        THROW "UTILS_INVALID_MAX_WORDS";
    };

    LET $words = array::filter(
        string::split(
            string::replace(
                string::trim($value),
                <regex>"\\s+",
                " "
            ),
            " "
        ),
        |$word| $word != ""
    );

    RETURN IF array::len($words) <= $max_words {
        array::join($words," ")
    } ELSE {
        string::concat(
            array::join(
                array::slice($words,0,$max_words),
                " "
            ),
            $suffix
        )
    };
}
COMMENT "Tronque une chaîne à un nombre maximal de mots."
PERMISSIONS FULL;
