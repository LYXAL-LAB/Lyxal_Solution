-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_string_repeat
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_string_repeat(
    $value: string,
    $count: int,
    $separator: string
) -> string {
    IF $count < 0 {
        THROW "UTILS_INVALID_REPEAT_COUNT";
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
