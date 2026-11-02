-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/string_truncate_words.surql
-- Fonction : fn::utils_string_truncate_words
--
-- Tronque une chaîne à un nombre maximal de mots.
--
-- Paramètres
--   $value     : string
--   $max_words : int
--   $suffix    : string
--
-- Valeur renvoyée : string (contrat : crates/lyxal_core/Readme.md, fonctions utils)
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $max_words < 0
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_string_truncate_words(
    $value: string,
    $max_words: int,
    $suffix: string
) -> string {
    IF $max_words < 0 {
        THROW "CORE_INVALID_ARGUMENT";
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
