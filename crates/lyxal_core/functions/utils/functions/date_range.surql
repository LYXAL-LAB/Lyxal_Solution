-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_date_range
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_date_range(
    $start: datetime,
    $end: datetime,
    $step: duration,
    $inclusive_end: bool
) -> array<datetime> {
    IF $step <= 0s {
        THROW "UTILS_INVALID_DATE_RANGE_STEP";
    };

    IF $end < $start {
        THROW "UTILS_INVALID_DATE_RANGE";
    };

    LET $count = math::floor(
        type::float(duration::nanos($end-$start))
        / type::float(duration::nanos($step))
    );

    LET $values = array::map(
        array::range(
            0,
            type::int($count)+1
        ),
        |$index| $start + ($step*$index)
    );

    RETURN IF $inclusive_end
        AND (
            array::len($values)=0
            OR $values[array::len($values)-1] != $end
        )
    {
        array::append($values,$end)
    } ELSE {
        array::filter(
            $values,
            |$value|$inclusive_end OR $value<$end
        )
    };
}
COMMENT "Génère une plage de dates à intervalle fixe."
PERMISSIONS FULL;
