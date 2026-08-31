-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_collection_window
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_collection_window(
    $value: array<any>,
    $size: int,
    $step: int
) -> array<array<any>> {
    IF $size < 1 OR $step < 1 {
        THROW "UTILS_INVALID_WINDOW";
    };

    IF array::len($value) < $size {
        RETURN [];
    };

    LET $count = math::floor(
        (
            array::len($value)-$size
        ) / $step
    ) + 1;

    RETURN array::map(
        array::range(0,type::int($count)),
        |$index| array::slice(
            $value,
            $index*$step,
            ($index*$step)+$size
        )
    );
}
COMMENT "Produit des fenêtres glissantes sur une collection."
PERMISSIONS FULL;
