-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_array_sample
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_array_sample(
    $value: array<any>,
    $count: int
) -> array<any> {
    IF $count < 0 {
        THROW "UTILS_INVALID_SAMPLE_COUNT";
    };

    RETURN array::slice(
        array::shuffle($value),
        0,
        IF $count > array::len($value) {
            array::len($value)
        } ELSE {
            $count
        }
    );
}
COMMENT "Retourne un échantillon aléatoire sans remise."
PERMISSIONS FULL;
