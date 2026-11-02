-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/date_range.surql
-- Fonction : fn::utils_date_range
--
-- Génère une plage de dates à intervalle fixe.
--
-- Paramètres
--   $start         : datetime
--   $end           : datetime
--   $step          : duration
--   $inclusive_end : bool
--
-- Valeur renvoyée : array<datetime> (contrat : crates/lyxal_core/Readme.md, fonctions utils)
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $step <= 0s
--   CORE_INVALID_ARGUMENT : $end < $start
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_date_range(
    $start: datetime,
    $end: datetime,
    $step: duration,
    $inclusive_end: bool
) -> array<datetime> {
    IF $step <= 0s {
        THROW "CORE_INVALID_ARGUMENT";
    };

    IF $end < $start {
        THROW "CORE_INVALID_ARGUMENT";
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
