-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/string_repeat.surql
-- Fonction : fn::utils_string_repeat
--
-- Répète une chaîne avec un séparateur facultatif.
--
-- Paramètres
--   $value     : string
--   $count     : int
--   $separator : string
--
-- Valeur renvoyée : string (contrat : crates/lyxal_core/Readme.md, fonctions utils)
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $count < 0
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_string_repeat(
    $value: string,
    $count: int,
    $separator: string
) -> string {
    IF $count < 0 {
        THROW "CORE_INVALID_ARGUMENT";
    };

    RETURN array::join(
        array::map(
            array::range(0,$count),
            |$index| $value
        ),
        $separator
    );
}
COMMENT "Répète une chaîne avec un séparateur facultatif."
PERMISSIONS FULL;
